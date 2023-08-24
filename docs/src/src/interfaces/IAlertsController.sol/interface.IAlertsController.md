# IAlertsController
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/interfaces/IAlertsController.sol)


## Functions
### raiseAlert

This function creates an alert for an unhealthy Chainlink service


```solidity
function raiseAlert(bytes calldata data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|Optional payload|


### canAlert

This function returns true if the alerter may raise an alert
to claim rewards and false otherwise


```solidity
function canAlert(address alerter, bytes calldata data) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`alerter`|`address`|The alerter's address|
|`data`|`bytes`|Optional payload|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if alerter can alert, false otherwise|


### getStakingPools

This function returns the staking pools connected to this alerts controller


```solidity
function getStakingPools() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|address[] The staking pools|


