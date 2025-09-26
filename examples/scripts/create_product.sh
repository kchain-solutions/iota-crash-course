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

if [ -z "$CLOCK_ID" ]; then
  echo "❌ Error: CLOCK_ID is not set"
  exit 1
fi

echo "✅ Using AUDIT_TRAIL_PKG: $AUDIT_TRAIL_PKG"
echo "✅ Using CLOCK_ID: $CLOCK_ID"

# Product details
PRODUCT_NAME="Pro 48V Battery"
MANUFACTURER="EcoBike"
SERIAL_NUMBER="EB-48V-2024-001337"
IMAGE_URL="https://i.imgur.com/AdTJC8Y.png"
GAS_BUDGET=500000000

echo ""
echo "🔨 Creating product: $PRODUCT_NAME"
echo "📦 Manufacturer: $MANUFACTURER"
echo "🔢 Serial Number: $SERIAL_NUMBER"
echo ""

# Execute the transaction and capture output
RESULT=$(iota client call \
  --package "$AUDIT_TRAIL_PKG" \
  --module "app" \
  --function "new_product" \
  --args \
    "$PRODUCT_NAME" \
    "$MANUFACTURER" \
    "$SERIAL_NUMBER" \
    "$IMAGE_URL" \
    "$CLOCK_ID" \
  --gas-budget "$GAS_BUDGET" 2>&1)

echo "📋 Transaction Result:"
echo "$RESULT"

# Try to extract the product object ID from the result
PRODUCT_ID=$(echo "$RESULT" | grep -o "0x[a-fA-F0-9]\{64\}" | head -1)

if [ ! -z "$PRODUCT_ID" ]; then
  echo ""
  echo "🎉 Product created successfully!"
  echo "🆔 Product ID: $PRODUCT_ID"
  echo ""
  echo "💡 To use this product in trail records, set:"
  echo "export PRODUCT_ID=$PRODUCT_ID"
else
  echo ""
  echo "⚠️  Could not extract Product ID from transaction result"
  echo "Please check the transaction output above for the created object ID"
fi