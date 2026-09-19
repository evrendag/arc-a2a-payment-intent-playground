# Arc A2A Payment Intent Playground

An experimental, human-readable format for AI agents to describe a proposed USDC payment before it is signed.

This project is a small learning tool for exploring agent-to-agent payments on Arc Mainnet and Testnet. It does not custody funds, hold private keys, or sign in the background. The wallet owner must approve the final MetaMask transaction.

## What the agent demo includes

The [ArcFlow Agent Payment Demo](src/agent-demo.html) demonstrates:

1. An agent identity and purpose.
2. A per-intent spending limit (default: 0.010000 USDC).
3. Arc Mainnet chain verification (chain ID 5042).
4. Payment-intent creation.
5. An explicit human approval checkbox.
6. MetaMask transaction preparation and user signature.
7. Confirmation status, transaction hash, and Arc Explorer link.

The demo uses the Arc USDC ERC-20 interface for the transfer. It does not use a private key or send anything until the user clicks the final button and approves the transaction in the wallet.

## Testnet smart contract

[PaymentIntentRegistry.sol](contracts/PaymentIntentRegistry.sol) adds an escrow-based lifecycle for agent payments:

`createIntent → approveIntent → executeIntent`

It also supports cancellation and expiry refunds. The contract is experimental and unaudited. Use it on Arc Testnet only. See the [testnet deployment guide](contracts/DEPLOY.md).

## Arc network configuration

Verified network settings are stored in [config/arc-networks.json](config/arc-networks.json).

Arc Mainnet:

- RPC: `https://rpc.mainnet.arc.io`
- Chain ID: `5042`
- Explorer: `https://explorer.arc.io`
- USDC ERC-20 interface: `0x3600000000000000000000000000000000000000`

Arc Testnet:

- RPC: `https://rpc.testnet.arc.io`
- Chain ID: `5042002`
- Explorer: `https://explorer.testnet.arc.io`

Arc uses USDC as native gas. The native gas representation uses 18 decimals, while the ERC-20 interface uses 6 decimals. The demo and escrow contract use 6-decimal ERC-20 units for payment amounts.

## Run the demo

Serve the repository over HTTPS (for example with GitHub Pages or another static host), open `src/agent-demo.html`, connect MetaMask, and verify the recipient and amount before signing.

A wallet connection alone does not spend money. The final “Sign & send real USDC” button opens the wallet confirmation. Use a small amount first and check the recipient carefully.

## Example lifecycle

`created → reviewed → approved → submitted → confirmed`

A request can also become `rejected`, `expired`, or `cancelled`. The payment intent is a reviewable proposal; the transaction receipt is only available after the wallet signs and the network confirms it.

## Files

- `payment-intent.schema.json` — JSON Schema for the experimental format.
- `config/arc-networks.json` — mainnet and testnet network configuration.
- `config/agent-profile.json` — example agent purpose and spending policy.
- `contracts/PaymentIntentRegistry.sol` — escrowed, human-approved payment intent contract.
- `contracts/DEPLOY.md` — Arc Testnet deployment and lifecycle guide.
- `examples/research-agent-payment.json` — an agent paying for a research API call.
- `examples/merchant-agent-payment.json` — an agent preparing a merchant payment.
- `src/preview.html` — payment intent preview.
- `src/agent-demo.html` — wallet-approved agent payment demo.

## Important limitations

This is an educational prototype, not an official Arc standard. Review the recipient, amount, network, token contract, and transaction data independently. Never enter a seed phrase or private key. Do not treat an onchain payment as reversible.

Feedback and examples from Arc builders are welcome.
