# Counter
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/tests/Counter.sol)


## State Variables
### s_timelock

```solidity
address private s_timelock;
```


### s_number

```solidity
uint256 private s_number;
```


## Functions
### constructor


```solidity
constructor(address timelock);
```

### setNumber


```solidity
function setNumber(uint256 newNumber) public onlyTimelock;
```

### increment


```solidity
function increment() public onlyTimelock;
```

### mockRevert


```solidity
function mockRevert() public pure;
```

### number


```solidity
function number() external view returns (uint256);
```

### onlyTimelock


```solidity
modifier onlyTimelock();
```

