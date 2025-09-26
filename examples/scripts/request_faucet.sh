#!/bin/bash

# Script to request tokens from IOTA faucet for current account

echo "💧 IOTA Faucet Request"
echo ""

# Show current active address
ACTIVE_ADDRESS=$(iota client active-address 2>/dev/null)

if [ -z "$ACTIVE_ADDRESS" ]; then
    echo "❌ No active address found"
    echo "💡 Create or switch to an account first:"
    echo "   • make create-account"
    echo "   • iota client switch --address <alias>"
    exit 1
fi

echo "🎯 Requesting tokens for address: $ACTIVE_ADDRESS"
echo ""

# Request tokens from faucet
FAUCET_RESULT=$(iota client faucet 2>&1)
echo "$FAUCET_RESULT"

if echo "$FAUCET_RESULT" | grep -q "error\|Error\|failed\|Failed"; then
    echo ""
    echo "❌ Faucet request failed"
    echo "💡 Common issues:"
    echo "   • Rate limit reached (try again later)"
    echo "   • Network connectivity issues"
    echo "   • Account already has sufficient balance"
else
    echo ""
    echo "✅ Faucet request completed!"
    echo "⏳ Waiting for transaction to process..."
    sleep 3
    
    echo ""
    echo "💰 Updated balance:"
    iota client balance
fi