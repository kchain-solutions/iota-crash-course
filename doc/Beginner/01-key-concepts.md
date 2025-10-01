# MoveVM Basics: Key Concepts

The MoveVM executes smart contracts written in the Move programming language. Move is a secure and flexible language initially developed for Diem (Libra) and influenced by Rust, emphasizing safety of digital assets. **Unlike the Ethereum Virtual Machine (EVM) which uses accounts and balances with global shared state, Move uses a resource-oriented model**. **Assets in Move are represented as objects (resources) that have strict ownership rules. Objects cannot be accidentally duplicated or dropped, which helps prevent common vulnerabilities. This design allows formal verification of contracts and avoids issues like re-entrancy or arithmetic overflows by construction.**

IOTA’s implementation of Move (often called IOTA MoveVM) customizes Move for high throughput and fast finality. IOTA uses object-centric global storage: 

1. Each contract or asset is an object with a unique ID, and transactions must declare upfront which objects they will read or write. 
2. By knowing the exact objects a transaction will touch, the network can schedule non-overlapping transactions in parallel. This leads to major scalability gains independent transactions (e.g. two different token transfers between different users) can execute simultaneously without conflicts.
3. Parallel Execution and Safety: If a transaction only involves objects exclusively owned by the sender, IOTA can even commit it without a full consensus round, greatly reducing latency. Meanwhile, Move’s type system ensures that assets (resources) cannot be lost or misused. 

Here is an [Object Example](https://explorer.iota.org/object/0x7166faaf7ec86f05e3e3f76eebd6e76740f9de635b7d5c9bb0d294b683cc906d?network=testnet)

In summary, the MoveVM provides a safer runtime than the EVM and leverages IOTA's DAG-based architecture for concurrency, making it a powerful environment for secure and efficient smart contracts.

## Additional Resources

- **[Why Move? - IOTA Documentation](https://docs.iota.org/about-iota/why-move)** - Official explanation of Move's advantages
- **[Move Concepts - IOTA Documentation](https://docs.iota.org/developer/iota-101/move-overview/)** - Comprehensive Move language overview
- **[Object Model - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/object-model)** - Deep dive into IOTA's object-centric approach
- **[Smart Contracts on IOTA](https://docs.iota.org/tags/move-sc)** - Complete Move smart contract documentation