# IRewardVault
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/interfaces/IRewardVault.sol)


## Functions
### claimReward

Claims reward earned by a staker
Called by staking pools to forward claim requests from stakers or called by the stakers
themselves.


```solidity
function claimReward() external returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The amount of rewards claimed in juels|


### updateReward

Updates the staking pools' reward per token and staker’s reward state
in the reward vault.  This function is called whenever the staker's reward
state needs to be updated without resetting their multiplier

*This is called whenever an operator is slashed as we want to update
the operator's rewards state without resetting their multiplier.*


```solidity
function updateReward(address staker, uint256 stakerPrincipal) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker's address. If this is set to zero address, staker's reward update will be skipped|
|`stakerPrincipal`|`uint256`|The staker's current staked LINK amount in juels|


### finalizeReward

Finalizes the staker's reward and resets their multiplier.
This will apply the staker's current ramp up multiplier to their
earned rewards and store the amount of rewards they have earned before
their multiplier is reset.

*This is called whenever 1) A staker stakes 2) A staker unstakes
3) An operator is removed as we want to update the staker's
rewards AND reset their multiplier.*

*Staker rewards are not forfeited when they stake before they have
reached their maximum ramp up period multiplier.  Instead these
rewards are stored as already earned rewards and will be subject to the
multiplier the next time the contract calculates the staker's claimable
rewards.*

*Staker rewards are forfeited when a staker unstakes before they
have reached their maximum ramp up period multiplier.  Additionally an
operator will also forfeit any unclaimable rewards if they are removed
before they reach the maximum ramp up period multiplier.  The amount of
rewards forfeited is proportional to the amount unstaked relative to
the staker's total staked LINK amount when unstaking.  A removed operator forfeits
100% of their unclaimable rewards.*


```solidity
function finalizeReward(
  address staker,
  uint256 oldPrincipal,
  uint256 stakedAt,
  uint256 unstakedAmount,
  bool shouldClaim
) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker addres|
|`oldPrincipal`|`uint256`|The staker's staked LINK amount before finalizing|
|`stakedAt`|`uint256`|The last time the staker staked at|
|`unstakedAmount`|`uint256`|The amount that the staker has unstaked in juels|
|`shouldClaim`|`bool`|True if rewards should be transferred to the staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The claimed reward amount.|


### close

Closes the reward vault, disabling adding rewards and staking


```solidity
function close() external;
```

### isOpen

Returns a boolean that is true if the reward vault is open


```solidity
function isOpen() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if open, false otherwise|


### getReward

Returns the rewards that the staker would get if they withdraw now
Rewards calculation is based on the staker's multiplier


```solidity
function getReward(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The reward amount|


### getStoredReward

Returns the stored reward info of the staker


```solidity
function getStoredReward(address staker) external view returns (StakerReward memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`StakerReward`|The staker's stored reward info|


### isPaused

Returns whether or not the vault is paused


```solidity
function isPaused() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the vault is paused|


### hasRewardDurationEnded

Returns whether or not the reward duration for the pool has ended


```solidity
function hasRewardDurationEnded(address stakingPool) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingPool`|`address`|The address of the staking pool rewards are being shared to|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the reward duration has ended|


## Structs
### StakerReward
This struct is used to store the reward information for a staker.


```solidity
struct StakerReward {
  uint112 finalizedBaseReward;
  uint112 finalizedDelegatedReward;
  uint112 baseRewardPerToken;
  uint112 operatorDelegatedRewardPerToken;
  uint112 claimedBaseRewardsInPeriod;
  StakerType stakerType;
  uint256 storedBaseReward;
  uint256 earnedBaseRewardInPeriod;
}
```

## Enums
### StakerType
This enum describes the different staker types


```solidity
enum StakerType {
  NOT_STAKED,
  COMMUNITY,
  OPERATOR
}
```

