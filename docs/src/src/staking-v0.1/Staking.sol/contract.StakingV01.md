# StakingV01
[Git Source](https://github.com/code-423n4/2023-08-chainlink/blob/38d594fd52a417af576ce44eee67744196ba1094/src/staking-v0.1/Staking.sol)

**Inherits:**
[IStaking](/src/staking-v0.1/interfaces/IStaking.sol/interface.IStaking.md), [IStakingOwner](/src/staking-v0.1/interfaces/IStakingOwner.sol/interface.IStakingOwner.md), [IMigratable](/src/staking-v0.1/interfaces/IMigratable.sol/interface.IMigratable.md), [IMerkleAccessController](/src/staking-v0.1/interfaces/IMerkleAccessController.sol/interface.IMerkleAccessController.md), [IAlertsController](/src/staking-v0.1/interfaces/IAlertsController.sol/interface.IAlertsController.md), ConfirmedOwner, TypeAndVersionInterface, Pausable


## State Variables
### ALERTING_REWARD_STAKED_AMOUNT_DENOMINATOR
The amount to divide an alerter's stake amount when
calculating their reward for raising an alert.


```solidity
uint256 private constant ALERTING_REWARD_STAKED_AMOUNT_DENOMINATOR = 5;
```


### i_LINK

```solidity
LinkTokenInterface private immutable i_LINK;
```


### s_pool

```solidity
StakingPoolLib.Pool private s_pool;
```


### s_reward

```solidity
RewardLib.Reward private s_reward;
```


### i_monitoredFeed
The ETH USD feed that alerters can raise alerts for.


```solidity
AggregatorV3Interface private immutable i_monitoredFeed;
```


### s_proposedMigrationTarget
The proposed address stakers will migrate funds to


```solidity
address private s_proposedMigrationTarget;
```


### s_proposedMigrationTargetAt
The timestamp of when the migration target was proposed at


```solidity
uint256 private s_proposedMigrationTargetAt;
```


### s_migrationTarget
The address stakers can migrate their funds to


```solidity
address private s_migrationTarget;
```


### s_lastAlertedRoundId
The round ID of the last feed round an alert was raised


```solidity
uint256 private s_lastAlertedRoundId;
```


### s_merkleRoot
The merkle root of the merkle tree generated from the list
of staker addresses with early acccess.


```solidity
bytes32 private s_merkleRoot;
```


### i_priorityPeriodThreshold
The number of seconds until the feed is considered stale
and the priority period begins.


```solidity
uint256 private immutable i_priorityPeriodThreshold;
```


### i_regularPeriodThreshold
The number of seconds until the priority period ends
and the regular period begins.


```solidity
uint256 private immutable i_regularPeriodThreshold;
```


### i_maxAlertingRewardAmount
The amount of LINK to reward an operator who
raises an alert in the priority period.


```solidity
uint256 private immutable i_maxAlertingRewardAmount;
```


### i_minOperatorStakeAmount
The minimum stake amount that a node operator can stake


```solidity
uint256 private immutable i_minOperatorStakeAmount;
```


### i_minCommunityStakeAmount
The minimum stake amount that a community staker can stake


```solidity
uint256 private immutable i_minCommunityStakeAmount;
```


### i_minInitialOperatorCount
The minimum number of node operators required to initialize the
staking pool.


```solidity
uint256 private immutable i_minInitialOperatorCount;
```


### i_minRewardDuration
The minimum reward duration after pool config updates and pool
reward extensions


```solidity
uint256 private immutable i_minRewardDuration;
```


### i_slashableDuration
The duration of earned rewards to slash when an alert is raised


```solidity
uint256 private immutable i_slashableDuration;
```


### i_delegationRateDenominator
Used to calculate delegated stake amount
= amount / delegation rate denominator = 100% / 100 = 1%


```solidity
uint256 private immutable i_delegationRateDenominator;
```


## Functions
### constructor


```solidity
constructor(PoolConstructorParams memory params) ConfirmedOwner(msg.sender);
```

### typeAndVersion


```solidity
function typeAndVersion() external pure override returns (string memory);
```

### hasAccess

Validates if a community staker has access to the private staking pool


```solidity
function hasAccess(address staker, bytes32[] memory proof) external view override returns (bool);
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
function setMerkleRoot(bytes32 newMerkleRoot) external override onlyOwner;
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


### setPoolConfig

Set the pool config


```solidity
function setPoolConfig(
  uint256 maxPoolSize,
  uint256 maxCommunityStakeAmount,
  uint256 maxOperatorStakeAmount
) external override(IStakingOwner) onlyOwner whenActive;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxPoolSize`|`uint256`|The max amount of staked LINK allowed in the pool|
|`maxCommunityStakeAmount`|`uint256`|The max amount of LINK a community staker can stake|
|`maxOperatorStakeAmount`|`uint256`|The max amount of LINK a Node Op can stake|


### setFeedOperators

Allows the contract owner to set the list of on-feed operator addresses who are
subject to slashing

*Existing feed operators are cleared before setting the new operators.*


```solidity
function setFeedOperators(address[] calldata operators) external override(IStakingOwner) onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|New list of on-feed operator staker addresses|


### start

Transfers LINK tokens and initializes the reward

*Uses ERC20 approve + transferFrom flow*


```solidity
function start(
  uint256 amount,
  uint256 initialRewardRate
) external override(IStakingOwner) onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|rewards amount in LINK|
|`initialRewardRate`|`uint256`|The amount of LINK earned per second for each LINK staked.|


### conclude

Closes the pool, unreserving future staker rewards, expires the
reward and releases unreserved rewards


```solidity
function conclude() external override(IStakingOwner) onlyOwner whenActive;
```

### addReward

This function can be called to add rewards to the pool

*Should only be callable by the owner*


```solidity
function addReward(uint256 amount) external override(IStakingOwner) onlyOwner whenActive;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of rewards to add to the pool|


### withdrawUnusedReward

This function can be called to withdraw unused reward amount from
the staking pool. It can be called before the pool is initialized, after
the pool is concluded or when the reward expires.

*Should only be callable by the owner when the pool is closed*


```solidity
function withdrawUnusedReward() external override(IStakingOwner) onlyOwner whenInactive;
```

### addOperators

Adds one or more operators to a list of operators

*Required conditions for adding operators:
- Operators can only be added to the pool if they have no prior stake.
- Operators can only be readded to the pool if they have no removed
stake.
- Operators cannot be added to the pool after staking ends (either through
conclusion or through reward expiry).*


```solidity
function addOperators(address[] calldata operators) external override(IStakingOwner) onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|A list of operator addresses to add|


### removeOperators

Removes one or more operators from a list of operators. When an
operator is removed, we store their principal in a separate mapping to
prevent immediate withdrawals. This is so that the removed operator can
only unstake at the same time as every other staker.

*Should only be callable by the owner when the pool is open.
When an operator is removed they can stake as a community staker.
We allow that because the alternative (checking for removed stake before
staking) is going to unnecessarily increase gas costs in 99.99% of the
cases.*


```solidity
function removeOperators(address[] calldata operators)
  external
  override(IStakingOwner)
  onlyOwner
  whenActive;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operators`|`address[]`|A list of operator addresses to remove|


### changeRewardRate

This function can be called to change the reward rate for the pool.
This change only affects future rewards, i.e. rewards earned at a previous
rate are unaffected.

*Should only be callable by the owner. The rate can be increased or decreased.
The new rate cannot be 0.*


```solidity
function changeRewardRate(uint256 newRate) external override onlyOwner whenActive;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newRate`|`uint256`||


### emergencyPause

This function pauses staking

*Sets the pause flag to true*


```solidity
function emergencyPause() external override(IStakingOwner) onlyOwner;
```

### emergencyUnpause

This function unpauses staking

*Sets the pause flag to false*


```solidity
function emergencyUnpause() external override(IStakingOwner) onlyOwner;
```

### getFeedOperators


```solidity
function getFeedOperators() external view override(IStakingOwner) returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|List of the ETH-USD feed node operators' staking addresses|


### getMigrationTarget

This function returns the migration target contract address


```solidity
function getMigrationTarget() external view override(IMigratable) returns (address);
```

### proposeMigrationTarget

This function allows the contract owner to set a proposed
migration target address. If the migration target is valid it renounces
the previously accepted migration target (if any).


```solidity
function proposeMigrationTarget(address migrationTarget) external override(IMigratable) onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`migrationTarget`|`address`|Contract address to migrate stakes to.|


### acceptMigrationTarget

This function allows the contract owner to accept a proposed migration target address
after a waiting period.


```solidity
function acceptMigrationTarget() external override(IMigratable) onlyOwner;
```

### migrate

This function allows stakers to migrate funds to a new staking pool.


```solidity
function migrate(bytes calldata data) external override(IMigratable) whenInactive;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|Migration path details|


### raiseAlert

This function creates an alert for a stalled feed


```solidity
function raiseAlert() external override(IAlertsController) whenActive;
```

### canAlert

if an alert is raised many times such that it completely depletes the


```solidity
function canAlert(address alerter) external view override(IAlertsController) returns (bool);
```

### unstake

This function allows stakers to exit the pool after it has been
concluded. It returns the principal as well as base and delegation
rewards.


```solidity
function unstake() external override(IStaking) whenInactive;
```

### withdrawRemovedStake

This function allows removed operators to withdraw their original
principal. Operators can only withdraw after the pool is closed, like
every other staker.


```solidity
function withdrawRemovedStake() external override(IStaking) whenInactive;
```

### getStake


```solidity
function getStake(address staker) public view override(IStaking) returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 staker's staked principal amount|


### isOperator

Returns true if an address is an operator


```solidity
function isOperator(address staker) external view override(IStaking) returns (bool);
```

### isActive

The staking pool starts closed and only allows
stakers to stake once it's opened


```solidity
function isActive() public view override(IStaking) returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool pool status|


### getMaxPoolSize


```solidity
function getMaxPoolSize() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current maximum staking pool size|


### getCommunityStakerLimits


```solidity
function getCommunityStakerLimits() external view override(IStaking) returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 minimum amount that can be staked by a community staker|
|`<none>`|`uint256`||


### getOperatorLimits


```solidity
function getOperatorLimits() external view override(IStaking) returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 minimum amount that can be staked by an operator|
|`<none>`|`uint256`||


### getRewardTimestamps


```solidity
function getRewardTimestamps() external view override(IStaking) returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 reward initialization timestamp|
|`<none>`|`uint256`||


### getRewardRate


```solidity
function getRewardRate() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current reward rate, expressed in juels per second per micro LINK|


### getDelegationRateDenominator


```solidity
function getDelegationRateDenominator() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 current delegation rate|


### getAvailableReward

*This reflects how many rewards were made available over the
lifetime of the staking pool. This is not updated when the rewards are
unstaked or migrated by the stakers. This means that the contract balance
will dip below available amount when the reward expires and users start
moving their rewards.*


```solidity
function getAvailableReward() public view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount of LINK tokens made available for rewards in Juels|


### getBaseReward


```solidity
function getBaseReward(address staker) public view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 amount of base rewards earned by a staker in Juels|


### getDelegationReward


```solidity
function getDelegationReward(address staker) public view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 amount of delegation rewards earned by an operator in Juels|


### getTotalDelegatedAmount

Total delegated amount is calculated by dividing the total
community staker staked amount by the delegation rate, i.e.
totalDelegatedAmount = pool.totalCommunityStakedAmount / delegationRateDenominator


```solidity
function getTotalDelegatedAmount() public view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 staked amount that is used when calculating delegation rewards in Juels|


### getDelegatesCount

Delegates count increases after an operator is added to the list
of operators and stakes the minimum required amount.


```solidity
function getDelegatesCount() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 number of staking operators that are eligible for delegation rewards|


### getTotalStakedAmount


```solidity
function getTotalStakedAmount() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount staked by community stakers and operators in Juels|


### getTotalCommunityStakedAmount


```solidity
function getTotalCommunityStakedAmount() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount staked by community stakers in Juels|


### getTotalRemovedAmount

*Used to make sure that contract's balance is correct.
total staked amount + total removed amount + available rewards = current balance*


```solidity
function getTotalRemovedAmount() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 the sum of removed operator principals that have not been withdrawn from the staking pool in Juels.|


### getEarnedBaseRewards


```solidity
function getEarnedBaseRewards() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount of base rewards earned by all stakers in Juels|


### getEarnedDelegationRewards


```solidity
function getEarnedDelegationRewards() external view override(IStaking) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 total amount of delegated rewards earned by all node operators in Juels|


### isPaused

This function returns the pause state


```solidity
function isPaused() external view override(IStaking) returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool whether or not the pool is paused|


### getChainlinkToken


```solidity
function getChainlinkToken() public view override(IStaking) returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address LINK token contract's address that is used by the pool|


### getMonitoredFeed


```solidity
function getMonitoredFeed() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address The address of the feed being monitored to raise alerts for|


### onTokenTransfer

Called when LINK is sent to the contract via `transferAndCall`


```solidity
function onTokenTransfer(
  address sender,
  uint256 amount,
  bytes memory data
) external validateFromLINK whenNotPaused whenActive;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|Address of the sender|
|`amount`|`uint256`|Amount of LINK sent (specified in wei)|
|`data`|`bytes`|Optional payload containing a Staking Allowlist Merkle proof|


### _stakeAsCommunityStaker

Helper function for when a community staker enters the pool

*When an operator is removed they can stake as a community staker.
We allow that because the alternative (checking for removed stake before
staking) is going to unnecessarily increase gas costs in 99.99% of the
cases.*


```solidity
function _stakeAsCommunityStaker(address staker, uint256 amount) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker address|
|`amount`|`uint256`|The amount of principal staked|


### _stakeAsOperator

Helper function for when an operator enters the pool

*Function skips validating whether or not the operator stake
amount will cause the total stake amount to exceed the maximum pool size.
This is because the pool already reserves a fixed amount of space
for each operator meaning that an operator staking cannot cause the
total stake amount to exceed the maximum pool size.  Each operator
receives a reserved stake amount equal to the maxOperatorStakeAmount.
This is done by deducting operatorCount * maxOperatorStakeAmount from the
remaining pool space available for staking.*


```solidity
function _stakeAsOperator(address staker, uint256 amount) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker address|
|`amount`|`uint256`|The amount of principal staked|


### _exit

Helper function when staker exits the pool


```solidity
function _exit(address staker) private returns (uint256, uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker address|


### _calculateAlertingRewardAmount

Calculates the reward amount an alerter will receive for raising
a successful alert in the current alerting period.


```solidity
function _calculateAlertingRewardAmount(
  uint256 stakedAmount,
  bool isInPriorityPeriod
) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakedAmount`|`uint256`|Amount of LINK staked by the alerter|
|`isInPriorityPeriod`|`bool`|True if it is currently in the priority period|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|rewardAmount Amount of LINK rewards to be paid to the alerter|


### _isActive

*Having a private function for the modifer saves on the contract size*


```solidity
function _isActive() private view;
```

### whenActive

*Reverts if the staking pool is inactive (not open for staking or
expired)*


```solidity
modifier whenActive();
```

### whenInactive

*Reverts if the staking pool is active (open for staking)*


```solidity
modifier whenInactive();
```

### validateFromLINK

*Reverts if not sent from the LINK token*


```solidity
modifier validateFromLINK();
```

### test


```solidity
function test() public;
```

## Structs
### PoolConstructorParams
This struct defines the params required by the Staking contract's
constructor.


```solidity
struct PoolConstructorParams {
  LinkTokenInterface LINKAddress;
  AggregatorV3Interface monitoredFeed;
  uint256 initialMaxPoolSize;
  uint256 initialMaxCommunityStakeAmount;
  uint256 initialMaxOperatorStakeAmount;
  uint256 minCommunityStakeAmount;
  uint256 minOperatorStakeAmount;
  uint256 priorityPeriodThreshold;
  uint256 regularPeriodThreshold;
  uint256 maxAlertingRewardAmount;
  uint256 minInitialOperatorCount;
  uint256 minRewardDuration;
  uint256 slashableDuration;
  uint256 delegationRateDenominator;
}
```

