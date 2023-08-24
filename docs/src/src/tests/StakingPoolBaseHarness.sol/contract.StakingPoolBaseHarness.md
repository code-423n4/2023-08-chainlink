# StakingPoolBaseHarness
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/tests/StakingPoolBaseHarness.sol)

**Inherits:**
[StakingPoolBase](/src/pools/StakingPoolBase.sol/abstract.StakingPoolBase.md)


## Functions
### constructor


```solidity
constructor(ConstructorParamsBase memory params) StakingPoolBase(params);
```

### _validateOnTokenTransfer


```solidity
function _validateOnTokenTransfer(address, address, bytes calldata) internal pure override;
```

### _handleOpen


```solidity
function _handleOpen() internal pure override;
```

### setIsOpen

*This function is needed to bypass the whenOpen checks
in StakingPoolBase functions while keeping _handleOpen unimplemented.*


```solidity
function setIsOpen(bool isOpen) external onlyRole(DEFAULT_ADMIN_ROLE);
```

