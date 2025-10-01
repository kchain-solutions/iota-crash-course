# Using the IOTA Explorer with the Audit Trail Example

The IOTA Explorer is your window into the blockchain, providing real-time visibility into transactions, objects, and network activity. This guide shows you how to use the explorer effectively with our audit trail example.

## Explorer URLs

- **Mainnet, Testnet, Devnet**: [explorer.iota.org](https://explorer.iota.org)

> **Note**: Use the testnet explorer for following along with this crash course.


## Exploring Your Audit Trail Deployment

### 1. After Contract Deployment

When you run `make audit-trail-publish`, you'll see output like:
```
Transaction Digest: 0xabc123...def456
Package ID: 0x789ghi...jkl012
```

**Search for your deployment**:
1. Copy the **Transaction Digest**
2. Paste it in the explorer search bar
3. Press Enter

**What you'll see**:
- **Transaction Details**: Gas used, sender address, timestamp
- **Changes Made**: New package object created
- **Events Emitted**: Package published events
- **Objects Created**: Your smart contract package

### 2. Examining the Package Object

**Find your package**:
1. Search for the **Package ID** (0x789ghi...jkl012)
2. Click on the package object

**Package Information**:
```
Package: 0x789ghi...jkl012
├── Modules
│   ├── audit_trails::app        # Main business logic
│   └── audit_trails::nft_reward # NFT reward system
├── Dependencies  
│   ├── 0x1 (MoveStdlib)
│   ├── 0x2 (Iota Framework)
│   └── ...
└── Published At: Transaction 0xabc123...def456
```

**Key Information**:
- **Module names**: Confirms your contract structure
- **Dependencies**: Shows IOTA framework integration
- **Publication transaction**: Links back to deployment

## Tracking Product Creation

### 3. After Creating a Product

When you run `make audit-trail-create-product`, note the **Product ID** from the output:
```
🎉 Product created successfully!
🆔 Product ID: 0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f
```

**Explore the Product object**:
1. Search for the Product ID in the explorer: [0x9e31fbc...](https://explorer.iota.org/object/0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f?network=testnet)
2. Click on the object

**Real Product Object Example**:
```
Object: 0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f
├── Type: 0x1569ca9...::app::Product
├── Owner: Shared                    # ← This is key!
├── Version: 1
├── Data:
│   ├── id: 0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f
│   ├── name: "Pro 48V Battery"
│   ├── serial_number: "EB-48V-2024-001337"  
│   ├── manufacturer: "EcoBike"
│   ├── image_url: "https://i.imgur.com/AdTJC8Y.png"
│   └── timestamp: 1727358493651
└── Created In: Transaction 0x2b477...
```

> **🔗 Live Example**: You can view this actual Product object on the IOTA testnet explorer: [Product 0x9e31fbc...](https://explorer.iota.org/object/0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f?network=testnet)

**Key Observations**:
- **Owner: Shared**: Confirms this is a shared object
- **Type**: Shows the fully qualified Move type
- **Data fields**: All your product information is stored on-chain
- **Immutable ID**: This object has a permanent address

### 4. Viewing the Creation Transaction

Click on **"Created In"** transaction link to see:

**Transaction Overview**:
- **Sender**: Your account address
- **Gas Used**: Cost of creating the shared object
- **Status**: ✅ Success
- **Objects Changed**: Product object created

**Events Emitted**:
```
ProductEntryLogged {
    product_addr: "0xdef789...abc123",
    entry_addr: null                  # No entry for product creation
}
```

**Changes Summary**:
```
Created Objects:
└── 0xdef789...abc123 (Product) - Shared object
```

## Tracking Audit Trail Entries

### 5. After Adding an Audit Entry

When you run `make audit-trail-add-trail`, you'll get multiple object IDs:
```
🎉 Trail record added successfully!
🆔 Entry ID: 0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd
🎁 NFT reward should be minted to your address
```

**Search for the Entry object**:
1. Use the Entry ID in the explorer search: [0xf5afb512...](https://explorer.iota.org/object/0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd?network=testnet)
2. Examine the ProductEntry object

**Real ProductEntry Object Example**:
```
Object: 0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd
├── Type: 0x1569ca9...::app::ProductEntry  
├── Owner: 0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f  # ← Owned by Product!
├── Version: 1
├── Data:
│   ├── id: 0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd
│   ├── issuer_addr: "0xd9ea588a27b87233cffe1f8b647b49f75de66e25f21ddbcd0fb76430b19b0139"
│   ├── entry_data: "Quality check passed - Battery tested at full capacity..."
│   └── timestamp: 1727358530780
└── Created In: Transaction 0x4c8e9...
```

> **🔗 Live Example**: You can view this actual ProductEntry object on the IOTA testnet explorer: [ProductEntry 0xf5afb512...](https://explorer.iota.org/object/0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd?network=testnet)

**Notice the Ownership Relationship**:
- **ProductEntry Owner**: `0x9e31fbc...` (matches our Product ID from above!)
- **This proves the owned object relationship**: The ProductEntry is owned by the Product

**Key Observations**:
- **Owner**: Points to the Product object (not "Shared")
- **Issuer address**: The account that created the entry (`0xd9ea588a...`)
- **Owned relationship**: This entry belongs to the specific product
- **Cross-reference**: You can click the owner address to view the Product object

### 6. Finding Your NFT Reward

**Check objects owned by your address**:
1. Search for your account address in the explorer
2. Look for newly created objects

**Your Account Objects**:
```
Objects Owned by 0x<your-address>:
├── 0x123abc...def456 (Coin<IOTA>)      # Your IOTA tokens
└── 0x987fed...cba321 (RewardNFT)       # ← Your new NFT!
```

**NFT Object Details**:
```
Object: 0x987fed...cba321
├── Type: 0x789ghi...jkl012::nft_reward::RewardNFT
├── Owner: 0x<your-address>          # ← You own this NFT
├── Data:
│   ├── id: 0x987fed...cba321
│   ├── name: "Product Entry Badge"
│   ├── description: "Thanks for logging a product entry!"
│   └── image_url: "https://i.imgur.com/Jw7UvnH.png"
```

## Understanding Transaction Details

### 7. Complex Transaction Analysis

The audit entry transaction does multiple things. Click on the **creation transaction** to see:

**Real Transaction Effects Example**:
```
Objects Changed:
├── 0x9e31fbc... (Product)     # Referenced (not modified)
├── 0xf5afb512... (ProductEntry) # Created - owned by Product  
└── 0x<nft-id>... (RewardNFT)   # Created - owned by you

Events Emitted:
├── ProductEntryLogged {
│   product_addr: "0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f",
│   entry_addr: "0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd"
│}
└── NFTMinted {
    object_id: "0x<actual-nft-id>", 
    creator: "0xd9ea588a27b87233cffe1f8b647b49f75de66e25f21ddbcd0fb76430b19b0139",
    name: "Product Entry Badge"
  }
```

> **💡 Explore the relationships**: Notice how the Product ID from step 3 appears as the owner of the ProductEntry in step 5 - this demonstrates the owned object concept in practice!

**Gas Breakdown**:
- **Computation**: Move VM execution cost
- **Storage**: Cost of storing new objects
- **Total**: Combined cost for the complex transaction

## Advanced Explorer Features

### 8. Filtering and Searching

**Search by Type**:
- Filter objects by Move type
- Find all Products: `audit_trails::app::Product`
- Find all NFTs: `audit_trails::nft_reward::RewardNFT`

**Address Activity**:
- View all transactions sent by your address
- See objects owned by any address
- Track activity over time

**Network Analytics**:
- Transaction throughput (TPS)
- Gas price trends  
- Active addresses
- Popular contract types

### 9. Event Monitoring

**Real-time Events**:
```
Recent Events:
├── ProductEntryLogged - 2 minutes ago
├── NFTMinted - 2 minutes ago  
├── ProductEntryLogged - 5 minutes ago
└── Package Published - 10 minutes ago
```

**Event Details**:
- **Source**: Which contract emitted the event
- **Transaction**: Link to the triggering transaction
- **Data**: Event payload with relevant information

## Troubleshooting with Explorer

### 10. Common Issues and Solutions

**Transaction Failed**:
- **Explorer shows**: ❌ Transaction status
- **Error message**: Displayed in transaction details
- **Common causes**: Insufficient gas, invalid parameters

**Object Not Found**:
- **Check spelling**: Object IDs are case-sensitive
- **Verify network**: Testnet vs mainnet objects
- **Transaction status**: Ensure creation transaction succeeded

**Unexpected Results**:
- **Review transaction**: Check all objects changed
- **Examine events**: Events show what actually happened
- **Compare gas**: High gas might indicate errors

## Practical Exercise

Try this workflow to practice using the explorer with real examples:

1. **Deploy** your contract and note the Package ID
2. **Search** for the package in the explorer
3. **Create** a product and find the Product object (like [this example](https://explorer.iota.org/object/0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f?network=testnet))
4. **Add** an audit entry and trace the object relationships (like [this ProductEntry](https://explorer.iota.org/object/0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd?network=testnet))
5. **Verify ownership**: Notice how the ProductEntry's owner field points to the Product ID
6. **Find** your NFT reward in your account objects
7. **Review** all transactions you've created
8. **Explore** events emitted by your interactions

**Live Example Relationship**:
- **Product** (Shared): [0x9e31fbc...](https://explorer.iota.org/object/0x9e31fbc70705812934d16e6cab58ff96c46f6c219f68df68f6006b82fb89a19f?network=testnet)
- **ProductEntry** (Owned by Product): [0xf5afb512...](https://explorer.iota.org/object/0xf5afb512a567d2de0ab43c7a636401502ab0cab7735265526f67b1d4068ab0bd?network=testnet)

Click between these objects to understand how IOTA's object model creates relationships!

## Tips for Effective Explorer Use

### Navigation Best Practices

- **Bookmark transactions**: Save important deployment/creation transactions  
- **Copy object IDs**: Keep a list of your important objects
- **Use multiple tabs**: Compare objects and transactions side-by-side
- **Check timestamps**: Understand the sequence of events

### Understanding Performance

- **Shared objects**: Look for "Shared" in owner field
- **Owned objects**: Show specific owner addresses
- **Consensus cost**: Shared object transactions typically use more gas
- **Parallel execution**: Multiple owned object transactions can happen simultaneously

The IOTA Explorer is essential for understanding how your smart contracts behave in practice. Use it regularly during development to verify your expectations match reality and to debug any issues that arise.

## Additional Resources
- **[Object Model - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/object-model)** - Understanding the objects you see in the explorer
- **[Smart Contracts on IOTA](https://docs.iota.org/tags/move-sc)** - Documentation for the contracts you're exploring