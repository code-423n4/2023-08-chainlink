# MigrationProxy
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/MigrationProxy.sol)

**Inherits:**
ERC677ReceiverInterface, [PausableWithAccessControl](/src/PausableWithAccessControl.sol/abstract.PausableWithAccessControl.md), TypeAndVersionInterface

This contract is a proxy for migrating stakers from the Staking V0.1

*When a staker calls the migrate function on the staking v0.1 contract, it will transfer the
migrating LINK to this contract. This contract will then transfer the LINK to the appropriate
staking pool. If the user wants a partial migration, the amount to withdraw will be transferred
back to the staker.*

*invariant LINK balance of the contract is zero*


## State Variables
### i_LINK
The LINK Token


```solidity
LinkTokenInterface private immutable i_LINK;
```


### i_v01StakingAddress
The Staking V0.1 Pool


```solidity
address private immutable i_v01StakingAddress;
```


### i_operatorStakingPool
The Operator Staking Pool


```solidity
OperatorStakingPool private immutable i_operatorStakingPool;
```


### i_communityStakingPool
The Community Staking Pool


```solidity
CommunityStakingPool private immutable i_communityStakingPool;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params)
  PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender);
```

### onTokenTransfer

LINK transfer callback function called when transferAndCall is called with this
contract as a target.

*precondition The v0.1 staking is closed*

*precondition The v0.2 staking pools are open*

*precondition The migration proxy is not paused*

*A redundant check for the Staking V0.1 contract being closed is omitted. This function
can only be called by the V0.1 contract’s migrate function, which can
only be called when the V0.1 pool is closed.*


```solidity
function onTokenTransfer(
  address source,
  uint256 amount,
  bytes calldata data
) external override whenNotPaused validateFromLINK;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`source`|`address`|The Staking V0.1 address|
|`amount`|`uint256`|Amount of LINK token transferred|
|`data`|`bytes`|Bytes data received, represents migration path|


### _migrateToPool

Transfers the staker's funds and migration data to a staking pool.
If the staker is a operator, the OperatorStakingPool will be used; otherwise,
the CommunityStakingPool will be used.


```solidity
function _migrateToPool(address staker, uint256 amount, bytes calldata data) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker who is migrating|
|`amount`|`uint256`|Amount of LINK token transferred|
|`data`|`bytes`|Bytes data received, represents migration path|


### getConfig

Returns the configured addresses


```solidity
function getConfig() external view returns (address, address, address, address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The Link token, Staking V0.1, Operator staking pool, and community staking pool.|
|`<none>`|`address`||
|`<none>`|`address`||
|`<none>`|`address`||


### supportsInterface

This function allows the calling contract to
check if the contract deployed at this address is a valid
LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
if it implements the onTokenTransfer function.


```solidity
function supportsInterface(bytes4 interfaceId) public view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The ID of the interface to check against|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the contract is a valid LINKTokenReceiver.|


### typeAndVersion


```solidity
function typeAndVersion() external pure virtual override returns (string memory);
```

### validateFromLINK

*Reverts if not sent from the LINK token*


```solidity
modifier validateFromLINK();
```

## Errors
### InvalidZeroAddress
This error is thrown whenever a zero-address is supplied when
a non-zero address is required


```solidity
error InvalidZeroAddress();
```

### InvalidSourceAddress
This error is thrown when the onTokenTransfer source address is
not the Staking V0.1 address.


```solidity
error InvalidSourceAddress();
```

### InvalidAmounts
This error is thrown when the sum of amounts to stake and withdraw
isn't equal to the total amount passed to the Migration Proxy.


```solidity
error InvalidAmounts(uint256 amountToStake, uint256 amountToWithdraw, uint256 amountTotal);
```

### SenderNotLinkToken
This error is thrown whenever the sender is not the LINK token


```solidity
error SenderNotLinkToken();
```

## Structs
### ConstructorParams
This struct defines the params required by the MigrationProxy contract's
constructor.


```solidity
struct ConstructorParams {
  LinkTokenInterface LINKAddress;
  address v01StakingAddress;
  OperatorStakingPool operatorStakingPool;
  CommunityStakingPool communityStakingPool;
  uint48 adminRoleTransferDelay;
}
```

