# IOTA Digital Product Passport Demo

### Introduction & Context
We’ll walk through our Digital Product Passport demo, available at https://dpp.demo.iota.org.

We built this demonstration to show how the IOTA Trust Framework components can work together to dramatically reduce development complexity, increase security, and offer an innovative and seamless user experience.

While blockchain and distributed ledgers are sometimes perceived as complex to integrate and operate, our goal was to show the opposite:
➡️ Abstract complexity
➡️ Improve developer experience
➡️ Enhance security and trust guarantees
➡️ Deliver a clear UX for end users

In this demo, you will see how multiple products are orchestrated together in a practical scenario involving a battery Digital Product Passport and certified maintenance records.

### Components Used in the Demo

* Audit Trails: to notarize lifecycle events and guarantee tamper-proof traceability
* Decentralized Identity & Domain Linkage: to authenticate actors and link them to their verified web domains
* Reward Tokenization: to incentivize correct maintenance and recycling
* Hierarchies (Federated Trust Model): to represent the trust and permission chains between institutions, manufacturers, and technicians

* Gas Station: to provide a feeless experience for end-users while maintaining ledger security and accountability

These modules are designed to be modular, interoperable, and enterprise-friendly, ensuring that organizations can adopt them progressively.

### Why This Matters
I don’t claim that IOTA, or any public ledger, is a universal solution.
Over the years, I’ve come to believe that public ledgers solve a very specific class of problems:

When multiple independent actors need to record verifiable actions on a shared infrastructure and reach trustable consensus.

This applies strongly to ownership, traceability, and compliance workflows.

In this demo we focus on one of the most relevant industrial use cases today:
Digital Product Passports (DPPs), and specifically a maintenance scenario where a certified technician updates a battery’s health record.

### What We Will See in the Walkthrough
1) Product on-chain representation
We begin by looking at how the product — in this case, a battery — is represented on-chain.
In the demo, all data and metadata are openly exposed so you can clearly see the structure of the Digital Product Passport and the associated lifecycle records. In a real-world deployment, data visibility can be selective or private, but for demonstration purposes everything is transparent.
Here, the digital twin of the product is anchored on IOTA, and each object and state change is notarized, giving us verifiable proof of integrity over time.

2) Identity & Domain Linkage
Next, we look at identity.
The manufacturer is represented through a decentralized identity (DID) that is cryptographically anchored on the ledger.
But identity alone is not enough — trust also requires proof of control.
That’s why we also show domain linkage, ensuring a bidirectional verification between the DID and the organization’s website.
In short, we know who the manufacturer is, and we can verify they control their online presence — a critical foundation for business trust.

3) Federation Hierarchies & Trust Network
From identity, we move to governance.
The demo introduces a Service Network, which represents a federated trust model.
Within this federation, actors are authenticated and authorized through a chain of trust.
A Root of Authority — which could be a government agency or industry consortium — accredits the manufacturer.
The manufacturer, in turn, is able to accredit technicians or service providers.
This mirrors real industrial governance, where credentials propagate in a structured hierarchy rather than in isolation.

4) Vault & Reward Mechanism
Every Digital Product Passport in this demo includes a dedicated vault.
This vault enables incentive mechanisms — for example, rewarding proper maintenance or end-of-life recycling actions.
The idea is simple: if the product is serviced correctly, the system can automatically unlock a reward.
This introduces a powerful concept — token-driven behavioral incentives to support circular economy models and promote responsible product lifecycle actions.

5) Service Traceability & Reward Transactions
When a service action occurs — such as performing maintenance — that event is notarized on-chain and tied directly to the product’s history.
Alongside that traceable event, the system can automatically trigger a reward transaction.
This ensures verifiable accountability: we know who performed the service, when, and what actions were taken, and we also have a reward that acknowledges correct execution.
The audit trail becomes not only a technical ledger, but also an operational compliance tool.

6) Becoming a Certified Repairer

Before being able to record maintenance on-chain, our account must be authorized as a certified repair technician.
In the demo, the backend acts as the manufacturer and grants this accreditation.
You can observe this in the Federation object in the explorer, where authorization relationships are clearly represented.
Notice something important here: the technician doesn’t manually sign complex authorization transactions — the system handles credential logic transparently.
This is key for user adoption: strong cryptography and authorization, without UX friction.

7) Signing & Notarizing a Service Action
Once accredited, the technician can perform and notarize a maintenance action — in this example, recording a health snapshot of the battery.
The operation is signed and recorded immutably on the ledger.
Now, IOTA is not technically fee-less — but through the Gas Station component, we fully abstract transaction fees from the user experience.
This allows for the security of signed ledger transactions, without introducing payment friction for the maintenance operator.

8) Viewing the Earned Reward
After the maintenance entry is submitted, the associated reward becomes available to the technician.
They can immediately see the updated balance and verify that the incentive was distributed correctly.
This closes the loop: correct behavior → verifiable action → reward issued on-chain.

9) Next Steps & Further Exploration
Each module we touched today — identities, credentials, trust hierarchies, audit trails, token models, gas abstraction — deserves a dedicated deep-dive.
This demo is only a snapshot of what is possible when these building blocks work together.
If you’d like to explore any component further, or understand how these patterns can be adapted for real industrial deployments, feel free to reach out anytime — I’m happy to walk through the details with you.
