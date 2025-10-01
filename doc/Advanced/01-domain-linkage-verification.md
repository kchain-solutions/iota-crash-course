# Domain Linkage Verification

Domain linkage is a crucial feature in IOTA Identity that establishes a verifiable connection between a DID (Decentralized Identifier) and a web domain. This bidirectional linking enables trust and verification in decentralized applications by proving that a DID controller has control over a specific domain and vice versa.

## What is Domain Linkage?

Domain linkage creates a cryptographic connection between:
- **A DID Document** (containing identity information and verification methods)
- **A web domain** (like `https://example.com`)

This connection allows applications to verify that:
1. A domain is authentically controlled by the DID owner
2. A DID is officially associated with a specific domain

## How Domain Linkage Works

The linkage process involves two main components:

### 1. Linked Domain Service (DID → Domain)
The DID Document includes a `LinkedDomainService` that lists the domains associated with this identity:

```json
{
  "id": "did:iota:example#domain_linkage",
  "type": "LinkedDomains",
  "serviceEndpoint": [
    "https://foo.example.com",
    "https://bar.example.com"
  ]
}
```

### 2. DID Configuration Resource (Domain → DID)
The domain hosts a special file at `/.well-known/did-configuration.json` containing Domain Linkage Credentials that point back to the DID:

```json
{
  "@context": "https://identity.foundation/.well-known/did-configuration/v1",
  "linked_dids": [
    "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9..."
  ]
}
```

## Implementation Examples

### TypeScript/WASM Implementation

Here's a complete TypeScript implementation for verifying domain linkage using the IOTA Identity WASM library:

```typescript
import {
  CoreDID,
  DomainLinkageConfiguration,
  EcDSAJwsVerifier,
  IdentityClientReadOnly,
  IotaDID,
  IotaDocument,
  Jwt,
  JwtCredentialValidationOptions,
  JwtDomainLinkageValidator,
  LinkedDomainService,
} from '@iota/identity-wasm/node'
import { IotaClient } from '@iota/iota-sdk/client'

interface DomainLinkageResource {
  "@context": string;
  linked_dids: string[];
}

interface VerifyDomainLinkageRequest {
  did: string;
}

interface VerifyDomainLinkageResponse {
  fromDidCheck: boolean;
  fromDomainCheck: boolean;
}

const DAPP_URL = process.env.NEXT_PUBLIC_DAPP_URL as string
const IOTA_IDENTITY_PKG_ID = process.env.IOTA_IDENTITY_PKG_ID as string
const NETWORK_URL = process.env.NEXT_PUBLIC_NETWORK_URL as string

export async function verifyDomainLinkage(did: string): Promise<VerifyDomainLinkageResponse> {
  return {
    fromDidCheck: await startingFromDid(did),
    fromDomainCheck: await startingFromDomain()
  }
}

// Case 1: Starting verification from DID (DID → Domain verification)
async function startingFromDid(did: string): Promise<boolean> {
  try {
    const identityClient = await getIdentityClient(IOTA_IDENTITY_PKG_ID)

    // Resolve the DID document from the IOTA network
    const didDocument: IotaDocument = await identityClient.resolveDid(IotaDID.parse(did))

    // Extract LinkedDomainService from the DID document
    const linkedDomainServices: LinkedDomainService[] = didDocument
      .service()
      .filter((service) => LinkedDomainService.isValid(service))
      .map((service) => LinkedDomainService.fromService(service))

    if (linkedDomainServices.length === 0) {
      return false
    }

    // Get domains from the service
    const domains: string[] = linkedDomainServices[0].domains()

    // Fetch the DID configuration from the domain
    const fetchedConfigurationResource = await fetchDidConfiguration(domains[0])

    // Create configuration resource from fetched data
    const configurationResource = new DomainLinkageConfiguration([
      Jwt.fromJSON(fetchedConfigurationResource.linked_dids[0]),
    ])

    // Validate the linkage
    new JwtDomainLinkageValidator(new EcDSAJwsVerifier()).validateLinkage(
      didDocument,
      DomainLinkageConfiguration.fromJSON(configurationResource),
      domains[0],
      new JwtCredentialValidationOptions()
    )

    return true
  } catch (error) {
    console.error('Error verifying linkage from DID:', error)
    return false
  }
}

// Case 2: Starting verification from domain (Domain → DID verification)
async function startingFromDomain(): Promise<boolean> {
  try {
    const identityClient = await getIdentityClient(IOTA_IDENTITY_PKG_ID)

    // Fetch DID configuration from the domain
    const fetchedConfigurationResource = await fetchDidConfiguration(DAPP_URL)
    const configurationResource = new DomainLinkageConfiguration([
      Jwt.fromJSON(fetchedConfigurationResource.linked_dids[0]),
    ])

    // Extract issuer DIDs from the configuration
    const issuers: Array<CoreDID> = configurationResource.issuers()
    const issuerDocument: IotaDocument = await identityClient.resolveDid(IotaDID.parse(issuers[0].toString()))

    // Validate the linkage
    new JwtDomainLinkageValidator(new EcDSAJwsVerifier()).validateLinkage(
      issuerDocument,
      configurationResource,
      DAPP_URL,
      new JwtCredentialValidationOptions()
    )

    return true
  } catch (error) {
    console.error('Error verifying linkage from domain:', error)
    return false
  }
}

async function getIdentityClient(identityPackageId: string): Promise<IdentityClientReadOnly> {
  const iotaClient = new IotaClient({ url: NETWORK_URL })
  return await IdentityClientReadOnly.createWithPkgId(iotaClient, identityPackageId)
}

export async function fetchDidConfiguration(dappUrl: string): Promise<DomainLinkageResource> {
  const configurationUrl = `${dappUrl}/.well-known/did-configuration.json`

  const response = await fetch(configurationUrl, {
    method: 'GET',
    headers: {
      Accept: 'application/json',
    },
  })

  if (!response.ok) {
    throw new Error(`Failed to fetch DID configuration: ${response.status} ${response.statusText}`)
  }

  return await response.json()
}
```

### Rust Implementation

Here's a Rust implementation for domain linkage verification:

```rust
use std::str::FromStr;
use dotenvy::dotenv;

use identity_ecdsa_verifier::EcDSAJwsVerifier;
use identity_iota::credential::{
    DomainLinkageConfiguration, DomainLinkageValidationError, JwtCredentialValidationOptions,
    JwtDomainLinkageValidator, LinkedDomainService,
};
use identity_iota::iota::IotaDID;
use identity_iota::{core::Url, iota::IotaDocument, resolver::Resolver};

use backend::{identity_utils::get_client, utils::MANUFACTURER_ALIAS};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv().ok();

    // Read configuration from environment
    let domain_str = std::env::var("NEXT_PUBLIC_DAPP_URL")
        .expect("Missing env var NEXT_PUBLIC_DAPP_URL");
    let domain_url: Url = Url::parse(&domain_str)?;

    let did_str = std::env::var("MANUFACTURER_DID")
        .expect("Missing env var MANUFACTURER_DID");
    let did = IotaDID::from_str(&did_str)
        .expect("Error: IotaDID::from_str");

    // Setup IOTA client and resolver
    let identity_client = get_client(MANUFACTURER_ALIAS)
        .await
        .expect("Error: get_client");

    let mut resolver: Resolver<IotaDocument> = Resolver::new();
    resolver.attach_iota_handler((*identity_client).clone());

    // Resolve the DID document
    let did_document: IotaDocument = resolver.resolve(&did).await?;

    // Extract linked domain services from DID document
    let linked_domain_services: Vec<LinkedDomainService> = did_document
        .service()
        .iter()
        .cloned()
        .filter_map(|service| LinkedDomainService::try_from(service).ok())
        .collect();

    assert_eq!(linked_domain_services.len(), 1);

    // Get domain from the linked domain service
    let domains: &[Url] = linked_domain_services
        .first()
        .ok_or_else(|| anyhow::anyhow!("expected a domain"))?
        .domains();
    let domain_from_did: Url = domains
        .first()
        .ok_or_else(|| anyhow::anyhow!("expected a domain"))?
        .clone();

    // Fetch DID configuration resource from the domain
    let configuration_resource = DomainLinkageConfiguration::fetch_configuration(domain_url.clone()).await?;

    // Validate the domain linkage
    let validation_result: Result<(), DomainLinkageValidationError> =
        JwtDomainLinkageValidator::with_signature_verifier(EcDSAJwsVerifier::default())
            .validate_linkage(
                &did_document,
                &configuration_resource,
                &domain_from_did,
                &JwtCredentialValidationOptions::default(),
            );

    if validation_result.is_ok() {
        println!("✅ Successful domain linkage validation");
    } else {
        println!("❌ Unsuccessful domain linkage validation");
        println!("{:?}", validation_result);
        println!("{}", did_document);
    }

    Ok(())
}
```

## Complete Domain Linkage Setup

Based on the official IOTA Identity documentation, here's how to set up domain linkage from scratch:

### 1. Create Linked Domain Service

First, add a `LinkedDomainService` to your DID document:

```typescript
import {
    DIDUrl,
    IotaDocument,
    LinkedDomainService,
} from "@iota/identity-wasm/node";

// Assuming you have a published DID document
let serviceUrl: DIDUrl = did.clone().join("#domain_linkage");
let linkedDomainService: LinkedDomainService = new LinkedDomainService({
    id: serviceUrl,
    domains: ["https://foo.example.com", "https://bar.example.com"],
});

// Add service to DID document
document.insertService(linkedDomainService.toService());

// Update the DID document on-chain
const controllerToken = await identity.getControllerToken(identityClient);
await identity.updateDidDocument(document, controllerToken!).buildAndExecute(identityClient);
```

### 2. Create DID Configuration Resource

Create a Domain Linkage Credential and host it on your domain:

```typescript
import {
    Credential,
    DomainLinkageConfiguration,
    Duration,
    JwsSignatureOptions,
    Timestamp,
} from "@iota/identity-wasm/node";

// Create the Domain Linkage Credential
let domainLinkageCredential: Credential = Credential.createDomainLinkageCredential({
    issuer: document.id(),
    origin: "https://foo.example.com",
    expirationDate: Timestamp.nowUTC().checkedAdd(Duration.weeks(10))!,
});

// Sign the credential
const credentialJwt = await document.createCredentialJwt(
    storage,
    vmFragment,
    domainLinkageCredential,
    new JwsSignatureOptions(),
);

// Create the DID Configuration Resource
let configurationResource: DomainLinkageConfiguration = new DomainLinkageConfiguration([credentialJwt]);

// Host this at https://foo.example.com/.well-known/did-configuration.json
console.log("Configuration Resource:", JSON.stringify(configurationResource.toJSON(), null, 2));
```

### 3. Verification Process

Domain linkage verification can start from either direction:

#### Case 1: Starting from Domain
- Fetch `/.well-known/did-configuration.json`
- Extract issuer DIDs from the configuration
- Resolve the DID documents
- Validate the Domain Linkage Credential

#### Case 2: Starting from DID
- Resolve the DID document
- Extract linked domain services
- Fetch the DID configuration from each domain
- Validate the linkage

## Verification Flows

### Bidirectional Verification
For complete trust, both directions should be verified:

1. **Domain → DID**: Verify that the domain's DID configuration points to the expected DID
2. **DID → Domain**: Verify that the DID document's linked domain service includes the expected domain

### Error Handling
Common verification failures include:
- Missing or invalid DID configuration file
- Expired Domain Linkage Credentials
- Signature verification failures
- Mismatched domains between DID document and configuration

## Use Cases

### Web Application Authentication
- Users authenticate with their DID
- Application verifies domain linkage to ensure DID authenticity
- Enables trusted interactions without traditional PKI

### Decentralized Identity Verification
- Organizations prove domain ownership through DIDs
- Enables verifiable business credentials
- Supports supply chain and audit trail verification

### Cross-Platform Identity
- Link social media profiles to DIDs
- Verify website ownership for reputation systems
- Enable seamless identity portability

## Security Considerations

### Certificate Management
- Domain Linkage Credentials should have reasonable expiration times
- Regular rotation of signing keys is recommended
- Monitor for unauthorized changes to DID configuration files

### Verification Best Practices
- Always verify both directions (bidirectional linkage)
- Validate credential expiration dates
- Check signature integrity using proper verifiers
- Implement proper error handling for network failures

### Common Pitfalls
- Not verifying credential expiration
- Accepting unidirectional linkage as sufficient
- Improper signature verification
- Ignoring network and resolver errors

## Additional Resources

- **[Official Domain Linkage Example](https://github.com/iotaledger/identity/blob/main/bindings/wasm/identity_wasm/examples/src/1_advanced/7_domain_linkage.ts)** - Complete TypeScript implementation
- **[DID Configuration Specification](https://identity.foundation/.well-known/resources/did-configuration/)** - W3C specification for domain linkage
- **[IOTA Identity Documentation](https://docs.iota.org/developer/iota-identity/)** - Comprehensive identity framework documentation