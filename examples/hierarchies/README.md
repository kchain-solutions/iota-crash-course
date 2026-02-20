# IOTA Hierarchies Examples

TypeScript examples for the @iota/hierarchies package.

## Prerequisites

This project has been tested with **IOTA CLI version v1.17.1-rc**.

### 1. Install/Update IOTA CLI

To install or update the IOTA CLI to the correct version:

```bash
cargo install --locked --git https://github.com/iotaledger/iota.git --tag v1.17.1-rc --features tracing iota
```

Verify the installation:

```bash
iota --version
# Should output: iota 1.17.1-rc or similar
```

### 2. Configure IOTA Client Environment

The IOTA client must be configured to connect to the correct network. You can add network environments using:

```bash
iota client new-env --alias <name> --rpc <url>
```

#### Example Configurations:

**Local Network:**
```bash
iota client new-env --alias local --rpc http://127.0.0.1:9000
iota client switch --env local
```

Configuration details:
```yaml
- alias: local
  rpc: "http://127.0.0.1:9000"
  graphql: ~
  ws: ~
  basic_auth: ~
  faucet: "http://127.0.0.1:9123/gas"
```

**Testnet:**
```bash
iota client new-env --alias testnet --rpc https://api.testnet.iota.cafe:443
iota client switch --env testnet
```

Configuration details:
```yaml
- alias: testnet
  rpc: "https://api.testnet.iota.cafe:443"
  graphql: ~
  ws: ~
  basic_auth: ~
  faucet: "https://faucet.testnet.iota.cafe/gas"
```

Verify your active environment:

```bash
iota client active-env
iota client envs
```

## Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment Variables

Copy the example environment file and edit it:

```bash
cp .env.example .env
```

Edit `.env` and set your configuration:

```env
IOTA_HIERARCHIES_PKG_ID=<your_package_id>
NETWORK_URL=http://127.0.0.1:9000
NETWORK_NAME_FAUCET=localnet
```

### 3. Deploy Hierarchies Move Package (Required for Local Testing)

Before running the examples locally, you need to deploy the Hierarchies Move package to get the `IOTA_HIERARCHIES_PKG_ID`.

Use the official deployment script from the hierarchies repository:

```bash
# Clone the hierarchies repository
git clone https://github.com/iotaledger/hierarchies.git
cd hierarchies/hierarchies-move

# Run the publish script
./scripts/publish_hierarchies.sh
```

The script is available at: https://github.com/iotaledger/hierarchies/blob/main/hierarchies-move/scripts/publish_hierarchies.sh

After deployment, copy the package ID from the script output and paste it into your `.env` file as `IOTA_HIERARCHIES_PKG_ID`.

**Note**: For testnet or mainnet, adjust the `NETWORK_URL` and `NETWORK_NAME_FAUCET` in your `.env` file accordingly:

- **Testnet**: 
  ```env
  NETWORK_URL=https://api.testnet.iota.cafe
  NETWORK_NAME_FAUCET=testnet
  ```

- **Mainnet**: 
  ```env
  NETWORK_URL=https://api.mainnet.iota.cafe
  NETWORK_NAME_FAUCET=mainnet
  ```

## Available Examples

### 1. iota_add_property.ts (Reference Implementation)
Working example showing how to add properties to a federation.

```bash
npm run start:add-property
```

### 2. example_to_be_fixed.ts (Fixed Example)
Example demonstrating how to validate accreditation properties.

```bash
npm run start:example
```

## Issue Fixed

**Original Error**: The `example_to_be_fixed.ts` file attempted to validate a property with value "Invalid Value" which was not among the allowed values (allowedValues contained only "Hello").

**Applied Corrections**:
1. Fixed import path from `../../util` to `./utils`
2. Changed `validationValue` from `PropertyValue.newText("Invalid Value")` to `PropertyValue.newText("Hello")`
3. Removed extra space in Map declaration: `Map<PropertyName, PropertyValue>` instead of `Map < PropertyName, PropertyValue>`

## Available Scripts

- `npm run build` - Compile TypeScript
- `npm run check` - Check TypeScript errors without compilation
- `npm run start:add-property` - Run add property example
- `npm run start:example` - Run validate properties example

## Troubleshooting

### Error: "Dependent package not found on-chain"

This means the `IOTA_HIERARCHIES_PKG_ID` in your `.env` file doesn't exist on the network you're connected to.

**Solution**: Deploy the hierarchies package to your local network first (requires IOTA CLI v1.17.1-rc):

```bash
# Make sure you have the correct IOTA CLI version
iota --version  # Should be v1.17.1-rc

# In a separate terminal, start IOTA local network
iota start --force-regenesis

# Clone and deploy hierarchies
git clone https://github.com/iotaledger/hierarchies.git
cd hierarchies/hierarchies-move
./scripts/publish_hierarchies.sh

# Copy the output package ID to your .env file
```

### No console output

Make sure:
1. Your local IOTA network is running (`iota start`)
2. The `IOTA_HIERARCHIES_PKG_ID` in `.env` is correct
3. The faucet is accessible (check `NETWORK_NAME_FAUCET`)

## Project Structure

```
.
├── .env.example          # Example environment configuration
├── .env                  # Your environment configuration (not committed)
├── .gitignore           # Git ignore file
├── package.json         # NPM dependencies and scripts
├── tsconfig.json        # TypeScript configuration
├── README.md            # This file
└── src/
    ├── utils.ts                  # Utility functions and client setup
    ├── iota_add_property.ts      # Reference implementation
    └── example_to_be_fixed.ts    # Fixed validation example
```
