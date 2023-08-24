# PausableWithAccessControl
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/PausableWithAccessControl.sol)

**Inherits:**
[IPausable](/src/interfaces/IPausable.sol/interface.IPausable.md), Pausable, AccessControlDefaultAdminRules


## State Variables
### PAUSER_ROLE
This is the ID for the pauser role, which is given to the addresses that can pause and
unpause the contract.

*Hash: 65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a*


```solidity
bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
```


## Functions
### constructor


```solidity
constructor(
  uint48 adminRoleTransferDelay,
  address defaultAdmin
) AccessControlDefaultAdminRules(adminRoleTransferDelay, defaultAdmin);
```

### emergencyPause

This function pauses the contract

*Sets the pause flag to true*


```solidity
function emergencyPause() external override onlyRole(PAUSER_ROLE);
```

### emergencyUnpause

This function unpauses the contract

*Sets the pause flag to false*


```solidity
function emergencyUnpause() external override onlyRole(PAUSER_ROLE);
```

