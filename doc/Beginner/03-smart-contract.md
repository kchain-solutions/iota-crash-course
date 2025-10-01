# Smart Contract Structure in IOTA Move

This guide explains the fundamental concepts and structure needed to write smart contracts in IOTA's Move Virtual Machine, from project setup to advanced patterns.

## 🗂️ Project Structure

A Move smart contract project follows a standard directory layout:

```
my-project/
├── Move.toml              # Package configuration and metadata
├── sources/               # Source code directory
│   ├── main.move         # Primary module
│   ├── utils.move        # Utility functions
│   └── types.move        # Custom data structures
├── tests/                # Unit tests (optional)
└── build/                # Compiled bytecode (generated)
```

### Move.toml Configuration

The `Move.toml` file is the heart of your project configuration:

```toml
[package]
name = "my_contract"           # Package name (use underscores)
license = "Apache-2.0"         # License identifier
version = "0.1.0"              # Semantic versioning
edition = "2024.beta"          # Move language edition

[dependencies]
# IOTA framework is automatically included
# Add custom dependencies here if needed

[addresses]
my_contract = "0x0"            # Resolved during deployment

[dev-addresses]
# Addresses used during development/testing
```

**Key Configuration Fields**:
- **`name`**: Must match your module declarations
- **`edition`**: Determines Move language features available
- **`addresses`**: Maps package names to blockchain addresses
- **`dependencies`**: External packages your contract uses

## 📦 Module System

### Module Declaration

Every Move file must start with a module declaration:

```move
module my_contract::core {
    // Module contents go here
}
```

**Module Naming Convention**:
- **Package name**: `my_contract` (matches Move.toml)
- **Module name**: `core` (describes module purpose)
- **Separator**: `::` (namespace separator)

### Import System

```move
module my_contract::main {
    // Standard library imports
    use std::string::{Self, String};
    use std::vector;
    
    // IOTA framework imports
    use iota::object::{Self, UID, ID};
    use iota::transfer;
    use iota::tx_context::{Self, TxContext};
    use iota::coin::{Self, Coin};
    use iota::iota::IOTA;
    
    // Local module imports
    use my_contract::utils::validate_input;
    
    // External package imports
    // use external_package::module_name::function_name;
}
```

**Import Patterns**:
- **`Self`**: Import the module itself for qualified calls
- **Selective imports**: Import specific types/functions
- **Aliasing**: Use `as` to rename imports if conflicts occur

## 🏗️ Data Structures and Abilities

### Resource Structs (On-chain Objects)

```move
public struct MyAsset has key, store {
    id: UID,                    // Required for all objects
    value: u64,
    owner_info: String,
    metadata: vector<u8>
}

public struct Configuration has key {
    id: UID,
    admin: address,
    settings: Table<String, u64>
}
```

### Abilities System

Move's ability system controls what operations are allowed on types:

| Ability | Description | Use Case |
|---------|-------------|----------|
| **`key`** | Can be stored as top-level object | On-chain objects with addresses |
| **`store`** | Can be stored inside other structs | Nested data structures |
| **`copy`** | Can be copied/duplicated | Simple data types |
| **`drop`** | Can be discarded/destroyed | Temporary values |

**Common Ability Combinations**:

```move
// On-chain asset (cannot be copied or dropped)
struct Token has key, store {
    id: UID,
    value: u64
}

// Copyable data (numbers, booleans)
struct Config has copy, drop, store {
    rate: u64,
    enabled: bool
}

// Event (emitted and discarded)
struct TransferEvent has copy, drop {
    from: address,
    to: address,
    amount: u64
}
```

**⚠️ Security Implications**:
- **Never give `copy` to assets** - would allow duplication
- **`drop` on assets** - could lead to accidental loss
- **`key + store`** - Standard for transferable objects

## 🔧 Function Types

### Entry Functions (Transaction Endpoints)

```move
public entry fun create_asset(
    value: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    let asset = MyAsset {
        id: object::new(ctx),
        value,
        owner_info: string::utf8(b"New Asset"),
        metadata: vector::empty()
    };
    
    transfer::transfer(asset, recipient);
}
```

**Entry Function Rules**:
- **`public entry`**: Callable from transactions
- **No return values**: Cannot return data to caller
- **Transaction boundaries**: Each call is atomic

### Public Functions (Module API)

```move
public fun get_value(asset: &MyAsset): u64 {
    asset.value
}

public fun update_metadata(
    asset: &mut MyAsset,
    new_data: vector<u8>
) {
    asset.metadata = new_data;
}
```

**Public Function Features**:
- **Can return values**: Enable complex interactions
- **Callable by other modules**: Building blocks for composition
- **Not directly callable**: Need entry function wrapper

### Package Functions (Internal API)

```move
public(package) fun mint_token(
    amount: u64,
    ctx: &mut TxContext
): Token {
    Token {
        id: object::new(ctx),
        value: amount
    }
}
```

**Package Function Benefits**:
- **Controlled access**: Only modules in same package can call
- **Internal APIs**: Share functionality between related modules
- **Security boundary**: Prevent external misuse

## 🔐 Object Creation Patterns

### Shared Objects (Global Access)

```move
public entry fun create_marketplace(ctx: &mut TxContext) {
    let marketplace = Marketplace {
        id: object::new(ctx),
        listings: table::new(ctx),
        fee_rate: 250  // 2.5%
    };
    
    transfer::share_object(marketplace);
}
```

**Shared Object Properties**:
- **Global accessibility**: Anyone can read/interact
- **Full consensus required**: Higher latency, more gas
- **Ideal for**: Marketplaces, DAOs, public registries

### Owned Objects (Private Access)

```move
public entry fun create_wallet(
    initial_amount: u64,
    owner: address,
    ctx: &mut TxContext
) {
    let wallet = Wallet {
        id: object::new(ctx),
        balance: initial_amount,
        transactions: vector::empty()
    };
    
    transfer::transfer(wallet, owner);
}
```

**Owned Object Properties**:
- **Single owner**: Only owner can modify
- **Partial consensus**: Lower latency, less gas
- **Ideal for**: Personal assets, private data

## 🛡️ Capability Pattern for Shared Objects

The capability pattern provides secure access control for shared objects:

```move
// Admin capability - proves authorization
public struct AdminCap has key, store {
    id: UID
}

// Shared configuration object
public struct GlobalConfig has key {
    id: UID,
    settings: Table<String, u64>
}

// One-time witness for initialization
public struct MY_CONTRACT has drop {}

// Initialize with capability creation
fun init(witness: MY_CONTRACT, ctx: &mut TxContext) {
    // Create admin capability
    let admin_cap = AdminCap {
        id: object::new(ctx)
    };
    
    // Create shared configuration
    let config = GlobalConfig {
        id: object::new(ctx),
        settings: table::new(ctx)
    };
    
    transfer::transfer(admin_cap, tx_context::sender(ctx));
    transfer::share_object(config);
}

// Admin-only function
public entry fun update_config(
    _: &AdminCap,                    // Proves caller has admin rights
    config: &mut GlobalConfig,
    key: String,
    value: u64
) {
    table::add(&mut config.settings, key, value);
}
```

**Capability Pattern Benefits**:
- **Granular permissions**: Different capabilities for different roles
- **Transferable authority**: Capabilities can be transferred or shared
- **Composable security**: Combine multiple capabilities for complex access control
- **No centralized registry**: Capabilities are self-contained proofs

### Advanced Capability Patterns

```move
// Time-limited capability
public struct TemporaryCap has key, store {
    id: UID,
    expires_at: u64
}

// Multi-signature capability
public struct MultiSigCap has key, store {
    id: UID,
    required_sigs: u64,
    signers: vector<address>
}

// Usage-limited capability
public struct LimitedCap has key, store {
    id: UID,
    remaining_uses: u64
}
```

## 🎯 Design Principles

### 1. Resource Safety
- Use abilities correctly to prevent asset duplication
- Avoid `drop` on valuable resources
- Leverage Move's type system for automatic safety

### 2. Performance Optimization
- Choose owned vs shared objects based on access patterns
- Minimize shared object contention
- Use events for off-chain data needs

### 3. Modularity
- Separate concerns across modules
- Use package functions for internal APIs
- Design for reusability and composition

### 4. Security First
- Use capabilities for access control
- Validate all inputs in entry functions
- Follow principle of least privilege

## 📜 Common Patterns Summary

| Pattern | Use Case | Implementation |
|---------|----------|---------------|
| **Asset Management** | Tokens, NFTs | `key + store`, owned objects |
| **Global Registry** | Marketplaces, DAOs | Shared objects with capabilities |
| **Access Control** | Admin functions | Capability pattern |
| **Event Logging** | Off-chain integration | Event emission |
| **Multi-module** | Complex applications | Package functions |

## Additional Resources

- **[Move Concepts - IOTA Documentation](https://docs.iota.org/developer/iota-101/move-overview/)** - Comprehensive Move language guide for IOTA
- **[Smart Contracts on IOTA](https://docs.iota.org/tags/move-sc)** - Complete Move smart contract documentation
- **[Object Model - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/object-model)** - Understanding IOTA's object-centric architecture
- **[From Solidity/EVM to Move](https://docs.iota.org/developer/evm-to-move/)** - Migration guide from traditional smart contract patterns
- **[Move Stdlib](https://github.com/iotaledger/iota/tree/develop/external-crates/move/crates/move-stdlib/sources)** - Move Standard Library
- **[Move IOTA Framework](https://github.com/iotaledger/iota/tree/develop/crates/iota-framework/packages/iota-framework/sources)** - Move IOTA Framework 