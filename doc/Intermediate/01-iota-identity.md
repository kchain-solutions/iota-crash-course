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

Using the IOTA Identity WASM library in Node.js/TypeScript:

```typescript
const iotaClient = new IotaClient({ network: "testnet" });
const identityClient = await Identity.getClient(iotaClient); 

// 1. Create a new DID Document (unpublished, in-memory)
const { doc: newDoc, key: privateKey } = Identity.createNewDidDocument();

// 2. Publish the DID Document on IOTA
const result = await identityClient.createIdentity(newDoc).execute();
const did = result.did;  // e.g., did:iota:testnet:0x1234abcd

console.log("New DID created:", did);

// 3. Resolve the DID to verify it was published
const resolved = await identityClient.resolveDid(did);
console.log("Resolved DID Document:", resolved.document);
console.log("Metadata:", resolved.metadata);
```

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

### Identity-Gated Smart Contracts

```move
public entry fun restricted_function(
    identity_proof: &IdentityProof,
    ctx: &mut TxContext
) {
    // Verify the caller owns a specific DID
    assert!(verify_identity(identity_proof, ctx.sender()), E_UNAUTHORIZED);
    // Execute restricted logic
}
```

### Credential-Based Access Control

```move
public entry fun premium_feature(
    credential: &VerifiableCredential,
    ctx: &mut TxContext  
) {
    // Verify the user has a valid premium credential
    assert!(verify_credential(credential, PREMIUM_ISSUER), E_INVALID_CREDENTIAL);
    // Grant access to premium features
}
```

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

## Use Cases

### Supply Chain Identity
- **Product authenticity**: Each product gets a unique DID
- **Manufacturer verification**: Prove product origin with DID signatures
- **Quality certifications**: Issue credentials for compliance standards

### Academic Credentials
- **Student identities**: Each student has a self-sovereign DID
- **Diploma issuance**: Universities issue verifiable degree credentials
- **Employer verification**: Companies verify credentials without contacting universities

### IoT Device Identity
- **Device DIDs**: Each IoT device has its own identity
- **Secure communication**: Devices authenticate using DID signatures
- **Access control**: Grant permissions based on device credentials

## Next Steps

After understanding DID fundamentals:

1. **Experiment** with the provided code examples
2. **Create your own DID** using the WASM or Rust libraries
3. **Integrate DIDs** with Move smart contracts
4. **Build identity-aware applications** using IOTA's full stack
5. **Explore advanced features** like verifiable credentials and multi-party governance

The combination of IOTA's high-performance MoveVM and native identity infrastructure creates unique opportunities for building truly decentralized, identity-aware applications with both privacy and verifiability.

## Additional Resources

- **[IOTA Identity Documentation](https://identity.docs.iota.org/)** - Complete technical documentation
- **[DID Method Specification](https://identity.docs.iota.org/references/specifications/iota-did-method-spec/)** - IOTA's DID standard
- **[Verifiable Credentials Guide](https://identity.docs.iota.org/concepts/verifiable-credentials/)** - Credential workflows
- **[WASM Bindings API](https://identity.docs.iota.org/references/wasm-api/)** - TypeScript/JavaScript API reference
- **[Rust API Documentation](https://docs.rs/identity_iota/)** - Native Rust library documentation