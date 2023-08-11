# Migratable
[Git Source](https://github.com/smartcontractkit/destiny-next/blob/93e1115f8d7fb0029b73a936d125afb837306065/src/Migratable.sol)

**Inherits:**
[IMigratable](/src/interfaces/IMigratable.sol/interface.IMigratable.md)


## State Variables
### s_migrationTarget
The address of the new contract that this contract will be upgraded to.


```solidity
address internal s_migrationTarget;
```


## Functions
### setMigrationTarget

Sets the address this contract will be upgraded to


```solidity
function setMigrationTarget(address newMigrationTarget) external virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMigrationTarget`|`address`|The address of the migration target|


### _validateMigrationTarget

Helper function for validating the migration target


```solidity
function _validateMigrationTarget(address newMigrationTarget) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMigrationTarget`|`address`|The address of the new migration target|


### getMigrationTarget

Returns the current migration target of the contract


```solidity
function getMigrationTarget() external view virtual override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address The current migration target|


### validateMigrationTargetSet

*Reverts if the migration target is not set*


```solidity
modifier validateMigrationTargetSet();
```

