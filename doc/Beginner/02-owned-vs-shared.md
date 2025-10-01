# Owned vs. Shared Objects in Move

A cornerstone of Move on IOTA is the distinction between owned objects and shared objects. This fundamental design choice dramatically impacts **performance**, **consensus requirements**, and **scalability**. Understanding when to use each type is crucial for building efficient IOTA applications.

## 🚀 Performance Impact Overview

| Aspect             | Owned Objects     | Shared Objects |
|--------------------|-------------------|----------------|
| Consensus Type     | Partial Consensus | Full Consensus |
| Latency            | Lower             | Higher         |
| Throughput         | Higher            | Lower          |
| Parallel Execution | ✅ Yes             | ❌ Sequential   |
| Gas Costs          | Lower             | Higher         |

## 🔒 Owned Objects - Partial Consensus (High Performance)

**Definition**: An owned object has a single owner (typically an account address). Only transactions signed by that owner can read or write that object.

### ⚡ Performance Advantages

**Partial Consensus Process**:
1. **Local Validation**: Only verify the owner's signature and object state
2. **No Global Coordination**: No need to order transactions across all validators  
3. **Parallel Execution**: Multiple owned object transactions can run simultaneously
4. **Fast Finality**: Lower total latency compared to shared objects

**Why It's Faster**:
```
Alice transfers her coins: Object 0xabc123 (owned by Alice)
Bob transfers his coins:   Object 0xdef456 (owned by Bob)  
Charlie transfers his NFT: Object 0x789abc (owned by Charlie)

→ All 3 transactions execute in PARALLEL
→ No conflicts possible since different owners
→ Higher throughput achievable
```

### 🎯 When to Use Owned Objects

**Perfect For**:
- **Personal wallets and token balances** - Only you control your money
- **Individual NFTs and collectibles** - Each NFT belongs to one person
- **User profiles and private data** - Personal information storage
- **Gaming items and achievements** - Player-specific assets
- **High-frequency operations** - When speed is critical

	
## 🌐 Shared Objects - Full Consensus (High Collaboration) 

**Definition**: A shared object is not tied to a single owner, meaning anyone can potentially read or invoke its functions (writes still follow contract rules).

### 🎯 When to Use Shared Objects

**Essential For**:
- **Decentralized exchanges (DEX)** - Multiple traders need access to order books
- **Marketplaces and auctions** - Buyers compete for limited items  
- **Governance systems** - Community voting and decision making
- **Gaming worlds** - Shared game state that all players interact with
- **DeFi protocols** - Liquidity pools, lending platforms, staking rewards

**Collaboration Benefits**:
- **Trustless interaction** - No central authority needed
- **Atomic operations** - Complex multi-party transactions
- **Global accessibility** - Anyone can interact with the object
- **Consensus safety** - All state changes are globally verified


## 🎯 Strategic Design Decisions

### Performance-First Architecture

**Owned Objects (Partial Consensus)** - Choose When:
- ✅ **High-frequency operations** (payments, transfers, trading)  
- ✅ **Predictable performance** is critical
- ✅ **Single-user workflows** dominate your app
- ✅ **Cost optimization** is important

**Shared Objects (Full Consensus)** - Choose When:  
- ✅ **Multi-user coordination** is essential
- ✅ **Global state consistency** is required
- ✅ **Complex business logic** involves multiple parties  
- ✅ **Trustless collaboration** is the core feature


### 🔄 IOTA vs Ethereum Comparison

| Blockchain | Model | All Operations |
|------------|-------|----------------|
| **Ethereum** | Account-based | **Full Consensus** (Limited TPS) |
| **IOTA Move** | Object-based | **Partial** OR **Full Consensus** |

**IOTA's Advantage**: Developers can **choose** the right consensus model per use case, achieving significantly better performance for owned object operations while maintaining shared object functionality when needed.

This architectural flexibility allows IOTA Move developers to build applications that are both **highly performant** and **fully collaborative** - a combination impossible on traditional shared-state blockchains.

## Additional Resources

- **[Object Model - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/object-model)** - Complete guide to IOTA's object ownership model
- **[Transfer to Object - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/transfers/transfer-to-object)** - How to transfer objects between different owners
- **[Object Transfers - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/transfers/)** - All types of object transfer operations
- **[From Solidity/EVM to Move](https://docs.iota.org/developer/evm-to-move/)** - Comparison with traditional shared-state blockchain models