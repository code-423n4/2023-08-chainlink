// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';

import {Timelock} from './Timelock.sol';
import {PriceFeedAlertsController} from '../alerts/PriceFeedAlertsController.sol';
import {IMigratable} from '../interfaces/IMigratable.sol';
import {ISlashable} from '../interfaces/ISlashable.sol';
import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';
import {StakingPoolBase} from '../pools/StakingPoolBase.sol';
import {RewardVault} from '../rewards/RewardVault.sol';

/// @notice This contract is the contract manager of all staking contracts. Any contract upgrades or
/// parameter
/// updates will need to be scheduled here and go through the timelock.
/// @dev The deployer will transfer the staking contracts ownership to this contract and proposer
/// will schedule an accepting transaction in the timelock. After the timelock is passed, the
/// executor can execute the transaction and the staking contracts will be owned by this contract.
/// Example operations can be found in the integration tests.
contract StakingTimelock is Timelock {
  /// @notice This error is thrown whenever a zero-address is supplied when
  /// a non-zero address is required
  error InvalidZeroAddress();

  /// @notice This struct defines the params required by the StakingTimelock contract's
  /// constructor.
  struct ConstructorParams {
    /// @notice The reward vault address
    address rewardVault;
    /// @notice The Community Staker Staking Pool
    address communityStakingPool;
    /// @notice The Operator Staking Pool
    address operatorStakingPool;
    /// @notice The PriceFeedAlertsController address
    address alertsController;
    /// @notice initial minimum delay for operations
    uint256 minDelay;
    /// @notice account to be granted admin role
    address admin;
    /// @notice accounts to be granted proposer role
    address[] proposers;
    /// @notice accounts to be granted executor role
    address[] executors;
    /// @notice accounts to be granted canceller role
    address[] cancellers;
  }

  /// @notice 31 days in seconds (28 day unbonding period + 3 day buffer)
  uint256 private constant DELAY_ONE_MONTH = 31 days;

  constructor(ConstructorParams memory params)
    Timelock(params.minDelay, params.admin, params.proposers, params.executors, params.cancellers)
  {
    if (params.rewardVault == address(0)) revert InvalidZeroAddress();
    if (params.communityStakingPool == address(0)) revert InvalidZeroAddress();
    if (params.operatorStakingPool == address(0)) revert InvalidZeroAddress();
    if (params.alertsController == address(0)) revert InvalidZeroAddress();

    // Changing timelock delay
    _setDelay({
      target: address(this),
      selector: bytes4(keccak256('updateDelay(uint256)')),
      newDelay: DELAY_ONE_MONTH
    });
    _setDelay({
      target: address(this),
      selector: bytes4(keccak256('updateDelay((address,bytes4,uint256)[])')),
      newDelay: DELAY_ONE_MONTH
    });

    // Migrating staking pools to a new reward vault
    _setDelay({
      target: params.communityStakingPool,
      selector: StakingPoolBase.setRewardVault.selector,
      newDelay: DELAY_ONE_MONTH
    });
    _setDelay({
      target: params.operatorStakingPool,
      selector: StakingPoolBase.setRewardVault.selector,
      newDelay: DELAY_ONE_MONTH
    });

    // Migrating the staking pools to the upgraded pools
    _setDelay({
      target: params.communityStakingPool,
      selector: IMigratable.setMigrationTarget.selector,
      newDelay: DELAY_ONE_MONTH
    });
    _setDelay({
      target: params.operatorStakingPool,
      selector: IMigratable.setMigrationTarget.selector,
      newDelay: DELAY_ONE_MONTH
    });

    // Migrating the reward vault to the upgraded reward vault
    _setDelay({
      target: params.rewardVault,
      selector: IMigratable.setMigrationTarget.selector,
      newDelay: DELAY_ONE_MONTH
    });

    // Migrating the alerts controller to the upgraded alerts controller
    _setDelay({
      target: params.alertsController,
      selector: IMigratable.setMigrationTarget.selector,
      newDelay: DELAY_ONE_MONTH
    });

    // Granting a new slasher role / adding a new slashing condition
    _setDelay({
      target: params.operatorStakingPool,
      selector: ISlashable.addSlasher.selector,
      newDelay: DELAY_ONE_MONTH
    });

    // Updating unbonding periods in the staking pools
    _setDelay({
      target: params.communityStakingPool,
      selector: StakingPoolBase.setUnbondingPeriod.selector,
      newDelay: DELAY_ONE_MONTH
    });
    _setDelay({
      target: params.operatorStakingPool,
      selector: StakingPoolBase.setUnbondingPeriod.selector,
      newDelay: DELAY_ONE_MONTH
    });
  }
}
