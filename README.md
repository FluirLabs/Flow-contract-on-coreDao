

# Fluir Smart Contract

> “Money should move as seamlessly as information. Real-time streaming of value unlocks use cases we haven’t even imagined yet.”
> — **Vitalik Buterin**, Co-founder of Ethereum

**Fluir** is a real-time token distribution protocol deployed on **Core DAO**, enabling trustless, continuous, and flexible value transfer. Built for DAOs, teams, and protocols, Fluir transforms how tokens are vested, earned, and distributed on-chain.

---

## Why Core DAO Needs Fluir

Core DAO provides speed and decentralization, but teams still rely on spreadsheets, manual approvals, or custodial tools to release vested tokens and pay contributors.

**Fluir changes that.**

It offers an on-chain infrastructure for **automated token vesting**, contributor payments, grants, and more — all in real time. With Fluir, value flows according to transparent rules, eliminating ambiguity, delays, and misaligned incentives.

Fluir is Core’s missing financial layer for trustless capital distribution.

---

## What Fluir Enables

* Token vesting with cliffs and linear unlocks
* Real-time value distribution to contributors, DAOs, investors
* Stream control: pause, resume, extend, terminate
* Batch execution for scalable token operations
* Update recipients mid-stream without disrupting logic
* Transparent flow of capital, visible and enforceable on-chain

---

## Vesting Infrastructure Built In

Vesting is foundational to every serious Web3 protocol. Fluir introduces:

* **Cliffs** — Lock value until a defined start period
* **Intervals** — Gradual, continuous release across time
* **Accountability** — Ability to pause or terminate streams
* **Flexibility** — Update recipient, extend duration, settle balances
* **Transparency** — No hidden unlocks, everything lives on-chain

---

## Constructor

```solidity
constructor(
  address owner_,
  address weth_,
  address feeRecipient_,
  address autoWithdrawAccount_
)
```

Deploys Fluir with the necessary Core DAO-compatible configuration.

---

## Core Functions

| Function                                          | Description                                  |
| ------------------------------------------------- | -------------------------------------------- |
| `initializeFlow()` / `bulkCreateFlow()`           | Create a stream or multiple                  |
| `claimFromFlow()` / `bulkClaimFromFlow()`         | Claim unlocked balance                       |
| `prolongFlow()` / `bulkExtendFlow()`              | Extend end date of a stream                  |
| `haltFlow()` / `restartFlow()`                    | Pause or resume ongoing stream               |
| `terminateFlow()` / `bulkTerminateFlow()`         | End stream and settle balances               |
| `updateBeneficiary()` / `bulkUpdateBeneficiary()` | Assign new recipient                         |
| `availableFunds()`                                | View available funds for sender or recipient |

---

## Fee Structure

* **Per-token streaming fee**: Set by owner, in basis points
* **Auto-withdraw fee**: Fixed at `0.005 ETH`
* **Fee recipient**: Platform wallet to fund treasury or ecosystem growth

Only approved tokens can be streamed via Fluir.

```solidity
registerAsset(address token, uint256 feeRate)
bulkRegisterAsset(address[] tokens, uint256[] feeRates)
```

---

## Admin Controls

* `updateFeeCollector(address)` — Set new fee receiver
* `updateAutoClaimAccount(address)` — Change auto-withdraw wallet
* `configureGateway(address)` — Integrate off-chain or L2 logic
* `registerAsset()` / `bulkRegisterAsset()` — Add tokens and set streaming fees

---

## Technical Overview

* Modular Solidity architecture: `CreateLogic`, `ExtendLogic`, `WithdrawLogic`
* Secure by design: uses OpenZeppelin’s `SafeERC20`, `Ownable`, `ReentrancyGuard`
* Clean separation of stream state: handled via `Struct.sol`
* Interface exposed through `IStream.sol` for easy integration

---

## Subgraph Integration

Track real-time flows, pauses, updates, and claims via The Graph:

**Subgraph Playground**
[https://thegraph.com/hosted-service/subgraph/YOUR\_NAME/fluir-coredao](https://thegraph.com/hosted-service/subgraph/YOUR_NAME/fluir-coredao)

*Replace with your actual subgraph path.*

---

## Use Cases

* Token vesting for teams, advisors, and investors
* Continuous contributor rewards for DAO operations
* Ecosystem grant disbursement without trust assumptions
* Escrow-like financial contracts governed on-chain
* Royalty and licensing payments to creators or service providers

---

## Testing Suggestions

* Simulate a 12-month vesting stream with a 3-month cliff
* Pause a stream and resume after delay — check time sync
* Update the recipient and verify uninterrupted payout
* Batch create and terminate 100+ flows for scalability
* Validate token fee accuracy and auto-withdraw balance return

---

## Live on Core DAO

Fluir is now live on Core — bringing modern capital flows to one of the most decentralized and secure EVM networks.

It’s built for serious builders who want to unlock fair, flexible, and transparent token distribution — from day one to scale.

---

## License

Licensed under **AGPL-3.0**.

