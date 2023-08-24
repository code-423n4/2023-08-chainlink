# IAlertsControllerOwner
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/interfaces/IAlertsControllerOwner.sol)


## Functions
### setSlashableOperators

Allows the contract owner to set the list of operator addresses who are
subject to slashing.


```solidity
function setSlashableOperators(address[] calldata operators, bytes calldata data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|New list of operator staker addresses|
|`data`|`bytes`|Optional payload|


### getSlashableOperators

Returns the slashable operators.


```solidity
function getSlashableOperators(bytes calldata data) external view returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|Optional payload|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|The list of slashable operators' addresses.|


