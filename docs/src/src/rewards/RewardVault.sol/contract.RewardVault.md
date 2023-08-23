# RewardVault
[Git Source](https://github.com/smartcontractkit/destiny-next/blob/93e1115f8d7fb0029b73a936d125afb837306065/src/rewards/RewardVault.sol)

**Inherits:**
ERC677ReceiverInterface, [IRewardVault](/src/interfaces/IRewardVault.sol/interface.IRewardVault.md), [Migratable](/src/Migratable.sol/abstract.Migratable.md), [PausableWithAccessControl](/src/PausableWithAccessControl.sol/abstract.PausableWithAccessControl.md), TypeAndVersionInterface

This contract is the reward vault for the staking pools. Admin can deposit rewards into
the vault and set the emission rate for each pool to control the reward distribution.

*This contract interacts with the community and operator staking pools that it is connected
to. A reward vault is connected to only one community and operator staking pool during its
lifetime, which means when we upgrade either one of the pools or introduce a new type of pool,
we will need to update this contract and deploy a new reward vault.*

*invariant LINK balance of the contract is greater than or equal to the sum of unvested
rewards.*

*invariant The sum of all stakers' rewards is less than or equal to the sum of vested
rewards.*

*invariant The reward bucket with zero emission rate has zero reward.*

*invariant Stakers' multipliers are within 0 and the max value.*

*We only support LINK token in v0.2 staking. Rebasing tokens, ERC777 tokens, fee-on-transfer
tokens or tokens that do not have 18 decimal places are not supported.*


## State Variables
### REWARDER_ROLE
This is the ID for the rewarder role, which is given to the
addresses that will add rewards to the vault.

*Hash: beec13769b5f410b0584f69811bfd923818456d5edcf426b0e31cf90eed7a3f6*


```solidity
bytes32 public constant REWARDER_ROLE = keccak256('REWARDER_ROLE');
```


### MAX_MULTIPLIER
The maximum possible value of a multiplier.


```solidity
uint256 private constant MAX_MULTIPLIER = 1e18;
```


### i_LINK
The LINK token


```solidity
LinkTokenInterface private immutable i_LINK;
```


### i_communityStakingPool
The community staking pool.


```solidity
CommunityStakingPool private immutable i_communityStakingPool;
```


### i_operatorStakingPool
The operator staking pool.


```solidity
OperatorStakingPool private immutable i_operatorStakingPool;
```


### s_rewardBuckets
The reward buckets.


```solidity
RewardBuckets private s_rewardBuckets;
```


### s_vaultConfig
The vault config.


```solidity
VaultConfig private s_vaultConfig;
```


### s_finalVestingCheckpointData
The checkpoint information at the time the reward vault was closed
or migrated


```solidity
VestingCheckpointData private s_finalVestingCheckpointData;
```


### s_rewardPerTokenUpdatedAt
The time the reward per token was last updated


```solidity
uint256 private s_rewardPerTokenUpdatedAt;
```


### s_migrationSource
The address of the vault that will be migrated to this vault


```solidity
address private s_migrationSource;
```


### s_rewards
Stores reward information for each staker


```solidity
mapping(address => StakerReward) private s_rewards;
```


## Functions
### constructor


```solidity
constructor(ConstructorParams memory params)
  PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender);
```

### addReward

Adds more rewards into the reward vault
Calculates the reward duration from the amount and emission rate

*To add rewards to all pools use address(0) as the pool address*

*There is a possibility that a fraction of the added rewards can be locked in this
contract as dust, specifically, when the amount is not divided by the emission rate evenly. We
will handle this case operationally and make sure that the amount is large relative to the
emission rate so there will only be small dust (less than 10^18 juels).*

*precondition The caller must have the default admin role.*

*precondition This contract must be open and not paused.*

*precondition The caller must have at least `amount` LINK tokens.*

*precondition The caller must have approved this contract for the transfer of at least
`amount` LINK tokens.*


```solidity
function addReward(
  address pool,
  uint256 amount,
  uint256 emissionRate
) external onlyRewarder whenOpen whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`address`|The staking pool address|
|`amount`|`uint256`|The reward amount|
|`emissionRate`|`uint256`|The target emission rate (token/second)|


### getDelegationRateDenominator

Returns the delegation rate denominator


```solidity
function getDelegationRateDenominator() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The delegation rate denominator|


### setDelegationRateDenominator

Updates the delegation rate

*precondition The caller must have the default admin role.*


```solidity
function setDelegationRateDenominator(uint256 newDelegationRateDenominator)
  external
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newDelegationRateDenominator`|`uint256`|The delegation rate denominator.|


### setMultiplierDuration

Sets the new multiplier ramp up time.  This will impact the
amount of rewards a staker can immediately claim.

*precondition The caller must have the default admin role.*


```solidity
function setMultiplierDuration(uint256 newMultiplierDuration) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMultiplierDuration`|`uint256`|The new multiplier ramp up time|


### setMigrationSource

Sets the migration source for the vault

*precondition The caller must have the default admin role.*


```solidity
function setMigrationSource(address newMigrationSource) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMigrationSource`|`address`|The new migration source|


### getMigrationSource

Returns the current migration source


```solidity
function getMigrationSource() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address The current migration source|


### _validateMigrationTarget

Helper function for validating the migration target

*precondition The caller must have the default admin role.*


```solidity
function _validateMigrationTarget(address newMigrationTarget)
  internal
  override(Migratable)
  onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMigrationTarget`|`address`|The address of the new migration target|


### migrate

Migrates the contract

*This will migrate the unvested rewards and checkpoint the staking pools.*

*precondition The caller must have the default admin role.*

*precondition The reward vault must be open.*

*precondition The migration target must be set.*

*precondition The migration target must implement the onTokenTransfer function.*


```solidity
function migrate(bytes calldata data)
  external
  override(IMigratable)
  onlyRole(DEFAULT_ADMIN_ROLE)
  whenOpen
  validateMigrationTargetSet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|Optional calldata to call on new contract|


### supportsInterface

This function allows the calling contract to
check if the contract deployed at this address is a valid
LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
if it implements the onTokenTransfer function.


```solidity
function supportsInterface(bytes4 interfaceID) public view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceID`|`bytes4`|The ID of the interface to check against|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the contract is a valid LINKTokenReceiver.|


### onTokenTransfer

This function is called by the LINK token contract when the previous version reward
vault transfers LINK tokens to this contract.

*precondition The migration source must be set.*


```solidity
function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The sender of the tokens|
|`amount`|`uint256`|The amount of tokens transferred|
|`data`|`bytes`|The data passed from the previous version reward vault|


### claimReward

Claims reward earned by a staker
Called by staking pools to forward claim requests from stakers or called by the stakers
themselves.

*precondition This contract must not be paused.*

*precondition The caller must be a staker with a non-zero reward.*


```solidity
function claimReward() external override whenNotPaused returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The amount of rewards claimed in juels|


### _transferRewards

Transfers a staker's finalized reward to the staker


```solidity
function _transferRewards(
  address staker,
  StakerReward memory stakerReward
) private returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker to send rewards to|
|`stakerReward`|`StakerReward`|The staker's reward data|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The amount of rewards transferred to the staker|


### updateReward

Updates the staking pools' reward per token and staker’s reward state
in the reward vault.  This function is called whenever the staker's reward
state needs to be updated without resetting their multiplier

*precondition The caller must be a staking pool.*


```solidity
function updateReward(address staker, uint256 stakerPrincipal) external override onlyStakingPool;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker's address. If this is set to zero address, staker's reward update will be skipped|
|`stakerPrincipal`|`uint256`|The staker's current principal in juels|


### finalizeReward

Finalizes the staker's reward and resets their multiplier.
This will apply the staker's current ramp up multiplier to their
earned rewards and store the amount of rewards they have earned before
their multiplier is reset.

*This applies any final logic such as the multipliers to the staker's newly accrued and
stored rewards and store the value.*

*The caller staking pool must update the total principal of the pool AFTER calling this
function.*

*precondition The caller must be a staking pool.*


```solidity
function finalizeReward(
  address staker,
  uint256 oldPrincipal,
  uint256 stakedAt,
  uint256 unstakedAmount,
  bool shouldClaim
) external override onlyStakingPool returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker addres|
|`oldPrincipal`|`uint256`|The staker's principal before finalizing|
|`stakedAt`|`uint256`|The last time the staker staked at|
|`unstakedAmount`|`uint256`|The amount that the staker has unstaked in juels|
|`shouldClaim`|`bool`|True if rewards should be transferred to the staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The claimed reward amount.|


### close

Closes the reward vault, disabling adding rewards and staking

*Withdraws any unvested LINK rewards to the owner's address.*

*precondition The caller must have the default admin role.*

*precondition This contract must be open.*


```solidity
function close() external override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen;
```

### getReward

Returns the rewards that the staker would get if they withdraw now
Rewards calculation is based on the staker's multiplier


```solidity
function getReward(address staker) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The reward amount|


### isOpen

Returns a boolean that is true if the reward vault is open


```solidity
function isOpen() external view override returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if open, false otherwise|


### hasRewardDurationEnded

Returns whether or not the reward duration for the pool has ended


```solidity
function hasRewardDurationEnded(address stakingPool) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingPool`|`address`|The address of the staking pool rewards are being distributed to|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the reward duration has ended|


### getRewardBuckets

Returns the reward buckets within this vault


```solidity
function getRewardBuckets() external view returns (RewardBuckets memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`RewardBuckets`|The reward buckets|


### getRewardPerTokenUpdatedAt

Returns the timestamp of the last reward per token update


```solidity
function getRewardPerTokenUpdatedAt() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The timestamp of the last update|


### getMultiplierDuration

Returns the multiplier ramp up time


```solidity
function getMultiplierDuration() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The multiplier ramp up time|


### getMultiplier

Returns the ramp up multiplier of the staker

*Multipliers are in the range of 0 and 1, so we multiply them by 1e18 (WAD) to preserve
the decimals.*


```solidity
function getMultiplier(address staker) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The address of the staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's multiplier|


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


### calculateLatestStakerReward

Calculates and returns the latest reward info of the staker


```solidity
function calculateLatestStakerReward(address staker)
  external
  view
  returns (StakerReward memory, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`StakerReward`|StakerReward The staker's reward info|
|`<none>`|`uint256`|uint256 The staker's forfeited reward in juels|


### getVestingCheckpointData

Returns the migration checkpoint data


```solidity
function getVestingCheckpointData() external view returns (VestingCheckpointData memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`VestingCheckpointData`|VestingCheckpointData The migration checkpoint|


### getUnvestedRewards

Returns the unvested rewards


```solidity
function getUnvestedRewards() external view returns (uint256, uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|unvestedCommunityBaseRewards The unvested community base rewards|
|`<none>`|`uint256`|unvestedOperatorBaseRewards The unvested operator base rewards|
|`<none>`|`uint256`|unvestedOperatorDelegatedRewards The unvested operator delegated rewards|


### isPaused

Returns whether or not the vault is paused


```solidity
function isPaused() external view override(IRewardVault) returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the vault is paused|


### _forfeitStakerBaseReward

Forfeits a proportion of the staker's full forfeited reward amount
based on the amount of juels they unstake


```solidity
function _forfeitStakerBaseReward(
  StakerReward memory stakerReward,
  uint256 fullForfeitedRewardAmount,
  uint256 unstakedAmount,
  uint256 oldPrincipal,
  bool isOperator
) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakerReward`|`StakerReward`|The staker's reward struct|
|`fullForfeitedRewardAmount`|`uint256`|The amount of rewards the staker has forfeited because of their multiplier in juels|
|`unstakedAmount`|`uint256`| The amount the staker has unstaked in juels|
|`oldPrincipal`|`uint256`|The staker's principal before unstaking in juels|
|`isOperator`|`bool`|True if the staker is an operator|


### _stopVestingRewardsToBuckets

Stops rewards in all buckets from vesting and close the vault.

*This will also checkpoint the staking pools*


```solidity
function _stopVestingRewardsToBuckets()
  private
  returns (uint256, uint256, uint256, uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The total emission rate from all three buckets|
|`<none>`|`uint256`|uint256 The total amount of unvested rewards in juels|
|`<none>`|`uint256`|uint256 The amount of unvested operator base rewards in juels|
|`<none>`|`uint256`|uint256 The amount of unvested community base rewards in juels|
|`<none>`|`uint256`|uint256 The amount of unvested operator delegated rewards in juels|


### _getTotalPrincipal

Returns the total principal staked in a staking pool.  This will
return the staking pool's latest total principal if the vault has not been
migrated from and the pool's total principal at the time the vault was
migrated if the vault has already been migrated.


```solidity
function _getTotalPrincipal(IStakingPool stakingPool) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingPool`|`IStakingPool`|The staking pool to query the total principal for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The total principal staked in the staking pool|


### _getStakerPrincipal

Returns the staker's principal in a staking pool.  This will
return the staker's latest principal if the vault has not been
migrated from and the staker's principal at the time the vault was
migrated if the vault has already been migrated.


```solidity
function _getStakerPrincipal(
  address staker,
  IStakingPool stakingPool
) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker to query the total principal for|
|`stakingPool`|`IStakingPool`|The staking pool to query the total principal for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's principal in the staking pool in juels|


### _getMultiplier

Helper function to get a staker's current multiplier


```solidity
function _getMultiplier(uint256 stakedAt) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakedAt`|`uint256`|The time the staker last staked at|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's multiplier|


### _getStakerStakedAtTime

Returns the staker's staked at time in a staking pool.  This will
return the staker's latest staked at time if the vault has not been
migrated from and the staker's staked at time at the time the vault was
migrated if the vault has already been migrated.


```solidity
function _getStakerStakedAtTime(
  address staker,
  IStakingPool stakingPool
) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker to query the staked at time for|
|`stakingPool`|`IStakingPool`|The staking pool to query the staked at time for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The staker's average staked at time in the staking pool|


### _getMigratedAtCheckpointId

Returns the migrated at checkpoint ID to use depending on which
staking pool the staker is in


```solidity
function _getMigratedAtCheckpointId(IStakingPool stakingPool) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingPool`|`IStakingPool`|The stake pool to query the migrated at checkpoint ID for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The checkpointId|


### _getMigratedAtTotalPoolPrincipal

Return the staking pool's total principal at the time the vault was
migrated


```solidity
function _getMigratedAtTotalPoolPrincipal(IStakingPool stakingPool) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingPool`|`IStakingPool`|The staking pool to query the total principal for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The pool's total principal at the time the vault was upgraded|


### _checkpointStakingPools

Records the current checkpoint IDs and the total principal in the
operator and community staking pools

*This is called in the migrate function when upgrading the vault*


```solidity
function _checkpointStakingPools() private;
```

### _stopVestingBucketRewards

Stops rewards in a bucket from vesting


```solidity
function _stopVestingBucketRewards(RewardBucket storage bucket) private returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bucket`|`RewardBucket`|The bucket to stop vesting rewards for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The amount of unvested rewards in juels|


### _updateRewardBuckets

Updates the reward buckets


```solidity
function _updateRewardBuckets(address pool, uint256 amount, uint256 emissionRate) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`address`|The staking pool address|
|`amount`|`uint256`|The reward amount|
|`emissionRate`|`uint256`|The target emission rate (Juels/second)|


### _updateRewardBucket

Updates the reward bucket


```solidity
function _updateRewardBucket(
  RewardBucket storage bucket,
  uint256 amount,
  uint256 emissionRate
) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bucket`|`RewardBucket`|The reward bucket|
|`amount`|`uint256`|The reward amount|
|`emissionRate`|`uint256`|The target emission rate (token/second)|


### _updateRewardDurationEndsAt

Updates the reward duration end time of the bucket


```solidity
function _updateRewardDurationEndsAt(
  RewardBucket storage bucket,
  uint256 rewardAmount,
  uint256 emissionRate
) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bucket`|`RewardBucket`|The reward bucket|
|`rewardAmount`|`uint256`|The reward amount|
|`emissionRate`|`uint256`|The emission rate|


### _getBucketRewardAndEmissionRateSplit

Splits the reward and emission rates between the different reward buckets

*If the pool is not targeted, the returned reward and emission rate will be zero*


```solidity
function _getBucketRewardAndEmissionRateSplit(
  address pool,
  uint256 amount,
  uint256 emissionRate,
  bool isDelegated
) private view returns (BucketRewardEmissionSplit memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`address`|The staking pool address (or zero address if the reward is split between all pools)|
|`amount`|`uint256`|The reward amount|
|`emissionRate`|`uint256`|The emission rate (juels/second)|
|`isDelegated`|`bool`|Whether the reward is delegated or not|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`BucketRewardEmissionSplit`|BucketRewardEmissionSplit The rewards and emission rates after distributing the reward amount to the buckets|


### _checkForRoundingToZeroRewardAmountSplit

Validates the added reward amount after splitting to avoid a rounding error when
dividing


```solidity
function _checkForRoundingToZeroRewardAmountSplit(
  uint256 rewardAmount,
  uint256 communityPoolShare,
  uint256 operatorPoolShare,
  uint256 totalPoolShare
) private pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`rewardAmount`|`uint256`|The reward amount|
|`communityPoolShare`|`uint256`|The size of the community staking pool to take into account|
|`operatorPoolShare`|`uint256`|The size of the operator staking pool to take into account|
|`totalPoolShare`|`uint256`|The total size of the pools to take into account|


### _checkForRoundingToZeroEmissionRateSplit

Validates the emission rate after splitting to avoid a rounding error when dividing


```solidity
function _checkForRoundingToZeroEmissionRateSplit(
  uint256 emissionRate,
  uint256 communityPoolShare,
  uint256 operatorPoolShare,
  uint256 totalPoolShare
) private pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`emissionRate`|`uint256`|The emission rate|
|`communityPoolShare`|`uint256`|The size of the community staking pool to take into account|
|`operatorPoolShare`|`uint256`|The size of the operator staking pool to take into account|
|`totalPoolShare`|`uint256`|The total size of the pools to take into account|


### _checkForRoundingToZeroDelegationSplit

Validates the delegation denominator after splitting to avoid a rounding error when
dividing


```solidity
function _checkForRoundingToZeroDelegationSplit(
  uint256 communityReward,
  uint256 communityRate,
  uint256 delegationDenominator
) private pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`communityReward`|`uint256`|The reward for the community staking pool|
|`communityRate`|`uint256`|The emission rate for the community staking pool|
|`delegationDenominator`|`uint256`|The delegation denominator|


### _updateRewardPerToken

Private util function for updateRewardPerToken


```solidity
function _updateRewardPerToken() private;
```

### _calculatePoolsRewardPerToken

Util function for calculating the current reward per token for the pools


```solidity
function _calculatePoolsRewardPerToken() private view returns (uint256, uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The community reward per token|
|`<none>`|`uint256`|uint256 The operator reward per token|
|`<none>`|`uint256`|uint256 The operator delegated reward per token|


### _calculateVestedRewardPerToken

Calculate a bucket’s vested rewards earned per token


```solidity
function _calculateVestedRewardPerToken(
  RewardBucket memory rewardBucket,
  uint256 totalPrincipal
) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`rewardBucket`|`RewardBucket`|The reward bucket to calculate the vestedRewardPerToken for|
|`totalPrincipal`|`uint256`|The total principal staked in a pool associated with the reward bucket|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The vested rewards earned per token|


### _calculateEarnedBaseReward

Calculates a stakers earned base reward


```solidity
function _calculateEarnedBaseReward(
  StakerReward memory stakerReward,
  uint256 stakerPrincipal,
  uint256 baseRewardPerToken
) private pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakerReward`|`StakerReward`|The staker's reward info|
|`stakerPrincipal`|`uint256`|The staker's principal|
|`baseRewardPerToken`|`uint256`|The base reward per token of the staking pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The earned base reward|


### _calculateEarnedDelegatedReward

Calculates a operators earned delegated reward


```solidity
function _calculateEarnedDelegatedReward(
  StakerReward memory stakerReward,
  uint256 stakerPrincipal,
  uint256 operatorDelegatedRewardPerToken
) private pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakerReward`|`StakerReward`|The staker's reward info|
|`stakerPrincipal`|`uint256`|The staker's principal|
|`operatorDelegatedRewardPerToken`|`uint256`|The operator delegated reward per token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The earned delegated reward|


### _applyMultiplier

Applies the multiplier to the staker's reward

*Finalizes rewards by incrementing the staker's finalizedBaseReward*


```solidity
function _applyMultiplier(
  StakerReward memory stakerReward,
  bool shouldForfeit,
  uint256 stakerStakedAtTime
) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakerReward`|`StakerReward`|The staker's reward info|
|`shouldForfeit`|`bool`|True if the staker should forfeit rewards if they haven't reach the max multiplier|
|`stakerStakedAtTime`|`uint256`|The time the staker last staked at|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The forfeited reward amount in juels|


### _calculateAccruedReward

Calculates the newly accrued reward of a staker since the last time the staker's
reward was updated


```solidity
function _calculateAccruedReward(
  uint256 principal,
  uint256 rewardPerToken,
  uint256 vestedRewardPerToken
) private pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`principal`|`uint256`|The staker's principal|
|`rewardPerToken`|`uint256`|The base or delegated reward per token of the staker|
|`vestedRewardPerToken`|`uint256`|The vested reward per token of the staking pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The accrued reward amount|


### _calculateStakerReward

Calculates and updates a staker's rewards

*Staker rewards are forfeited when a staker unstakes before they
have reached their maximum ramp up period multiplier.  Additionally an
operator will also forfeit any unclaimed rewards if they are removed
before they reach the maximum ramp up period multiplier.*


```solidity
function _calculateStakerReward(
  address staker,
  bool isOperator,
  uint256 stakerPrincipal
) private view returns (StakerReward memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker's address|
|`isOperator`|`bool`|True if the staker is an operator, false otherwise|
|`stakerPrincipal`|`uint256`||


### _distributeForfeitedReward

Distributes the forfeited reward immediately to the reward buckets


```solidity
function _distributeForfeitedReward(
  uint256 forfeitedReward,
  uint256 amountOfRecipientTokens,
  bool toOperatorPool
) private returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`forfeitedReward`|`uint256`|The amount of forfeited rewards in juels|
|`amountOfRecipientTokens`|`uint256`|The amount of tokens that the forfeited rewards should be distributed to|
|`toOperatorPool`|`bool`|Whether the forfeited reward should be distributed to the operator pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The amount of forfeited reward that were redistributed|
|`<none>`|`uint256`|uint256 The amount of forfeited reward that can be reclaimed due to empty pools|


### _calculateForfeitedRewardDistribution

Helper function for calculating the vested reward per token and the reclaimable
reward

*If the pool the staker is in is empty and we can't calculate the reward per token, we
allow the staker to reclaim the forfeited reward.*


```solidity
function _calculateForfeitedRewardDistribution(
  uint256 forfeitedReward,
  uint256 amountOfRecipientTokens
) private pure returns (uint256, uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`forfeitedReward`|`uint256`|The amount of forfeited reward|
|`amountOfRecipientTokens`|`uint256`|The amount of tokens that the forfeited rewards should be distributed to|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The amount of distributed forfeited reward|
|`<none>`|`uint256`|uint256 The distributed forfeited reward per token|
|`<none>`|`uint256`|uint256 The amount of reclaimable reward|


### _updateStakerRewardPerToken

Updates the staker's base and/or delegated reward per token values

*This function is called when staking, unstaking, claiming rewards, finalizing rewards for
removed operators, and slashing operators.*


```solidity
function _updateStakerRewardPerToken(
  StakerReward memory stakerReward,
  bool isOperator
) private view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakerReward`|`StakerReward`|The staker reward struct|
|`isOperator`|`bool`|Whether the staker is an operator or not|


### _getReward

Calculates a staker's earned rewards


```solidity
function _getReward(address staker) private view returns (StakerReward memory, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The staker|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`StakerReward`|The staker reward info|
|`<none>`|`uint256`|The forfeited reward|


### _getUnvestedRewards

Calculates the amount of unvested rewards in a reward bucket


```solidity
function _getUnvestedRewards(RewardBucket memory bucket) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bucket`|`RewardBucket`|The bucket to calculate unvested rewards for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The amount of unvested rewards in the bucket|


### _validateAddedRewards

Validates that the amount of rewards added and the emission rate
are valid and enough to cover the delegation rate


```solidity
function _validateAddedRewards(uint256 addedRewardAmount, uint256 totalEmissionRate) private view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addedRewardAmount`|`uint256`|The amount of added rewards|
|`totalEmissionRate`|`uint256`|The emission rate to the entire vault|


### _isOperator

Returns whether or not an address is currently an operator or
is a removed operator


```solidity
function _isOperator(address staker) private view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the staker is an operator|


### onlyRewarder

*Reverts if the msg.sender doesn't have the rewarder role.*


```solidity
modifier onlyRewarder();
```

### onlyStakingPool

*Reverts if the msg.sender is not a valid staking pool*


```solidity
modifier onlyStakingPool();
```

### whenOpen

*Reverts if the reward vault has been closed*


```solidity
modifier whenOpen();
```

### typeAndVersion


```solidity
function typeAndVersion() external pure virtual override returns (string memory);
```

## Events
### DelegationRateDenominatorSet
This event is emitted when the delegation rate is updated.


```solidity
event DelegationRateDenominatorSet(
  uint256 oldDelegationRateDenominator, uint256 newDelegationRateDenominator
);
```

### RewardAdded
This event is emitted when rewards are added to the vault


```solidity
event RewardAdded(address indexed pool, uint256 amount, uint256 emissionRate);
```

### VaultOpened
This event is emited when the vault is opened.


```solidity
event VaultOpened();
```

### VaultClosed
This event is emitted when the vault is closed.


```solidity
event VaultClosed(uint256 totalUnvestedRewards);
```

### RewardClaimed
This event is emitted when the staker claims rewards


```solidity
event RewardClaimed(address indexed staker, uint256 claimedRewards);
```

### MultiplierDurationSet
This event is emitted when the ramp up time for multipliers is changed.


```solidity
event MultiplierDurationSet(uint256 oldMultiplierDuration, uint256 newMultiplierDuration);
```

### ForfeitedRewardDistributed
This event is emitted when the forfeited rewards are distributed back into the reward
buckets.


```solidity
event ForfeitedRewardDistributed(
  uint256 vestedReward, uint256 vestedRewardPerToken, uint256 reclaimedReward, bool isOperatorReward
);
```

### VaultMigrated
This event is emitted when the owner migrates the rewards in the
vault


```solidity
event VaultMigrated(
  address indexed migrationTarget, uint256 totalUnvestedRewards, uint256 totalEmissionRate
);
```

### VaultMigrationProcessed
This event is emitted when the tokens from the old vault is migrated to this contract.


```solidity
event VaultMigrationProcessed(
  address indexed migrationSource, uint256 totalUnvestedRewards, uint256 totalEmissionRate
);
```

### MigrationSourceSet
This event is emitted when the migration source is set


```solidity
event MigrationSourceSet(address indexed oldMigrationSource, address indexed newMigrationSource);
```

### PoolRewardUpdated
This event is emitted when the pool rewards are updated


```solidity
event PoolRewardUpdated(
  uint256 communityBaseRewardPerToken,
  uint256 operatorBaseRewardPerToken,
  uint256 operatorDelegatedRewardPerToken
);
```

### StakerRewardUpdated
This event is emitted when a staker's rewards are updated


```solidity
event StakerRewardUpdated(
  address indexed staker,
  uint256 finalizedBaseReward,
  uint256 finalizedDelegatedReward,
  uint256 baseRewardPerToken,
  uint256 operatorDelegatedRewardPerToken,
  uint256 claimedBaseRewardsInPeriod
);
```

### RewardFinalized
This event is emitted when the staker rewards are finalized


```solidity
event RewardFinalized(address staker, bool shouldForfeit);
```

## Errors
### InvalidPool
This error is thrown when the pool address is not one of the registered staking pools


```solidity
error InvalidPool();
```

### InvalidRewardAmount
This error is thrown when the reward amount is invalid when adding rewards


```solidity
error InvalidRewardAmount();
```

### InvalidEmissionRate
This error is thrown when the emission rate is invalid when adding rewards


```solidity
error InvalidEmissionRate();
```

### InvalidDelegationRateDenominator
This error is thrown when the delegation rate is invalid when setting delegation rate


```solidity
error InvalidDelegationRateDenominator();
```

### InvalidMigrationSource
This error is thrown when the owner tries to set the migration source to the
zero address


```solidity
error InvalidMigrationSource();
```

### AccessForbidden
This error is thrown when an address who doesn't have access tries to call a function
For example, when the caller is not a rewarder and adds rewards to the vault, or
when the caller is not a staking pool and tries to call updateRewardPerToken.


```solidity
error AccessForbidden();
```

### InvalidZeroAddress
This error is thrown whenever a zero-address is supplied when
a non-zero address is required


```solidity
error InvalidZeroAddress();
```

### RewardDurationTooShort
This error is thrown when the reward duration is too short when adding rewards


```solidity
error RewardDurationTooShort();
```

### InsufficentRewardsForDelegationRate
this error is thrown when the rewards remaining are insufficient for the new
delegation denominator


```solidity
error InsufficentRewardsForDelegationRate();
```

### VaultAlreadyClosed
This error is thrown when calling an operation that is not allowed when the vault is
closed.


```solidity
error VaultAlreadyClosed();
```

### NoRewardToClaim
This error is thrown when the staker tries to claim rewards and the staker has no
rewards to claim.


```solidity
error NoRewardToClaim();
```

### InvalidStaker
This error is thrown when claiming rewards, the given staker parameter is not the
msg.sender


```solidity
error InvalidStaker(address stakerArg, address msgSender);
```

### SenderNotLinkToken
This error is thrown whenever the sender is not the LINK token


```solidity
error SenderNotLinkToken();
```

### CannotClaimRewardWhenPaused
This error is thrown when the vault is paused and the staker tries to claim rewards


```solidity
error CannotClaimRewardWhenPaused();
```

## Structs
### ConstructorParams
The constructor parameters.


```solidity
struct ConstructorParams {
  LinkTokenInterface linkToken;
  CommunityStakingPool communityStakingPool;
  OperatorStakingPool operatorStakingPool;
  uint32 delegationRateDenominator;
  uint32 initialMultiplierDuration;
  uint48 adminRoleTransferDelay;
}
```

### RewardBucket
This struct is used to store the reward information for a reward bucket.


```solidity
struct RewardBucket {
  uint80 emissionRate;
  uint80 rewardDurationEndsAt;
  uint80 vestedRewardPerToken;
}
```

### RewardBuckets
This struct is used to store the reward buckets states.


```solidity
struct RewardBuckets {
  RewardBucket operatorBase;
  RewardBucket communityBase;
  RewardBucket operatorDelegated;
}
```

### VaultConfig
This struct is used to store the vault config.


```solidity
struct VaultConfig {
  uint32 delegationRateDenominator;
  uint32 multiplierDuration;
  bool isOpen;
}
```

### VestingCheckpointData
This struct is used to store the checkpoint information at the time the reward vault
is migrated or closed


```solidity
struct VestingCheckpointData {
  uint256 operatorPoolTotalPrincipal;
  uint256 communityPoolTotalPrincipal;
  uint256 operatorPoolCheckpointId;
  uint256 communityPoolCheckpointId;
}
```

### BucketRewardEmissionSplit
This struct is used for aggregating the return values of a function that calculates
the reward emission rate splits.


```solidity
struct BucketRewardEmissionSplit {
  uint256 communityReward;
  uint256 operatorReward;
  uint256 operatorDelegatedReward;
  uint256 communityRate;
  uint256 operatorRate;
  uint256 delegatedRate;
}
```

### StakerReward
This struct is used to store the reward information for a staker.


```solidity
struct StakerReward {
  uint112 finalizedBaseReward;
  uint112 finalizedDelegatedReward;
  uint112 baseRewardPerToken;
  uint112 operatorDelegatedRewardPerToken;
  uint112 claimedBaseRewardsInPeriod;
  uint256 storedBaseReward;
}
```

