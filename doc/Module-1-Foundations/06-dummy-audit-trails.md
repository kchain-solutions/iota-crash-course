# Dummy Audit Trails Example: Interaction Guide

> **Prerequisiti:** [05 - Testing e Debugging](05-testing-and-debugging.md)
> **Tempo stimato:** 60 minuti
> **Hands-On:** `examples/dummy-audit-trails/`
> **Prossimo:** [07 - IOTA Explorer](07-iota-explorer.md)

---

This guide walks you through the dummy audit trails example, explaining how to interact with the smart contract and what happens behind the scenes.

## Example Overview

The dummy audit trails example demonstrates a simplified supply chain tracking system where:

- **Products** are created as **shared objects** that anyone can audit
- **Audit entries** are created as **owned objects** that belong to specific products  
- **NFT rewards** are automatically minted for users who contribute audit entries

## Architecture Deep Dive

### Smart Contract Components

```
audit_trails package
    app module                  # Main business logic
        Product (shared)        # Collaborative product records
        ProductEntry (owned)    # Individual audit entries  
        ProductEntryLogged      # Event for off-chain tracking
    nft_reward module          # Reward system
        RewardNFT (owned)       # NFT badges for participants
        NFTMinted              # Event for NFT creation
```


## Step-by-Step Interaction Guide

### Prerequisites Setup

1. **Install Dependencies**:
   ```bash
   make install-rust
   make install-iota-cli
   make check-dependencies
   ```

2. **Create Account**:
   ```bash
   make create-account
   # Creates account, requests faucet, and sets as active
   ```

3. **Verify Setup**:
   ```bash
   make balance
   # Should show IOTA tokens for gas fees
   ```

### Deploy the Smart Contract

4. **Build Contract**:
   ```bash
   make audit-trail-build
   ```
   
   **What happens**: Compiles the Move source code into bytecode

5. **Deploy to Network**:
   ```bash
   make audit-trail-publish
   ```
   
   **What happens**:
   - Publishes the `audit_trails` package to the blockchain
   - Automatically runs `init` functions in both modules
   - Creates admin capabilities and NFT display configuration
   - Returns a **Package ID** that identifies your deployed contract

6. **Configure Environment**:
   ```bash
   # Copy the Package ID from the publish output
   cd examples/dummy-audit-trails
   cp .env.example .env
   # Edit .env and set AUDIT_TRAIL_PKG=0x<your-package-id>
   ```

### Interact with the Contract

7. **Create a Product (Shared Object)**:
   ```bash
   make audit-trail-create-product
   ```
   
   **Behind the scenes**:
   ```move
   transfer::share_object(Product {
       id: p_id,
       name: "Pro 48V Battery",
       serial_number: "EB-48V-2024-001337", 
       manufacturer: "EcoBike",
       image_url: "https://i.imgur.com/AdTJC8Y.png",
       timestamp: clock::timestamp_ms(clock)
   });
   ```
   
   **Result**: Creates a Product object that anyone can reference and audit

8. **Set Product ID**:
   ```bash
   export PRODUCT_ID=0x<product-id-from-step-7>
   ```

9. **Add Audit Trail Entry (Owned Object + NFT)**:
   ```bash
   make audit-trail-add-trail
   ```
   
   **Behind the scenes**:
   ```move
   // Create ProductEntry owned by the Product
   transfer::transfer(ProductEntry {
       id: e_id,
       issuer_addr: tx_context::sender(ctx),
       entry_data: "Quality check passed - Battery tested...",
       timestamp: clock::timestamp_ms(clock)
   }, product_addr);
   
   // Mint NFT reward to the user
   send_nft_reward(
       b"Product Entry Badge",
       b"Thanks for logging a product entry!",
       b"https://i.imgur.com/Jw7UvnH.png",
       tx_context::sender(ctx),
       ctx
   );
   ```
   
   **Result**: 
   - Creates ProductEntry object owned by the Product
   - Mints NFT reward to your account
   - Emits events for off-chain tracking

## Understanding the Object Model

### Shared Objects: Products

**Creation**:
```move
public entry fun new_product(
    name: String,
    manufacturer: String,
    serial_number: String,
    image_url: String,
    clock: &Clock,
    ctx: &mut TxContext
)
```

**Characteristics**:
- **Global accessibility**: Any user can reference this object in transactions
- **Consensus required**: All operations go through full consensus
- **Higher gas costs**: Due to consensus overhead
- **Collaborative**: Perfect for resources that multiple parties need to interact with

**Use case**: Products need to be auditable by multiple stakeholders in a supply chain

### Owned Objects: Product Entries  

**Creation**:
```move
public entry fun log_entry_data(
    product: &Product,          // Reference to shared Product
    entry_data: String,
    clock: &Clock, 
    ctx: &mut TxContext
)
```

**Characteristics**:
- **Single owner**: The Product object owns all its audit entries
- **Parallel execution**: Multiple users can create entries simultaneously  
- **Lower latency**: No consensus needed for parallel operations
- **Private by default**: Only owner can access directly

**Use case**: Individual audit records that belong to specific products

### Event-Driven Architecture

**Events emitted**:
```move
// When product is created
event::emit(ProductEntryLogged {
    product_addr: p_addr,
    entry_addr: option::none()  // No entry for product creation
});

// When audit entry is added  
event::emit(ProductEntryLogged {
    product_addr,
    entry_addr: option::some<address>(e_addr)
});

// When NFT is minted
event::emit(NFTMinted {
    object_id: object::id(&nft),
    creator: caller,
    name: nft.name,
});
```

**Off-chain benefits**:
- **Real-time notifications**: Dapps can listen for events
- **Audit trails**: Complete history of all operations  
- **Analytics**: Track usage patterns and user engagement

## Performance Implications

### Why This Design is Efficient

1. **Product Creation** (Shared):
   - **Low frequency**: Products are created rarely
   - **High collaboration**: Many users need to audit
   - **Consensus acceptable**: Setup cost is worth the collaborative benefits

2. **Audit Entry Creation** (Owned):
   - **High frequency**: Many audits per product
   - **Independent operations**: Each audit is separate
   - **Parallel execution**: Multiple audits can happen simultaneously

3. **NFT Rewards** (Owned):
   - **Personal assets**: Each NFT belongs to the user who earned it
   - **Instant transfer**: No consensus needed for personal asset operations



**Benefits**:
- **No bottlenecks**: Users don't wait for each other
- **Scalable**: Performance doesn't degrade with more users
- **Cost-effective**: Lower gas fees for high-frequency operations

## Advanced Interactions

### Multiple Products
```bash
# Create additional products
make audit-trail-create-product  # Creates Product 2
export PRODUCT_ID=<new-product-id>
make audit-trail-add-trail       # Audit Product 2

# Switch back to first product
export PRODUCT_ID=<first-product-id>  
make audit-trail-add-trail       # Add another audit to Product 1
```

### Account Management
```bash
# Create different accounts for different roles
make create-account ALIAS=manufacturer
make create-account ALIAS=auditor  
make create-account ALIAS=consumer

# Switch between accounts
make switch-account ALIAS=auditor
make audit-trail-add-trail        # Audit as different user
```

## Next Steps

After completing this example:

1. **Explore the Code**: Read the Move source files to understand implementation details
2. **Modify Parameters**: Change product names, descriptions, or add new fields
3. **Add Features**: Implement product updates, user roles, or approval workflows  
4. **Monitor On-chain**: Use the IOTA Explorer to view your transactions and objects
5. **Build Your Own**: Create a new smart contract using these patterns

This example provides a foundation for understanding IOTA Move development and can be extended for real-world supply chain, asset tracking, or collaborative workflow applications.

## Additional Resources

- **[Move Concepts - IOTA Documentation](https://docs.iota.org/developer/iota-101/move-overview/)** - Complete Move programming guide
- **[Object Model - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/object-model)** - Understanding owned vs shared objects
- **[Object Transfers - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/transfers/)** - How object ownership works in practice
- **[Smart Contracts on IOTA](https://docs.iota.org/tags/move-sc)** - All IOTA Move smart contract documentation