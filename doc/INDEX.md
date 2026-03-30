# IOTA Crash Course - Indice e Percorsi di Apprendimento

Benvenuto nel crash course IOTA MoveVM. Questa guida ti accompagna dai concetti fondamentali fino all'integrazione enterprise, attraverso 5 moduli tematici con prerequisiti espliciti e percorsi di apprendimento dedicati.

---

## Mappa del Curriculum

```
Module 1: Foundations
  01-getting-started -> 02-key-concepts -> 03-owned-vs-shared -> 04-smart-contract
                                                                       |
                                           05-testing-and-debugging <--+
                                                     |
                                           06-dummy-audit-trails -> 07-iota-explorer
                                                     |
                                                     v
Module 2: Trust Framework
  01-overview -----> 02-iota-identity -----> 03-verifiable-credentials
       |                                             |
       +---> 04-iota-hierarchies                     |
       |                                             |
       +---> 05-iota-notarization                    |
                                                     v
Module 3: Infrastructure                   Module 4: Integration
  01-gas-station                             01-domain-linkage (richiede M2-02)
  02-package-upgrades (richiede M1-04)       02-digital-product-passport (richiede M2, M3-01)
                                             03-frontend-integration (richiede M1-04)

Module 5: Reference (consultabile in qualsiasi momento)
  01-enterprise-technical-faq
  02-token-creation-guide
  03-cheat-sheet
```

---

## Percorsi di Apprendimento

### Path A: Smart Contract Developer (8-10 ore)

Obiettivo: scrivere, testare, pubblicare e aggiornare smart contract Move su IOTA.

| Step | Documento | Tempo | Hands-On |
|------|----------|-------|----------|
| 1 | [Getting Started](Module-1-Foundations/01-getting-started.md) | 30 min | Installare tool, creare account |
| 2 | [Key Concepts](Module-1-Foundations/02-key-concepts.md) | 20 min | Comprendere modello a oggetti |
| 3 | [Owned vs Shared](Module-1-Foundations/03-owned-vs-shared.md) | 20 min | Trade-off prestazionali |
| 4 | [Smart Contract](Module-1-Foundations/04-smart-contract.md) | 45 min | Studiare i pattern Move |
| 5 | [Testing e Debugging](Module-1-Foundations/05-testing-and-debugging.md) | 45 min | Scrivere test per audit-trails |
| 6 | [Dummy Audit Trails](Module-1-Foundations/06-dummy-audit-trails.md) | 60 min | Ciclo completo build-publish-interact |
| 7 | [IOTA Explorer](Module-1-Foundations/07-iota-explorer.md) | 30 min | Esplorare oggetti on-chain |
| 8 | [Package Upgrades](Module-3-Infrastructure/02-package-upgrades.md) | 30 min | Pattern di upgrade |
| 9 | [Token Creation](Module-5-Reference/02-token-creation-guide.md) | 30 min | Creare un token custom |
| 10 | [Cheat Sheet](Module-5-Reference/03-cheat-sheet.md) | -- | Da tenere a portata di mano |

### Path B: Enterprise Architect (6-8 ore)

Obiettivo: comprendere le capability enterprise di IOTA e progettare sistemi DPP/trust.

| Step | Documento | Tempo | Hands-On |
|------|----------|-------|----------|
| 1 | [Getting Started](Module-1-Foundations/01-getting-started.md) | 30 min | Opzionale |
| 2 | [Key Concepts](Module-1-Foundations/02-key-concepts.md) | 20 min | Fondamentali |
| 3 | [Owned vs Shared](Module-1-Foundations/03-owned-vs-shared.md) | 20 min | Modello di performance |
| 4 | [Trust Framework Overview](Module-2-Trust-Framework/01-trust-framework-overview.md) | 30 min | I 5 prodotti |
| 5 | [IOTA Identity](Module-2-Trust-Framework/02-iota-identity.md) | 30 min | Ciclo di vita DID |
| 6 | [Verifiable Credentials](Module-2-Trust-Framework/03-verifiable-credentials.md) | 30 min | VC + SD-JWT |
| 7 | [IOTA Hierarchies](Module-2-Trust-Framework/04-iota-hierarchies.md) | 30 min | RBAC on-chain |
| 8 | [IOTA Notarization](Module-2-Trust-Framework/05-iota-notarization.md) | 30 min | 3 pattern |
| 9 | [Gas Station](Module-3-Infrastructure/01-iota-gas-station.md) | 45 min | Transazioni sponsorizzate |
| 10 | [Digital Product Passport](Module-4-Integration/02-digital-product-passport.md) | 45 min | Architettura DPP |
| 11 | [Enterprise FAQ](Module-5-Reference/01-enterprise-technical-faq.md) | 20 min | Domande frequenti |

### Path C: Full Stack dApp Developer (10-12 ore)

Obiettivo: costruire una dApp completa con frontend, smart contract, identity e transazioni sponsorizzate.

| Step | Documento | Tempo | Hands-On |
|------|----------|-------|----------|
| 1-7 | Path A step 1-7 | ~5 ore | Sviluppo smart contract completo |
| 8 | [Trust Framework](Module-2-Trust-Framework/01-trust-framework-overview.md) | 30 min | Ecosistema |
| 9 | [IOTA Identity](Module-2-Trust-Framework/02-iota-identity.md) | 30 min | Operazioni DID |
| 10 | [Gas Station](Module-3-Infrastructure/01-iota-gas-station.md) | 60 min | Deploy sidecar, sponsored call |
| 11 | [Domain Linkage](Module-4-Integration/01-domain-linkage-verification.md) | 30 min | Verifica bidirezionale |
| 12 | [Frontend Integration](Module-4-Integration/03-frontend-integration.md) | 60 min | React dApp con dApp Kit |
| 13 | [Cheat Sheet](Module-5-Reference/03-cheat-sheet.md) | -- | Da tenere a portata di mano |

---

## Indice Completo dei Documenti

### Module 1: Foundations

| # | Documento | Descrizione | Tempo |
|---|----------|-------------|-------|
| 01 | [Getting Started](Module-1-Foundations/01-getting-started.md) | Setup ambiente, installazione, primo account | 30 min |
| 02 | [Key Concepts](Module-1-Foundations/02-key-concepts.md) | EVM vs MoveVM, modello a oggetti, architettura IOTA | 20 min |
| 03 | [Owned vs Shared](Module-1-Foundations/03-owned-vs-shared.md) | Pattern di ownership, implicazioni prestazionali | 20 min |
| 04 | [Smart Contract](Module-1-Foundations/04-smart-contract.md) | Struttura Move, moduli, funzioni, pattern | 45 min |
| 05 | [Testing e Debugging](Module-1-Foundations/05-testing-and-debugging.md) | test_scenario, std::debug, coverage | 45 min |
| 06 | [Dummy Audit Trails](Module-1-Foundations/06-dummy-audit-trails.md) | Walkthrough completo dell'esempio audit-trails | 60 min |
| 07 | [IOTA Explorer](Module-1-Foundations/07-iota-explorer.md) | Navigare transazioni e oggetti on-chain | 30 min |

### Module 2: Trust Framework

| # | Documento | Descrizione | Tempo |
|---|----------|-------------|-------|
| 01 | [Trust Framework Overview](Module-2-Trust-Framework/01-trust-framework-overview.md) | I 5 prodotti, architettura modulare, pattern di integrazione | 30 min |
| 02 | [IOTA Identity](Module-2-Trust-Framework/02-iota-identity.md) | DID su IOTA: creazione, risoluzione, aggiornamento | 30 min |
| 03 | [Verifiable Credentials](Module-2-Trust-Framework/03-verifiable-credentials.md) | VC, SD-JWT, Selective Disclosure | 30 min |
| 04 | [IOTA Hierarchies](Module-2-Trust-Framework/04-iota-hierarchies.md) | Federation, deleghe, RBAC on-chain | 30 min |
| 05 | [IOTA Notarization](Module-2-Trust-Framework/05-iota-notarization.md) | Locked, Dynamic e Audit Trails | 30 min |

### Module 3: Infrastructure

| # | Documento | Descrizione | Tempo |
|---|----------|-------------|-------|
| 01 | [Gas Station](Module-3-Infrastructure/01-iota-gas-station.md) | Transazioni sponsorizzate, deployment, monitoring | 45 min |
| 02 | [Package Upgrades](Module-3-Infrastructure/02-package-upgrades.md) | UpgradeCap, versioned shared objects, sicurezza | 30 min |

### Module 4: Integration

| # | Documento | Descrizione | Tempo |
|---|----------|-------------|-------|
| 01 | [Domain Linkage](Module-4-Integration/01-domain-linkage-verification.md) | Verifica bidirezionale DID-dominio | 30 min |
| 02 | [Digital Product Passport](Module-4-Integration/02-digital-product-passport.md) | Architettura DPP, EU ESPR, lifecycle | 45 min |
| 03 | [Frontend Integration](Module-4-Integration/03-frontend-integration.md) | dApp Kit, TypeScript SDK, wallet | 60 min |

### Module 5: Reference

| # | Documento | Descrizione | Tempo |
|---|----------|-------------|-------|
| 01 | [Enterprise FAQ](Module-5-Reference/01-enterprise-technical-faq.md) | Domande tecniche enterprise e ESG | 20 min |
| 02 | [Token Creation](Module-5-Reference/02-token-creation-guide.md) | Coin, CoinManager, Closed-Loop Token | 30 min |
| 03 | [Cheat Sheet](Module-5-Reference/03-cheat-sheet.md) | Comandi CLI, pattern comuni, quick reference | -- |

---

## Indice degli Esempi

| Esempio | Stato | Documenti associati | Directory |
|---------|-------|--------------------|-----------|
| Dummy Audit Trails | Completo | M1-06, M1-07 | `examples/dummy-audit-trails/` |
| Gas Station Sidecar | Completo | M3-01 | `examples/gas-station-sidecar/` |
| Hierarchies | In sviluppo | M2-04 | `examples/hierarchies/` |
| Identity Basics | Pianificato | M2-02, M2-03 | `examples/identity-basics/` |
| Notarization Basics | Pianificato | M2-05 | `examples/notarization-basics/` |

---

## Risorse Esterne

- [IOTA Developer Documentation](https://docs.iota.org)
- [IOTA Explorer (Testnet)](https://explorer.rebased.iota.org)
- [IOTA Explorer (Mainnet)](https://explorer.iota.org)
- [IOTA GitHub](https://github.com/iotaledger)
- [DPP Demo Showcase](https://dpp.demo.iota.org/)
