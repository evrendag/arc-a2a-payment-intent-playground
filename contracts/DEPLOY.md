# Testnet deployment and lifecycle

This contract is experimental and unaudited. Use Arc Testnet only.

## Network

- Chain ID: 5042002
- RPC: https://rpc.testnet.arc.io
- Explorer: https://explorer.testnet.arc.io
- USDC ERC-20 interface: 0x3600000000000000000000000000000000000000

Get testnet USDC from the official Circle faucet before testing.

## Deploy with Remix

1. Open https://remix.ethereum.org.
2. Create `PaymentIntentRegistry.sol` and paste the contract from this folder.
3. Compile with Solidity 0.8.24.
4. In **Deploy & Run Transactions**, choose **Injected Provider - MetaMask**.
5. Switch MetaMask to Arc Testnet.
6. Enter the testnet USDC interface address in the constructor field.
7. Click **Deploy** and confirm the deployment in MetaMask.
8. Save the deployed contract address and transaction hash.

## Test one intent

The creator must first approve the registry contract to spend the testnet USDC. Use the USDC contract's `approve(registry, amount)` function. Amounts use 6 decimals: 0.01 USDC is `10000`.

Then call:

1. `createIntent(recipient, executor, amount, purposeHash, expiry)`
2. `approveIntent(1)`
3. `executeIntent(1)`

Use a future Unix timestamp for `expiry`. For a cancellation test, call `cancelIntent(1)` instead of `executeIntent(1)`. For an expiry test, wait until expiry and call `expireIntent(1)`.

Every state-changing step opens a separate MetaMask confirmation. Do not use a mainnet token address or real funds with this experimental contract.
