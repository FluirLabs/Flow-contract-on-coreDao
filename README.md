

# Fluir Smart Contract

> “Money should move as seamlessly as information. Real-time streaming of value unlocks use cases we haven’t even imagined yet.”
> — **Vitalik Buterin**, Co-founder of Ethereum

**Fluir** is a real-time token distribution protocol built for the Core DAO ecosystem. It allows DAOs, protocols, teams, and contributors to manage vesting, payroll, and incentive flows with on-chain precision  without relying on manual operations or trust assumptions.

---

## Why Core DAO Needs Fluir

Core DAO offers speed and decentralization  but builders still face fragmented tools for **token vesting**, **grants**, and **payroll**. Teams often rely on spreadsheets, off-chain agreements, or custodial wallets to handle value distribution.

**Fluir solves this with on-chain streaming.**

Whether you're vesting tokens to team members, rewarding DAO contributors, or managing multi-party payouts, Fluir allows for controlled and transparent capital flows backed entirely by smart contracts.

---

## Payroll, Built Natively for Web3

**Payroll in crypto is broken** — with delays, mismatched wallets, and manual payouts.

Fluir introduces an on-chain payroll infrastructure where:

* Contributors get paid continuously
* Teams can pause, resume, or terminate based on performance
* Wallets can be updated without interrupting payments
* DAOs can scale operations using batched flows
* Every stream is visible, verifiable, and enforceable on-chain

---

## Vesting with Cliff Logic

Vesting is a core mechanism for long-term alignment. Fluir supports:

* **Cliff release at `startTime`**: The defined cliff amount becomes available exactly at stream start
* **Interval-based distribution**: Remaining tokens stream over time based on your configuration
* **On-chain transparency**: Unlock logic and balances are fully visible
* **Stream control**: Pause, resume, extend, or close a vesting agreement at any time
* **Recipient updates**: Change wallet ownership mid-vesting without disruption

---

## What Fluir Offers

* Token distribution flows with full lifecycle control
* Real-time, on-chain settlement without middlemen
* Role-based access for senders and recipients
* On-chain updates for recipient address
* Batch-friendly design for DAOs and large teams
* Pausable, resumable, and extendable streams
* Termination logic to settle remaining balances

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

Deploys the core Fluir contract with administrative configuration.

---

## Stream Lifecycle Functions

| Function                                          | Purpose                                      |
| ------------------------------------------------- | -------------------------------------------- |
| `initializeFlow()` / `bulkCreateFlow()`           | Create one or many token streams             |
| `claimFromFlow()` / `bulkClaimFromFlow()`         | Withdraw unlocked balance                    |
| `prolongFlow()` / `bulkExtendFlow()`              | Extend the end time of a stream              |
| `haltFlow()` / `restartFlow()`                    | Pause and resume an active stream            |
| `terminateFlow()` / `bulkTerminateFlow()`         | Settle and close a stream                    |
| `updateBeneficiary()` / `bulkUpdateBeneficiary()` | Change recipient address                     |
| `availableFunds()`                                | View current balance for sender or recipient |

---

## Admin Configuration

* `updateFeeCollector(address)`
* `updateAutoClaimAccount(address)`
* `configureGateway(address)`
* `registerAsset(address token)`
* `bulkRegisterAsset(address[] tokens)`

> These functions allow the Fluir contract to stay extensible and adaptable across Core DAO tooling.

---

## Subgraph Integration

Monitor streams and lifecycle events using The Graph:

**Subgraph Playground**
[https://thegraph.com/hosted-service/subgraph/YOUR\_NAME/fluir-coredao](https://thegraph.com/hosted-service/subgraph/YOUR_NAME/fluir-coredao)

---

## Use Cases

* Token vesting for Core DAO teams, investors, and advisors
* Contributor payroll for DAOs and decentralized orgs
* Real-time disbursement of ecosystem grants
* Royalties or service-based continuous payments
* Escrow-like contracts with settlement logic
* Internal team compensation with full traceability

---

## Deployment on Core DAO

Fluir is live on **Core DAO**, enabling fair, transparent, and real-time capital distribution. By replacing manual payouts with stream-based automation, Fluir helps Core builders:

* Vest tokens responsibly
* Pay contributors reliably
* Distribute capital trustlessly
* Build long-term incentives directly into code

Fluir is the financial rail for modern DAOs and decentralized teams — delivering capital at the speed of trust.

---

## License

Licensed under **AGPL-3.0**.

---

