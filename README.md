# Chainlink Staking audit details
- Total Prize Pool: $250,000 USDC 
  - HM awards: $189,337.50 USDC 
  - Analysis awards: $11,475 USDC 
  - QA awards: $5,737.50 USDC 
  - Bot Race awards: $17,212.50 USDC 
  - Gas awards: $5,737.50 USDC 
  - Judge awards: $12,000 USDC 
  - Lookout awards: $8,000 USDC 
  - Scout awards: $500 USDC 
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2023-08-chainlink-staking-v02/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts August 25, 2023 20:00 UTC
- Ends September 12, 2023 20:00 UTC

**IMPORTANT NOTE:** Prior to receiving payment from this audit you MUST become a [Certified Contributor](https://docs.code4rena.com/roles/certified-contributors)  (successfully complete KYC). You do not have to become certified before submitting bugs. But you must successfully complete the certification process within 30 days of the audit end date in order to receive awards. This applies to all audit participants including wardens, teams, bot crews, judges, lookouts, and scouts.

## Automated Findings / Publicly Known Issues

Automated findings output for the audit can be found [here](https://github.com/code-423n4/2023-08-chainlink/blob/main/bot-report.md) within 24 hours of audit opening.

*Note for C4 wardens: Anything included in the automated findings output is considered a publicly known issue and is ineligible for awards.*

# Overview

We are releasing several new contracts to support Staking v0.2, which is the second iteration of Chainlink Staking. An overview blog of Staking v0.2 can be found [here](https://blog.chain.link/chainlink-staking-v0-2-overview).

To learn more about Chainlink Staking and the technical design, please check out the following resources:

- [Technical Specification](https://github.com/code-423n4/2023-08-chainlink/blob/main/docs/specs.pdf): Learn about the internals of the Staking contracts.
- [Staker Reward Calculations](https://github.com/code-423n4/2023-08-chainlink/blob/main/docs/rewards.pdf):  A more detailed explanation on how staker rewards are calculated
- [Staker Actions](https://github.com/code-423n4/2023-08-chainlink/blob/main/docs/actions.pdf): An explanation of primary staker actions.
- [Developer Guide](#developer-guide): Learn how to compile the code and run tests.
- [Glossary](#glossary)

# Scope
*See [scope.txt](https://github.com/code-423n4/2023-08-chainlink/blob/main/scope.txt)*

Specific focus should be paid to the contracts listed below:

| Contract           | Description                                                                                                                                                                                                                            | Lines of Code (and comments) | Libraries used                                                    | External contracts called                      |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ----------------------------------------------------------------- | ---------------------------------------------- |
| [src/Migratable.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/Migratable.sol)       | Abstract contract that contracts can inherit to make the migratable                                                                                                                                                                                               | 28(7)                       |                                                                   |                                                | 
| [src/MigrationProxy.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/MigrationProxy.sol)       | Intermediary contract to handle migrations from v0.1. This contract exists as the v0.1 only accepts a single migration target.                                                                                                                                       | 87 (63)                       |  | [`LinkToken`](https://github.com/smartcontractkit/LinkToken/blob/master/contracts/v0.4/LinkToken.sol), `OperatorStakingPool`, `CommunityStakingPool`, `PausableWithAccessControl` |
| [src/PausableWithAccessControl.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/PausableWithAccessControl.sol)       | Abstract contract that contracts can inherit from in order to make themselves pausable. In addition to extending OpenZeppelin's `Pausable` contract, this contract also introduces the `PAUSER` role, which an address must have in order to pause/unpause a contract.                                                                                                                                                                                                 | 18 (6)                                                                                                                                                                                                  |         [@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/AccessControlDefaultAdminRules.sol), [@openzeppelin/contracts/security/Pausable.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/security/Pausable.sol)                                       |
| [src/alerts/PriceFeedAlertsController.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/alerts/PriceFeedAlertsController.sol)        | Alerts controller contract defining the logic around when alerts can be raised when the downtime threshold for a feed is met.  | 304 (212)                    | [`@openzeppelin/contracts/utils/Checkpoints.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/Checkpoints.sol) | `OperatorStakingPool`, `CommunityStakingPool`, `PausableWithAccessControl`, [`Chainlink Feed EACAggregatorProxy`](https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/EACAggregatorProxy.sol) |
| [src/pools/CommunityStakingPool.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/pools/CommunityStakingPool.sol)      | The v0.2 community staking pool that will hold the LINK community stakers have staked.                                                                                                                                                                 | 75 (49)                    |                       [`@openzeppelin/contracts/utils/cryptography/MerkleProof.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)                                            |               `OperatorStakingPool`                               |
| [src/pools/OperatorStakingPool.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/pools/OperatorStakingPool.sol) | The v0.2 node operator staking pool that will hold the LINK Node Operator Stakers have staked.                                                                                                                                                            | 308 (214)                     |                   [`@openzeppelin/contracts/utils/Checkpoints.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/Checkpoints.sol), [`@openzeppelin/contracts/utils/math/Math.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol)                                                |          `RewardVault`                                     |
| [src/pools/StakingPoolBase.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/pools/StakingPoolBase.sol)       | Abstract contract that defines the logic shared by the `CommunityStakingPool` and `OperatorStakingPool` contracts.                                                                      | 438 (241)                       |               [`@openzeppelin/contracts/utils/Checkpoints.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/Checkpoints.sol), [`@openzeppelin/contracts/utils/math/SafeCast.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)                                                    |                    [`LINKToken`](https://github.com/smartcontractkit/LinkToken/blob/master/contracts/v0.4/LinkToken.sol)                            |
| [src/rewards/RewardVault.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/rewards/RewardVault.sol)       | The reward vault is the contract that defines the earned rewards calculation logic. This contract also holds all LINK rewards funded by the contract manager.                                                                                                                                                                       | 1002 (525)                       |       [`@openzeppelin/contracts/utils/math/SafeCast.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol), [`@openzeppelin/contracts/utils/math/Math.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol), [`@solmate/utils/FixedPointMathLib.sol`](https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)                                                            |      [`LINKToken`](https://github.com/smartcontractkit/LinkToken/blob/master/contracts/v0.4/LinkToken.sol), `OperatorStakingPool`, `CommunityStakingPool`                                          |
| [src/timelock/StakingTimelock.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/timelock/StakingTimelock.sol)       | The staking timelock contract is the contract that administers operational changes to the other staking contracts. Any operational transaction will need to be executed through this address after a timelock period.                                                                                                                                                                | 87 (28)                       |                                                                   |    `OperatorStakingPool`, `CommunityStakingPool`, `PriceFeedAlertsController`, `RewardVault`                                            |
| [src/timelock/Timelock.sol](https://github.com/code-423n4/2023-08-chainlink/blob/main/src/timelock/Timelock.sol)       | This is the base timelock contract that `StakingTimelock` inherits from and defines all the timelock logic to propose, execute and cancel transactions.                                                                                                                                                                                                   | 191 (256)                       |     [`@openzeppelin/contracts/utils/structs/EnumerableSet.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol)                                                         |                                                |

## Out of scope

| Contract               | Description                                            |
| ---------------------- | ------------------------------------------------------ |
| src/interfaces/\*.sol      | Interfaces, contains no logic. Provided for reference. |
| src/tests/\*.sol | Mock and helper contracts for testing purposes only.   |
| test/\*.sol            | Foundry unit, fuzz and invariant tests.                      |
| scripts/\*.sol            | Foundry deployment scripts                      |
| External libraries            |                       |

# Additional Context

### Glossary

| Term              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Node Operator Staker    | An entity that is contributing to the decentralized oracle network (DON) operations by running Chainlink node software. Also referred to as Operators. These stakers will only be allowed to stake in the `OperatorStakingPool`.                                                                                                                                                                                                                                                                                                                              |
| Community Staker  | A Chainlink token holder who is not an Operator that is a participant of Staking v0.2. These stakers will only be allowed to stake in the `CommunityStakingPool`.                                                                                                                                                                                                                                                                                                                                                                                                   |
| Staker            | A staker (a Node Operator or Community Staker) who stakes in a Staking v0.2 pool                                                                                                                                                                                                                                                                                                                                                                                                           |
| Alerter           | A staker who raises a feed downtime alert on-chain.                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Allowlist         |A list of Ethereum addresses that will be allowed to stake in the `CommunityStakingPool` before General Access.                                                                                                                                                                                                                                                                                                                                                                                                     |
| Base Reward       | A Staking Reward for stakers is made available at a rate as defined in the `RewardVault` contract. The amount of base rewards a staker earns is equal to the amount of total amount of rewards made available to the pool multiplied by their share of the pool relative to other stakers of the same type.  |
| Delegation Reward | A proportion of Base Rewards from Community Staker rewards that is divided proportionally between all Operators who have staked at least the minimum required amount.                                        |
| Aggregate Reward Rate       | This parameter expresses the amount of rewards that become available to all stakers per second. This value is then made available to the Community Stakers and Operators in proportion to their pool sizes. |
| Ramp Up Multiplier       | A staker-specific value that determines how much reward a staker can claim at the current time. Grows linearly from 0 to 1x. |
| Unbonding Period | A period of time stakers are required to wait before unstaking. |
| Claim Period | The period of time following the unbonding period in which a staker may unstake their tokens.  |
| Reward Duration | The period of time an amount of rewards are made available for. |
| Timelock Period | The period of time after a transaction is proposed in the Timelock before the transaction can be executed. |


### Areas of Concern, Attack Surfaces, Invariants

### Areas of Concern

The team's largest concerns with the Staking V0.2 protocol are around

 - Integrity of Staking and Unstaking mechanisms (i.e., can stakers successfully stake and unstake their LINK?)
 - Reward calculation/claim logic
  - Does a staker earn the correct amount of rewards at all times?
  - Is the ramp up multiplier correctly applied and reset at all times?
 - Contract upgradability patterns
  - Can a staker's LINK be locked in an older contract?
  - Can a staker lose any of their rewards once a reward vault is upgraded?
  - Does any state in any contract get corrupted whenever there is an upgrade?

### Staking access controls

- Are all access control modifiers implemented correctly and working as expected?
- Can addresses other than the contract manager access manager-only functions? This includes setting pool configuration, adding and removing operators, pausing, and others.
- Can an adversary or the contract manager unlock staked LINK that does not belong to them?

### Staking pool management

- Can the contract manager immediately pause a staking pool in case of an emergency?
- Can the contract manager always add and remove operators before Staking v0.2 has concluded?
- Must the contract manager go through a timelock period to add a new slashing condition on the `OperatorStakingPool`?
- Can the contract manager perform operational actions such as updating the unbonding period AFTER the timelock period is over?

### Reward vault management

- Can the contract manager extend the reward duration by adding more rewards to the `RewardVault`?
- Can the contract manager immediately pause the reward vault in case of an emergency?
- Can the contract manager migrate the reward vault?
- Can the contract manager perform operational actions such as updating the multiplier ramp up period and delegation rates?

### Staking and Unstaking

- Can a staker bypass the unbonding period and unstake instantly?
- Can a staker fail to unbond and unstake at any point in time?
- Can a removed operator fail to unstake their removed LINK?
- Can a bad unbonding period prevent a staker from unstaking altogether?
- Can a bad claim period prevent a staker from unstaking altogether?
- Can a staker unbond and unstake their LINK before any changes proposed by the admin become live after the timelock period?

### Staking and Unstaking Invariants

- The total amount staked by all stakers should equal the total stake of the pool.
- The total staked amount SHOULD NOT be greater than the maximum pool size.
- A Community Staker SHOULD NOT be allowed to stake in the operator staking pool.
- An operator SHOULD NOT be allowed to stake in the Community Staking pool unless they have already been removed.

### Rewards

- Are the reward amounts computed correctly?
- Can stakers exploit reward calculations to receive more than their fair share?
    - Can an adversary use rounding error to gain extra rewards, especially when locking and unlocking?
    - Could an adversary use specific inputs or timing conditions to receive more rewards than their fair share?
- Are there underflow/overflow issues in reward calculations that can lock the contract?
- Can the rewards in the pool deplete unexpectedly or earlier than expected?
- Can a malicious actor steal rewards from a staker?
- Can a staker receive too few rewards due to a rounding error?
- Can a malicious actor steal stakers’ stake?

### Rewards Invariants

- The amount of available and remaining rewards SHOULD NOT exceed the LINK balance of the RewardVault contract.
- The sum of all earned staker rewards SHOULD NOT exceed the amount of rewards.
- A reward vault bucket with a zero aggregate reward rate should not be making available any more rewards.
- The reward vault's multiplier should be between zero and the `MAX_MULTIPLIER` 

### Alerting and Slashing

- Can non-stakers alert?
- Can stakers always alert when the feed downtime threshold of 3 hours is met?
- Can duplicate alerts for the same price feed round be raised?
- Can alerters exploit and receive duplicate alerter rewards?
- Can stakers other than on-feed operators have their rewards slashed? (Only on-feed operators should)

### Alerting and Slashing Invariants

- Can non-stakers alert?
- Can node operator stakers always alert when the feed priority downtime threshold is met?
- Can all stakers always alert when the feed regular downtime threshold is met?
- Can duplicate alerts for the same price feed round be raised?
- Can alerters exploit and receive duplicate alerter rewards?
- Can stakers other than on-feed operators have their rewards slashed? 

### Migration

- Can the contract manager frontrun stakers and set a new migration target unexpectedly?

### Migration invariants

- Stakers SHOULD always be able to migrate when the pool has been concluded by the contract manager and migration target is set.

### Timelock invariants

- The min delay for a selector cannot be lower than the global min delay.
- Stakers should be able to unbond and unstake before major protocol changes.
- The timelock delay for upgrade operations should be greater than the unbonding period. 

### General

- Can any getter function in the Staking v0.2 contracts revert?
- Can the contract be bricked?


## Scoping Details 

```
- If you have a public code repo, please share it here:  NA
- How many contracts are in scope?:   10
- Total SLoC for these contracts?:  2538
- How many external imports are there?: 8.  This is the number of unique external libraries used and the unique number of external contracts that Staking v0.2 contracts interact with
- How many separate interfaces and struct definitions are there for the contracts within scope?:  10 interfaces 20 structs
- Does most of your code generally use composition or inheritance?:  Inheritance 
- How many external calls?:   2.  Staking v0.2 makes external calls to the LINK token and Chainlink Price Feeds 
- What is the overall line coverage percentage provided by your tests?: 100%
- Is this an upgrade of an existing system?: Yes.  This is the second iteration of Chainlink's Staking protocol
- Check all that apply (e.g., timelock, NFT, AMM, ERC20, rollups, etc.): Timelock, ERC-20 Token, Chainlink Price Feeds
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?:  Yes 
- Please describe required context: You may need to understand how Chainlink Price Feeds work in order to understand how the `PriceFeedAlertsController` detects feed downtime. Price data values can be read by calling the feed's `getLatestRoundData` function.  The `PriceFeedAlertsController` calls this function to retrieve the time the feed was last updated and compares it against the current `block.timestamp` to determine if the feed has been down for longer than the configured alertable threshold.

Additionally you may also need to understand how rewards are migrated from Staking v0.1.
- Does it use an oracle?:  No but the PriceFeedAlertsController reads the last updated at time from Chainlink Data Feeds.
- Describe any novel or unique curve logic or mathematical models your code uses: The `RewardVault` calculates staker rewards by implementing the widely used reward-per-token model implemented by other staker protocols. A more detailed explanation of this can be found in the Staking Reward Calculations document.
- Is this either a fork of or an alternate implementation of another project?:   No
- Does it use a side-chain?: No
- Describe any specific areas you would like addressed:
  - Reward calculation and the logic in the RewardVault  
  - Upgradability patterns
```

# Developer Guide

**NOTE:  Run the commands below from the root of the project directory**


### Prerequisites

- The code in this repository is built using the Foundry framework.  Please install it by following
[these](https://book.getfoundry.sh/getting-started/installation) setup instructions if you have not set it up yet.

### Compile

Compile the smart contracts with Forge:

```sh
forge build
```

### Format files

```sh
forge fmt
```

### Test

Run unit tests:

```sh
forge test
```

Run integration tests:
```sh
FOUNDRY_PROFILE=integration forge test
```

Run invariant tests:
```sh
FOUNDRY_PROFILE=invariant forge test
```

Run a single test:

```sh
forge test test/MyContract.test.ts
```

### Coverage

Generate a test coverage report:

```sh
pnpm coverage
```

Unit test coverage is at 100%.

### Clean

Delete the output smart contract artifacts directory and clears the Forge cache:

```sh
forge clean
```

### Gas snapshot

You can find a `.gas-snapshot` file for several key flows. You may find it helpful during gas golfing.

```
pnpm gas
```

### Automated documentation

```
forge doc --serve
```

### Slither

Run Slither with `slither src`
The output is provided, see [slither.txt](https://github.com/code-423n4/2023-08-chainlink/blob/main/slither.txt)
