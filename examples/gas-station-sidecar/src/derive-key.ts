import { Ed25519Keypair } from "@iota/iota-sdk/keypairs/ed25519";
import { decodeIotaPrivateKey } from "@iota/iota-sdk/cryptography";
import { toB64 } from "@iota/bcs";

// Derives an Ed25519 keypair from a mnemonic phrase.
// Outputs JSON with address, bech32 private key, and base64 private key.
//
// Usage: npx tsx src/derive-key.ts "word1 word2 ... word12"

const mnemonic = process.argv[2];

if (!mnemonic) {
  console.error("Usage: npx tsx src/derive-key.ts <mnemonic>");
  process.exit(1);
}

const keypair = Ed25519Keypair.deriveKeypair(mnemonic);
const address = keypair.getPublicKey().toIotaAddress();
const privateKeyBech32 = keypair.getSecretKey();
const { secretKey } = decodeIotaPrivateKey(privateKeyBech32);
const privateKeyBase64 = toB64(secretKey);

console.log(
  JSON.stringify({
    address,
    privateKeyBech32,
    privateKeyBase64,
  })
);
