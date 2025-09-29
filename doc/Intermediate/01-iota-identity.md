# IOTA Identity: Decentralized Identifiers (DIDs) on IOTA

Decentralized Identifiers (DIDs) are a key component of self-sovereign identity, and IOTA provides a robust framework (the IOTA Identity library) for creating and managing DIDs on its ledger. A DID is essentially a globally unique identifier (like `did:iota:123...`) that maps to a DID Document — a document containing public keys, authentication methods, and other metadata about an identity.

In IOTA's implementation, DIDs are stored on the ledger as special Identity objects, and the IOTA Identity library provides convenient APIs to perform all operations (Create, Read, Update, Deactivate). These operations under the hood translate to on-chain transactions that modify the Identity objects.

## Core DID Operations

### Creating a DID

To create a new DID on IOTA, you need to create an Identity object on the ledger that will hold the DID Document. In practice, this means preparing a DID Document (at least containing a public key for the controller of the DID) and then calling the `Identity::new` function via a transaction.

Using the higher-level Identity WASM SDK (in Node.js or Rust), this is abstracted for you: you simply call an API like `createIdentity()` with appropriate parameters. The result of a successful creation is that a new Object (Identity) is stored on-chain, and its Object ID becomes the unique DID tag.

**DID Format**: `did:iota:<network>:0x<ObjectID>`

For example: `did:iota:testnet:0xabc123...def` where `testnet` indicates the network and the hex after `0x` is the object's ID.

### Resolving (Reading) a DID

Reading a DID means fetching the latest DID Document associated with that DID from the ledger (also known as resolving the DID). Given a DID, a client would parse it to get the network and the object ID, then query an IOTA node for the object with that ID.

The IOTA Identity library provides a straightforward method: `resolveDid(did)`. The result includes:
- **doc**: Contains fields like `id` (the DID itself), `verificationMethod` (public keys), authentication methods, services, etc.
- **meta**: Includes timestamps like when it was created/updated and other state info

### Updating a DID Document

DIDs can be updated to add or remove keys, add new service endpoints, rotate authentication keys, etc. In IOTA, a DID update is achieved by transactions calling `Identity::propose_update` and then `Identity::execute_update` on the Identity object.

The process is split into "propose" and "execute" to support multi-controller DIDs. For a single-controller DID, the process can be simplified where the single owner can effectively approve and execute in one step.

### Deactivating or Deleting a DID

IOTA's DID method allows for deactivation (temporary or permanent):
- **Soft deactivation**: Publishing an update that sets a `deactivated: true` flag
- **Permanent deletion**: Wiping the DID Document from the Identity object

Deletion is a heavy action and not commonly performed, as it could break references. In most scenarios, rotation and deactivation suffice.

## Practical Implementation Examples

### TypeScript/WASM Example

The IOTA Identity WASM library provides comprehensive APIs for DID operations. Here's the conceptual flow:

**1. Create and Publish DID**:
- Initialize IOTA client and network connection
- Generate DID document with verification methods  
- Create identity on-chain using `createIdentity()` 
- Build and execute transaction to publish DID

**2. Resolve DID**:
- Query the published DID document from the network
- Retrieve current state and metadata
- Verify cryptographic integrity

**3. Update DID Document**:
- Generate new verification methods or services
- Create update proposal with controller token
- Execute update transaction on-chain

**📚 Complete Working Examples**:
- **[Create DID](https://github.com/iotaledger/identity/blob/main/bindings/wasm/identity_wasm/examples/0_basic/0_create_did.ts)** - Full DID creation workflow
- **[Update DID](https://github.com/iotaledger/identity/blob/main/bindings/wasm/identity_wasm/examples/0_basic/2_update_did.ts)** - DID document updates and verification methods
- **[Delete DID](https://github.com/iotaledger/identity/blob/main/bindings/wasm/identity_wasm/examples/0_basic/4_delete_did.ts)** - DID deactivation and deletion

## Code Examples and Resources

### WASM/TypeScript Examples

The IOTA Identity team provides comprehensive examples for WASM bindings covering:

- **Basic DID Operations**: Creating, resolving, updating DIDs
- **Verifiable Credentials**: Issuing and verifying credentials
- **Advanced Features**: Multi-signature DIDs, service endpoints, key rotation

**📚 Explore WASM Examples**: [identity/bindings/wasm/examples](https://github.com/iotaledger/identity/tree/main/bindings/wasm/identity_wasm/examples)

Key examples include:
- `0_basic/0_create_did.ts` - Basic DID creation
- `0_basic/1_resolve_did.ts` - DID resolution
- `0_basic/2_update_did.ts` - DID document updates
- `1_advanced/` - Advanced identity features
- `credential/` - Verifiable credential workflows

### Rust Examples

For Rust developers, native examples demonstrate:

- **High-performance DID operations** using the native Rust library
- **Advanced cryptographic features** and key management
- **Custom identity workflows** and integrations

**📚 Explore Rust Examples**: [identity/examples](https://github.com/iotaledger/identity/tree/main/examples)

Key examples include:
- `0_basic/` - Fundamental DID operations
- `1_advanced/` - Complex identity scenarios  
- Credential management and verification
- Custom resolver implementations

## Integration with IOTA MoveVM

DIDs on IOTA integrate seamlessly with Move smart contracts, enabling powerful use cases:

### Identity-Aware Applications

IOTA Identity integrates with Move smart contracts to enable powerful identity-based functionality:

**Conceptual Integration Patterns**:

**1. Identity-Gated Contracts**:
- Smart contracts can verify DID ownership before executing functions
- Users prove control of their DID to access restricted features
- Enables self-sovereign access control without centralized authorities

**2. Credential-Based Access**:
- Verifiable credentials act as on-chain permissions
- Users present credentials to unlock premium features or roles
- Issuers can revoke credentials to remove access

**3. Reputation Systems**:
- DIDs accumulate reputation through on-chain interactions
- Smart contracts can query reputation scores for decision making
- Enables trust-based applications without revealing personal data

**📚 Integration Examples**:
- **[Identity in Move Contracts](https://github.com/iotaledger/identity/tree/main/examples)** - Rust examples showing DID integration patterns
- **[Credential Verification](https://docs.iota.org/developer/iota-identity/how-tos/verifiable-credentials/create)** - Official verification workflows

## Development Workflow

### 1. Setup Development Environment

```bash
# Install IOTA Identity library
npm install @iota/identity-wasm
# or for Rust
cargo add iota-identity
```

### 2. Basic DID Lifecycle

1. **Create**: Generate DID and publish to IOTA ledger
2. **Resolve**: Fetch DID document from any IOTA node
3. **Update**: Modify keys, services, or metadata
4. **Verify**: Use DID for authentication or credential verification

### 3. Advanced Patterns

- **Multi-controller DIDs**: Shared control between multiple parties
- **Threshold signatures**: Require multiple approvals for updates
- **Service endpoints**: Link DIDs to external services
- **Credential issuance**: Create and manage verifiable credentials

## Explorer Integration

After creating DIDs, use the IOTA Explorer to inspect them:

1. **Search by DID**: Use the DID string to find the Identity object
2. **Object inspection**: View the raw DID document data
3. **Transaction history**: Track all DID operations over time
4. **Verification**: Confirm DIDs are properly anchored on-chain

**Example DID on Explorer**: Search for a DID's object ID (the part after `0x`) to see its current state and history.

## Security Considerations

### Key Management
- **Private key security**: Protect DID controller keys
- **Key rotation**: Regularly update cryptographic keys
- **Backup strategies**: Ensure key recovery procedures

### Operational Security
- **Multi-signature**: Use multiple controllers for critical DIDs
- **Threshold schemes**: Require multiple approvals for sensitive operations
- **Monitoring**: Track DID operations for unauthorized changes


## Next Steps

After understanding DID fundamentals:

1. **Experiment** with the provided code examples
2. **Create your own DID** using the WASM or Rust libraries
3. **Integrate DIDs** with Move smart contracts
4. **Build identity-aware applications** using IOTA's full stack
5. **Explore advanced features** like verifiable credentials and multi-party governance

The combination of IOTA's high-performance MoveVM and native identity infrastructure creates unique opportunities for building truly decentralized, identity-aware applications with both privacy and verifiability.

## Additional Resources

### Official IOTA Documentation
- **[IOTA Identity - IOTA Documentation](https://docs.iota.org/developer/iota-identity/)** - Main IOTA Identity documentation portal
- **[Create Verifiable Credentials](https://docs.iota.org/developer/iota-identity/how-tos/verifiable-credentials/create)** - Step-by-step credential creation guide
- **[IOTA DID Method Specification](https://docs.iota.org/developer/iota-identity/references/iota-did-method-spec)** - Official DID method specification
- **[Verifiable Credentials Concepts](https://docs.iota.org/developer/iota-identity/explanations/verifiable-credentials)** - Understanding VCs in IOTA