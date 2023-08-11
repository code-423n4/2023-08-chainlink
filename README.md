# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration.

Your audit will use two repos: 
- **an _audit_ repo** (this one), which is used for scoping your audit and for providing information to wardens
- **a _findings_ repo**, where issues are submitted (shared with you after the audit) 

Ultimately, when we launch the audit, this repo will be made public and will contain the smart contracts to be reviewed and all the information needed for audit participants. The findings repo will be made public after the audit report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the audit sponsor (⭐️)**.

---
# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Provide a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 48 business hours prior to audit start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)


---

## ⭐️ Sponsor: Edit this README

Under "SPONSORS ADD INFO HERE" heading below, include the following:

- [ ] Modify the bottom of this `README.md` file to describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2022-08-foundation#readme))
  - [ ] When linking, please **provide all links as full absolute links** versus relative links
  - [X] All information should be provided in markdown format (HTML does not render on Code4rena.com)
- [X] Under the "Scope" heading, provide the name of each contract and:
  - [X] source lines of code (excluding blank lines and comments) in each
  - [X] external contracts called in each
  - [X] libraries used in each
- [X] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [X] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
- [X] Describe anything else that adds any special logic that makes your approach unique
- [X] Identify any areas of specific concern in reviewing the code
- [ ] Review the Gas award pool amount. This can be adjusted up or down, based on your preference - just flag it for Code4rena staff so we can update the pool totals across all comms channels. 
- [ ] Optional / nice to have: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] See also: [this checklist in Notion](https://code4rena.notion.site/Key-info-for-Code4rena-sponsors-f60764c4c4574bbf8e7a6dbd72cc49b4#0cafa01e6201462e9f78677a39e09746)
- [ ] Delete this checklist and all text above the line below when you're ready.

---

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
- Submit findings [using the C4 form](https://code4rena.com/contests/2023-08-chainlink-staking/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts August 11, 2023 20:00 UTC
- Ends August 28, 2023 20:00 UTC

**IMPORTANT NOTE**: Prior to receiving payment from this audit you MUST become a Certified Warden (successfully complete KYC). You do not have to complete this process before competing or submitting bugs. You must have started this process within 48 hours after the audit ends, i.e. **by August 30, 2023 at 20:00 UTC in order to receive payment.**

## Automated Findings / Publicly Known Issues

Automated findings output for the audit can be found [here](bot-report.md) within 24 hours of audit opening.

*Note for C4 wardens: Anything included in the automated findings output is considered a publicly known issue and is ineligible for awards.*

[ ⭐️ SPONSORS ADD INFO HERE ]

# Overview

We are releasing several new contracts to support Staking V0.2, which is the second iteration of Chainlink's staking program.

To learn more about Staking and the technical design, please check out the following resources:

- [Technical Specification](https://github.com/code-423n4/2022-11-chainlink/blob/main/docs/specs.md): Learn about the internals of the Staking contracts.
- [Staker Reward Calculations]():  A more detailed explanation on how staker rewards are calculated
- [Staker And Admin Flows]()/[Staking V0.2 Scenarios]():  High level overview of the actions a staker and admin can take
- [API Docs](https://github.com/code-423n4/2023-08-chainlink/blob/cl-economics-audit-prep/docs/src/SUMMARY.md): Autogenerated docs based on inline documentation.
- [Developer Guide](#developer-guide): Learn how to compile the code and run tests.
- [Glossary](#glossary)

# Scope

Specific focus should be paid to the contracts listed below:

| Contract           | Description                                                                                                                                                                                                                            | Lines of Code (and comments) | Libraries used                                                    | External contracts called                      |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ----------------------------------------------------------------- | ---------------------------------------------- |
| src/Migratable.sol       | Abstract contract that contracts can inherit to make the migratable.                                                                                                                                                                                               | 28(7)                       |                                                                   |                                                | 
| src/MigrationProxy.sol       | Intermediary contract to handle migrations from V0.1.  This contract exists as the V0.1 only accepts a single migration target.                                                                                                                                       | 87 (63)                       |  | [`LinkToken`](https://github.com/smartcontractkit/LinkToken/blob/master/contracts/v0.4/LinkToken.sol), `OperatorStakingPool`, `CommunityStakingPool`, `PausableWithAccessControl` |
| src/PausableWithAccessControl.sol       | Abstract contract that contracts can inherit from in order to make themselves pausable.  In addition to extending OpenZeppelin's Pausable contract, this contract also introduces the PAUSER role, which an address must have in order to pause/unpause a contract.                                                                                                                                                                                                 | 18 (6)                                                                                                                                                                                                  |         [@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/AccessControlDefaultAdminRules.sol), [@openzeppelin/contracts/security/Pausable.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/security/Pausable.sol)                                       |
| src/alerts/PriceFeedAlertsController.sol        | Alerts controller contract defining the logic around when alerts can be raised when a feed goes down.  | 304 (212)                    | [`@openzeppelin/contracts/utils/Checkpoints.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/Checkpoints.sol) | `OperatorStakingPool`, `CommunityStakingPool`, `PausableWithAccessControl`, [`Chainlink Feed EACAggregatorProxy`](https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/EACAggregatorProxy.sol) |
| src/pools/CommunityStakingPool.sol      | The V0.2 community staking pool that will hold the LINK community stakers have staked.                                                                                                                                                                 | 75 (49)                    |                       [`@openzeppelin/contracts/utils/cryptography/MerkleProof.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)                                            |               `OperatorStakingPool`                               |
| src/pools/OperatorStakingPool.sol | The V0.2 operator staking pool that will hold the LINK operators have staked.                                                                                                                                                            | 308 (214)                     |                   [`@openzeppelin/contracts/utils/Checkpoints.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/Checkpoints.sol), [`@openzeppelin/contracts/utils/math/Math.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol)                                                |          `RewardVault`                                     |
| src/pools/StakingPoolBase.sol       | Abstract contract that defines the logic shared by the CommunityStakingPool and OperatorStakingPool contracts.                                                                      | 438 (241)                       |               [`@openzeppelin/contracts/utils/Checkpoints.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/Checkpoints.sol), [`@openzeppelin/contracts/utils/math/SafeCast.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)                                                    |                    [`LINKToken`](https://github.com/smartcontractkit/LinkToken/blob/master/contracts/v0.4/LinkToken.sol)                            |
| src/rewards/RewardVault.sol       | The reward vault is the contract that defines the reward distribution and calculation logic.  This contract also holds all LINK rewards funded by the admin.                                                                                                                                                                       | 1002 (525)                       |       [`@openzeppelin/contracts/utils/math/SafeCast.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol), [`@openzeppelin/contracts/utils/math/Math.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol), [`@solmate/utils/FixedPointMathLib.sol`](https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)                                                            |      [`LINKToken`](https://github.com/smartcontractkit/LinkToken/blob/master/contracts/v0.4/LinkToken.sol), `OperatorStakingPool`, `CommunityStakingPool`                                          |
| src/timelock/StakingTimelock.sol       | The staking timelock contract is the contract that administer operational changes to the other staking contracts.  Any operational transaction will need to be executed through this address after a timelock period.                                                                                                                                                                | 87 (28)                       |                                                                   |    `OperatorStakingPool`, `CommunityStakingPool`, `PriceFeedAlertsController`, `RewardVault`                                            |
| src/timelock/Timelock.sol       | This is the base timelock contract that `StakingTimelock` inherits from and defines all the timelock logic to propose, execute and cancel transactions.                                                                                                                                                                                                   | 191 (256)                       |     [`@openzeppelin/contracts/utils/structs/EnumerableSet.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol)                                                         |                                                |

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
| Node Operator     | An entity that is contributing to the decentralized oracles network (DON) operations by running the Chainlink node software. Also referred to as operators.  These stakers will only be allowed to stake in the `OperatorStakingPool`.                                                                                                                                                                                                                                                                                                                               |
| Community Staker  | A Chainlink token holder who is not an Operator that is a participant of Staking v0.2.  These stakers will only be allowed to stake in the `CommunityStakingPool`.                                                                                                                                                                                                                                                                                                                                                                                                    |
| Staker            | A staker (an Operator or community staker) who stakes in a staking v0.2 pool.                                                                                                                                                                                                                                                                                                                                                                                                           |
| Alerter           | A staker who raises a feed downtime alert on-chain.                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Allowlist         | A list of Ethereum addresses that will be allowed to stake in the `CommunityStakingPool` before it goes public.                                                                                                                                                                                                                                                                                                                                                                                                     |
| Base Reward       | A Staking Reward for Stakers is issued at an emission rate as defined in the `RewardVault` contract.  The amount of base rewards a staker earns is equal to the amount of vested rewards multiplied by their share of the pool relative to other stakers of the same type.  |
| Delegation Reward | A proportion of Base Rewards from Community Staker rewards that is divided proportionally between all Operators who have staked the minimum required amount.                                        |
| Emission Rate       | This parameter expresses the amount of rewards that become available to all stakers per second.  This value is then distributed to the community stakers and operators in proportion to their pool sizes.  You can view an example of this in the [Staking V0.2 Scenarios]() documentation.  |
| Ramp Up Multiplier       | A staker-specific value that determines how much reward a staker can claim at the current time. Incentivizes stakers to stake for longer. Grows linearly from 0 to 1x. |
| Unbonding Period | A period of time stakers are required to wait before unstaking. |
| Claim Period | The period of time following the unbonding period in which a staker may unstake their tokens.  |
| Reward Duration | The period of time an amount of rewards is distributed for. |


### Areas of Concern, Attack Surfaces, Invariants

### Areas of Concern

The team's largest concerns with the Staking V0.2 protocol are around

 - Reward calculation/distribution logic
  - Does a staker earn the correct amount of rewards at all times?
  - Is the ramp up multiplier correctly applied and reset at all times?
 - Contract upgradability patterns
  - Can a staker's principal be locked in an older contract?
  - Can a staker lose any of their rewards once a reward vault is upgraded?
  - Does any state in any contract get corrupted whenever there is an upgrade?

### Staking access controls

- Is all access control sound?
- Can addresses other than the contract manager access manager-only functions? This includes setting pool configuration, adding and removing operators, pausing, and others.
- Can an adversary or the contract manager unlock stake that does not belong to them?

### Staking pool management

- Can the Staking v0.1 pool always be concluded by the contract manager? (When rewards have not yet depleted)
- Can the contract manager always add and remove operators before Staking v0.1 has concluded?
- Can removed operators only unlock after Staking v0.1 has concluded?

### Staking and Unstaking

- Can a staker bypass the unbonding period and unstake instantly?
- Can a staker fail to unbond and unstake at any point in time?
- Can a removed operator fail to unstake their removed principal?
- Can a bad unbonding period prevent a staker from unstaking altogether?
- Can a bad claim period period prevent a staker from unstaking altogether?

### Staking and Unstaking Invariants

- The total amount staked by all stakers should equal the total principal of the pool
- The total staked amount SHOULT NOT be greater than the maximum pool size
- An community staker SHOULD NOT be allowed to stake in the operator staking pool
- An operator SHOULD NOT be allowed to stake in the community staking pool unless
  they have already been removed

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

- The amount of unvested rewards SHOULD NOT exceed the LINK balance of the RewardVault contract.
- The sum of all earned staker rewards SHOULD NOT exceed the amount of vested rewards.
- A reward vault bucket with a zero emission rate should not be vesting any more rewards.
- The reward vault's multiplier should be between zero and the MAX_MULTIPLIER 

### Alerting and Slashing

- Can non-stakers alert?
- Can stakers always alert when the feed downtime threshold of 3 hours is met?
- Can duplicate alerts for the same price feed round be raised?
- Can alerters exploit and receive duplicate alerter rewards?
- Can stakers other than on-feed operators have their rewards slashed? (Only on-feed operators should)

### Alerting and Slashing Invariants

- Non-stakers SHOULD NOT be able to raise an alert.
- Duplicate alerts for the same price feed round SHOULD NOT exist.
- Only on-feed operators set by the contract should be slashed.

### Migration

- Can the contract manager frontrun stakers and set a new migration target unexpectedly?

### Migration invariants

- Stakers SHOULD always be able to migrate when the pool has been concluded by the contract manager and migration target is set.

### General

- Can any getter function in the Staking v0.2 contracts revert?
- Can the contract be bricked?

## Scoping Details 

```
- If you have a public code repo, please share it here:  NA
- How many contracts are in scope?:   10
- Total SLoC for these contracts?:  2538
- How many external imports are there?: 8.  This is the number of external libraries used and the number of external contracts that Staking V0.2 contracts interact with
- How many separate interfaces and struct definitions are there for the contracts within scope?:  10 interfaces 20 structs
- Does most of your code generally use composition or inheritance?:  Inheritance 
- How many external calls?:   2.  Staking V0.2 makes external calls to the LINKToken and the Chainlink price feed oracles
- What is the overall line coverage percentage provided by your tests?: 100%
- Is this an upgrade of an existing system?: Yes.  This is the second iteration of Chainlink's staking protocol
- Check all that apply (e.g. timelock, NFT, AMM, ERC20, rollups, etc.): Timelock, ERC-20 Token, Chainlink Price Feeds
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?:  Yes 
- Please describe required context: You may need to understand how Chainlink price feeds work in order to understand how the `PriceFeedAlertsController` detects feed downtime.  Today Chainlink DONs write an updated price on-chain every 30s along with a timestamp of when this price was updated.  These values can then be read by calling the feed's `getLatestRoundData` function.  The `PriceFeedAlertsController` calls this function to retrieve the time the feed was last updated and compares it against the current `block.timestamp` to determine if the feed has been down for longer than the configured alertable threshold.
- Does it use an oracle?:  No
- Describe any novel or unique curve logic or mathematical models your code uses: The `RewardVault` calculates staker rewards by implementing the widely used reward-per-token model implemented by other staker protocols. A more detailed explanation of this can be found in the Staking Reward Calculations document.
- Is this either a fork of or an alternate implementation of another project?:   No
- Does it use a side-chain?: No
- Describe any specific areas you would like addressed:
  - Reward calculation and distribution logic in the `RewardVault`
  - Upgradability patterns

### Staking access controls
1.  Is all access control sound?
2. Can addresses other than the contract admin access admin-only functions? This includes setting pool configuration, adding and removing operators, pausing, and others.
3. Can an adversary or the contract admin unlock stake that does not belong to them?
```

# Developer Guide

**NOTE:  Run the commands below from the root of the project directory**


### Prerequidites

- The code in this repository is built using the Foundry framework.  Please install it by following
[these](https://book.getfoundry.sh/getting-started/installation) setup instructions if you have not set it up yet.

### Compile

Compile the smart contracts with Forge:

```sh
$ forge build
```

### Format files

```sh
$ forge fmt
```

### Test

Run unit tests:

```sh
$ forge test
```

Run integration tests:
```sh
$ FOUNRY_PROFILE=integration forge test
```

Run invariant tests:
```sh
$ FOUNRY_PROFILE=invariant forge test
```

Run a single test:

```sh
$ forge test test/MyContract.test.ts
```


### Coverage

Generate a test coverage report:

```sh
$ forge coverage
```

Unit test coverage is at 100%.

### Clean

Delete the output smart contract artifacts directory and clears the Forge cache:

```sh
$ forge clean
```

### Slither static analysis

Make sure you are on the [latest](https://github.com/crytic/slither/releases) `>=0.9.0` version of Slither.

```sh
slither .
```

Make sure you have python and slither installed. You can install it by running

```sh
asdf install
pip3 install -r tools/requirements.txt
asdf reshim python
```

### Gas snapshot

You can find a `.gas-snapshot` file for several key flows. You may find it helpful during gas golfing.

```
FOUNDRY_PROFILE=gas forge snapshot
```
