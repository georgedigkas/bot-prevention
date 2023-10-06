import {
  Connection,
  Ed25519Keypair,
  JsonRpcProvider,
  RawSigner,
  TransactionBlock,
} from "@mysten/sui.js";
import * as dotenv from "dotenv";

dotenv.config({ path: "../.env" });

const phrase = process.env.ADMIN_PHRASE;
const fullnode = process.env.FULLNODE!;
const keypair = Ed25519Keypair.deriveKeypair(phrase!);
const adminAddress = keypair.getPublicKey().toSuiAddress();
const provider = new JsonRpcProvider(
  new Connection({
    fullnode: fullnode,
  })
);
const signer = new RawSigner(keypair, provider);

const mystenlabsOraclePackageId = process.env.MYSTENLABS_ORACLE_PACKAGE_ID;
const mystenlabsOracleModuleName = "mystenlabs_oracle";

const demoAppPackageId = process.env.DEMO_APP_PACKAGE_ID;
const demoAppModuleName = "interact";

const weather_oracle =
  "0x1aedcca0b67b891c64ca113fce87f89835236b4c77294ba7e2db534ad49a58dc";

let transactionBlock = new TransactionBlock();

const authorization = transactionBlock.moveCall({
  target: `${mystenlabsOraclePackageId}::${mystenlabsOracleModuleName}::authorize`,
});

transactionBlock.moveCall({
  target: `${demoAppPackageId}::${demoAppModuleName}::interact`,
  arguments: [authorization],
});

transactionBlock.setGasBudget(10000000);
signer
  .signAndExecuteTransactionBlock({
    transactionBlock,
    requestType: "WaitForLocalExecution",
    options: {
      showObjectChanges: true,
      showEffects: true,
    },
  })
  .then((result) => {
    console.log(result);
  });