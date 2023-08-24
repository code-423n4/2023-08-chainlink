# StakingPoolBaseV2
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/tests/StakingPoolBaseV2.sol)

**Inherits:**
IERC165, ConfirmedOwner

This is a sample migration target contract.

*The Staking v2 contract will need to implement something similar.*


## State Variables
### i_LINK
The LINK token


```solidity
LinkTokenInterface internal immutable i_LINK;
```


### migratedAmount

```solidity
mapping(address => uint256) public migratedAmount;
```


### migratedData

```solidity
mapping(address => bytes) public migratedData;
```


### s_migrationSource

```solidity
address private s_migrationSource;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params) ConfirmedOwner(msg.sender);
```

### onTokenTransfer

LINK transfer callback function called when transferAndCall is called with this
contract as a target.


```solidity
function onTokenTransfer(
  address sender,
  uint256 amount,
  bytes memory data
) public onlyMigrationSource validateFromLINK;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|Pool sending the tokens.|
|`amount`|`uint256`|Amount of LINK token transferred|
|`data`|`bytes`|Bytes data received|


### supportsInterface

This function allows the calling contract to
check if the contract deployed at this address is a valid
LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
if it implements the onTokenTransfer function.


```solidity
function supportsInterface(bytes4 interfaceID) external pure returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceID`|`bytes4`|The ID of the interface to check against|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the contract is a valid LINKTokenReceiver.|


### onlyMigrationSource

*Reverts if the migration source is not set or the sender is not the migration source.*


```solidity
modifier onlyMigrationSource();
```

### validateFromLINK

*Reverts if not sent from the LINK token*


```solidity
modifier validateFromLINK();
```

## Events
### StakerMigrated
This event is emitted when the contract receives the migration tokens


```solidity
event StakerMigrated(
  address staker, uint256 amount, uint256 stakerStakedAtTime, bytes data, address sender
);
```

## Errors
### InvalidMigrationSource
This error is thrown when the owner tries to set the migration source to the
zero address


```solidity
error InvalidMigrationSource();
```

### SenderNotMigrationSource
This error is thrown when the sender is not the migration source.


```solidity
error SenderNotMigrationSource();
```

### SenderNotLinkToken
This error is thrown whenever the sender is not the LINK token


```solidity
error SenderNotLinkToken();
```

## Structs
### ConstructorParams
This struct defines the params required by the StakingPoolBase contract's
constructor.


```solidity
struct ConstructorParams {
  LinkTokenInterface LINKAddress;
  address migrationSource;
}
```

