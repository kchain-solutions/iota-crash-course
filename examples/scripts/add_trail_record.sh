#!/bin/bash

# Script to add a trail record to an existing product

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

if [ -z "$PRODUCT_ID" ]; then
  echo "❌ Error: PRODUCT_ID is not set"
  echo "💡 Run create_product.sh first to create a product"
  exit 1
fi

if [ -z "$CLOCK_ID" ]; then
  echo "❌ Error: CLOCK_ID is not set"
  exit 1
fi

echo "✅ Using AUDIT_TRAIL_PKG: $AUDIT_TRAIL_PKG"
echo "✅ Using PRODUCT_ID: $PRODUCT_ID"
echo "✅ Using CLOCK_ID: $CLOCK_ID"

# Trail record details
ENTRY_DATA="Quality check passed - Battery tested at full capacity, all cells balanced, BMS functioning correctly. Ready for shipment."
GAS_BUDGET=500000000

echo ""
echo "📝 Adding trail record to product"
echo "💬 Entry Data: $ENTRY_DATA"
echo ""

# Execute the transaction and capture output
RESULT=$(iota client call \
  --package "$AUDIT_TRAIL_PKG" \
  --module "app" \
  --function "log_entry_data" \
  --args \
    "$PRODUCT_ID" \
    "$ENTRY_DATA" \
    "$CLOCK_ID" \
  --gas-budget "$GAS_BUDGET" 2>&1)

echo "📋 Transaction Result:"
echo "$RESULT"

# Try to extract the product entry object ID from the result
ENTRY_ID=$(echo "$RESULT" | grep -o "0x[a-fA-F0-9]\{64\}" | tail -1)

if [ ! -z "$ENTRY_ID" ]; then
  echo ""
  echo "🎉 Trail record added successfully!"
  echo "🆔 Entry ID: $ENTRY_ID"
  echo "🎁 NFT reward should be minted to your address"
  echo ""
  echo "💡 The ProductEntry object is now owned by the Product at: $PRODUCT_ID"
else
  echo ""
  echo "⚠️  Could not extract Entry ID from transaction result"
  echo "Please check the transaction output above for the created object ID"
fi