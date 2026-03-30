# IOTA Trust Framework Overview

> **Prerequisiti:** [Module 1 - Foundations](../Module-1-Foundations/02-key-concepts.md) (concetti base del modello a oggetti)
> **Tempo stimato:** 30 minuti
> **Prossimo:** [02 - IOTA Identity](02-iota-identity.md)

---

## Perche' il Trust Framework?

Le organizzazioni incontrano spesso resistenza all'adozione della blockchain a causa di un'idea sbagliata: che richieda la sostituzione dei processi aziendali esistenti. La realta' e' diversa. L'IOTA Trust Framework e' progettato per **estendere, non sostituire** i sistemi esistenti, permettendo alle imprese di ampliare le proprie capacita' operative rispettando i requisiti normativi e di compliance.

I tradizionali approcci centralizzati (database condivisi, integrazioni punto-punto, processi di verifica manuali) creano colli di bottiglia, inefficienza, punti di guasto singoli e lacune di compliance. Il Trust Framework risolve questi problemi con componenti modulari production-ready.

### Caratteristiche Chiave

| Caratteristica | Dettaglio |
|---------------|-----------|
| **Open source** | Nessun vendor lock-in, audit completo del codice |
| **Costi bassi** | ~0.005 IOTA per transazione, critico per workload enterprise |
| **Standard W3C** | DID, Verifiable Credentials, interoperabile by design |
| **Smart contract MoveVM** | Garanzie di sicurezza piu' forti dell'EVM |
| **Architettura modulare** | Usa solo i prodotti che ti servono |
| **SDK TypeScript e Rust** | Binding developer-friendly per entrambi i linguaggi |

## I 5 Building Blocks

Il Trust Framework e' composto da 5 prodotti che possono essere usati singolarmente o combinati:

```
+-------------------+     +-------------------+     +-------------------+
|  IOTA Identity    |     | IOTA Hierarchies  |     | IOTA Notarization |
|  WHO is the actor |---->| WHAT role they     |---->| RECORD what       |
|  (DID, VC)        |     | play (RBAC)        |     | happened          |
+-------------------+     +-------------------+     +-------------------+
         |                         |                         |
         v                         v                         v
+-------------------+     +-------------------+
| IOTA Gas Station  |     | IOTA Secret       |
| PAY for users     |     | Storage            |
| (fee sponsorship) |     | SIGN securely      |
+-------------------+     +-------------------+
```

### 1. IOTA Identity

Implementa pattern standard W3C per l'identita' decentralizzata (DID). Fornisce primitive di identita' per persone, organizzazioni, dispositivi e oggetti digitali, stabilendo un layer di trust unificato.

**Quando usarlo:**
- Hai bisogno di identita' verificabili per gli attori del tuo ecosistema
- Devi emettere o verificare credenziali (Verifiable Credentials)
- Serve Domain Linkage per collegare DID a domini web

**Documentazione:** https://docs.iota.org/developer/iota-identity/
**Esempi:** [TypeScript](https://github.com/iotaledger/identity/tree/main/bindings/wasm/identity_wasm/examples) | [Rust](https://github.com/iotaledger/identity/tree/main/examples)

**Approfondimento:** [02 - IOTA Identity](02-iota-identity.md)

### 2. IOTA Hierarchies

Definisce relazioni strutturate e autorita' delegate tra i partecipanti. Funziona come access control manager on-chain, applicando permessi role-based (RBAC) attraverso smart contract personalizzati.

**Quando usarlo:**
- Hai una gerarchia organizzativa (casa madre, filiali, enti certificatori)
- Serve delega di permessi tra livelli (Root -> Accreditatore -> Attestatore)
- Devi validare ruoli on-chain prima di permettere operazioni

**Documentazione:** https://docs.iota.org/developer/iota-hierarchies/
**Esempi:** [TypeScript](https://github.com/iotaledger/hierarchies/tree/main/bindings/wasm/hierarchies_wasm/examples) | [Rust](https://github.com/iotaledger/hierarchies/tree/main/hierarchies-rs/examples)

**Approfondimento:** [04 - IOTA Hierarchies](04-iota-hierarchies.md)

### 3. IOTA Notarization

Garantisce l'integrita' e il timestamp di dati critici (fatture, bolle di trasporto, certificati) ancorando prove crittografiche on-chain. Tre pattern disponibili:

| Pattern | Modello | Mutabilita' | Caso d'uso |
|---------|---------|-------------|------------|
| **Locked** | "Tavola di pietra" | Immutabile | Prova singola definitiva |
| **Dynamic** | "Documento vivente" | Versioned, aggiornabile | Stato corrente con storico |
| **Audit Trails** | "Catena di eventi" | Append-only, multi-attore | Supply chain, DPP |

**Quando usarlo:**
- Devi garantire l'integrita' di documenti o dati
- Serve un audit trail immutabile con piu' contributori
- Hai bisogno di timestamp verificabili on-chain

**Documentazione:** https://docs.iota.org/developer/iota-notarization/
**Esempi:** [TypeScript](https://github.com/iotaledger/notarization/tree/main/bindings/wasm/notarization_wasm/examples/src) | [Rust](https://github.com/iotaledger/notarization/tree/main/examples)

**Approfondimento:** [05 - IOTA Notarization](05-iota-notarization.md)

### 4. IOTA Gas Station

Abilita la sponsorizzazione delle fee di transazione, permettendo agli utenti di interagire con applicazioni on-chain senza possedere token nativi. Critico per l'usabilita' enterprise.

**Quando usarlo:**
- I tuoi utenti non devono gestire criptovalute (fornitori, agenti logistici)
- Serve una UX "zero-token" per l'onboarding
- Hai bisogno di gestione ottimizzata dei coin object

**Documentazione:** https://docs.iota.org/operator/gas-station/
**Esempi:** https://github.com/iotaledger/gas-station/tree/main/examples

**Approfondimento:** [Module 3 - Gas Station](../Module-3-Infrastructure/01-iota-gas-station.md)

**Hands-On:** L'esempio pratico si trova in `examples/gas-station-sidecar/`

### 5. IOTA Secret Storage

Permette alle applicazioni di richiedere firme crittografiche senza esporre le chiavi private. Fornisce un'interfaccia standardizzata e auditabile per l'approvazione delle transazioni e la firma dei dati.

**Quando usarlo:**
- Serve key management sicuro (HSM, cloud KMS)
- Non vuoi esporre chiavi private all'application layer
- Hai bisogno di auditing delle operazioni di firma

**Documentazione:** https://github.com/iotaledger/secret-storage

## Pattern di Integrazione

I prodotti del Trust Framework raggiungono il massimo valore quando combinati. Ecco i pattern piu' comuni:

### Gas Station + Secret Storage (Layer Infrastrutturale)

Gas Station e Secret Storage operano al livello infrastrutturale e si compongono con tutti gli altri moduli. Gas Station fornisce non solo sponsorizzazione delle fee ma anche ottimizzazione delle performance per la gestione dei coin object. E' nativamente integrato con Identity e Notarization per la firma sicura delle transazioni.

### Identity + Hierarchies (Pattern WHO + WHAT)

Quando IOTA Identity e' combinato con Domain Linkage, fornisce attestazione dell'identita' reale per un DID specifico. Per le entita' aziendali, il DID stabilisce **CHI** e' l'attore dietro la sua identita' on-chain.

Questo DID puo' poi essere configurato come attributo di indirizzo all'interno di Hierarchies, creando una struttura organizzativa che mappa le relazioni tra entita' e stabilisce catene di credenziali che mostrano esattamente **CHI** ha accreditato **CHI** per un ruolo particolare.

In sintesi: **Identity attesta CHI e' un'entita', Hierarchies definisce QUALE ruolo gioca nell'ecosistema.**

### Hierarchies + Audit Trails (Permessi per Registrazioni)

Negli scenari di audit trail, ruoli diversi richiedono livelli di permesso diversi (Write, Admin, Read-only, etc.). Hierarchies associa ruoli come attributi agli indirizzi IOTA, permettendo un'unica fonte di verita' estendibile orizzontalmente attraverso piu' componenti, garantendo la corretta applicazione dei permessi per gli Audit Trails.

## Esempio Completo: Digital Product Passport

Un caso d'uso che combina tutti e 5 i prodotti:

1. **IOTA Identity** - Produttore, fornitori e riciclatori hanno DID verificati con Domain Linkage
2. **IOTA Hierarchies** - L'ente regolatore delega l'autorita' alle agenzie nazionali, che onboardano tutti i partecipanti con permessi role-based
3. **IOTA Notarization** - Ogni evento del ciclo di vita del prodotto (produzione, spedizione, riciclo) e' registrato come Audit Trail immutabile
4. **IOTA Gas Station** - Gli operatori della supply chain interagiscono senza gestire criptovalute
5. **IOTA Secret Storage** - La firma delle transazioni e' gestita in modo sicuro senza esporre chiavi all'application layer

**Demo live:** [dpp.demo.iota.org](https://dpp.demo.iota.org/)

**Approfondimento:** [Module 4 - Digital Product Passport](../Module-4-Integration/02-digital-product-passport.md)

## Da Dove Iniziare

La maggior parte delle organizzazioni inizia con uno o due prodotti e si espande man mano. Punti di partenza comuni:

| Caso d'uso | Prodotti iniziali |
|------------|------------------|
| **Digital Product Passport** | Identity + Notarization + Hierarchies |
| **Credential Management** | Identity + Hierarchies (WHO + WHAT) |
| **Document Integrity** | Notarization (Locked o Dynamic) |
| **User Experience** | Gas Station + Secret Storage |

## Risorse

- [IOTA Identity docs](https://docs.iota.org/developer/iota-identity/)
- [IOTA Hierarchies docs](https://docs.iota.org/developer/iota-hierarchies/)
- [IOTA Notarization docs](https://docs.iota.org/developer/iota-notarization/)
- [IOTA Gas Station docs](https://docs.iota.org/operator/gas-station/)
- [IOTA Secret Storage](https://github.com/iotaledger/secret-storage)
- [DPP Demo showcase](https://dpp.demo.iota.org/)

---

**Prossimo:** [02 - IOTA Identity](02-iota-identity.md)
