# IOTA Enterprise Technical FAQ

This document provides technical answers to common questions about IOTA's capabilities for enterprise and ESG use cases. All information is based on the current IOTA protocol implementation and technical specifications.

## 1. Core Protocol & Performance

### How does IOTA ensure scalability and reliability for high-volume, low-value microtransactions?

IOTA mainnet L1 uses Delegated Proof-of-Stake (dPoS) consensus protocol with parallel processing, enabling high performance with tens of thousands of TPS and sub-second finality, while maintaining strong security guarantees. MoveVM provides secure execution for microtransactions.

**Technical benchmarks:**
- Theoretical throughput: ~250K TPS under ideal conditions
- Practical throughput: 10-20K TPS (accounting for storage and network I/O)
- Finality: Sub-second confirmation times
- Architecture: Designed for horizontal scaling without typical blockchain limitations

### Can IOTA smart contracts support voucher-like or redeemable digital assets representing real-world usage rights?

Yes, Move language on IOTA supports flexible asset creation with custom redemption logic, ownership transfers, capability access management and programmable conditions ideal for voucher systems. The Closed Loop Token standard allows for the creation of tokens with defined rules and restrictions.

### Are there benchmarks demonstrating IOTA's ability to handle millions of small transactions efficiently?

While there are no live production projects consistently pushing IOTA to thousands of small transactions per second, benchmarks (IOTA Starfish Consensus) and in-depth studies demonstrate theoretical throughput capabilities. The architecture has been designed to scale horizontally and remove typical blockchain limitations, enabling high throughput without relying on heavy fees, making IOTA particularly well suited for microtransactions.

## 2. Transaction Costs & Usability

### How predictable and stable are transaction fees under high-volume conditions?

**Current fee structure:**
- Average transaction fee: 0.005 IOTA

**Fee components:**
- Computation fee: computation_units × (reference_gas_price + tip)
- Storage fee: storage_units × storage_price
- Both reference gas price and storage price are protocol parameters

**High-volume behavior:**
- Additional tip applied to transactions leads to transaction prioritization through processing validator nodes
- Base fees remain stable as protocol parameters

### Is it possible to abstract transaction costs away from end-users?

Yes, IOTA supports sponsored transactions where third parties can pay gas fees on behalf of users, enabling gasless user experiences. The IOTA Gas Station abstracts the complexity and need to buy and manage IOTA tokens away from the end user.

**Technical implementation:**
- Containerized solution for transaction sponsoring
- Authenticated API endpoint interaction
- User reserves transaction slot, then submits signed transaction
- Multiple Gas Station instances can be deployed for enterprise scalability
- Extensive configuration options including address-based allow/deny lists
- Advanced filter rules via Rego Expressions through Access Controller

## 3. Tokenization & Asset Models

### What types of real-world assets can be tokenized on IOTA?

IOTA's MoveVM upgrade enables comprehensive asset tokenization. The platform is currently in the growth phase of its Application and DeFi/Tokenization ecosystem since the MoveVM deployment in May 2025.

**Available token standards:**
- Asset Tokenization
- Coin Standard
- Coin Manager
- Closed-Loop-Token Standard
- ERC-20-like tokens (Fungible Token)
- ERC-721-like NFTs (Non-Fungible Token)

### How flexible is the framework in distinguishing between utility-style tokens and investment-style tokens?

MoveVM's type system allows precise asset modeling with custom properties, behaviors, and compliance rules to distinguish utility vs investment tokens clearly. The framework supports:

- Custom redemption logic
- Ownership transfer mechanisms
- Capability access management
- Programmable conditions and restrictions
- Compliance rule integration at the protocol level

### Is it possible to design tokens with multiple redemption options or use cases?

Yes, Move's flexible object model supports complex tokens with multiple redemption methods, conditional logic, and programmable utility functions. This enables sophisticated multi-use token designs with various redemption pathways.

## 4. Identity, Trust & Compliance

### How can IOTA's identity framework verify authenticity or origin of assets represented on-chain?

For product provenance and tracking use cases, IOTA combines Identity and Notarization capabilities:

**Actor Authentication:**
- Supply chain actors represented via IOTA Identities (DIDs)
- Domain-Linkage feature establishes bidirectional connection between web domain and DID
- Actors can prove control of both DID and associated web domain (e.g., company.com)

**On-chain Statements:**
- Authenticated actors make verifiable statements about tracked products via IOTA Notarization
- Statements can include: harvest dates, component replacements, container arrivals, etc.
- All statements are cryptographically verifiable and immutably recorded

### To what extent does IOTA support auditability and regulatory compliance?

**Auditability Features:**
- **Immutable Ledger:** All data written to IOTA L1 is immutable, timestamped, and cryptographically verifiable
- **Notarization:** Organizations can anchor document hashes or events on-chain, creating tamper-proof records without exposing underlying data
- **Delegated Access & Hierarchies:** Model roles and permissions on-chain with transparent logging of all control changes

**Regulatory Compliance:**
- **GDPR Alignment:** Architecture separates identifiers from personal data; only non-reversible cryptographic proofs are anchored, ensuring "right to be forgotten" compliance
- **Verifiable Credentials (VCs):** Implements W3C standards (DIDs and VCs) for interoperable identity management
- **Selective Disclosure:** Supports SD-JWT for minimum required attribute sharing
- **Tokenization & Compliance Controls:** Integrates metadata and compliance rules directly into assets, enabling KYC/AML checks, transfer restrictions, and jurisdictional controls at protocol level

**Practical Applications:**
- Enterprises can prove compliance (ESG reporting, supply chain certifications) by notarizing relevant documents
- Regulators can verify records on-chain without accessing sensitive raw data
- Users maintain control of identity data while ensuring accountability

## 5. Ecosystem & Deployment

### Does IOTA provide enterprise-grade managed services?

The IOTA SDK is designed to integrate with enterprise-grade managed services including DFNS, Turnkey, AWS KMS, and other key management solutions. The validator node ecosystem provides distributed infrastructure options.

### Are there technical capabilities for infrastructure, energy, or sustainability sectors?

**Gas Station Enterprise Features:**
- Containerized deployment with Redis storage
- KMS integration for secure key management
- Access Controller with sophisticated filtering
- Prometheus metrics and monitoring
- Scalable multi-instance deployment
- Hierarchical wallet architecture support

**Identity & Compliance:**
- W3C-compliant DID infrastructure
- Domain linkage verification
- Verifiable credentials with selective disclosure
- GDPR-compliant architecture
- Immutable audit trails

**Tokenization Capabilities:**
- Flexible asset modeling with compliance controls
- Multi-redemption token designs
- Utility vs. investment token distinction
- Protocol-level compliance rule enforcement

## Technical Implementation Notes

### Gas Station Configuration

**Funding Calculations (based on 0.005 IOTA per transaction):**

| Volume Level | Daily Txs | Weekly Cost | Recommended Funding (30% margin) |
|--------------|-----------|-------------|----------------------------------|
| Low          | 100       | 3.5 IOTA    | 4.55 IOTA                       |
| Medium       | 1,000     | 35 IOTA     | 45.5 IOTA                       |
| High         | 10,000    | 350 IOTA    | 455 IOTA                        |

**Key insight:** 1 IOTA covers approximately 200 transactions at current rates.

### Identity Technical Specifications

**DID Format:** `did:iota:<network>:0x<ObjectID>`

**Operations supported:**
- Create: Generate DID and publish to IOTA ledger
- Resolve: Fetch DID document from any IOTA node
- Update: Modify keys, services, or metadata via propose/execute pattern
- Deactivate/Delete: Soft deactivation or permanent removal

**Domain Linkage Process:**
1. DID Document includes LinkedDomainService
2. Domain hosts DID Configuration Resource at `/.well-known/did-configuration.json`
3. Bidirectional verification ensures cryptographic linkage between DID and domain

### Compliance Architecture

**Data Separation Model:**
- Personal data stored off-chain
- Only cryptographic proofs anchored on-chain
- Verifiable without exposing sensitive information
- GDPR "right to be forgotten" compliance maintained

This technical FAQ represents the current capabilities of the IOTA protocol and is based on publicly available technical documentation and specifications.