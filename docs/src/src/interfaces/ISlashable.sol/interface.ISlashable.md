# ISlashable
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/interfaces/ISlashable.sol)


## Functions
### addSlasher

Adds a new slasher with the given config


```solidity
function addSlasher(address slasher, SlasherConfig calldata config) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The address of the slasher|
|`config`|`SlasherConfig`|The slasher config|


### setSlasherConfig

Sets the slasher config


```solidity
function setSlasherConfig(address slasher, SlasherConfig calldata config) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The address of the slasher|
|`config`|`SlasherConfig`|The slasher config|


### getSlasherConfig

Returns the slasher config


```solidity
function getSlasherConfig(address slasher) external view returns (SlasherConfig memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The slasher|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`SlasherConfig`|The slasher config|


### getSlashCapacity

Returns the slash capacity for a slasher


```solidity
function getSlashCapacity(address slasher) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`slasher`|`address`|The slasher|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The slash capacity|


### slashAndReward

Slashes stakers and rewards the alerter.  Moves slashed staker
funds into the alerter reward funds.  The alerter is then
rewarded by the funds in the alerter reward funds.


```solidity
function slashAndReward(
  address[] calldata stakers,
  address alerter,
  uint256 principalAmount,
  uint256 alerterRewardAmount
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakers`|`address[]`|The list of stakers to slash|
|`alerter`|`address`|The alerter that successfully raised the alert|
|`principalAmount`|`uint256`|The amount of the staker's staked LINK amount to slash|
|`alerterRewardAmount`|`uint256`|The reward amount to be given to the alerter|


## Errors
### InvalidSlasherConfig
This error is thrown when the slasher config is invalid


```solidity
error InvalidSlasherConfig();
```

### InvalidRole
This error is thrown when the contract manager tries to set the slasher role directly
through
`grantRole`


```solidity
error InvalidRole();
```

### InvalidSlasher
This error is thrown then the contract manager tries to set the slasher config for an
address
that doesn't have the slasher role


```solidity
error InvalidSlasher();
```

## Structs
### SlasherConfig
This struct defines the parameters of the slasher config


```solidity
struct SlasherConfig {
  uint256 refillRate;
  uint256 slashCapacity;
}
```

### SlasherState
This struct defines the parameters of the slasher state


```solidity
struct SlasherState {
  uint256 lastSlashTimestamp;
  uint256 remainingSlashCapacityAmount;
}
```

