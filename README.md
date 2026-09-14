# Arc A2A Payment Intent Playground

An experimental, human-readable format for AI agents to describe a proposed USDC payment before it is signed.

This project is a small learning tool for exploring agent-to-agent payments on Arc Testnet. It does not custody funds, sign transactions, or claim to be an official Arc standard.

## Why payment intents?

An agent should not jump directly from a task to a transfer. Before signing, a user or policy engine should be able to inspect:

- who will receive the payment;
- which network and token are used;
- the maximum amount;
- why the payment is being requested;
- when the request expires;
- whether the same request has already been processed.

A payment intent makes those details explicit.

## Example lifecycle

`created → reviewed → approved → submitted → confirmed`

A request can also become `rejected`, `expired`, or `cancelled`. The intent is not a transaction receipt; it is a proposal that can be reviewed before execution.

## Files

- `payment-intent.schema.json` — JSON Schema for the experimental format.
- `examples/research-agent-payment.json` — an agent paying for a research API call.
- `examples/merchant-agent-payment.json` — an agent preparing a merchant payment.
- `src/preview.html` — a dependency-free preview page that validates the important fields visually.

## Run the preview

Open `src/preview.html` directly in a browser. No wallet connection or API key is required.

## Important limitations

This is an educational prototype. It does not verify wallet ownership, guarantee payment settlement, or replace a production payment authorization system. Always use a dedicated test wallet and testnet assets while experimenting.

Feedback and examples from Arc builders are welcome.
