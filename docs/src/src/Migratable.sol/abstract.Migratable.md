# Migratable
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/Migratable.sol)

**Inherits:**
[IMigratable](/src/staking-v0.1/interfaces/IMigratable.sol/interface.IMigratable.md)


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

This function returns the migration target contract address


```solidity
function getMigrationTarget() external view virtual override returns (address);
```

### validateMigrationTargetSet

*Reverts if the migration target is not set*


```solidity
modifier validateMigrationTargetSet();
```

