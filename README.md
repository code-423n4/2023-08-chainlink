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
  - [ ] All information should be provided in markdown format (HTML does not render on Code4rena.com)
- [ ] Under the "Scope" heading, provide the name of each contract and:
  - [ ] source lines of code (excluding blank lines and comments) in each
  - [ ] external contracts called in each
  - [ ] libraries used in each
- [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [ ] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
- [ ] Describe anything else that adds any special logic that makes your approach unique
- [ ] Identify any areas of specific concern in reviewing the code
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

*Please provide some context about the code being audited, and identify any areas of specific concern in reviewing the code. (This is a good place to link to your docs, if you have them.)*

# Scope

Specific focus should be paid to the contracts listed below:

| Contract           | Description                                                                                                                                                                                                                            | Lines of Code (and comments) | Libraries used                                                    | External contracts called                      |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ----------------------------------------------------------------- | ---------------------------------------------- |
| src/Migratable.sol       | Abstract contract that contracts can inherit to make the migratable.                                                                                                                                                                                               | 28(7)                       |                                                                   |                                                | 
| src/MigrationProxy.sol       | Intermediary contract to handle migrations from V0.1.  This contract exists as the V0.1 only accepts a single migration target.                                                                                                                                       | 87 (63)                       |  | [`LinkToken`](https://github.com/smartcontractkit/LinkToken/blob/master/contracts/v0.4/LinkToken.sol), `OperatorStakingPool`, `CommunityStakingPool`, `PausableWithAccessControl` |
| src/PausableWithAccessControl.sol       | Abstract contract that contracts can inherit from in order to make themselves pausable.  In addition to extending OpenZeppelin's Pausable contract, this contract also introduces the PAUSER role, which an address must have in order to pause/unpause a contract.                                                                                                                                                                                                 | 18 (6)                                                                                                                                                                                                  |                                                |
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

*Describe any novel or unique curve logic or mathematical models implemented in the contracts*

*Sponsor, please confirm/edit the information below.*

## Scoping Details 
```
- If you have a public code repo, please share it here:  https://github.com/smartcontractkit/staking
- How many contracts are in scope?:   20
- Total SLoC for these contracts?:  2297
- How many external imports are there?: 15 
- How many separate interfaces and struct definitions are there for the contracts within scope?:  10 interfaces 20 structs
- Does most of your code generally use composition or inheritance?:  Inheritance 
- How many external calls?:   15
- What is the overall line coverage percentage provided by your tests?: 100%
- Is this an upgrade of an existing system?: False
- Check all that apply (e.g. timelock, NFT, AMM, ERC20, rollups, etc.): Timelock function, ERC-20 Token
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?:  False 
- Please describe required context: n/a  
- Does it use an oracle?:  Chainlink
- Describe any novel or unique curve logic or mathematical models your code uses: None that are unique. The code does use some math for calculating staking rewards and withdrawal penalties.
- Is this either a fork of or an alternate implementation of another project?:   False
- Does it use a side-chain?: False
- Describe any specific areas you would like addressed:
### Staking access controls
1.  Is all access control sound?
2. Can addresses other than the contract admin access admin-only functions? This includes setting pool configuration, adding and removing operators, pausing, and others.
3. Can an adversary or the contract admin unlock stake that does not belong to them?
```

# Tests

*Provide every step required to build the project from a fresh git clone, as well as steps to run the tests with a gas report.* 

*Note: Many wardens run Slither as a first pass for testing.  Please document any known errors with no workaround.* 
