#!/bin/bash
# =============================================================================
# 1-setup.sh — Generate service account + gas station account, update .env
# =============================================================================
# Prerequisites:
#   - iota CLI installed (https://docs.iota.org/developer/getting-started/install-iota)
#   - npm install (already run, or script will install)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"
TIMESTAMP=$(date +%s)

# --- Helpers ---

update_env() {
  local key="$1" value="$2"
  if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
    sed -i.bak "s|^${key}=.*|${key}=${value}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# --- Preflight ---

echo "=== IOTA Gas Station Setup ==="
echo ""

if ! command -v iota &>/dev/null; then
  echo "ERROR: iota CLI not found. Install from https://docs.iota.org/developer/getting-started/install-iota"
  exit 1
fi
echo "[OK] iota CLI found"

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq not found. Install with: brew install jq"
  exit 1
fi
echo "[OK] jq found"

if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
  echo ""
  echo "Installing npm dependencies..."
  npm --prefix "$SCRIPT_DIR" install
fi
echo "[OK] npm dependencies"

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "[OK] Created .env from .env.example"
else
  echo "[OK] .env exists"
fi

# Fix broken wallet state
IOTA_CLIENT_CONFIG="${HOME}/.iota/iota_config/client.yaml"
if [ -f "$IOTA_CLIENT_CONFIG" ]; then
  if ! iota client active-address &>/dev/null; then
    echo ""
    echo "[FIX] Wallet state broken. Removing stale active_address..."
    sed -i.bak '/^active_address:/d' "$IOTA_CLIENT_CONFIG" && rm -f "${IOTA_CLIENT_CONFIG}.bak"
  fi
fi

echo ""
echo "Switching to testnet..."
iota client switch --env testnet 2>/dev/null || \
  iota client new-env --alias testnet --rpc https://api.testnet.iota.cafe 2>/dev/null || true

# GAS_STATION_AUTH
AUTH_TOKEN=$(openssl rand -hex 16)
update_env "GAS_STATION_AUTH" "$AUTH_TOKEN"
echo "[OK] GAS_STATION_AUTH: $AUTH_TOKEN"

# =============================================================================
# SERVICE ACCOUNT (calls smart contracts, Gas Station pays gas)
# =============================================================================
SA_ALIAS="service-account-${TIMESTAMP}"

echo ""
echo "==========================================="
echo "  Creating Service Account (alias: $SA_ALIAS)"
echo "==========================================="
echo ""

# Try JSON first (structured output with mnemonic)
SA_JSON=$(iota client new-address --alias "$SA_ALIAS" --json 2>&1) || true
SA_ADDRESS=$(echo "$SA_JSON" | jq -r '.address // empty' 2>/dev/null)
SA_MNEMONIC=$(echo "$SA_JSON" | jq -r '.recoveryPhrase // empty' 2>/dev/null)

# Fallback to text output
if [ -z "$SA_ADDRESS" ]; then
  echo "JSON output not available, trying text..."
  SA_TEXT=$(iota client new-address --alias "${SA_ALIAS}-txt" 2>&1) || true
  echo "$SA_TEXT"
  SA_ADDRESS=$(echo "$SA_TEXT" | grep -oE '0x[a-fA-F0-9]{64}' | head -1)
fi

if [ -z "$SA_ADDRESS" ]; then
  echo "ERROR: Could not create service account."
  echo "JSON output was: $SA_JSON"
  exit 1
fi
echo "Service account address: $SA_ADDRESS"
update_env "SERVICE_ACCOUNT_ADDRESS" "$SA_ADDRESS"
echo "[OK] Wrote SERVICE_ACCOUNT_ADDRESS to .env"

# Derive keys from mnemonic
if [ -n "$SA_MNEMONIC" ] && [ "$SA_MNEMONIC" != "null" ] && [ ${#SA_MNEMONIC} -gt 20 ]; then
  echo "Deriving private key from mnemonic..."
  SA_KEYS=$(npx tsx "$SCRIPT_DIR/src/derive-key.ts" "$SA_MNEMONIC" 2>&1)
  SA_PRIVKEY=$(echo "$SA_KEYS" | jq -r '.privateKeyBech32 // empty' 2>/dev/null)

  if [ -n "$SA_PRIVKEY" ] && [ "$SA_PRIVKEY" != "null" ]; then
    echo "Private key: ${SA_PRIVKEY:0:25}..."
    update_env "SERVICE_ACCOUNT_PRIVATE_KEY" "$SA_PRIVKEY"
    echo "[OK] Wrote SERVICE_ACCOUNT_PRIVATE_KEY to .env"
  else
    echo "WARNING: derive-key output: $SA_KEYS"
    echo "Export manually: iota keytool export --key-identity $SA_ADDRESS"
  fi
else
  echo "WARNING: No mnemonic in output. Export key manually:"
  echo "  iota keytool export --key-identity $SA_ADDRESS"
fi

echo ""
echo "[OK] Service account ready (no IOTA needed, Gas Station pays gas)"

# =============================================================================
# GAS STATION ACCOUNT (owns gas coins, co-signs sponsored transactions)
# =============================================================================
GS_ALIAS="gas-station-${TIMESTAMP}"

echo ""
echo "==========================================="
echo "  Creating Gas Station Account (alias: $GS_ALIAS)"
echo "==========================================="
echo ""

# Try JSON first (structured output with mnemonic)
GS_JSON=$(iota client new-address --alias "$GS_ALIAS" --json 2>&1) || true
GS_ADDRESS=$(echo "$GS_JSON" | jq -r '.address // empty' 2>/dev/null)
GS_MNEMONIC=$(echo "$GS_JSON" | jq -r '.recoveryPhrase // empty' 2>/dev/null)

# Fallback to text output
if [ -z "$GS_ADDRESS" ]; then
  echo "JSON output not available, trying text..."
  GS_TEXT=$(iota client new-address --alias "${GS_ALIAS}-txt" 2>&1) || true
  echo "$GS_TEXT"
  GS_ADDRESS=$(echo "$GS_TEXT" | grep -oE '0x[a-fA-F0-9]{64}' | head -1)
fi

if [ -z "$GS_ADDRESS" ]; then
  echo "ERROR: Could not create gas station account."
  echo "JSON output was: $GS_JSON"
  exit 1
fi
echo "Gas station address: $GS_ADDRESS"
update_env "GAS_STATION_ADDRESS" "$GS_ADDRESS"
echo "[OK] Wrote GAS_STATION_ADDRESS to .env"

# Derive keys from mnemonic
if [ -n "$GS_MNEMONIC" ] && [ "$GS_MNEMONIC" != "null" ] && [ ${#GS_MNEMONIC} -gt 20 ]; then
  echo "Deriving private key from mnemonic..."
  GS_KEYS=$(npx tsx "$SCRIPT_DIR/src/derive-key.ts" "$GS_MNEMONIC" 2>&1)
  GS_PRIVKEY_B64=$(echo "$GS_KEYS" | jq -r '.privateKeyBase64 // empty' 2>/dev/null)

  if [ -n "$GS_PRIVKEY_B64" ] && [ "$GS_PRIVKEY_B64" != "null" ]; then
    echo "Private key (base64): ${GS_PRIVKEY_B64:0:20}..."
    update_env "GAS_STATION_PRIVATE_KEY" "$GS_PRIVKEY_B64"
    echo "[OK] Wrote GAS_STATION_PRIVATE_KEY to .env"
  else
    echo "WARNING: derive-key output: $GS_KEYS"
    echo "Export manually: iota keytool export --key-identity $GS_ADDRESS"
  fi
else
  echo "WARNING: No mnemonic in output. Export key manually:"
  echo "  iota keytool export --key-identity $GS_ADDRESS"
fi

echo ""
echo "Switching to gas station account for faucet..."
iota client switch --address "$GS_ADDRESS" 2>/dev/null || true

echo "Requesting faucet (gas station needs IOTA to sponsor transactions)..."
iota client faucet 2>&1 || echo "WARNING: Faucet request failed"
echo "Waiting for funds (5s)..."
sleep 5

echo ""
echo "Gas station balance:"
iota client balance 2>/dev/null || echo "(could not fetch balance)"

# Stay on gas station account (it has IOTA for the deploy step)

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "==========================================="
echo "  Setup Complete"
echo "==========================================="
echo ""
echo "  Service Account:   $SA_ADDRESS  (alias: $SA_ALIAS)"
echo "  Gas Station:       $GS_ADDRESS  (alias: $GS_ALIAS)"
echo "  Auth Token:        $AUTH_TOKEN"
echo ""
echo "  .env updated automatically."
echo ""
echo "  Next step: bash 2-deploy.sh"
echo "==========================================="
