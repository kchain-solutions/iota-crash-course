import * as dotenv from "dotenv";
import { IotaClient, type TransactionEffects } from "@iota/iota-sdk/client";
import { type ObjectRef, Transaction } from "@iota/iota-sdk/transactions";
import { Ed25519Keypair } from "@iota/iota-sdk/keypairs/ed25519";
import {
  IOTA_PRIVATE_KEY_PREFIX,
  decodeIotaPrivateKey,
} from "@iota/iota-sdk/cryptography";
import { toB64 } from "@iota/bcs";
import axios from "axios";
import { bech32 } from "bech32";

// ---------------------------------------------------------------------------
// Sponsored Hello World — Gas Station Example
// ---------------------------------------------------------------------------
// This script calls hello_world::hello::create via a Gas Station.
// The sender does NOT need IOTA. The Gas Station sponsors the transaction.
//
// Flow:
//   1. Load sender keypair from SERVICE_ACCOUNT_PRIVATE_KEY
//   2. Reserve gas from Gas Station (POST /v1/reserve_gas)
//   3. Build a Transaction with moveCall to hello::create
//   4. Sign locally with the sender's key
//   5. Submit to Gas Station for co-signing (POST /v1/execute_tx)
//   6. Print the explorer link
// ---------------------------------------------------------------------------

dotenv.config();

const nodeUrl = process.env.NODE_URL!;
const explorerUrl = process.env.EXPLORER_URL!;
const gasStationUrl = process.env.GAS_STATION_URL!;
const gasStationAuth = process.env.GAS_STATION_AUTH!;
const senderKey = process.env.SERVICE_ACCOUNT_PRIVATE_KEY!;
const packageId = process.env.PACKAGE_ID!;

interface ReserveGasResult {
  sponsor_address: string;
  reservation_id: number;
  gas_coins: ObjectRef[];
}

// Load an Ed25519 keypair from a private key (bech32 or base64)
function loadKeypair(key: string): Ed25519Keypair {
  let decoded;
  if (key.startsWith(IOTA_PRIVATE_KEY_PREFIX)) {
    decoded = decodeIotaPrivateKey(key);
  } else {
    const keyBech32 = bech32.encode(
      IOTA_PRIVATE_KEY_PREFIX,
      bech32.toWords(Buffer.from(key, "base64"))
    );
    decoded = decodeIotaPrivateKey(keyBech32);
  }
  return Ed25519Keypair.fromSecretKey(decoded.secretKey);
}

// Reserve gas coins from the Gas Station
async function reserveGas(gasBudget: number): Promise<ReserveGasResult> {
  const response = await axios.post(
    `${gasStationUrl}/v1/reserve_gas`,
    {
      gas_budget: gasBudget,
      reserve_duration_secs: 10,
    },
    {
      headers: { Authorization: `Bearer ${gasStationAuth}` },
    }
  );
  return response.data.result;
}

// Submit the signed transaction to the Gas Station for co-signing and execution
async function executeSponsored(
  reservationId: number,
  txBytes: Uint8Array,
  userSignature: string
): Promise<TransactionEffects> {
  const response = await axios.post(
    `${gasStationUrl}/v1/execute_tx`,
    {
      reservation_id: reservationId,
      tx_bytes: toB64(txBytes),
      user_sig: userSignature,
    },
    {
      headers: { Authorization: `Bearer ${gasStationAuth}` },
    }
  );
  return response.data.effects;
}

async function main() {
  // Validate env
  for (const [name, value] of Object.entries({
    NODE_URL: nodeUrl,
    GAS_STATION_URL: gasStationUrl,
    GAS_STATION_AUTH: gasStationAuth,
    SERVICE_ACCOUNT_PRIVATE_KEY: senderKey,
    PACKAGE_ID: packageId,
  })) {
    if (!value) {
      console.error(`Missing environment variable: ${name}`);
      console.error("Copy .env.example to .env and fill in the values.");
      process.exit(1);
    }
  }

  const client = new IotaClient({ url: nodeUrl });
  const keypair = loadKeypair(senderKey);
  const senderAddress = keypair.getPublicKey().toIotaAddress();

  console.log("=== Sponsored Hello World ===\n");
  console.log(`Service Account: ${senderAddress}`);
  console.log(`Package:         ${packageId}`);
  console.log(`Gas Station:     ${gasStationUrl}\n`);

  // 1. Reserve gas from the Gas Station
  const gasBudget = 50_000_000; // 0.05 IOTA
  console.log("Reserving gas from Gas Station...");
  const reservation = await reserveGas(gasBudget);
  console.log(`Sponsor:      ${reservation.sponsor_address}`);
  console.log(`Reservation:  ${reservation.reservation_id}\n`);

  // 2. Build the transaction: call hello_world::hello::create
  const tx = new Transaction();
  tx.moveCall({
    target: `${packageId}::hello::create`,
  });

  // Set sender and sponsor details
  tx.setSender(senderAddress);
  tx.setGasOwner(reservation.sponsor_address);
  tx.setGasPayment(reservation.gas_coins);
  tx.setGasBudget(gasBudget);

  // 3. Build and sign locally
  console.log("Signing transaction...");
  const unsignedTxBytes = await tx.build({ client });
  const signed = await keypair.signTransaction(unsignedTxBytes);

  // 4. Submit to Gas Station for co-signing and execution
  console.log("Submitting to Gas Station...\n");
  const effects = await executeSponsored(
    reservation.reservation_id,
    unsignedTxBytes,
    signed.signature
  );

  // 5. Print result
  const status = effects.status?.status;
  const digest = effects.transactionDigest;

  if (status === "success") {
    console.log("Transaction successful!");
    console.log(`Explorer: ${explorerUrl}/txblock/${digest}?network=testnet`);

    // Find the created HelloObject
    const created = effects.created;
    if (created && created.length > 0) {
      console.log(`\nCreated objects:`);
      for (const obj of created) {
        const ref = obj.reference;
        console.log(`  ${explorerUrl}/object/${ref.objectId}?network=testnet`);
      }
    }
  } else {
    console.error(`Transaction failed: ${status}`);
    console.error(effects);
  }
}

main().catch((err) => {
  console.error("Error:", err.message || err);
  process.exit(1);
});
