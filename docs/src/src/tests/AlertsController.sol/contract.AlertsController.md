# AlertsController
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/tests/AlertsController.sol)

**Inherits:**
ConfirmedOwner


## State Variables
### i_alerterRewardAmount

```solidity
uint256 private immutable i_alerterRewardAmount;
```


### i_slashableAmount

```solidity
uint256 private immutable i_slashableAmount;
```


### i_communityStakingPool

```solidity
CommunityStakingPool private immutable i_communityStakingPool;
```


### i_operatorStakingPool

```solidity
OperatorStakingPool private immutable i_operatorStakingPool;
```


### s_slashableOperators

```solidity
address[] private s_slashableOperators;
```


### s_alertRaisable

```solidity
bool private s_alertRaisable;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params) ConfirmedOwner(msg.sender);
```

### toggleRaisable


```solidity
function toggleRaisable() external onlyOwner;
```

### raiseAlert


```solidity
function raiseAlert(address feed) external;
```

### canAlert


```solidity
function canAlert(address alerter, address feed) external view returns (bool);
```

### getStakingPools


```solidity
function getStakingPools() external view returns (address[] memory);
```

### _canAlert


```solidity
function _canAlert(address alerter, address) internal view returns (bool);
```

### setSlashableOperators


```solidity
function setSlashableOperators(address[] calldata operators, address) external onlyOwner;
```

### getSlashableOperators


```solidity
function getSlashableOperators(address) public view returns (address[] memory);
```

## Errors
### AlertInvalid

```solidity
error AlertInvalid();
```

## Structs
### ConstructorParams

```solidity
struct ConstructorParams {
  uint256 alerterRewardAmount;
  uint256 slashableAmount;
  CommunityStakingPool communityStakingPool;
  OperatorStakingPool operatorStakingPool;
  address[] slashableOperators;
}
```

