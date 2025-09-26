# IOTA Audit Trail Demo

A simplified smart contract example demonstrating **owned vs shared objects** concepts in IOTA Move.

## 🎯 Purpose

This demo showcases the key difference between:
- **Shared Objects** (`Product`) - can be accessed by anyone
- **Owned Objects** (`ProductEntry`) - owned by specific addresses and enable parallel execution

## 📋 Features

- Create products as **shared objects** that anyone can interact with
- Add audit trail entries as **owned objects** that belong to specific products  
- Automatic NFT reward minting when adding trail records
- No complex permissions or hierarchies - anyone can interact

## 🚀 Quick Start

### 1. Setup Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your values
nano .env
```

### 2. Build and Deploy

```bash
# Build the contract
make build

# Publish to network (update .env with package ID after this)
make publish

# Make scripts executable
make setup
```

### 3. Create Your First Product

```bash
# Create a product (shared object)
make create-product

# Copy the Product ID from output and set it in .env
export PRODUCT_ID=0x1234...
```

### 4. Add Trail Records

```bash
# Add audit trail entry (owned object + NFT reward)
make add-trail
```

## 📖 Available Commands

Run `make help` to see all available commands:

- `make build` - Build the Move contract
- `make publish` - Deploy contract to network  
- `make create-product` - Create new product (shared object)
- `make add-trail` - Add trail record (owned object)
- `make clean` - Clean build artifacts

## 🏗️ Architecture

### Smart Contract Structure

```
audit_trails::app
├── Product (shared object)
│   ├── name, manufacturer, serial_number
│   ├── image_url, timestamp
│   └── Shared with transfer::share_object()
│
└── ProductEntry (owned object)
    ├── issuer_addr, entry_data, timestamp
    └── Owned by Product via transfer::transfer()
```

### Key Concepts Demonstrated

1. **Shared Objects**: `Product` is created with `transfer::share_object()` making it accessible to all users
2. **Owned Objects**: `ProductEntry` is transferred to the product's address, creating ownership relationship
3. **Parallel Execution**: Multiple users can create products simultaneously since they don't conflict
4. **Asset Safety**: NFT rewards are automatically minted using Move's resource safety guarantees

## 🔍 Understanding the Code

### Product Creation (Shared Object)
```move
// Creates a shared object anyone can reference
transfer::share_object(Product { ... });
```

### Trail Entry (Owned Object)  
```move
// Creates an owned object belonging to the product
transfer::transfer(ProductEntry { ... }, product_addr);
```

### Automatic Rewards
```move
// Mints NFT reward for each trail entry
send_nft_reward(name, description, image_url, recipient, ctx);
```

## 📝 Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AUDIT_TRAIL_PKG` | Published package ID | `0x1234...` |
| `CLOCK_ID` | System clock object | `0x6` |
| `PRODUCT_ID` | Created product ID | `0xabcd...` |

## 🎓 Learning Outcomes

After running this demo, you'll understand:

- How shared objects enable multi-user interactions
- How owned objects enable parallel execution and gas optimization
- Move's resource safety preventing asset duplication/loss
- IOTA's object-centric transaction model vs account-based systems
- Practical smart contract deployment and interaction patterns