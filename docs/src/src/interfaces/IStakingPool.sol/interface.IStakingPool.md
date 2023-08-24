# IStakingPool
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/interfaces/IStakingPool.sol)


## Functions
### unstake

Unstakes amount LINK tokens from the staker’s staked LINK amount
Also claims all of the earned rewards if claimRewards is true


```solidity
function unstake(uint256 amount, bool shouldClaimReward) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of LINK tokens to unstake|
|`shouldClaimReward`|`bool`|If true will claim all reward|


### getTotalPrincipal

Returns the total amount staked in the pool


```solidity
function getTotalPrincipal() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total amount staked in pool|


### getStakerPrincipal

Returns the staker's staked LINK amount


```solidity
function getStakerPrincipal(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's staked LINK amount|


### getStakerPrincipalAt

Returns the staker's staked LINK amount


```solidity
function getStakerPrincipalAt(address staker, uint256 checkpointId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|
|`checkpointId`|`uint256`|The checkpoint ID to fetch the staker's balance for.  Pass 0 to return the staker's latest staked LINK amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's staked LINK amount|


### getStakerStakedAtTime

Returns the staker's average staked at time


```solidity
function getStakerStakedAtTime(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's average staked at time|


### getStakerStakedAtTimeAt

Returns the staker's average staked at time for a checkpoint ID


```solidity
function getStakerStakedAtTimeAt(
  address staker,
  uint256 checkpointId
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to query for|
|`checkpointId`|`uint256`|The checkpoint to query for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's average staked at time|


### getRewardVault

Returns the current reward vault address


```solidity
function getRewardVault() external view returns (IRewardVault);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IRewardVault`|The reward vault|


### getChainlinkToken

Returns the address of the LINK token contract


```solidity
function getChainlinkToken() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The LINK token contract's address that is used by the pool|


### getMigrationProxy

Returns the migration proxy contract address


```solidity
function getMigrationProxy() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The migration proxy contract address|


### isOpen

Returns a boolean that is true if the pool is open


```solidity
function isOpen() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the pool is open, false otherwise|


### isActive

Returns a boolean that is true if the pool is active,
i.e. is open and there are remaining rewards to vest in the pool.


```solidity
function isActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the pool is active, false otherwise|


### getStakerLimits

Returns the minimum and maximum amounts a staker can stake in the
pool


```solidity
function getStakerLimits() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 minimum amount that can be staked by a staker|
|`<none>`|`uint256`|uint256 maximum amount that can be staked by a staker|


### getMaxPoolSize

uint256 Returns the maximum amount that can be staked in the pool


```solidity
function getMaxPoolSize() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current maximum staking pool size|


## Events
### MigrationProxySet
This event is emitted when the migration proxy address has been set


```solidity
event MigrationProxySet(address indexed migrationProxy);
```

### PoolSizeIncreased
This event is emitted when the staking pool's maximum size is
increased


```solidity
event PoolSizeIncreased(uint256 maxPoolSize);
```

### MaxPrincipalAmountIncreased
This event is emitted when the maximum stake amount


```solidity
event MaxPrincipalAmountIncreased(uint256 maxPrincipalPerStaker);
```

### Staked
This event is emitted when a staker adds stake to the pool.


```solidity
event Staked(address indexed staker, uint256 newStake, uint256 totalStake);
```

### Unstaked
This event is emitted when a staker removes stake from the pool.


```solidity
event Unstaked(address indexed staker, uint256 amount, uint256 claimedReward);
```

## Errors
### AccessForbidden
This error is thrown when a caller tries to execute a transaction
that they do not have permissions for


```solidity
error AccessForbidden();
```

### InvalidZeroAddress
This error is thrown whenever a zero-address is supplied when
a non-zero address is required


```solidity
error InvalidZeroAddress();
```

### SenderNotLinkToken
This error is thrown whenever the sender is not the LINK token


```solidity
error SenderNotLinkToken();
```

### MigrationProxyNotSet
This error is thrown whenever the migration proxy address has not been set


```solidity
error MigrationProxyNotSet();
```

### RewardVaultNotSet
This error is thrown whenever the reward vault address has not been set


```solidity
error RewardVaultNotSet();
```

### InvalidData
This error is thrown when invalid data is passed to the onTokenTransfer function


```solidity
error InvalidData();
```

### InsufficientStakeAmount
This error is thrown when the staker tries to stake less than the min amount


```solidity
error InsufficientStakeAmount();
```

### ExceedsMaxStakeAmount
This error is thrown when the staker tries to stake more than the max amount


```solidity
error ExceedsMaxStakeAmount();
```

### ExceedsMaxPoolSize
This error is thrown when the staker tries to stake more than the max pool size


```solidity
error ExceedsMaxPoolSize();
```

### StakeNotFound
This error is raised when stakers attempt to exit the pool


```solidity
error StakeNotFound(address staker);
```

### UnstakeZeroAmount
This error is thrown when the staker tries to unstake a zero amount


```solidity
error UnstakeZeroAmount();
```

### UnstakeExceedsPrincipal
This error is thrown when the staker tries to unstake more than the
staked LINK amount


```solidity
error UnstakeExceedsPrincipal();
```

### UnstakePrincipalBelowMinAmount
This error is thrown when the staker tries to unstake an amount that leaves their
staked LINK amount below the minimum amount


```solidity
error UnstakePrincipalBelowMinAmount();
```

## Structs
### Staker
This struct defines the state of a staker


```solidity
struct Staker {
  Checkpoints.Trace224 history;
  uint128 unbondingPeriodEndsAt;
  uint128 claimPeriodEndsAt;
}
```

