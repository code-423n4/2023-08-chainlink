# CommunityStakingPool
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/pools/CommunityStakingPool.sol)

**Inherits:**
[StakingPoolBase](/src/pools/StakingPoolBase.sol/abstract.StakingPoolBase.md), [IMerkleAccessController](/src/staking-v0.1/interfaces/IMerkleAccessController.sol/interface.IMerkleAccessController.md), TypeAndVersionInterface

This contract manages the staking of LINK tokens for the community stakers.

*This contract inherits the StakingPoolBase contract and interacts with the MigrationProxy,
OperatorStakingPool, and RewardVault contracts.*

*invariant Operators cannot stake in the community staking pool.*


## State Variables
### s_operatorStakingPool
The operator staking pool contract


```solidity
OperatorStakingPool private s_operatorStakingPool;
```


### s_merkleRoot
The merkle root of the merkle tree generated from the list
of staker addresses with early acccess.


```solidity
bytes32 private s_merkleRoot;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams);
```

### _validateOnTokenTransfer

Validate for when LINK is staked or migrated into the pool


```solidity
function _validateOnTokenTransfer(
  address sender,
  address staker,
  bytes calldata data
) internal view override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The address transferring LINK into the pool. Could be the migration proxy contract or the staker.|
|`staker`|`address`|The address staking or migrating LINK into the pool|
|`data`|`bytes`|Arbitrary data passed when staking or migrating|


### _handleOpen

Handler for opening the pool


```solidity
function _handleOpen() internal view override(StakingPoolBase);
```

### hasAccess

Validates if a community staker has access to the private staking pool


```solidity
function hasAccess(address staker, bytes32[] calldata proof) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The community staker's address|
|`proof`|`bytes32[]`|Merkle proof for the community staker's allowlist|


### _hasAccess

Util function that validates if a community staker has access to an
access limited community staking pool


```solidity
function _hasAccess(address staker, bytes32[] memory proof) private view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The community staker's address|
|`proof`|`bytes32[]`|Merkle proof for the community staker's allowlist|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the community staker has access to the access limited community staking pool|


### setMerkleRoot

This function is called to update the staking allowlist in a private staking pool

*precondition The caller must have the default admin role.*


```solidity
function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMerkleRoot`|`bytes32`|Merkle Tree root, used to prove access for community stakers will be required at start but can be removed at any time by the owner when staking access will be granted to the public.|


### getMerkleRoot


```solidity
function getMerkleRoot() external view override returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The current root of the Staking allowlist merkle tree|


### setOperatorStakingPool

This function sets the operator staking pool

*precondition The caller must have the default admin role.*


```solidity
function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
  external
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOperatorStakingPool`|`OperatorStakingPool`|The new operator staking pool|


### typeAndVersion


```solidity
function typeAndVersion() external pure virtual override returns (string memory);
```

## Events
### OperatorStakingPoolChanged
This event is emitted when the operator staking pool


```solidity
event OperatorStakingPoolChanged(
  address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
);
```

## Errors
### MerkleRootNotSet
This error is thrown when the pool is opened with an empty
merkle root


```solidity
error MerkleRootNotSet();
```

## Structs
### ConstructorParams
This struct defines the params required by the Staking contract's
constructor.


```solidity
struct ConstructorParams {
  ConstructorParamsBase baseParams;
  OperatorStakingPool operatorStakingPool;
}
```

