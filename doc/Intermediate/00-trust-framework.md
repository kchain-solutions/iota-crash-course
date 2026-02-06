# Trust Framework Overview

## Introduction

Organizations often encounter resistance to blockchain adoption due to the misconception that it requires replacing established business processes. IOTA empowers organizations to extend their operational capabilities while meeting regulatory and compliance requirements.

The IOTA Trust Framework mitigates this friction by providing composable components that abstract integration complexity, allowing TypeScript and Rust developers to augment rather than replace existing systems.

Each Trust Framework product is architected as a standalone module while maintaining composability with other components to extract compounded value through integration patterns.

The Trust Framework products are designed as modular building blocks to facilitate on-chain onboarding. By leveraging these framework components, organizations can avoid the risks and maintenance costs associated with implementing custom smart contracts.

For a comprehensive demonstration of how Trust Framework products integrate together, explore the official IOTA DPP showcase at https://dpp.demo.iota.org/

Below is an overview of each Trust Framework product with links to documentation and examples.

## IOTA Identity

IOTA Identity implements industry-standard patterns (W3C) for Decentralized Identity in both a DLT-agnostic and IOTA method-specific manner. This framework provides identity primitives for people, organizations, devices, and digital objects, establishing a unified trust layer across all actors in the ecosystem.

**Documentation**: https://docs.iota.org/developer/iota-identity/

**Examples**:
- **TypeScript**: https://github.com/iotaledger/identity/tree/main/bindings/wasm/identity_wasm/examples
- **Rust**: https://github.com/iotaledger/identity/tree/main/examples

## IOTA Hierarchies

IOTA Hierarchies defines structured relationships and delegated authorities among participants, such as parent companies, subsidiaries, or certification bodies. This component can operate as an on-chain access control manager, potentially enforcing role-based permissions across the IOTA Audit Trails or custom smart contracts.

**Documentation**: https://docs.iota.org/developer/iota-hierarchies/

**Examples**:
- **TypeScript**: https://github.com/iotaledger/hierarchies/tree/main/bindings/wasm/hierarchies_wasm/examples
- **Rust**: https://github.com/iotaledger/hierarchies/tree/main/hierarchies-rs/examples

## IOTA Notarization

IOTA Notarization secures the integrity and timestamp of critical trade data (such as invoices, bills of lading, or certificates) by anchoring cryptographic proofs on-chain. The framework supports three notarization patterns:

- **Locked Notarization**: An immutable proof point anchored on-chain
- **Dynamic Notarization**: A mutable, versioned state record that reflects the latest update
- **Audit Trails**: An immutable event chain where multiple actors contribute updates on-chain, ideal for DPP and supply chain scenarios (WIP)

**Documentation**: https://docs.iota.org/developer/iota-notarization/

**Examples**:
- **TypeScript**: https://github.com/iotaledger/notarization/tree/main/bindings/wasm/notarization_wasm/examples/src
- **Rust**: https://github.com/iotaledger/notarization/tree/main/examples

## IOTA Gas Station

IOTA Gas Station enables transaction fee sponsorship, allowing users to interact with on-chain applications without holding native tokens. This capability is critical for enterprise usability, as it allows participants such as suppliers or logistics agents to submit documents or trigger transactions without managing gas fees.

**Documentation**: https://docs.iota.org/operator/gas-station/

**Examples**: https://github.com/iotaledger/gas-station/tree/main/examples

## IOTA Secret Storage

IOTA Secret Storage enables applications to securely request cryptographic signatures without exposing private keys. It provides a standardized, auditable interface for transaction approval, identity verification, and data signing, maintaining key security while offering developers the flexibility to integrate existing key management solutions.

**Note**: We are close to releasing the Secret Storage AWS connector, and the HashiCorp Vault connector will follow in the pipeline.

**Documentation**: https://github.com/iotaledger/secret-storage

## Trust Framework Integration Patterns

### Gas Station and Secret Storage

Gas Station and Secret Storage operate at the infrastructure layer and can be composed with all other modules. Gas Station provides not only transaction fee sponsorship but also performance optimization for coin object management, delegating operational complexity to a dedicated component. Gas Station is natively integrated with Identity and Notarization for secure transaction signing. 

### Hierarchies and Audit Trails (WIP)

In audit trail scenarios, different roles require different permission levels (Write, Admin, Read-only, etc.). Hierarchies associates roles as attributes to IOTA addresses, enabling a single source of truth to be extended horizontally across multiple components while guaranteeing correct permission enforcement for Audit Trails. 


### Identity and Hierarchies

When IOTA Identity is combined with domain linkage, it provides attestation of real-world identity for a specific DID. For business entities, the DID establishes **WHO** the actor is behind their on-chain identity.

This DID can then be configured as an address attribute within Hierarchies, effectively creating an organizational structure that maps relationships between entities and establishes credential chains showing exactly **WHO** accredited **WHOM** for a particular role.

In summary, Identity attests **WHO** an entity is, while Hierarchies defines **WHAT** role that entity plays within the ecosystem.

**Documentation**: https://docs.iota.org/developer/iota-identity/how-tos/domain-linkage/create-and-verify



