# 🚀 IOTA Blockchain Adoption Crash Course

A hands-on crash course for learning IOTA's Move Virtual Machine (MoveVM) and its unique approach to smart contracts and decentralized identity. This repository provides practical examples and step-by-step guides to help developers quickly understand and experiment with IOTA's blockchain technology.

## 🎯 Purpose

This crash course is designed for developers who are:
- New to IOTA's MoveVM and smart contract development
- Looking to understand the differences between owned vs shared objects
- Interested in building decentralized applications on IOTA
- Wanting hands-on experience with IOTA's development tools

## 📚 Repository Structure

```
iota-crash-course/
├── 📖 doc/                    # Theoretical concepts and guides
│   ├── Beginner/              # Foundational learning materials
│   │   ├── 01-key-concepts.md     # MoveVM fundamentals
│   │   ├── 02-owned-vs-shared.md  # Object ownership patterns
│   │   ├── 03-smart-contract.md   # Smart contract structure
│   │   ├── 04-dummy-audit-trails.md # Example interaction guide
│   │   └── 05-iota-explorer.md    # Blockchain exploration guide
│   ├── Intermediate/          # Advanced topics
│   │   └── 01-iota-identity.md    # Decentralized Identity (DIDs)
│   └── Advanced/              # Expert-level implementations
│       └── 01-domain-linkage-verification.md # Domain linkage verification
├── 🔧 examples/               # Practical implementations
│   ├── scripts/               # Reusable automation scripts
│   └── dummy-audit-trails/    # Complete smart contract example
└── 🛠️ Makefile                # Automated development commands
```

## 🚀 Quick Start

### Prerequisites Installation

1. **Install Rust and Cargo** (if not already installed):
   ```bash
   make install-rust
   ```

2. **Install IOTA CLI**:
   ```bash
   make install-iota-cli
   ```

3. **Verify Installation**:
   ```bash
   make check-dependencies
   ```

### Account Setup

4. **Create and Fund Account**:
   ```bash
   make create-account
   # or with custom alias: make create-account ALIAS=myaccount
   ```

5. **Check Account Balance**:
   ```bash
   make balance
   ```

### Run Your First Example

6. **Build the Smart Contract**:
   ```bash
   make audit-trail-build
   ```

7. **Deploy to Network**:
   ```bash
   make audit-trail-publish
   ```

8. **Update Configuration** (after deployment):
   - Copy the package ID from the publish output
   - Edit `examples/dummy-audit-trails/.env` and set `AUDIT_TRAIL_PKG=0x...`

9. **Create Your First Product** (Shared Object):
   ```bash
   make audit-trail-create-product
   ```

10. **Add an Audit Trail** (Owned Object + NFT Reward):
    ```bash
    export PRODUCT_ID=<id-from-step-9>
    make audit-trail-add-trail
    ```

## 📖 Learning Path

### 1. Understand Core Concepts
Start by reading the documentation in the `doc/` directory:

- **[Key Concepts](doc/Beginner/01-key-concepts.md)**: Learn about MoveVM fundamentals and object-oriented design
- **[Owned vs Shared Objects](doc/Beginner/02-owned-vs-shared.md)**: Understand IOTA's unique performance optimizations
- **[Smart Contract Structure](doc/Beginner/03-smart-contract.md)**: Learn how Move contracts are organized and structured
- **[Audit Trail Example](doc/Beginner/04-dummy-audit-trails.md)**: Step-by-step guide to interacting with the example
- **[IOTA Explorer Guide](doc/Beginner/05-iota-explorer.md)**: Master blockchain exploration and debugging
- **[IOTA Identity Guide](doc/Intermediate/01-iota-identity.md)**: Understand how to use IOTA Identity SDK to manage Decentralized Identities
- **[Domain Linkage Verification](doc/Advanced/01-domain-linkage-verification.md)**: Advanced identity verification with bidirectional domain-DID linking

### 2. Hands-on Examples
Explore the practical implementation in `examples/dummy-audit-trails/`:

- **Simple audit trail system** demonstrating both shared and owned objects
- **Automatic NFT rewards** for participating in the audit process
- **Real smart contract** that you can deploy and interact with

### 3. Key Learning Outcomes
By completing this crash course, you'll understand:

- **Object Model**: How IOTA's object-centric approach differs from account-based systems
- **Performance**: Why owned objects enable parallel execution and low latency
- **Smart Contracts**: How to write, deploy, and interact with Move contracts
- **Development Tools**: Using IOTA CLI, explorer, and development workflows

## 🛠️ Available Commands

### Prerequisites and Setup
```bash
make install-rust           # Install/update Rust and Cargo
make install-iota-cli       # Install IOTA CLI v1.6.1
make check-dependencies     # Verify all tools are installed
```

### Account Management
```bash
make create-account [ALIAS=test]  # Create new account + request faucet
make list-accounts               # Show all accounts and active one  
make faucet                      # Request tokens for current account
make balance                     # Check current account balance
make switch-account ALIAS=name   # Switch to different account
```

### Smart Contract Development
```bash
make audit-trail-build           # Build the Move smart contract
make audit-trail-publish         # Deploy contract to network
make audit-trail-create-product  # Create shared Product object
make audit-trail-add-trail       # Create owned ProductEntry object
make audit-trail-clean          # Clean build artifacts
```

### Help and Information
```bash
make help                   # Show all available commands
make audit-trail-help      # Show detailed audit trail commands
```

## 🏗️ Smart Contract Architecture

The audit trail example demonstrates key IOTA concepts:

### Shared Objects
- **Product**: Created with `transfer::share_object()`
- **Accessible by anyone** for reading and interaction
- **Higher latency** due to consensus requirements
- **Perfect for collaborative resources**

### Owned Objects  
- **ProductEntry**: Created with `transfer::transfer()`
- **Owned by specific Product** address
- **Lower latency** through parallel execution
- **Ideal for private data and assets**

### Automatic Rewards
- **NFT minting** on every audit trail entry
- **Demonstrates asset creation** and transfer
- **Shows integration** between different contract modules

## 🌐 IOTA Explorer Integration

After deploying and interacting with contracts, use the IOTA Explorer to verify on-chain activity:

- [explorer.iota.org](https://explorer.iota.org)

Search for transaction IDs or object IDs to see detailed information about your contracts and transactions.

## 📝 Configuration

### Environment Variables
Each example uses its own `.env` file for configuration:

```bash
# examples/dummy-audit-trails/.env
AUDIT_TRAIL_PKG=0x1234...     # Published package ID
CLOCK_ID=0x6                  # System clock object (standard)
PRODUCT_ID=0xabcd...          # Created product ID
```

### Development Workflow
The typical development cycle:

1. **Setup**: Install tools and create account
2. **Build**: Compile Move smart contract
3. **Deploy**: Publish contract to network
4. **Configure**: Update .env with deployed package ID
5. **Interact**: Create objects and call contract functions
6. **Verify**: Use explorer to confirm on-chain state

## 🤝 Contributing

This crash course is designed to be educational and practical. If you find issues or have suggestions for improvements, please feel free to contribute by:

- Reporting bugs or unclear documentation
- Suggesting additional examples or use cases
- Improving the automation scripts or Makefile commands

## 📚 Additional Resources

- **[IOTA Developer Documentation](https://docs.iota.org/)**
- **[Move Language Reference](https://move-language.github.io/move/)**
- **[IOTA Identity Framework](https://identity.docs.iota.org/)**
- **[IOTA Explorer](https://explorer.iota.org)**

## 🏁 Next Steps

After completing this crash course:

1. **Experiment** with modifying the audit trail contract
2. **Create your own** Move smart contract from scratch  
3. **Explore** IOTA's identity and DID capabilities
4. **Build** a decentralized application using IOTA's full stack

Happy coding with IOTA! 🚀