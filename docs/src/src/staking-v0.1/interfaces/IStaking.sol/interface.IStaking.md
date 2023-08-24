# IStaking
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/interfaces/IStaking.sol)


## Functions
### unstake

This function allows stakers to exit the pool after it has been
concluded. It returns the principal as well as base and delegation
rewards.


```solidity
function unstake() external;
```

### withdrawRemovedStake

This function allows removed operators to withdraw their original
principal. Operators can only withdraw after the pool is closed, like
every other staker.


```solidity
function withdrawRemovedStake() external;
```

### getChainlinkToken


```solidity
function getChainlinkToken() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address LINK token contract's address that is used by the pool|


### getStake


```solidity
function getStake(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 staker's staked principal amount|


### isOperator

Returns true if an address is an operator


```solidity
function isOperator(address staker) external view returns (bool);
```

### isActive

The staking pool starts closed and only allows
stakers to stake once it's opened


```solidity
function isActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool pool status|


### getMaxPoolSize


```solidity
function getMaxPoolSize() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current maximum staking pool size|


### getCommunityStakerLimits


```solidity
function getCommunityStakerLimits() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 minimum amount that can be staked by a community staker|
|`<none>`|`uint256`|uint256 maximum amount that can be staked by a community staker|


### getOperatorLimits


```solidity
function getOperatorLimits() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 minimum amount that can be staked by an operator|
|`<none>`|`uint256`|uint256 maximum amount that can be staked by an operator|


### getRewardTimestamps


```solidity
function getRewardTimestamps() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 reward initialization timestamp|
|`<none>`|`uint256`|uint256 reward expiry timestamp|


### getRewardRate


```solidity
function getRewardRate() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current reward rate, expressed in juels per second per micro LINK|


### getDelegationRateDenominator


```solidity
function getDelegationRateDenominator() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current delegation rate|


### getAvailableReward

*This reflects how many rewards were made available over the
lifetime of the staking pool. This is not updated when the rewards are
unstaked or migrated by the stakers. This means that the contract balance
will dip below available amount when the reward expires and users start
moving their rewards.*


```solidity
function getAvailableReward() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount of LINK tokens made available for rewards in Juels|


### getBaseReward


```solidity
function getBaseReward(address) external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 amount of base rewards earned by a staker in Juels|


### getDelegationReward


```solidity
function getDelegationReward(address) external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 amount of delegation rewards earned by an operator in Juels|


### getTotalDelegatedAmount

Total delegated amount is calculated by dividing the total
community staker staked amount by the delegation rate, i.e.
totalDelegatedAmount = pool.totalCommunityStakedAmount / delegationRateDenominator


```solidity
function getTotalDelegatedAmount() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 staked amount that is used when calculating delegation rewards in Juels|


### getDelegatesCount

Delegates count increases after an operator is added to the list
of operators and stakes the minimum required amount.


```solidity
function getDelegatesCount() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 number of staking operators that are eligible for delegation rewards|


### getEarnedBaseRewards


```solidity
function getEarnedBaseRewards() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount of base rewards earned by all stakers in Juels|


### getEarnedDelegationRewards


```solidity
function getEarnedDelegationRewards() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount of delegated rewards earned by all node operators in Juels|


### getTotalStakedAmount


```solidity
function getTotalStakedAmount() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount staked by community stakers and operators in Juels|


### getTotalCommunityStakedAmount


```solidity
function getTotalCommunityStakedAmount() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount staked by community stakers in Juels|


### getTotalRemovedAmount

*Used to make sure that contract's balance is correct.
total staked amount + total removed amount + available rewards = current balance*


```solidity
function getTotalRemovedAmount() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 the sum of removed operator principals that have not been withdrawn from the staking pool in Juels.|


### isPaused

This function returns the pause state


```solidity
function isPaused() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool whether or not the pool is paused|


### getMonitoredFeed


```solidity
function getMonitoredFeed() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address The address of the feed being monitored to raise alerts for|


## Events
### Staked
This event is emitted when a staker adds stake to the pool.


```solidity
event Staked(address staker, uint256 newStake, uint256 totalStake);
```

### Unstaked
This event is emitted when a staker exits the pool.


```solidity
event Unstaked(address staker, uint256 principal, uint256 baseReward, uint256 delegationReward);
```

## Errors
### SenderNotLinkToken
This error is thrown whenever the sender is not the LINK token


```solidity
error SenderNotLinkToken();
```

### AccessForbidden
This error is thrown whenever an address does not have access
to successfully execute a transaction


```solidity
error AccessForbidden();
```

### InvalidZeroAddress
This error is thrown whenever a zero-address is supplied when
a non-zero address is required


```solidity
error InvalidZeroAddress();
```

