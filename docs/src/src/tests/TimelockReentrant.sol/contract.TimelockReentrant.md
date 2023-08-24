# TimelockReentrant
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/tests/TimelockReentrant.sol)


## State Variables
### _reenterTarget

```solidity
address private _reenterTarget;
```


### _reenterData

```solidity
bytes private _reenterData;
```


### _reentered

```solidity
bool _reentered;
```


## Functions
### disableReentrancy


```solidity
function disableReentrancy() external;
```

### enableRentrancy


```solidity
function enableRentrancy(address target, bytes calldata data) external;
```

### reenter


```solidity
function reenter() external;
```

