# MoveVM Basics: Key Concepts

> **Prerequisiti:** [01 - Getting Started](01-getting-started.md)
> **Tempo stimato:** 20 minuti
> **Prossimo:** [03 - Owned vs Shared Objects](03-owned-vs-shared.md)

---

## Panoramica

Questo documento introduce i concetti fondamentali di IOTA MoveVM: il modello a oggetti, le differenze architetturali rispetto all'EVM, e come IOTA Rebased abilita l'esecuzione parallela e la finalita' rapida.

## IOTA Rebased: L'Architettura

IOTA Rebased rappresenta una transizione fondamentale: da un ledger basato su UTXO/Tangle a un **ledger basato su oggetti** con smart contract Move nativi a Layer 1.

Le caratteristiche principali:

| Caratteristica | Dettaglio |
|---------------|-----------|
| **Consenso** | Delegated Proof-of-Stake (DPoS) |
| **Smart Contracts** | Move nativi a L1 (non un L2 separato) |
| **Modello di storage** | Object-centric (ogni asset e' un oggetto con UID) |
| **Esecuzione parallela** | Transazioni su oggetti diversi eseguite simultaneamente |
| **Finalita'** | Sub-secondo per oggetti owned, pochi secondi per shared |
| **Costo transazione** | ~0.005 IOTA per transazione |

### Due Percorsi di Consenso

IOTA usa due meccanismi diversi in base al tipo di oggetto:

1. **Byzantine Consistent Broadcast** - Per oggetti owned (proprietario singolo). Non richiede consenso completo: il nodo verifica la firma del proprietario e propaga la transazione. Risultato: latenza bassissima.

2. **Consenso Mysticeti** - Per oggetti shared (accesso multiplo). Richiede accordo tra i validatori. Piu' lento ma necessario quando piu' parti interagiscono sullo stesso oggetto.

Questa distinzione e' cruciale per il design delle applicazioni (approfondita in [03 - Owned vs Shared](03-owned-vs-shared.md)).

## Il Modello a Oggetti Move

The MoveVM executes smart contracts written in the Move programming language. Move is a secure and flexible language initially developed for Diem (Libra) and influenced by Rust, emphasizing safety of digital assets. **Unlike the Ethereum Virtual Machine (EVM) which uses accounts and balances with global shared state, Move uses a resource-oriented model**. **Assets in Move are represented as objects (resources) that have strict ownership rules. Objects cannot be accidentally duplicated or dropped, which helps prevent common vulnerabilities. This design allows formal verification of contracts and avoids issues like re-entrancy or arithmetic overflows by construction.**

In Move, tutto e' un **oggetto**. Ogni oggetto ha:

- **UID** - Identificatore unico globale, immutabile dopo la creazione
- **Owner** - Chi possiede l'oggetto (un indirizzo, "shared", o "immutable")
- **Version** - Incrementata ad ogni modifica
- **Type** - Il tipo Move che definisce la struttura (es. `0x2::coin::Coin<IOTA>`)

```move
public struct MyObject has key, store {
    id: UID,           // Identificatore unico
    value: u64,        // Dati custom
    description: String
}
```

### Abilities: il Sistema di Tipi di Move

Ogni tipo in Move dichiara le sue **abilities**, che controllano cosa si puo' fare con esso:

| Ability | Significato | Quando usarla |
|---------|------------|---------------|
| `key` | L'oggetto puo' esistere nello storage globale | Quasi sempre (rende il tipo un "oggetto") |
| `store` | Puo' essere contenuto dentro altri oggetti | Quando serve composizione |
| `copy` | Puo' essere duplicato | Per valori semplici (numeri, stringhe) |
| `drop` | Puo' essere scartato | Per valori temporanei, MAI per asset di valore |

Un oggetto con `key` ma senza `drop` **non puo' sparire** - deve essere esplicitamente trasferito o distrutto. Questo previene la perdita accidentale di asset.

## Token Management: EVM vs MoveVM

Per capire la differenza fondamentale, consideriamo come vengono gestiti i token:

### **EVM (Account Model)**
```
Ethereum Smart Contract:
+--------------------------+
| Token Contract           |
| mapping(address => u256) |  <- Tabella di stato globale
| alice: 100 ETH          |
| bob: 50 ETH             |  <- Tutti i bilanci in un unico posto
| charlie: 25 ETH         |
+--------------------------+
```

**Processo di trasferimento**: Quando Alice invia token a Bob, il contratto modifica la mapping globale - i bilanci di Alice e Bob cambiano nello stato condiviso. Tutte le operazioni sullo stesso contratto sono serializzate.

### **MoveVM (Object Model)**
```
IOTA Objects:
Alice's Coin Object    Bob's Coin Object      Charlie's Coin Object
+------------------+   +------------------+    +------------------+
| ID: 0xabc123     |   | ID: 0xdef456     |    | ID: 0x789abc     |
| value: 100 IOTA  |   | value: 50 IOTA   |    | value: 25 IOTA   |
| owner: alice     |   | owner: bob       |    | owner: charlie   |
+------------------+   +------------------+    +------------------+
```

**Processo di trasferimento**: Quando Alice invia token a Bob, l'oggetto coin di Alice viene trasferito direttamente. Ogni token esiste come oggetto indipendente. Le operazioni su oggetti diversi possono avvenire in parallelo.

### Confronto Diretto

| Aspetto | EVM | MoveVM |
|---------|-----|--------|
| **Modello** | Account-based, stato globale condiviso | Object-based, stato distribuito |
| **Parallelismo** | Limitato (stato condiviso = colli di bottiglia) | Nativo (oggetti indipendenti = esecuzione parallela) |
| **Sicurezza asset** | Logica nel contratto (vulnerabile a reentrancy) | Garantita dal type system (reentrancy impossibile) |
| **Trasferimento** | Modifica mapping globale | Cambio di ownership dell'oggetto |
| **Verifica formale** | Complessa | Supportata nativamente |
| **Costo gas** | Variabile, spesso alto | Basso e prevedibile (~0.005 IOTA) |

## Esecuzione Parallela e Scalabilita'

IOTA's implementation of Move (often called IOTA MoveVM) customizes Move for high throughput and fast finality. IOTA uses object-centric global storage:

1. Each contract or asset is an object with a unique ID, and transactions must declare upfront which objects they will read or write.
2. By knowing the exact objects a transaction will touch, the network can schedule non-overlapping transactions in parallel. This leads to major scalability gains - independent transactions (e.g. two different token transfers between different users) can execute simultaneously without conflicts.
3. If a transaction only involves objects exclusively owned by the sender, IOTA can even commit it without a full consensus round, greatly reducing latency. Meanwhile, Move's type system ensures that assets (resources) cannot be lost or misused.

```
Transazione 1: Alice -> Bob (Coin 0xabc)     ]
Transazione 2: Charlie -> Dave (Coin 0x789)   ] Eseguite in PARALLELO
Transazione 3: Eve -> Frank (Coin 0xfed)      ]

Transazione 4: Modifica SharedObject 0x555     ] Richiede consenso,
Transazione 5: Modifica SharedObject 0x555     ] eseguite in SEQUENZA
```

## Mental Model: Pensare a Oggetti

Quando progetti un'applicazione IOTA, pensa in termini di oggetti fisici:

- **Un NFT** = un quadro in una galleria. Ha un proprietario, puo' essere trasferito, non puo' essere duplicato
- **Un token** = una moneta nel tuo portafoglio. Puoi inviarla, dividerla, unirla con altre
- **Un registro condiviso** = una bacheca pubblica. Tutti possono leggerla, solo chi ha i permessi puo' scrivere
- **Una capability** = una chiave. Chi la possiede puo' compiere certe azioni

Questa analogia ti aiutera' a scegliere i pattern giusti per i tuoi smart contract.

## Esplorare un Oggetto

Puoi vedere un oggetto reale sull'Explorer IOTA:

[Esempio di oggetto su Testnet](https://explorer.rebased.iota.org/object/0x7166faaf7ec86f05e3e3f76eebd6e76740f9de635b7d5c9bb0d294b683cc906d?network=testnet)

Nell'Explorer noterai:
- **Object ID**: l'identificatore unico
- **Version**: il numero di versione corrente
- **Owner**: chi possiede l'oggetto
- **Type**: il tipo Move dell'oggetto
- **Content**: i dati contenuti

## Risorse Aggiuntive

- **[Why Move? - IOTA Documentation](https://docs.iota.org/about-iota/why-move)** - Official explanation of Move's advantages
- **[Move Concepts - IOTA Documentation](https://docs.iota.org/developer/iota-101/move-overview/)** - Comprehensive Move language overview
- **[Object Model - IOTA Documentation](https://docs.iota.org/developer/iota-101/objects/object-model)** - Deep dive into IOTA's object-centric approach
- **[Smart Contracts on IOTA](https://docs.iota.org/tags/move-sc)** - Complete Move smart contract documentation

---

**Prossimo:** [03 - Owned vs Shared Objects](03-owned-vs-shared.md)
