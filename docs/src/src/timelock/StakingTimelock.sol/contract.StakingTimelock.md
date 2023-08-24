# StakingTimelock
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/timelock/StakingTimelock.sol)

**Inherits:**
[Timelock](/src/timelock/Timelock.sol/contract.Timelock.md)

This contract is the contract manager of all staking contracts. Any contract upgrades or
parameter
updates will need to be scheduled here and go through the timelock.

*The deployer will transfer the staking contracts ownership to this contract and proposer
will schedule an accepting transaction in the timelock. After the timelock is passed, the
executor can execute the transaction and the staking contracts will be owned by this contract.
Example operations can be found in the integration tests.*


## State Variables
### DELAY_ONE_MONTH
31 days in seconds (28 day unbonding period + 3 day buffer)


```solidity
uint256 private constant DELAY_ONE_MONTH = 31 days;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params)
  Timelock(params.minDelay, params.admin, params.proposers, params.executors, params.cancellers);
```

## Errors
### InvalidZeroAddress
This error is thrown whenever a zero-address is supplied when
a non-zero address is required


```solidity
error InvalidZeroAddress();
```

## Structs
### ConstructorParams
This struct defines the params required by the StakingTimelock contract's
constructor.


```solidity
struct ConstructorParams {
  address rewardVault;
  address communityStakingPool;
  address operatorStakingPool;
  address alertsController;
  uint256 minDelay;
  address admin;
  address[] proposers;
  address[] executors;
  address[] cancellers;
}
```

