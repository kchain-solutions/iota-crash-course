# Testing e Debugging degli Smart Contract Move

> **Prerequisiti:** [04 - Smart Contract](04-smart-contract.md)
> **Tempo stimato:** 45 minuti
> **Hands-On:** Scrivere e eseguire test, usare il debugger, verificare la coverage
> **Prossimo:** [06 - Dummy Audit Trails](06-dummy-audit-trails.md)

---

## Panoramica

In Move, i contratti pubblicati su blockchain sono **immutabili** (a meno di upgrade espliciti). Questo rende il testing particolarmente critico: non puoi "patchare" un bug dopo il deploy. Questa guida copre unit test, test multi-transazione con `test_scenario`, debugging e coverage.

## 1. Unit Test Basics

### Sintassi dei Test

I test Move sono funzioni pubbliche annotate con `#[test]`:

```move
#[test]
public fun test_sword_creation() {
    // Crea un contesto di test
    let mut ctx = tx_context::dummy();

    // Crea un oggetto
    let sword = Sword {
        id: object::new(&mut ctx),
        magic: 42,
        strength: 7,
    };

    // Verifica i valori
    assert!(magic(&sword) == 42, 0);
    assert!(strength(&sword) == 7, 1);

    // IMPORTANTE: gli oggetti con `key` senza `drop` devono essere consumati
    let dummy_address = @0xCAFE;
    transfer::public_transfer(sword, dummy_address);
}
```

### Regole fondamentali

- I test sono funzioni `public` senza parametri e senza return
- L'annotazione `#[test]` marca la funzione come test
- Gli oggetti senza ability `drop` **devono** essere trasferiti o distrutti prima che la funzione termini
- Usa `assert!(condizione, codice_errore)` per le verifiche

### Eseguire i Test

```bash
# Esegui tutti i test
iota move test

# Esegui solo test che contengono "sword" nel nome
iota move test sword

# Output atteso
# [ PASS    ] 0x0::my_module::test_sword_creation
# Test result: OK. Total tests: 1; passed: 1; failed: 0
```

## 2. Test Multi-Transazione con `test_scenario`

Il vero potere del testing Move sta nel modulo `iota::test_scenario`, che permette di simulare una sequenza di transazioni da utenti diversi, come accadrebbe on-chain.

### Concetti Chiave

| Funzione | Scopo |
|----------|-------|
| `test_scenario::begin(sender)` | Inizia uno scenario con un indirizzo sender |
| `test_scenario::next_tx(scenario, sender)` | Avanza alla transazione successiva con un nuovo sender |
| `test_scenario::take_from_sender(scenario)` | Prendi un oggetto appartenente al sender corrente |
| `test_scenario::take_from_address(scenario, addr)` | Prendi un oggetto da un indirizzo specifico |
| `test_scenario::return_to_sender(scenario, obj)` | Restituisci un oggetto al sender |
| `test_scenario::end(scenario)` | Concludi lo scenario (verifica cleanup) |

### Esempio Completo: Test Multi-Utente

```move
#[test]
public fun test_sword_transactions() {
    // 1. Definisci gli utenti
    let admin = @0xAD;
    let initial_owner = @0xAA;
    let final_owner = @0xBB;

    // 2. Inizia lo scenario come admin
    let mut scenario = test_scenario::begin(admin);

    // 3. Prima transazione: admin crea una sword
    {
        // Simula l'init del modulo
        init(test_scenario::ctx(&mut scenario));
    };

    // 4. Seconda transazione: admin crea e trasferisce la sword
    test_scenario::next_tx(&mut scenario, admin);
    {
        let mut forge = test_scenario::take_from_sender<Forge>(&scenario);
        let sword = new_sword(&mut forge, 42, 7, test_scenario::ctx(&mut scenario));
        transfer::public_transfer(sword, initial_owner);
        test_scenario::return_to_sender(&scenario, forge);
    };

    // 5. Terza transazione: initial_owner trasferisce a final_owner
    test_scenario::next_tx(&mut scenario, initial_owner);
    {
        let sword = test_scenario::take_from_sender<Sword>(&scenario);
        transfer::public_transfer(sword, final_owner);
    };

    // 6. Quarta transazione: final_owner verifica
    test_scenario::next_tx(&mut scenario, final_owner);
    {
        let sword = test_scenario::take_from_sender<Sword>(&scenario);
        assert!(magic(&sword) == 42, 0);
        assert!(strength(&sword) == 7, 1);
        test_scenario::return_to_sender(&scenario, sword);
    };

    // 7. Concludi lo scenario
    test_scenario::end(scenario);
}
```

### Regola Importante: Effetti delle Transazioni

In `test_scenario`, gli effetti di una transazione (come creare o trasferire un oggetto) sono disponibili solo nella transazione **successiva**.

Ad esempio: se la transazione 2 crea una `Sword` e la trasferisce all'indirizzo admin, quell'oggetto sara' recuperabile dall'indirizzo admin solo a partire dalla transazione 3.

```move
// Se serve recuperare un oggetto da un indirizzo specifico
// (non necessariamente il sender corrente):
let sword = test_scenario::take_from_address<Sword>(&scenario, initial_owner);
```

## 3. Utility di Test: `iota::test_utils`

Il modulo `iota::test_utils` fornisce helper per semplificare le asserzioni:

```move
use iota::test_utils;

#[test]
public fun test_assert_utils() {
    // Confronto di uguaglianza (piu' leggibile di assert!)
    test_utils::assert_eq(42u64, 42u64);

    // Confronto di vettori (ordine irrilevante)
    let v1 = vector[1, 2, 3];
    let v2 = vector[3, 1, 2];
    test_utils::assert_same_elems(v1, v2);

    // Distruggi un oggetto quando non serve piu'
    let mut ctx = tx_context::dummy();
    let obj = MyObject { id: object::new(&mut ctx), value: 0 };
    test_utils::destroy(obj);
}
```

| Funzione | Scopo |
|----------|-------|
| `assert_eq(t1, t2)` | Fallisce se `t1 != t2` |
| `assert_same_elems(v1, v2)` | Verifica che due vettori contengano gli stessi elementi |
| `destroy(x)` | Distrugge un oggetto (utile per cleanup nei test) |

## 4. Debugging con `std::debug`

Quando un test fallisce e non e' chiaro il motivo, puoi usare `std::debug` per stampare valori:

```move
use std::debug;

#[test]
public fun test_with_debug() {
    let value = 42u64;

    // Stampa un valore
    debug::print(&value);
    // Output: [debug] 42

    // Stampa lo stack trace
    debug::print_stack_trace();
}
```

### Quando usare il debug

- Quando un `assert!` fallisce e non capisci perche'
- Per ispezionare lo stato di un oggetto durante i test
- Per tracciare il flusso di esecuzione in scenari complessi

**Nota:** `debug::print` funziona solo durante i test (`iota move test`), non on-chain.

## 5. Test Coverage

La coverage ti dice quale percentuale del tuo codice e' coperta dai test.

```bash
# Step 1: Esegui i test con flag coverage
iota move test --coverage

# Step 2: Visualizza il sommario
iota move coverage summary --test
```

Output tipico:

```
+-------------------------+
| Move Coverage Summary   |
+-------------------------+
Module 0x0::my_module
>>> % Module coverage: 92.81
+-------------------------+
| % Move Coverage: 92.81  |
+-------------------------+
```

### Obiettivo di Coverage

Per smart contract che gestiscono asset di valore, punta ad almeno l'**80% di coverage**. Per funzioni critiche (trasferimenti, creazione di asset), punta al **100%**.

## 6. Errori Comuni e Come Risolverli

### "unused value without 'drop'"

```
error[E06001]: unused value without 'drop'
   -- sources/my_module.move:55:65
   |
 4 |       public struct Sword has key, store {
   |                     ----- To satisfy the constraint, the 'drop' ability
   |                           would need to be added here
```

**Causa:** Hai creato un oggetto nel test ma non lo hai consumato (trasferito o distrutto).

**Soluzione:** Trasferisci l'oggetto o usa `test_utils::destroy()`:

```move
// Opzione 1: trasferisci
transfer::public_transfer(sword, @0xCAFE);

// Opzione 2: distruggi (solo nei test)
test_utils::destroy(sword);
```

### "object does not exist"

**Causa:** Stai cercando di prendere un oggetto nella stessa transazione in cui e' stato creato.

**Soluzione:** Usa `test_scenario::next_tx()` prima di recuperare l'oggetto.

### "object owned by a different address"

**Causa:** Stai usando `take_from_sender` ma l'oggetto appartiene a un altro indirizzo.

**Soluzione:** Usa `take_from_address(scenario, correct_address)`.

## 7. Esercizio Pratico: Testare Audit Trails

Prova ad aggiungere test al contratto `dummy-audit-trails`. Ecco uno schema di partenza:

```move
#[test]
public fun test_create_product() {
    let manufacturer = @0xMANU;
    let mut scenario = test_scenario::begin(manufacturer);

    // 1. Crea un prodotto
    {
        create_product(
            b"Widget X",
            b"SN-001",
            b"https://example.com/img.png",
            test_scenario::ctx(&mut scenario)
        );
    };

    // 2. Verifica che il prodotto esista come shared object
    test_scenario::next_tx(&mut scenario, manufacturer);
    {
        let product = test_scenario::take_shared<Product>(&scenario);
        // Verifica i campi...
        test_scenario::return_shared(product);
    };

    test_scenario::end(scenario);
}
```

**Hands-On:** L'esempio completo si trova in `examples/dummy-audit-trails/`. Prova a compilare e testare con:

```bash
make audit-trail-build
```

## 8. Best Practices

1. **Testa ogni entry function** - Ogni funzione pubblica dovrebbe avere almeno un test
2. **Testa gli scenari negativi** - Verifica che le operazioni non autorizzate falliscano
3. **Usa test_scenario per flussi multi-utente** - Simula interazioni realistiche
4. **Pulisci sempre gli oggetti** - Ogni oggetto creato deve essere consumato
5. **Esegui la coverage regolarmente** - Prima di ogni publish, verifica la coverage
6. **Nomi descrittivi** - `test_cannot_transfer_without_permission` > `test_fail_1`

## Risorse Aggiuntive

- **[Build and Test - IOTA Docs](https://docs.iota.org/developer/getting-started/build-test)** - Guida ufficiale completa
- **[test_scenario source](https://github.com/iotaledger/iota/blob/develop/crates/iota-framework/packages/iota-framework/sources/test/test_scenario.move)** - Codice sorgente del modulo
- **[Move CLI Reference](https://docs.iota.org/references/cli/move)** - Tutti i flag disponibili per `iota move test`

---

**Prossimo:** [06 - Dummy Audit Trails](06-dummy-audit-trails.md)
