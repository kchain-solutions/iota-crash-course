#!/bin/bash

# Script to list all IOTA accounts and show current active account

echo "👥 IOTA Account Management"
echo ""

echo "📋 All available addresses:"
iota client addresses

echo ""
echo "💰 Current account balance:"
ACTIVE_ADDRESS=$(iota client active-address 2>/dev/null)

if [ ! -z "$ACTIVE_ADDRESS" ]; then
    echo "🎯 Active address: $ACTIVE_ADDRESS"
    iota client balance
else
    echo "⚠️  No active address found"
    echo "💡 Use 'make create-account' or 'iota client switch --address <alias>' to select an account"
fi

echo ""
echo "🔧 Account management commands:"
echo "   • Create new account: make create-account [alias]"
echo "   • Switch account: iota client switch --address <alias>"  
echo "   • Request tokens: make faucet"
echo "   • Check balance: make balance"