# Arc A2A Payment Intent Playground

An experimental, human-readable format for AI agents to describe a proposed USDC payment before it is signed.

This project is a small learning tool for exploring agent-to-agent payments on Arc Mainnet and Testnet. It does not custody funds, sign transactions, or claim to be an official Arc standard.

## What the agent demo includes

The new [ArcFlow Agent Payment Demo](src/agent-demo.html) demonstrates:

1. An agent identity and purpose.
2. A per-intent spending limit.
3. Mainnet/Testnet chain selection.
4. Payment-intent creation.
5. Human approval as the default policy.
6. A transparent result showing that no transaction was submitted.

The demo validates the recipient format and refuses amounts above the agent limit. It intentionally does not connect a wallet or broadcast a transaction yet.

## Why payment intents?

An agent should not jump directly from a task to a transfer. Before signing, a user or policy engine should be able to inspect:

- who will receive the payment;
- which network and token are used;
- the maximum amount;
- why the payment is being requested;
- when the request expires;
- whether the same request has already been processed.

A payment intent makes those details explicit.

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

Arc uses USDC as native gas. The native gas representation uses 18 decimals, while the ERC-20 interface uses 6 decimals. Applications should use the ERC-20 interface for balance reads and transfers and must not mix these decimal values.

## Example lifecycle

`created → reviewed → approved → submitted → confirmed`

A request can also become `rejected`, `expired`, or `cancelled`. The intent is not a transaction receipt; it is a proposal that can be reviewed before execution.

## Files

- `payment-intent.schema.json` — JSON Schema for the experimental format.
- `config/arc-networks.json` — mainnet and testnet network configuration.
- `config/agent-profile.json` — example agent purpose and spending policy.
- `examples/research-agent-payment.json` — an agent paying for a research API call.
- `examples/merchant-agent-payment.json` — an agent preparing a merchant payment.
- `src/preview.html` — payment intent preview.
- `src/agent-demo.html` — interactive agent payment preview.

## Run the demo

Open `src/agent-demo.html` directly in a browser. No wallet connection, private key, or API key is required.

## Important limitations

This is an educational prototype. It does not verify wallet ownership, guarantee payment settlement, or replace a production payment authorization system. Do not send real funds from this repository without independently reviewing the recipient, amount, network, contract code, and transaction data.

Feedback and examples from Arc builders are welcome.
