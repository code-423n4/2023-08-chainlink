# IMerkleAccessController
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/interfaces/IMerkleAccessController.sol)


## Functions
### hasAccess

Validates if a community staker has access to the private staking pool


```solidity
function hasAccess(address staker, bytes32[] calldata proof) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The community staker's address|
|`proof`|`bytes32[]`|Merkle proof for the community staker's allowlist|


### setMerkleRoot

This function is called to update the staking allowlist in a private staking pool

*Only callable by the contract owner*


```solidity
function setMerkleRoot(bytes32 newMerkleRoot) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMerkleRoot`|`bytes32`|Merkle Tree root, used to prove access for community stakers will be required at start but can be removed at any time by the owner when staking access will be granted to the public.|


### getMerkleRoot


```solidity
function getMerkleRoot() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The current root of the Staking allowlist merkle tree|


## Events
### MerkleRootChanged
Emitted when the contract owner updates the staking allowlist


```solidity
event MerkleRootChanged(bytes32 newMerkleRoot);
```

