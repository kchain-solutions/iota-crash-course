import express from "express";
import { Ed25519Keypair } from "@iota/iota-sdk/keypairs/ed25519";
import { fromBase64, toB64 } from "@iota/iota-sdk/utils";
import {
  toSerializedSignature,
  messageWithIntent,
} from "@iota/iota-sdk/cryptography";
import { blake2b } from "@noble/hashes/blake2b";

// ---------------------------------------------------------------------------
// Local KMS Sidecar for IOTA Gas Station
// ---------------------------------------------------------------------------
// Same API contract as the AWS KMS sidecar, but signs locally with an
// Ed25519 keypair loaded from the GAS_STATION_PRIVATE_KEY env var.
//
// Use this for:
//   - Development and staging (no AWS costs)
//   - Self-hosted deployments without cloud dependency
//   - Testing the Gas Station sidecar integration
//
// In production with high-value keys, replace with the AWS KMS sidecar
// or a HashiCorp Vault sidecar.
// ---------------------------------------------------------------------------

function loadKeypair(): Ed25519Keypair {
  const privateKeyB64 = process.env.GAS_STATION_PRIVATE_KEY;
  if (!privateKeyB64) {
    throw new Error(
      "GAS_STATION_PRIVATE_KEY env var is required (base64-encoded Ed25519 secret key)"
    );
  }
  return Ed25519Keypair.fromSecretKey(fromBase64(privateKeyB64));
}

async function main() {
  const keypair = loadKeypair();
  const address = keypair.getPublicKey().toIotaAddress();
  console.log(`Sidecar loaded. IOTA address: ${address}`);

  const app = express();
  app.use(express.json());

  const port = Number(process.env.PORT) || 8001;

  // Health check
  app.get("/", (_req, res) => {
    res.send("Local KMS Sidecar OK");
  });

  // Return the IOTA address derived from the signing key
  app.get("/get-pubkey-address", (_req, res) => {
    try {
      res.json({ iotaPubkeyAddress: address });
    } catch (error) {
      console.error("get-pubkey-address error:", error);
      res.status(500).send("Internal server error");
    }
  });

  // Sign transaction bytes and return a serialized IOTA signature
  app.post("/sign-transaction", async (req, res) => {
    try {
      const { txBytes } = req.body;

      if (!txBytes) {
        return res.status(400).send("Missing txBytes in request body");
      }

      const txBytesArray = fromBase64(txBytes);

      // Reproduce the same intent hashing the Gas Station expects:
      //   digest = blake2b( intent || txBytes )
      const intentMessage = messageWithIntent("TransactionData", txBytesArray);
      const digest = blake2b(intentMessage, { dkLen: 32 });

      // Sign the digest with the local Ed25519 key
      const signature = await keypair.sign(digest);

      // Pack into IOTA serialized signature format: flag || sig || pk
      const serializedSignature = toSerializedSignature({
        signatureScheme: "ED25519",
        signature,
        publicKey: keypair.getPublicKey(),
      });

      console.log(`Signed tx (${txBytesArray.length} bytes)`);
      res.json({ signature: serializedSignature });
    } catch (error) {
      console.error("sign-transaction error:", error);
      res.status(500).send("Internal server error");
    }
  });

  app.listen(port, () => {
    console.log(`Local KMS Sidecar listening on http://localhost:${port}`);
  });
}

main();
