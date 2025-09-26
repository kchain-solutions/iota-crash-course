# Smart Contract Structure in IOTA Move

This guide explains how smart contracts are structured in IOTA's Move Virtual Machine using our audit trail example as a practical case study.

## Move Module Structure

A Move smart contract is organized into **modules**. Each module is a collection of structs, functions, and constants that define a specific piece of functionality.

### Module Declaration

```move
module audit_trails::app {
    // Module contents
}
```

- **`audit_trails`** - Package name (defined in Move.toml)
- **`app`** - Module name within the package
- **`::`** - Namespace separator

## Import Dependencies

```move
use std::string::String;           // Standard library for strings
use iota::clock::{Self, Clock};    // IOTA's clock for timestamps
use iota::event;                   // Event emission functionality
use audit_trails::nft_reward::send_nft_reward; // Our NFT module
```

**Key Patterns:**
- **Standard Library**: `std::*` for basic types and utilities
- **IOTA Framework**: `iota::*` for blockchain-specific functionality  
- **Local Modules**: `package_name::module_name` for cross-module communication

## Data Structures (Structs)

### Resource Structs (Objects)

Resource structs represent on-chain objects with unique abilities:

```move
public struct Product has key, store {
    id: UID,                    // Unique identifier
    name: String,
    serial_number: String,
    manufacturer: String,
    image_url: String,
    timestamp: u64
}
```

**Abilities Explained:**
- **`key`**: Can be stored as a top-level object (has an address)
- **`store`**: Can be stored inside other structs
- **`copy`**: Can be copied (not used for resources - would duplicate assets!)
- **`drop`**: Can be discarded (dangerous for resources!)

### Event Structs

Events are emitted to notify off-chain systems:

```move
public struct ProductEntryLogged has drop, store, copy {
    product_addr: address,
    entry_addr: Option<address>
}
```

**Event Abilities:**
- **`copy`**: Events need to be copyable
- **`drop`**: Events can be discarded after emission
- **`store`**: Can be stored temporarily

## Object Creation Patterns

### Shared Objects (Collaborative State)

```move
public entry fun new_product(
    name: String,
    manufacturer: String,
    serial_number: String, 
    image_url: String,
    clock: &Clock,
    ctx: &mut TxContext
) {
    let p_id = object::new(ctx);        // Create unique ID
    let p_addr = object::uid_to_address(&p_id); // Get address
    
    transfer::share_object(Product {    // Make it shared!
        id: p_id,
        name,
        serial_number,
        manufacturer,
        image_url,
        timestamp: clock::timestamp_ms(clock)
    });
    
    event::emit(ProductEntryLogged {    // Notify observers
        product_addr: p_addr,
        entry_addr: option::none()
    });
}
```

**Shared Object Characteristics:**
- **Anyone can access** for reading and valid operations
- **Higher latency** due to consensus requirements
- **Perfect for collaborative resources** (marketplaces, DAOs, games)

### Owned Objects (Private State)

```move
public entry fun log_entry_data(
    product: &Product,              // Reference to shared object
    entry_data: String,
    clock: &Clock,
    ctx: &mut TxContext
) {
    let product_id = object::id<Product>(product);
    let product_addr = object::id_to_address(&product_id);
    
    let e_id = object::new(ctx);
    let e_addr = object::uid_to_address(&e_id);
    
    transfer::transfer(ProductEntry {   // Transfer to specific owner!
        id: e_id,
        issuer_addr: tx_context::sender(ctx),
        entry_data,
        timestamp: clock::timestamp_ms(clock)
    }, product_addr);                   // Product becomes the owner
    
    // Emit event and mint reward...
}
```

**Owned Object Characteristics:**
- **Single owner** (in this case, the Product object)
- **Lower latency** through parallel execution
- **Ideal for private data** and user-specific assets

## Function Types

### Entry Functions (Public API)

```move
public entry fun new_product(/* parameters */) {
    // Implementation
}
```

**Entry Function Properties:**
- **`public entry`**: Can be called directly from transactions
- **No return value**: Entry functions don't return data
- **Transaction boundaries**: Each call is a separate transaction

### Public Functions (Inter-module)

```move
public fun name(nft: &RewardNFT): &String {
    &nft.name
}
```

**Public Function Properties:**
- **`public`**: Callable by other modules
- **Can return values**: Used for queries and inter-module communication
- **Not entry points**: Cannot be called directly from transactions

### Package-only Functions

```move
public(package) fun send_nft_reward(/* parameters */) {
    // Implementation  
}
```

**Package Function Properties:**
- **`public(package)`**: Only callable within the same package
- **Module boundaries**: Enables controlled access between related modules

## Multi-Module Architecture

Our audit trail example uses two modules:

### Main Module (`audit_trails::app`)
- **Product management**: Creating and managing audit trail products
- **Entry logging**: Adding audit entries to products  
- **Event emission**: Notifying external systems

### NFT Reward Module (`audit_trails::nft_reward`)
- **NFT creation**: Minting reward NFTs
- **Display setup**: Configuring how NFTs appear in wallets
- **Access control**: Managing who can mint NFTs

**Integration Pattern:**
```move
// In app.move
use audit_trails::nft_reward::send_nft_reward;

// Later in log_entry_data function
send_nft_reward(
    b"Product Entry Badge",
    b"Thanks for logging a product entry!",
    b"https://i.imgur.com/Jw7UvnH.png",
    tx_context::sender(ctx),
    ctx
);
```

## Key Design Patterns

### 1. Object Ownership Strategy
- **Shared Products**: Enable collaborative audit trails
- **Owned Entries**: Ensure entries belong to specific products
- **Performance optimization**: Parallel processing where possible

### 2. Event-Driven Architecture  
- **Emit events** for all significant state changes
- **Enable off-chain indexing** and real-time updates
- **Provide audit trails** for all operations

### 3. Capability-Based Security
- **One-Time Witness (OTW)**: Ensures only module publisher can initialize
- **Admin capabilities**: Control sensitive operations
- **Resource safety**: Move's type system prevents asset duplication

### 4. Modular Design
- **Separation of concerns**: Core logic vs. reward system
- **Reusability**: NFT module can be used by other contracts
- **Maintainability**: Clear boundaries between functionalities

## Deployment Structure

### Move.toml Configuration
```toml
[package]
name = "audit trails"
license = "Apache-2.0"
version = "0.1.0"
edition = "2024.beta"

[dependencies]
# Dependencies are automatically included

[addresses]
audit_trails = "0x0"    # Resolved during deployment
```

### Directory Structure
```
dummy-audit-trails/
    Move.toml           # Package configuration
    sources/            # Source code directory
    audit_trails.move    # Main module
    nft_reward.move      # NFT reward module
```

## Transaction Flow Example

1. **Deploy Contract**: Publish modules to blockchain
2. **Initialize**: `init` functions run automatically  
3. **Create Product**: Call `new_product` creates shared object
4. **Log Entry**: Call `log_entry_data` creates owned object + mints NFT
5. **Events Emitted**: Off-chain systems can track all activities

This structure demonstrates IOTA Move's unique approach to blockchain development, combining performance optimizations (owned objects) with collaborative features (shared objects) in a type-safe, resource-oriented programming model.