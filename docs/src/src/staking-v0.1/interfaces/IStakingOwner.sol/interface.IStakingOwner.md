# IStakingOwner
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/interfaces/IStakingOwner.sol)

Owner functions restricted to the setup and maintenance
of the staking contract by the owner.


## Functions
### addOperators

Adds one or more operators to a list of operators

*Should only callable by the Owner*


```solidity
function addOperators(address[] calldata operators) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|A list of operator addresses to add|


### removeOperators

Removes one or more operators from a list of operators. When an
operator is removed, we store their principal in a separate mapping to
prevent immediate withdrawals. This is so that the removed operator can
only unstake at the same time as every other staker.

*Should only be callable by the owner when the pool is open.
When an operator is removed they can stake as a community staker.
We allow that because the alternative (checking for removed stake before
staking) is going to unnecessarily increase gas costs in 99.99% of the
cases.*


```solidity
function removeOperators(address[] calldata operators) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|A list of operator addresses to remove|


### setFeedOperators

Allows the contract owner to set the list of on-feed operator addresses who are
subject to slashing

*Existing feed operators are cleared before setting the new operators.*


```solidity
function setFeedOperators(address[] calldata operators) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|New list of on-feed operator staker addresses|


### getFeedOperators


```solidity
function getFeedOperators() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|List of the ETH-USD feed node operators' staking addresses|


### changeRewardRate

This function can be called to change the reward rate for the pool.
This change only affects future rewards, i.e. rewards earned at a previous
rate are unaffected.

*Should only be callable by the owner. The rate can be increased or decreased.
The new rate cannot be 0.*


```solidity
function changeRewardRate(uint256 rate) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`rate`|`uint256`|The new reward rate|


### addReward

This function can be called to add rewards to the pool

*Should only be callable by the owner*


```solidity
function addReward(uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of rewards to add to the pool|


### withdrawUnusedReward

This function can be called to withdraw unused reward amount from
the staking pool. It can be called before the pool is initialized, after
the pool is concluded or when the reward expires.

*Should only be callable by the owner when the pool is closed*


```solidity
function withdrawUnusedReward() external;
```

### setPoolConfig

Set the pool config


```solidity
function setPoolConfig(
  uint256 maxPoolSize,
  uint256 maxCommunityStakeAmount,
  uint256 maxOperatorStakeAmount
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPoolSize`|`uint256`|The max amount of staked LINK allowed in the pool|
|`maxCommunityStakeAmount`|`uint256`|The max amount of LINK a community staker can stake|
|`maxOperatorStakeAmount`|`uint256`|The max amount of LINK a Node Op can stake|


### start

Transfers LINK tokens and initializes the reward

*Uses ERC20 approve + transferFrom flow*


```solidity
function start(uint256 amount, uint256 initialRewardRate) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|rewards amount in LINK|
|`initialRewardRate`|`uint256`|The amount of LINK earned per second for each LINK staked.|


### conclude

Closes the pool, unreserving future staker rewards, expires the
reward and releases unreserved rewards


```solidity
function conclude() external;
```

### emergencyPause

This function pauses staking

*Sets the pause flag to true*


```solidity
function emergencyPause() external;
```

### emergencyUnpause

This function unpauses staking

*Sets the pause flag to false*


```solidity
function emergencyUnpause() external;
```

## Errors
### InvalidDelegationRate
This error is thrown when an zero delegation rate is supplied


```solidity
error InvalidDelegationRate();
```

### InvalidRegularPeriodThreshold
This error is thrown when an invalid regular period threshold is supplied


```solidity
error InvalidRegularPeriodThreshold();
```

### InvalidMinOperatorStakeAmount
This error is thrown when an invalid min operator stake amount is
supplied


```solidity
error InvalidMinOperatorStakeAmount();
```

### InvalidMinCommunityStakeAmount
This error is thrown when an invalid min community stake amount
is supplied


```solidity
error InvalidMinCommunityStakeAmount();
```

### InvalidMaxAlertingRewardAmount
This error is thrown when an invalid max alerting reward is
supplied


```solidity
error InvalidMaxAlertingRewardAmount();
```

### MerkleRootNotSet
This error is thrown when the pool is started with an empty
merkle root


```solidity
error MerkleRootNotSet();
```

