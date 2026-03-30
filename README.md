# IOTA Blockchain Adoption Crash Course

A hands-on crash course for learning IOTA's Move Virtual Machine (MoveVM) and its unique approach to smart contracts, decentralized identity, and enterprise trust infrastructure. This repository provides practical examples and step-by-step guides to help developers quickly understand and experiment with IOTA's blockchain technology.

## Purpose

This crash course is designed for developers who are:
- New to IOTA's MoveVM and smart contract development
- Looking to understand the differences between owned vs shared objects
- Interested in IOTA's Trust Framework for enterprise applications
- Wanting hands-on experience with IOTA's development tools

## Repository Structure

```
iota-crash-course/
├── doc/                              # Documentation organized in 5 modules
│   ├── INDEX.md                      # Master index and learning paths
│   ├── Module-1-Foundations/         # Core MoveVM concepts
│   │   ├── 01-getting-started.md         # Environment setup
│   │   ├── 02-key-concepts.md            # MoveVM fundamentals
│   │   ├── 03-owned-vs-shared.md         # Object ownership patterns
│   │   ├── 04-smart-contract.md          # Smart contract structure
│   │   ├── 05-testing-and-debugging.md   # Testing and debugging
│   │   ├── 06-dummy-audit-trails.md      # Example walkthrough
│   │   └── 07-iota-explorer.md           # Blockchain exploration
│   ├── Module-2-Trust-Framework/     # Identity and trust layer
│   │   ├── 01-trust-framework-overview.md
│   │   └── 02-iota-identity.md
│   ├── Module-3-Infrastructure/      # Operations and deployment
│   │   └── 01-iota-gas-station.md
│   ├── Module-4-Integration/         # System integration patterns
│   │   └── 01-domain-linkage-verification.md
│   └── Module-5-Reference/           # Quick lookup material
│       └── 01-enterprise-technical-faq.md
├── examples/                         # Practical implementations
│   ├── dummy-audit-trails/           # Move smart contract example
│   ├── gas-station-sidecar/          # Gas Station + KMS deployment
│   ├── hierarchies/                  # Hierarchies example (WIP)
│   └── scripts/                      # Reusable automation scripts
└── Makefile                          # Automated development commands
```

## Quick Start

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

## Learning Paths

The documentation is organized in 5 modules with explicit prerequisites and three learning paths. See [doc/INDEX.md](doc/INDEX.md) for the complete curriculum map.

### Path A: Smart Contract Developer (8-10 hours)
Write, test, deploy, and upgrade Move smart contracts on IOTA.

### Path B: Enterprise Architect (6-8 hours)
Understand IOTA's enterprise capabilities and design DPP/trust systems.

### Path C: Full Stack dApp Developer (10-12 hours)
Build a complete dApp with frontend, smart contract, identity, and sponsored transactions.

### Module Overview

| Module | Focus | Documents |
|--------|-------|-----------|
| [Module 1: Foundations](doc/Module-1-Foundations/) | Core MoveVM concepts, first smart contract | 7 docs |
| [Module 2: Trust Framework](doc/Module-2-Trust-Framework/) | Identity, credentials, hierarchies | 2 docs |
| [Module 3: Infrastructure](doc/Module-3-Infrastructure/) | Gas Station, deployment | 1 doc |
| [Module 4: Integration](doc/Module-4-Integration/) | Domain linkage, DPP, frontend | 1 doc |
| [Module 5: Reference](doc/Module-5-Reference/) | FAQ, cheat sheet | 1 doc |

## Available Commands

### Prerequisites and Setup
```bash
make install-rust           # Install/update Rust and Cargo
make install-iota-cli       # Install IOTA CLI
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

## Smart Contract Architecture

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

## IOTA Explorer Integration

After deploying and interacting with contracts, use the IOTA Explorer to verify on-chain activity:

- **Testnet**: [explorer.rebased.iota.org](https://explorer.rebased.iota.org)
- **Mainnet**: [explorer.iota.org](https://explorer.iota.org)

Search for transaction IDs or object IDs to see detailed information about your contracts and transactions.

## Configuration

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
3. **Test**: Run unit tests (`iota move test`)
4. **Deploy**: Publish contract to network
5. **Configure**: Update .env with deployed package ID
6. **Interact**: Create objects and call contract functions
7. **Verify**: Use explorer to confirm on-chain state

## Contributing

This crash course is designed to be educational and practical. If you find issues or have suggestions for improvements, please feel free to contribute by:

- Reporting bugs or unclear documentation
- Suggesting additional examples or use cases
- Improving the automation scripts or Makefile commands

## Additional Resources

- **[IOTA Developer Documentation](https://docs.iota.org/)**
- **[Move Language Reference](https://move-language.github.io/move/)**
- **[IOTA Identity Framework](https://docs.iota.org/developer/iota-identity/)**
- **[IOTA Explorer](https://explorer.iota.org)**
- **[DPP Demo Showcase](https://dpp.demo.iota.org/)**

## Next Steps

After completing this crash course:

1. **Experiment** with modifying the audit trail contract
2. **Test** your contracts with `iota move test` and coverage
3. **Explore** IOTA's Trust Framework components
4. **Build** a decentralized application using IOTA's full stack
5. **Deploy** a Gas Station for gasless user experience
