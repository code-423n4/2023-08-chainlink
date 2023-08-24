# StakingPoolLib
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/StakingPoolLib.sol)


## Functions
### _setConfig

Sets staking pool parameters


```solidity
function _setConfig(
  Pool storage pool,
  uint256 maxPoolSize,
  uint256 maxCommunityStakeAmount,
  uint256 maxOperatorStakeAmount
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`Pool`||
|`maxPoolSize`|`uint256`|Maximum total stake amount across all stakers|
|`maxCommunityStakeAmount`|`uint256`|Maximum stake amount for a single community staker|
|`maxOperatorStakeAmount`|`uint256`|Maximum stake amount for a single node operator|


### _open

Opens the staking pool


```solidity
function _open(Pool storage pool, uint256 minInitialOperatorCount) internal;
```

### _close

Closes the staking pool


```solidity
function _close(Pool storage pool) internal;
```

### _isOperator

Returns true if a supplied staker address is in the operators list


```solidity
function _isOperator(Pool storage pool, address staker) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`Pool`||
|`staker`|`address`|Address of a staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### _getTotalStakedAmount

Returns the sum of all principal staked in the pool


```solidity
function _getTotalStakedAmount(Pool storage pool) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|totalStakedAmount|


### _getRemainingPoolSpace

Returns the amount of remaining space available in the pool for
community stakers. Community stakers can only stake up to this amount
even if they are within their individual limits.


```solidity
function _getRemainingPoolSpace(Pool storage pool) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|remainingPoolSpace|


### _addOperators

*Required conditions for adding operators:
- Operators can only been added to the pool if they have no prior stake.
- Operators can only been readded to the pool if they have no removed
stake.
- Operators cannot be added to the pool after staking ends (either through
conclusion or through reward expiry).*


```solidity
function _addOperators(Pool storage pool, address[] calldata operators) internal;
```

### _setFeedOperators

Helper function to set the list of on-feed Operator addresses


```solidity
function _setFeedOperators(Pool storage pool, address[] calldata operators) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`Pool`||
|`operators`|`address[]`|List of Operator addresses|


### test


```solidity
function test() public;
```

## Events
### PoolOpened
This event is emitted when the staking pool is opened for stakers


```solidity
event PoolOpened();
```

### PoolConcluded
This event is emitted when the staking pool is concluded


```solidity
event PoolConcluded();
```

### PoolSizeIncreased
This event is emitted when the staking pool's maximum size is
increased


```solidity
event PoolSizeIncreased(uint256 maxPoolSize);
```

### MaxCommunityStakeAmountIncreased
This event is emitted when the maximum stake amount


```solidity
event MaxCommunityStakeAmountIncreased(uint256 maxStakeAmount);
```

### MaxOperatorStakeAmountIncreased
This event is emitted when the maximum stake amount for node
operators is increased


```solidity
event MaxOperatorStakeAmountIncreased(uint256 maxStakeAmount);
```

### OperatorAdded
This event is emitted when an operator is added


```solidity
event OperatorAdded(address operator);
```

### OperatorRemoved
This event is emitted when an operator is removed


```solidity
event OperatorRemoved(address operator, uint256 amount);
```

### FeedOperatorsSet
This event is emitted when the contract owner sets the list
of feed operators subject to slashing


```solidity
event FeedOperatorsSet(address[] feedOperators);
```

## Errors
### InvalidPoolStatus
Surfaces the required pool status to perform an operation


```solidity
error InvalidPoolStatus(bool currentStatus, bool requiredStatus);
```

### InvalidPoolSize
This error is raised when attempting to decrease maximum pool size


```solidity
error InvalidPoolSize(uint256 maxPoolSize);
```

### InvalidMaxStakeAmount
This error is raised when attempting to decrease maximum stake amount
for community stakers or node operators


```solidity
error InvalidMaxStakeAmount(uint256 maxStakeAmount);
```

### InsufficientRemainingPoolSpace
This error is raised when attempting to add more node operators without
sufficient available pool space to reserve their allocations.


```solidity
error InsufficientRemainingPoolSpace(uint256 remainingPoolSize, uint256 requiredPoolSize);
```

### InsufficientStakeAmount

```solidity
error InsufficientStakeAmount(uint256 requiredAmount);
```

### ExcessiveStakeAmount
This error is raised when stakers attempt to stake past pool limits


```solidity
error ExcessiveStakeAmount(uint256 remainingAmount);
```

### StakeNotFound
This error is raised when stakers attempt to exit the pool


```solidity
error StakeNotFound(address staker);
```

### ExistingStakeFound
This error is raised when addresses with existing stake is added as an operator


```solidity
error ExistingStakeFound(address staker);
```

### OperatorAlreadyExists
This error is raised when an address is duplicated in the supplied list of operators.
This can happen in addOperators and setFeedOperators functions.


```solidity
error OperatorAlreadyExists(address operator);
```

### OperatorIsAssignedToFeed
This error is thrown when the owner attempts to remove an on-feed operator.

*The owner must remove the operator from the on-feed list first.*


```solidity
error OperatorIsAssignedToFeed(address operator);
```

### OperatorDoesNotExist
This error is raised when removing an operator in removeOperators
and setFeedOperators


```solidity
error OperatorDoesNotExist(address operator);
```

### OperatorIsLocked
This error is raised when operator has been removed from the pool
and is attempted to be readded


```solidity
error OperatorIsLocked(address operator);
```

### InadequateInitialOperatorsCount
This error is raised when attempting to start staking with less
than the minimum required node operators


```solidity
error InadequateInitialOperatorsCount(
  uint256 currentOperatorsCount, uint256 minInitialOperatorsCount
);
```

## Structs
### PoolLimits

```solidity
struct PoolLimits {
  uint96 maxPoolSize;
  uint80 maxCommunityStakeAmount;
  uint80 maxOperatorStakeAmount;
}
```

### PoolState

```solidity
struct PoolState {
  bool isOpen;
  uint8 operatorsCount;
  uint96 totalCommunityStakedAmount;
  uint96 totalOperatorStakedAmount;
}
```

### Staker

```solidity
struct Staker {
  bool isOperator;
  bool isFeedOperator;
  uint96 stakedAmount;
  uint96 removedStakeAmount;
}
```

### Pool

```solidity
struct Pool {
  mapping(address => Staker) stakers;
  address[] feedOperators;
  PoolState state;
  PoolLimits limits;
  uint256 totalOperatorRemovedAmount;
}
```

