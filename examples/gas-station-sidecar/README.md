# IOTA Gas Station: Hello World Example

A complete, ready-to-run example. Deploy a Move contract on IOTA testnet and call it through a Gas Station with a local sidecar. The service account does not need IOTA to call the contract.

For architecture and security details, see [GAS-STATION-GUIDE.md](GAS-STATION-GUIDE.md).

## Prerequisites

- [IOTA CLI](https://docs.iota.org/developer/getting-started/install-iota) installed
- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- Node.js 20+
- jq (`brew install jq` / `apt install jq`)

## Quick Start

```bash
npm install
bash 1-setup.sh
bash 2-deploy.sh
# Verify that .env and gas-station-config.production.yaml
# contain real addresses (no PLACEHOLDERs). Then:
docker compose up -d
npx tsx src/sponsored-call.ts
```

Each script updates `.env` and `gas-station-config.production.yaml` automatically. Before starting Docker, verify that `gas-station-config.production.yaml` contains the real `SERVICE_ACCOUNT_ADDRESS` and `PACKAGE_ID` from `.env` (not placeholder values). The Gas Station will fail to start otherwise.

## Step by Step

### Step 1: Create Accounts

```bash
npm install
bash 1-setup.sh
```

This script does everything automatically:
- Creates `.env` from `.env.example`
- Creates a **service account** for calling smart contracts (no IOTA needed)
- Creates a **gas station account** that owns gas coins and funds it via faucet
- Generates a random `GAS_STATION_AUTH` bearer token
- Writes `SERVICE_ACCOUNT_PRIVATE_KEY`, `GAS_STATION_PRIVATE_KEY`, and `GAS_STATION_AUTH` to `.env`

### Step 2: Deploy the Contract

```bash
bash 2-deploy.sh
```

This script:
- Publishes the `contract/` Move package to testnet
- Writes `PACKAGE_ID` to `.env`
- Updates `gas-station-config.production.yaml` with the real service account address and package ID (replaces the placeholders)

### Step 3: Start the Gas Station

```bash
docker compose up -d
```

This starts three services:
- **Redis** (state backend)
- **KMS Sidecar** (local Ed25519 signing with gas station key)
- **Gas Station** (sponsored transaction service on port 9527)

Verify it's running:

```bash
docker compose logs gas-station
```

### Step 4: Call the Contract (Sponsored)

```bash
npx tsx src/sponsored-call.ts
```

Expected output:

```
=== Sponsored Hello World ===

Service Account: 0xabc...
Package:         0xdef...
Gas Station:     http://localhost:9527

Reserving gas from Gas Station...
Sponsor:         0x123...
Reservation:     1

Signing transaction...
Submitting to Gas Station...

Transaction successful!
Explorer: https://explorer.rebased.iota.org/txblock/DIGEST?network=testnet

Created objects:
  https://explorer.rebased.iota.org/object/OBJECT_ID?network=testnet
```

Open the explorer link. You will see a `HelloObject` with the "Hello World" message, owned by the service account.

The service account never held IOTA. The Gas Station paid the gas.

## What Happens Under the Hood

```
Service Account (no IOTA)       Gas Station               IOTA Testnet
       |                             |                          |
       |  POST /v1/reserve_gas       |                          |
       |---------------------------->|                          |
       |  { sponsor, gas_coins }     |                          |
       |<----------------------------|                          |
       |                             |                          |
       |  Build tx: hello::create    |                          |
       |  Set gasOwner = sponsor     |                          |
       |  Sign with service key      |                          |
       |                             |                          |
       |  POST /v1/execute_tx        |                          |
       |  { tx_bytes, user_sig }     |                          |
       |---------------------------->|                          |
       |                             |  Co-sign + submit tx     |
       |                             |------------------------->|
       |                             |  TransactionEffects      |
       |                             |<-------------------------|
       |  { effects }                |                          |
       |<----------------------------|                          |
```

## Files

| File | Description |
|------|-------------|
| `.env.example` | Environment variables template |
| `1-setup.sh` | Create service account + gas station account, auto-populate `.env` |
| `2-deploy.sh` | Deploy contract, auto-populate `.env` + config |
| `src/sponsored-call.ts` | Call the contract via Gas Station (sponsored) |
| `src/derive-key.ts` | Helper: derive keys from mnemonic |
| `contract/` | Move package: `hello::create()` mints a HelloObject |
| `gas-station-config.yaml` | Gas Station config (dev, local keypair) |
| `gas-station-config.production.yaml` | Gas Station config (sidecar) |
| `docker-compose.yaml` | Redis + Local Sidecar + Gas Station |
| `docker-compose.aws.yaml` | Override: AWS KMS sidecar |
| `sidecar/` | Local signing sidecar (reference implementation) |
| `GAS-STATION-GUIDE.md` | Architecture and security guide |

## Troubleshooting

**"Missing environment variable"** — Run `bash 1-setup.sh` and `bash 2-deploy.sh` first. They populate `.env` automatically.

**"Request failed with status code 401"** — `GAS_STATION_AUTH` in `.env` does not match the Gas Station container. Restart with `docker compose up -d` after running the setup scripts.

**"Request failed with status code 403"** — Service account address or Package ID not whitelisted. Run `bash 2-deploy.sh` again or check `gas-station-config.production.yaml`.

**"Insufficient gas"** — The gas station account is out of funds. Switch to the gas station address and run `iota client faucet`.

**"Connection refused on port 9527"** — Gas Station is not running. Check `docker compose logs gas-station`.

## Need Help?

Contact us at **valerio@kchain.solutions**.
