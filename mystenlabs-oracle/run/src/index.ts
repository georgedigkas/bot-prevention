// Import the necessary modules from @mysten/sui.js
import {
  Connection,
  Ed25519Keypair,
  JsonRpcProvider,
  RawSigner,
  TransactionBlock,
} from "@mysten/sui.js";

// Import the dotenv module to load environment variables from a .env file
import * as dotenv from "dotenv";

// Load the .env file from the parent directory
dotenv.config({ path: "../.env" });

// Get the phrase and fullnode values from the environment variables
const phrase = process.env.ADMIN_PHRASE;
const fullnode = process.env.FULLNODE!;

// Derive a keypair from the phrase using the Ed25519 algorithm
const keypair = Ed25519Keypair.deriveKeypair(phrase!);

// Create a provider that connects to the fullnode using JSON-RPC protocol
const provider = new JsonRpcProvider(
  new Connection({
    fullnode: fullnode,
  })
);

// Create a signer that uses the keypair and the provider to sign transactions
const signer = new RawSigner(keypair, provider);

// Get the package IDs of the mystenlabs oracle and the demo app from the environment variables
const mystenlabsOraclePackageId = process.env.MYSTENLABS_ORACLE_PACKAGE_ID;
const mystenlabsOracleModuleName = "mystenlabs_oracle";

const demoAppPackageId = process.env.DEMO_APP_PACKAGE_ID;
const demoAppModuleName = "interact";

// Create a new transaction block to store multiple transactions
let transactionBlock = new TransactionBlock();

// Call the authorize function from the mystenlabs oracle module and store the result in authorization
const authorization = transactionBlock.moveCall({
  target: `${mystenlabsOraclePackageId}::${mystenlabsOracleModuleName}::authorize`,
});

// Call the interact function from the demo app module and pass the authorization as an argument
transactionBlock.moveCall({
  target: `${demoAppPackageId}::${demoAppModuleName}::interact`,
  arguments: [authorization],
});

// Set the gas budget for the transaction block to 10 million units
transactionBlock.setGasBudget(10000000);

// Sign and execute the transaction block using the signer and wait for local execution
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
    // Log the result to the console
    console.log(result);
  });
