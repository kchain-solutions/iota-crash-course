# IOTA Gas Station: Setup and Security Guide

## 1. How Gas Sponsoring Works

The Gas Station sponsors transactions on behalf of your service account. Your service account does **not** need to hold any IOTA. The Gas Station owns a pool of gas coins and co-signs each transaction, covering the gas cost transparently.

Your application submits transactions through the Gas Station API. The Gas Station attaches gas, co-signs, and forwards the transaction to the IOTA network. From the service account's perspective, transactions are effectively gasless.

## 2. Funding the Gas Station

The Gas Station itself needs IOTA to operate. The setup process is straightforward:

1. Deploy the Gas Station (see `docker-compose.yaml` in this package).
2. Retrieve the Gas Station's **public address** from the signer configuration.
3. Share this address with your finance team. They transfer IOTA to that address.
4. The Gas Station automatically splits the balance into a pool of smaller gas coins for parallel transaction processing.

Here is an example of a funded, operational Gas Station on mainnet:
https://explorer.iota.org/address/0x5b45067591bd332447ec0ff190594060bf461c5619cf3ed933bd13b91d2b6bf3?network=mainnet

**Important:** Monitor the Gas Station balance continuously. If the balance runs out, all sponsored transactions will fail. Set up alerts based on the `daily-gas-usage-cap` in your configuration and the current balance. The Prometheus metrics endpoint (port 9184) can be used for this purpose.

## 3. Access Control

The Gas Station supports fine-grained access control. In the configuration files included in this package (`gas-station-config.yaml` and `gas-station-config.production.yaml`), we use a **deny-all** policy with explicit allow rules.

Each rule can restrict three dimensions simultaneously:

| Parameter | Purpose |
|-----------|---------|
| `sender-address` | Which account is allowed to submit transactions |
| `move-call-package-address` | Which smart contract (Move package) the transaction can interact with |
| `transaction-gas-budget` | Maximum gas budget per transaction |

```yaml
access-controller:
  access-policy: deny-all
  rules:
    - sender-address:
        - "SERVICE_ACCOUNT_PLACEHOLDER"
      move-call-package-address:
        - "PACKAGE_ADDRESS_PLACEHOLDER"
      transaction-gas-budget: "<=1000000000"
      action: allow
```

Any transaction that does not match all three conditions is rejected. This means even if an attacker obtains access to the Gas Station endpoint, they cannot use it to call arbitrary contracts or drain gas from unauthorized accounts.

Rules are evaluated **sequentially with first-match evaluation**. Once a matching rule applies, subsequent rules are skipped. If no rules match, the default policy applies (`deny-all` blocks, `allow-all` permits).

**Important:** The `gas-station-config.production.yaml` file contains placeholder values (`SERVICE_ACCOUNT_PLACEHOLDER`, `PACKAGE_ADDRESS_PLACEHOLDER`). The `2-deploy.sh` script replaces them automatically with the real addresses from `.env`. If you skip the deploy script or need to update the config manually, replace the placeholders with the `SERVICE_ACCOUNT_ADDRESS` and `PACKAGE_ID` values from your `.env` file. The Gas Station will fail to start if these placeholders are not replaced with valid IOTA addresses.

### Gas Usage Limiting (Rate Limiting per Sender)

Beyond static rules, the access controller supports **gas usage limits** with time windows. The `gas-usage` field acts as a matcher (not an action) and requires Redis for cluster-wide counter synchronization.

```yaml
access-controller:
  access-policy: deny-all
  rules:
    - sender-address: "*"
      gas-usage:
        value: "<1000000"
        window: 1day
        count-by: [ sender-address ]
      action: allow
```

The `count-by: [ sender-address ]` ensures each sender's gas usage is tracked and limited separately. This prevents a single account from consuming the entire daily gas budget.

### Hooks: External Filtering

When standard predicates are not sufficient, hooks delegate the decision to an external HTTP service. This enables complex authorization logic (checking external databases, third-party integrations, custom business rules).

```yaml
rules:
  - action:
      url: http://my-auth-service.com/check
      headers:
        Authorization:
          - Bearer TOKEN
```

The hook must respond with:

```json
{
  "decision": "allow | deny | noDecision"
}
```

A `noDecision` response causes the access controller to continue evaluating subsequent rules.

### Rego Expressions (v0.2+)

From version 0.2 onward, the access controller supports [Rego](https://www.openpolicyagent.org/docs/latest/policy-language/) (Open Policy Agent language) for complex filtering scenarios. Rego scripts are compiled at Gas Station startup. The source can be loaded from:

- `file` (local filesystem)
- `redis` (Redis storage)
- `http` (remote URL)

### Dynamic Rule Reloading

Access controller rules can be reloaded at runtime without restarting the Gas Station:

```bash
curl -X GET http://localhost:9527/v1/reload_access_controller \
  -H "Authorization: Bearer YOUR_TOKEN"
```

This is useful for updating rules in production without downtime (for example, adding a new service account).

For the full access control reference, see [IOTA Gas Station Features](https://docs.iota.org/operator/gas-station/architecture/features).

## 4. Private Key Management

The Gas Station needs a private key to sign sponsored transactions. How you manage this key depends on your security requirements.

### Option A: Local Key in Configuration (Development Only)

The simplest approach. The private key is stored as a base64 string directly in the configuration file.

```yaml
signer-config:
  local:
    keypair: "<BASE64_ENCODED_ED25519_PRIVATE_KEY>"
```

To convert an existing private key:

```bash
iota keytool convert <PRIVATE_KEY_HEX_OR_BASE64>
```

**This approach is acceptable for development and testing.** Do not use it in production, as the key is visible in the configuration file and potentially in version control, container images, or deployment logs.

### Option B: KMS Sidecar (Production)

In production, the Gas Station delegates signing to a **sidecar service** that connects to a Key Management System (AWS KMS, HashiCorp Vault, or similar).

```yaml
signer-config:
  sidecar:
    sidecar-url: https://kms-sidecar:8001
```

This package includes a local sidecar implementation in the `sidecar/` directory. The sidecar is generated as a reference and has **not been tested in production**. It is provided to illustrate the architecture and the API contract between the Gas Station and the signing service. If you need a specific implementation for AWS KMS or HashiCorp Vault, we can provide support.

## 5. Key Security: Runtime vs. Enclave

There are two fundamentally different approaches to protecting the signing key at runtime.

### Environment Variables (Runtime Loading)

The private key is injected as an environment variable at container startup. The key exists in memory during the process lifetime but is not persisted on disk inside the container.

```bash
docker run -e GAS_STATION_PRIVATE_KEY="base64..." gas-station-kms
```

This is the approach used in the local sidecar included in this package. The key is loaded once at startup and held in process memory. It is not written to disk, but it is technically accessible to anyone with access to the container runtime or a memory dump.

### Hardware Security Module / Enclave (Key Never Exposed)

With a KMS-backed sidecar (AWS KMS, Azure Key Vault, HashiCorp Vault with HSM backend), the private key **never leaves the secure enclave**. The signing operation happens inside the KMS. The sidecar sends a digest to the KMS, and the KMS returns the signature. At no point during the signing process is the raw private key exposed to the application, the container, or the host.

This is the recommended approach for production deployments where the Gas Station manages significant funds.

### Summary

| Approach | Key Exposure | Use Case |
|----------|-------------|----------|
| Config file (`local`) | Key visible in YAML | Development, testing |
| Environment variable | Key in process memory at runtime | Staging, low-value deployments |
| KMS / HSM enclave | Key never leaves secure hardware | Production, high-value deployments |

---

## 6. Monitoring and Observability

The Gas Station exposes a Prometheus metrics endpoint on port 9184 (configurable via `metrics-port`). It tracks reservation counts, execution success/failure rates, latency histograms, and coin pool usage. You can also enable detailed transaction logging with `TRANSACTIONS_LOGGING=true` for integration with Elasticsearch, Splunk, or Datadog.

For the full list of metrics, recommended Grafana queries, and observability architecture, see the official documentation:

- **Features (metrics, logging, analytics):** https://docs.iota.org/operator/gas-station/architecture/features

---

## Official Documentation

For the full reference (REST API, Rust SDK, advanced access control, Rego policy language), see:

- **Architecture and Features:** https://docs.iota.org/operator/gas-station/architecture/features
- **GitHub Repository:** https://github.com/iotaledger/gas-station

---

## Files in This Package

| File | Description |
|------|-------------|
| `README.md` | Quick start: deploy and call a Hello World contract via Gas Station |
| `.env.example` | All environment variables (Gas Station + service account + contract) |
| `1-setup.sh` | Generate service account + gas station account, auto-populate `.env` |
| `2-deploy.sh` | Deploy the Hello World contract |
| `src/sponsored-call.ts` | Call the contract via Gas Station (sponsored transaction) |
| `contract/` | Move package: `hello::create()` mints a HelloObject |
| `gas-station-config.yaml` | Development config (local keypair, no sidecar) |
| `gas-station-config.production.yaml` | Production config (KMS sidecar) |
| `docker-compose.yaml` | Full stack: Redis + Local Sidecar + Gas Station |
| `docker-compose.aws.yaml` | Override: replaces local sidecar with AWS KMS |
| `sidecar/` | Local signing sidecar (reference implementation, not production-tested) |
| `package.json` | Node.js dependencies for the TypeScript example |

## Need Help?

If you need assistance with a specific KMS integration, access control tuning, or monitoring setup, contact us
