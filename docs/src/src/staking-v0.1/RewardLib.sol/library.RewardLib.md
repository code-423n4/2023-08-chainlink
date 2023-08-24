# RewardLib
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/RewardLib.sol)


## State Variables
### REWARD_PRECISION
This is the reward calculation precision variable. LINK token has the
1e18 multiplier which means that rewards are floored after 6 decimals
points. Micro LINK is the smallest unit that is eligible for rewards.


```solidity
uint256 internal constant REWARD_PRECISION = 1e12;
```


## Functions
### _initialize

initializes the reward with the defined parameters

*can only be called once. Any future reward changes have to be done
using specific functions.*


```solidity
function _initialize(
  Reward storage reward,
  uint256 maxPoolSize,
  uint256 rate,
  uint256 minRewardDuration,
  uint256 availableReward
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reward`|`Reward`||
|`maxPoolSize`|`uint256`|maximum pool size that the reward is initialized with|
|`rate`|`uint256`|reward rate|
|`minRewardDuration`|`uint256`|the minimum duration rewards need to last for|
|`availableReward`|`uint256`|available reward amount|


### _isDepleted


```solidity
function _isDepleted(Reward storage reward) internal view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool true if the reward is expired (end <= now)|


### _accumulateBaseRewards

Helper function to accumulate base rewards
Accumulate reward per micro LINK before changing reward rate.
This keeps rewards prior to rate change unaffected.


```solidity
function _accumulateBaseRewards(Reward storage reward) internal;
```

### _accumulateDelegationRewards

Helper function to accumulate delegation rewards

*This function is necessary to correctly account for any changes in
eligible operators, delegated amount or reward rate.*


```solidity
function _accumulateDelegationRewards(Reward storage reward, uint256 delegatedAmount) internal;
```

### _calculateReward

Helper function to calculate rewards


```solidity
function _calculateReward(
  Reward storage reward,
  uint256 amount,
  uint256 duration
) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reward`|`Reward`||
|`amount`|`uint256`|a staked amount to calculate rewards for|
|`duration`|`uint256`|a duration that the specified amount receives rewards for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|rewardsAmount|


### _calculateAccruedDelegatedRewards

Calculates the amount of delegated rewards accumulated so far.

*This function takes into account the amount of delegated
rewards accumulated from previous delegate counts and amounts and
the latest additional value.*


```solidity
function _calculateAccruedDelegatedRewards(
  Reward storage reward,
  uint256 totalDelegatedAmount
) internal view returns (uint256);
```

### _calculateAccruedBaseRewards

Calculates the amount of rewards accrued so far.

*This function takes into account the amount of
rewards accumulated from previous rates in addition to
the rewards that will be accumulated based off the current rate
over a given duration.*


```solidity
function _calculateAccruedBaseRewards(
  Reward storage reward,
  uint256 amount
) internal view returns (uint256);
```

### _calculateConcludedBaseRewards

We use a simplified reward calculation formula because we know that
the reward is expired. We accumulate reward per micro LINK
before concluding the pool so we can avoid reading additional storage
variables.


```solidity
function _calculateConcludedBaseRewards(
  Reward storage reward,
  uint256 amount,
  address staker
) internal view returns (uint256);
```

### _updateReservedRewards

Reserves staker rewards. This is necessary to make sure that
there are always enough available LINK tokens for all stakers until the
reward end timestamp. The amount is calculated for the remaining reward
duration using the current reward rate.


```solidity
function _updateReservedRewards(
  Reward storage reward,
  uint256 baseRewardAmount,
  uint256 delegatedRewardAmount,
  bool isReserving
) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reward`|`Reward`||
|`baseRewardAmount`|`uint256`|The amount of base rewards to reserve or unreserve for|
|`delegatedRewardAmount`|`uint256`|The amount of delegated rewards to reserve or unreserve for|
|`isReserving`|`bool`|true if function should reserve more rewards. false will unreserve and deduct from the reserved total|


### _reserve

Increase reserved staker rewards.


```solidity
function _reserve(
  Reward storage reward,
  uint256 baseRewardAmount,
  uint256 delegatedRewardAmount
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reward`|`Reward`||
|`baseRewardAmount`|`uint256`|The amount of base rewards to reserve or unreserve for|
|`delegatedRewardAmount`|`uint256`|The amount of delegated rewards to reserve or unreserve for|


### _unreserve

Decrease reserved staker rewards.


```solidity
function _unreserve(
  Reward storage reward,
  uint256 baseRewardAmount,
  uint256 delegatedRewardAmount
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reward`|`Reward`||
|`baseRewardAmount`|`uint256`|The amount of base rewards to reserve or unreserve for|
|`delegatedRewardAmount`|`uint256`|The amount of delegated rewards to reserve or unreserve for|


### _release

function does multiple things:
- Unreserves future staking rewards to make them available for withdrawal;
- Expires the reward to stop rewards from accumulating;


```solidity
function _release(Reward storage reward, uint256 amount, uint256 delegatedAmount) internal;
```

### _getDelegatedAmount

calculates an amount that community stakers have to delegate to operators


```solidity
function _getDelegatedAmount(
  uint256 amount,
  uint256 delegationRateDenominator
) internal pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|base staked amount to calculate delegated amount against|
|`delegationRateDenominator`|`uint256`|Delegation rate used to calculate delegated stake amount|


### _getNonDelegatedAmount

calculates the amount of stake that remains after accounting for delegation
requirement


```solidity
function _getNonDelegatedAmount(
  uint256 amount,
  uint256 delegationRateDenominator
) internal pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|base staked amount to calculate non-delegated amount against|
|`delegationRateDenominator`|`uint256`|Delegation rate used to calculate delegated stake amount|


### _getRemainingDuration


```solidity
function _getRemainingDuration(Reward storage reward) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 the remaining reward duration (time until end), or 0 if expired/ended.|


### _updateDuration

This function is called when the staking pool is initialized,
pool size is changed, reward rates are changed, rewards are added, and an alert is raised


```solidity
function _updateDuration(
  Reward storage reward,
  uint256 maxPoolSize,
  uint256 totalStakedAmount,
  uint256 newRate,
  uint256 minRewardDuration,
  uint256 availableReward,
  uint256 totalDelegatedAmount
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reward`|`Reward`||
|`maxPoolSize`|`uint256`|Current maximum staking pool size|
|`totalStakedAmount`|`uint256`|Currently staked amount across community stakers and operators|
|`newRate`|`uint256`|New reward rate if it needs to be changed|
|`minRewardDuration`|`uint256`|The minimum duration rewards need to last for|
|`availableReward`|`uint256`|available reward amount|
|`totalDelegatedAmount`|`uint256`|total delegated amount delegated by community stakers|


### _getEarnedBaseRewards


```solidity
function _getEarnedBaseRewards(
  Reward storage reward,
  uint256 totalStakedAmount,
  uint256 totalDelegatedAmount
) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total amount of base rewards earned by all stakers|


### _getEarnedDelegationRewards


```solidity
function _getEarnedDelegationRewards(
  Reward storage reward,
  uint256 totalDelegatedAmount
) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total amount of delegated rewards earned by all node operators|


### _slashOnFeedOperators

Slashes all on feed node operators.
Node operators are slashed the minimum of either the
amount of rewards they have earned or the amount
of rewards earned by the minimum operator stake amount
over the slashable duration.


```solidity
function _slashOnFeedOperators(
  Reward storage reward,
  uint256 minOperatorStakeAmount,
  uint256 slashableDuration,
  address[] memory feedOperators,
  mapping(address => StakingPoolLib.Staker) storage stakers,
  uint256 totalDelegatedAmount
) internal;
```

### _getSlashableBaseRewards

The amount of rewards accrued over the slashable duration for a
minimum node operator stake amount


```solidity
function _getSlashableBaseRewards(
  Reward storage reward,
  uint256 minOperatorStakeAmount,
  uint256 slashableDuration
) private view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of base rewards to slash|


### _getSlashableDelegatedRewards

*The amount of delegated rewards accrued over the slashable duration*


```solidity
function _getSlashableDelegatedRewards(
  Reward storage reward,
  uint256 slashableDuration,
  uint256 totalDelegatedAmount
) private view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of delegated rewards to slash|


### _slashOperatorBaseRewards

Slashes an on feed node operator the minimum of
either the total amount of base rewards they have
earned or the amount of rewards earned by the
minimum operator stake amount over the slashable duration.


```solidity
function _slashOperatorBaseRewards(
  Reward storage reward,
  uint256 slashableRewards,
  address operator,
  uint256 operatorStakedAmount
) private returns (uint256);
```

### _slashOperatorDelegatedRewards

Slashes an on feed node operator the minimum of
either the total amount of delegated rewards they have
earned or the amount of delegated rewards they have
earned over the slashable duration.


```solidity
function _slashOperatorDelegatedRewards(
  Reward storage reward,
  uint256 slashableRewards,
  address operator,
  uint256 totalDelegatedAmount
) private returns (uint256);
```

### _getOperatorEarnedBaseRewards


```solidity
function _getOperatorEarnedBaseRewards(
  Reward storage reward,
  address operator,
  uint256 operatorStakedAmount
) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of base rewards an operator has earned.|


### _getOperatorEarnedDelegatedRewards


```solidity
function _getOperatorEarnedDelegatedRewards(
  Reward storage reward,
  address operator,
  uint256 totalDelegatedAmount
) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of delegated rewards an operator has earned.|


### _getCappedTimestamp

*This is necessary to ensure that rewards are calculated correctly
after the reward is depleted.*


```solidity
function _getCappedTimestamp(Reward storage reward) internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The current timestamp or, if the current timestamp has passed reward end timestamp, reward end timestamp.|


### test


```solidity
function test() public;
```

## Events
### RewardInitialized
emitted when the reward is initialized for the first time


```solidity
event RewardInitialized(
  uint256 rate, uint256 available, uint256 startTimestamp, uint256 endTimestamp
);
```

### RewardRateChanged
emitted when owner changes the reward rate


```solidity
event RewardRateChanged(uint256 rate);
```

### RewardAdded
emitted when owner adds more rewards to the pool


```solidity
event RewardAdded(uint256 amountAdded);
```

### RewardWithdrawn
emitted when owner withdraws unreserved rewards


```solidity
event RewardWithdrawn(uint256 amount);
```

### RewardSlashed
emitted when an on feed operator gets slashed.
Node operators are not slashed more than the amount of rewards they
have earned.  This means that a node operator that has not
accumulated at least two weeks of rewards will be slashed
less than an operator that has accumulated at least
two weeks of rewards.


```solidity
event RewardSlashed(
  address[] operator, uint256[] slashedBaseRewards, uint256[] slashedDelegatedRewards
);
```

## Errors
### RewardDurationTooShort
This error is thrown when the updated reward duration is less than a month


```solidity
error RewardDurationTooShort();
```

## Structs
### DelegatedRewards

```solidity
struct DelegatedRewards {
  uint8 delegatesCount;
  uint96 cumulativePerDelegate;
  uint32 lastAccumulateTimestamp;
}
```

### BaseRewards

```solidity
struct BaseRewards {
  uint80 rate;
  uint96 cumulativePerMicroLINK;
  uint32 lastAccumulateTimestamp;
}
```

### MissedRewards

```solidity
struct MissedRewards {
  uint96 base;
  uint96 delegated;
}
```

### ReservedRewards

```solidity
struct ReservedRewards {
  uint96 base;
  uint96 delegated;
}
```

### Reward

```solidity
struct Reward {
  mapping(address => MissedRewards) missed;
  DelegatedRewards delegated;
  BaseRewards base;
  ReservedRewards reserved;
  uint256 endTimestamp;
  uint32 startTimestamp;
}
```

