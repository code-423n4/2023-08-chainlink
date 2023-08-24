# SafeCast
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/SafeCast.sol)


## State Variables
### MAX_UINT_8
This is used to safely case timestamps to uint8


```solidity
uint256 private constant MAX_UINT_8 = type(uint8).max;
```


### MAX_UINT_32
This is used to safely case timestamps to uint32


```solidity
uint256 private constant MAX_UINT_32 = type(uint32).max;
```


### MAX_UINT_80
This is used to safely case timestamps to uint80


```solidity
uint256 private constant MAX_UINT_80 = type(uint80).max;
```


### MAX_UINT_96
This is used to safely case timestamps to uint96


```solidity
uint256 private constant MAX_UINT_96 = type(uint96).max;
```


## Functions
### _toUint8


```solidity
function _toUint8(uint256 value) internal pure returns (uint8);
```

### _toUint32


```solidity
function _toUint32(uint256 value) internal pure returns (uint32);
```

### _toUint80


```solidity
function _toUint80(uint256 value) internal pure returns (uint80);
```

### _toUint96


```solidity
function _toUint96(uint256 value) internal pure returns (uint96);
```

### test


```solidity
function test() public;
```

## Errors
### CastError

```solidity
error CastError();
```

