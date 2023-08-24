# IMigratable
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/interfaces/IMigratable.sol)


## Functions
### getMigrationTarget

This function returns the migration target contract address


```solidity
function getMigrationTarget() external view returns (address);
```

### proposeMigrationTarget

This function allows the contract owner to set a proposed
migration target address. If the migration target is valid it renounces
the previously accepted migration target (if any).


```solidity
function proposeMigrationTarget(address migrationTarget) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`migrationTarget`|`address`|Contract address to migrate stakes to.|


### acceptMigrationTarget

This function allows the contract owner to accept a proposed migration target address
after a waiting period.


```solidity
function acceptMigrationTarget() external;
```

### migrate

This function allows stakers to migrate funds to a new staking pool.


```solidity
function migrate(bytes calldata data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|Migration path details|


## Events
### MigrationTargetProposed
This event is emitted when a migration target is proposed by the contract owner.


```solidity
event MigrationTargetProposed(address migrationTarget);
```

### MigrationTargetAccepted
This event is emitted after a 7 day period has passed since a migration target is
proposed, and the target is accepted.


```solidity
event MigrationTargetAccepted(address migrationTarget);
```

### Migrated
This event is emitted when a staker migrates their stake to the migration target.


```solidity
event Migrated(
  address staker, uint256 principal, uint256 baseReward, uint256 delegationReward, bytes data
);
```

## Errors
### InvalidMigrationTarget
This error is raised when the contract owner supplies a non-contract migration target.


```solidity
error InvalidMigrationTarget();
```

