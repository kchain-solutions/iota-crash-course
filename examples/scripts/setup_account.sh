#!/bin/bash

# Script to create and setup a new IOTA account for testing

# Default alias name (can be overridden)
ALIAS=${1:-test}

echo "🔧 IOTA Account Setup"
echo "👤 Creating account with alias: $ALIAS"
echo ""

# Check if alias already exists
EXISTING_ADDRESS=$(iota client addresses --alias "$ALIAS" 2>/dev/null | grep "$ALIAS" | awk '{print $2}' 2>/dev/null)

if [ ! -z "$EXISTING_ADDRESS" ]; then
    echo "⚠️  Account with alias '$ALIAS' already exists: $EXISTING_ADDRESS"
    echo "🔄 Switching to existing account..."
    
    # Switch to existing account
    SWITCH_RESULT=$(iota client switch --address "$ALIAS" 2>&1)
    echo "$SWITCH_RESULT"
    
    if echo "$SWITCH_RESULT" | grep -q "error\|Error"; then
        echo "❌ Failed to switch to existing account"
        exit 1
    fi
    
    echo "✅ Switched to existing account: $ALIAS"
    echo ""
    
    # Show current balance
    echo "💰 Current balance:"
    iota client balance
    
    exit 0
fi

echo "📝 Step 1: Creating new address with alias '$ALIAS'"
CREATE_RESULT=$(iota client new-address --alias "$ALIAS" 2>&1)

echo "$CREATE_RESULT"

# Extract the new address from the output
NEW_ADDRESS=$(echo "$CREATE_RESULT" | grep -o "0x[a-fA-F0-9]\{64\}" | head -1)

if [ -z "$NEW_ADDRESS" ]; then
    echo "❌ Failed to create new address"
    echo "Please check the output above for errors"
    exit 1
fi

echo ""
echo "✅ Address created successfully!"
echo "🆔 New Address: $NEW_ADDRESS"
echo "🏷️  Alias: $ALIAS"


echo "🔄 Step 2: Switching to new account..."

SWITCH_RESULT=$(iota client switch --address "$ALIAS" 2>&1)
echo "$SWITCH_RESULT"

if echo "$SWITCH_RESULT" | grep -q "error\|Error"; then
    echo "❌ Failed to switch to new account"
    exit 1
fi

echo ""
echo "💧 Step 3: Requesting tokens from faucet..."

FAUCET_RESULT=$(iota client faucet 2>&1)
echo "$FAUCET_RESULT"

if echo "$FAUCET_RESULT" | grep -q "error\|Error\|failed\|Failed"; then
    echo "⚠️  Faucet request may have failed, but continuing..."
else
    echo "✅ Faucet request completed!"
fi

echo ""

echo "✅ Successfully switched to account: $ALIAS"

echo ""
echo "💰 Step 4: Checking balance..."
sleep 2  # Wait a moment for faucet transaction to process

iota client balance

echo ""
echo "🎉 Account setup complete!"
echo "📋 Summary:"
echo "   • Alias: $ALIAS"
echo "   • Address: $NEW_ADDRESS"
echo "   • Status: Active (selected)"
echo ""
echo "💡 Useful commands:"
echo "   • Check balance: iota client balance"
echo "   • List all addresses: iota client addresses"
echo "   • Switch accounts: iota client switch --address <alias>"
echo "   • Request more tokens: iota client faucet"