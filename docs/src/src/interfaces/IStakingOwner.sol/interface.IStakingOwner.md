# IStakingOwner
[Git Source](https://github.com/smartcontractkit/destiny-next/blob/93e1115f8d7fb0029b73a936d125afb837306065/src/interfaces/IStakingOwner.sol)


## Functions
### setPoolConfig

Set the pool config


```solidity
function setPoolConfig(uint256 maxPoolSize, uint256 maxPrincipalPerStaker) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPoolSize`|`uint256`|The max amount of staked LINK allowed in the pool|
|`maxPrincipalPerStaker`|`uint256`|The max amount of LINK a staker can stake in the pool.|


### open

Opens the pool for staking


```solidity
function open() external;
```

### close

Closes the pool


```solidity
function close() external;
```

### setMigrationProxy

Sets the migration proxy contract address


```solidity
function setMigrationProxy(address migrationProxy) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`migrationProxy`|`address`|The migration proxy contract address|


## Events
### PoolOpened
This event is emitted when the staking pool is opened for staking


```solidity
event PoolOpened();
```

### PoolClosed
This event is emitted when the staking pool is closed


```solidity
event PoolClosed();
```

## Errors
### InvalidMinStakeAmount
This error is thrown when an invalid min operator stake amount is
supplied


```solidity
error InvalidMinStakeAmount();
```

### InvalidPoolSize
This error is raised when attempting to decrease maximum pool size


```solidity
error InvalidPoolSize(uint256 maxPoolSize);
```

### InvalidMaxStakeAmount
This error is raised when attempting to decrease maximum stake amount
for the pool members


```solidity
error InvalidMaxStakeAmount(uint256 maxStakeAmount);
```

### PoolNotOpen
This error is thrown when the staking pool is closed.


```solidity
error PoolNotOpen();
```

### PoolNotClosed
This error is thrown when the staking pool is open.


```solidity
error PoolNotClosed();
```

### PoolHasBeenOpened
This error is thrown when the staking pool has been opened and admin tries to re-open.


```solidity
error PoolHasBeenOpened();
```

### PoolHasBeenClosed
This error is thrown when the pool has been closed and admin tries to re-open


```solidity
error PoolHasBeenClosed();
```

