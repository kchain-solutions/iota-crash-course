# Getting Started con IOTA MoveVM

> **Prerequisiti:** Nessuno
> **Tempo stimato:** 30 minuti
> **Hands-On:** Installare tool, creare un account, eseguire il primo comando

---

## Panoramica

Questa guida ti accompagna nell'installazione dell'ambiente di sviluppo IOTA, dalla CLI alle estensioni IDE, fino alla creazione del tuo primo account e la verifica che tutto funzioni correttamente.

## 1. Prerequisiti di Sistema

Prima di iniziare, assicurati di avere:

| Requisito | Versione minima | Verifica |
|-----------|----------------|----------|
| **Sistema Operativo** | macOS, Linux, Windows (WSL2) | -- |
| **Rust** | 1.75+ | `rustc --version` |
| **Git** | 2.x | `git --version` |
| **Node.js** (per esempi TypeScript) | 18+ | `node --version` |
| **pnpm** (per esempi TypeScript) | 8+ | `pnpm --version` |

### Installare Rust

Se non hai Rust installato:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

Oppure usa il Makefile del progetto:

```bash
make install-rust
```

## 2. Installare la IOTA CLI

La IOTA CLI e' lo strumento principale per lo sviluppo Move. Puoi installarla da sorgente:

```bash
cargo install --locked --git https://github.com/iotaledger/iota.git --branch mainnet --features tracing iota
```

Per una specifica rete di sviluppo, sostituisci `mainnet` con `testnet` o `devnet`.

Oppure usa il Makefile:

```bash
make install-iota-cli
```

### Verifica l'installazione

```bash
which iota
iota --version
```

### Workaround macOS (binari scaricati)

Se scarichi il binario pre-compilato su macOS, potresti dover rimuovere l'attributo di quarantena:

```bash
xattr -d com.apple.quarantine ./iota
```

## 3. Configurazione della Rete

IOTA supporta diverse reti. Per lo sviluppo, usa la testnet:

```bash
# Connettiti alla testnet
iota client new-env --alias testnet --rpc https://api.testnet.iota.cafe

# Verifica gli ambienti configurati
iota client envs

# Passa alla testnet
iota client switch --env testnet
```

### Reti disponibili

| Rete | RPC URL | Explorer | Uso |
|------|---------|----------|-----|
| **Testnet** | `https://api.testnet.iota.cafe` | [explorer.rebased.iota.org](https://explorer.rebased.iota.org) | Sviluppo e test |
| **Devnet** | `https://api.devnet.iota.cafe` | [explorer.rebased.iota.org](https://explorer.rebased.iota.org) | Feature sperimentali |
| **Mainnet** | `https://api.mainnet.iota.cafe` | [explorer.iota.org](https://explorer.iota.org) | Produzione |
| **Locale** | `http://127.0.0.1:9000` | -- | Test offline |

### Rete locale (opzionale)

Per test offline puoi avviare una rete locale:

```bash
RUST_LOG="off,iota_node=info" iota start --force-regenesis --with-faucet
```

## 4. Setup IDE

Per la migliore esperienza di sviluppo Move, installa l'estensione VSCode:

1. Apri VSCode
2. Cerca **"Move (IOTA)"** nel marketplace delle estensioni (publisher: `iotaledger`)
3. Installa l'estensione

L'estensione fornisce:
- Syntax highlighting per file `.move`
- Completamento automatico
- Controllo errori in tempo reale
- Navigazione tra definizioni

## 5. Creare il Primo Account

Un account IOTA e' necessario per interagire con la rete. Crea il tuo primo account:

```bash
# Crea un nuovo account
make create-account ALIAS=dev

# Oppure direttamente via CLI
iota client new-address ed25519
```

### Richiedere token dal Faucet

Per la testnet, puoi ottenere token gratuiti per pagare le transazioni:

```bash
make faucet

# Oppure direttamente
iota client faucet
```

### Verificare il bilancio

```bash
make balance

# Oppure
iota client balance
```

Dovresti vedere un bilancio positivo dopo aver usato il faucet.

## 6. Comandi Essenziali

| Comando | Descrizione |
|---------|-------------|
| `iota client active-address` | Mostra l'indirizzo attivo |
| `iota client active-env` | Mostra la rete attiva |
| `iota client balance` | Mostra il bilancio |
| `iota client faucet` | Richiedi token di test |
| `iota keytool list` | Lista tutti gli indirizzi |
| `iota move new <nome>` | Crea un nuovo progetto Move |
| `iota move build` | Compila un pacchetto Move |
| `iota move test` | Esegui i test |

## 7. Smoke Test (5 minuti)

Verifica che tutto funzioni creando un progetto Move di prova:

```bash
# 1. Crea un progetto di test
iota move new hello_iota

# 2. Entra nella directory
cd hello_iota

# 3. Compila (scarica le dipendenze)
iota move build

# 4. Esegui i test (nessun test ancora, ma verifica la build)
iota move test

# 5. Pulisci
cd ..
rm -rf hello_iota
```

Se tutti i comandi completano senza errori, il tuo ambiente e' pronto.

## 8. Struttura di un Progetto Move

Quando crei un nuovo progetto, viene generata questa struttura:

```
progetto/
├── Move.toml       # Configurazione del pacchetto e dipendenze
├── sources/        # File sorgente Move (.move)
└── tests/          # File di test (opzionale, i test possono stare in sources/)
```

Il file `Move.toml` definisce il nome del pacchetto, la versione e le dipendenze:

```toml
[package]
name = "hello_iota"
edition = "2024"

[dependencies]
Iota = { git = "https://github.com/iotaledger/iota.git", subdir = "crates/iota-framework/packages/iota-framework", rev = "framework/testnet" }

[addresses]
hello_iota = "0x0"
```

## 9. Verificare le Dipendenze del Progetto

Dal repository del crash course, puoi verificare che tutte le dipendenze siano installate:

```bash
make check-dependencies
```

Questo comando controlla Rust, IOTA CLI e le versioni installate.

---

## Prossimo Passo

Ora che il tuo ambiente e' configurato, procedi con i concetti fondamentali:

**Prossimo:** [02 - Key Concepts: EVM vs MoveVM](02-key-concepts.md)
