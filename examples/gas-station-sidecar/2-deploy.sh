#!/bin/bash
# =============================================================================
# 2-deploy.sh — Deploy the Hello World contract and update .env + configs
# =============================================================================
# Prerequisites:
#   - Run 1-setup.sh first
#   - Gas station account has testnet IOTA (funded by 1-setup.sh)
#   - jq installed
#
# This script:
#   1. Switches to the gas station account (which has IOTA) for deployment
#   2. Publishes the Move package in contract/
#   3. Writes PACKAGE_ID to .env
#   4. Updates gas-station-config.production.yaml with real addresses
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTRACT_DIR="$SCRIPT_DIR/contract"
ENV_FILE="$SCRIPT_DIR/.env"
CONFIG_FILE="$SCRIPT_DIR/gas-station-config.production.yaml"

# --- Helpers ---

update_env() {
  local key="$1" value="$2"
  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i.bak "s|^${key}=.*|${key}=${value}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# --- Check prerequisites ---

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env not found. Run 1-setup.sh first."
  exit 1
fi

# Load addresses from .env (written by 1-setup.sh)
SERVICE_ACCOUNT=$(grep "^SERVICE_ACCOUNT_ADDRESS=" "$ENV_FILE" | cut -d= -f2)
GAS_STATION_ACCOUNT=$(grep "^GAS_STATION_ADDRESS=" "$ENV_FILE" | cut -d= -f2)

if [ -z "$SERVICE_ACCOUNT" ]; then
  echo "ERROR: SERVICE_ACCOUNT_ADDRESS not found in .env. Run 1-setup.sh first."
  exit 1
fi

if [ -z "$GAS_STATION_ACCOUNT" ]; then
  echo "ERROR: GAS_STATION_ADDRESS not found in .env. Run 1-setup.sh first."
  exit 1
fi

# Switch to gas station account (it has IOTA for gas)
echo "Switching to gas station account for deployment..."
iota client switch --address "$GAS_STATION_ACCOUNT" 2>/dev/null || true

echo ""
echo "=== Deploy Hello World Contract ==="
echo ""
echo "  Service Account:     $SERVICE_ACCOUNT"
echo "  Gas Station Account: $GAS_STATION_ACCOUNT  (deploying from here)"
echo "  Contract:            $CONTRACT_DIR"
echo ""

# --- Publish ---

echo "Publishing Move package..."
RAW_OUTPUT=$(iota client publish \
  --with-unpublished-dependencies \
  --silence-warnings \
  --json \
  --gas-budget 500000000 \
  "$CONTRACT_DIR" 2>&1)

# The CLI mixes build messages (warnings, "INCLUDING DEPENDENCY", etc.) with
# the JSON output. Extract only the JSON block (from first '{' to last '}').
JSON_OUTPUT=$(echo "$RAW_OUTPUT" | awk '/^\{/{found=1} found{print}')

# Extract package ID
PACKAGE_ID=$(echo "$JSON_OUTPUT" | jq -r \
  '.objectChanges[] | select(.type == "published") | .packageId' 2>/dev/null)

if [ -z "$PACKAGE_ID" ] || [ "$PACKAGE_ID" = "null" ]; then
  echo "ERROR: Could not extract package ID."
  echo ""
  echo "Raw output:"
  echo "$RAW_OUTPUT"
  exit 1
fi

TX_DIGEST=$(echo "$JSON_OUTPUT" | jq -r '.digest' 2>/dev/null)

# --- Update .env ---

update_env "PACKAGE_ID" "$PACKAGE_ID"
echo "[OK] Wrote PACKAGE_ID to .env"

# --- Update gas-station-config.production.yaml ---

if [ -f "$CONFIG_FILE" ]; then
  sed -i.bak "s|SERVICE_ACCOUNT_PLACEHOLDER|$SERVICE_ACCOUNT|g" "$CONFIG_FILE" && rm -f "${CONFIG_FILE}.bak"
  sed -i.bak "s|PACKAGE_ADDRESS_PLACEHOLDER|$PACKAGE_ID|g" "$CONFIG_FILE" && rm -f "${CONFIG_FILE}.bak"
  echo "[OK] Updated gas-station-config.production.yaml with real addresses"
fi

# --- Summary ---

echo ""
echo "==========================================="
echo "  Deploy Complete"
echo "==========================================="
echo ""
echo "  Service Account: $SERVICE_ACCOUNT"
echo "  Package ID:      $PACKAGE_ID"
echo "  Transaction:     https://explorer.rebased.iota.org/txblock/$TX_DIGEST?network=testnet"
echo ""
echo "  .env and gas-station-config.production.yaml updated automatically."
echo ""
echo "Next steps:"
echo "  1. docker compose up -d"
echo "  2. npx tsx src/sponsored-call.ts"
echo "==========================================="
