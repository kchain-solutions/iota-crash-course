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


echo "✅ Using AUDIT_TRAIL_PKG: $AUDIT_TRAIL_PKG"
echo "✅ Using PRODUCT_ID: $PRODUCT_ID"


# Trail record details
ENTRY_DATA="Quality check passed - Battery tested at full capacity, all cells balanced, BMS functioning correctly. Ready for shipment."
GAS_BUDGET=500000000
CLOCK_ID=0x6

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