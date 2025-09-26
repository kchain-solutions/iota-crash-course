#!/bin/bash

# Script to create a new product on the audit trail

# Determine the correct .env file path (look in the example directory where this is called from)
if [ -f ".env" ]; then
    source .env
elif [ -f "dummy-audit-trails/.env" ]; then
    source dummy-audit-trails/.env
else
    echo "⚠️  .env file not found. Please create one in the example directory or current working directory."
    echo "💡 Copy .env.example to .env and fill in your values"
    exit 1
fi

# Check required environment variables
if [ -z "$AUDIT_TRAIL_PKG" ]; then
  echo "❌ Error: AUDIT_TRAIL_PKG is not set"
  exit 1
fi


echo "✅ Using AUDIT_TRAIL_PKG: $AUDIT_TRAIL_PKG"

# Product details
PRODUCT_NAME="Pro 48V Battery"
MANUFACTURER="EcoBike"
SERIAL_NUMBER="EB-48V-2024-001337"
IMAGE_URL="https://i.imgur.com/AdTJC8Y.png"
GAS_BUDGET=500000000
CLOCK_ID=0x6

echo ""
echo "🔨 Creating product: $PRODUCT_NAME"
echo "📦 Manufacturer: $MANUFACTURER"
echo "🔢 Serial Number: $SERIAL_NUMBER"
echo ""

# Execute the transaction and capture output
iota client call \
  --package "$AUDIT_TRAIL_PKG" \
  --module "app" \
  --function "new_product" \
  --args \
    "$PRODUCT_NAME" \
    "$MANUFACTURER" \
    "$SERIAL_NUMBER" \
    "$IMAGE_URL" \
    "$CLOCK_ID" \
  --gas-budget "$GAS_BUDGET"

