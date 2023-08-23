// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC677ReceiverInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import {TypeAndVersionInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

import {PausableWithAccessControl} from './PausableWithAccessControl.sol';
import {CommunityStakingPool} from './pools/CommunityStakingPool.sol';
import {OperatorStakingPool} from './pools/OperatorStakingPool.sol';

/// @notice This contract is a proxy for migrating stakers from the Staking V0.1
/// @dev When a staker calls the migrate function on the staking v0.1 contract, it will transfer the
/// migrating LINK to this contract. This contract will then transfer the LINK to the appropriate
/// staking pool. If the user wants a partial migration, the amount to withdraw will be transferred
/// back to the staker.
/// @dev invariant LINK balance of the contract is zero
contract MigrationProxy is
  ERC677ReceiverInterface,
  PausableWithAccessControl,
  TypeAndVersionInterface
{
  /// @notice This error is thrown whenever a zero-address is supplied when
  /// a non-zero address is required
  error InvalidZeroAddress();
  /// @notice This error is thrown when the onTokenTransfer source address is
  /// not the Staking V0.1 address.
  error InvalidSourceAddress();
  /// @notice This error is thrown when the sum of amounts to stake and withdraw
  /// isn't equal to the total amount passed to the Migration Proxy.
  error InvalidAmounts(uint256 amountToStake, uint256 amountToWithdraw, uint256 amountTotal);
  /// @notice This error is thrown whenever the sender is not the LINK token
  error SenderNotLinkToken();

  /// @notice This struct defines the params required by the MigrationProxy contract's
  /// constructor.
  struct ConstructorParams {
    /// @notice The LINK Token
    LinkTokenInterface LINKAddress;
    /// @notice The Staking V0.1 Pool
    address v01StakingAddress;
    /// @notice The Operator Staking Pool
    OperatorStakingPool operatorStakingPool;
    /// @notice The Community Staker Staking Pool
    CommunityStakingPool communityStakingPool;
    /// @notice The time it requires to transfer admin role
    uint48 adminRoleTransferDelay;
  }

  /// @notice The LINK Token
  LinkTokenInterface private immutable i_LINK;
  /// @notice The Staking V0.1 Pool
  address private immutable i_v01StakingAddress;
  /// @notice The Operator Staking Pool
  OperatorStakingPool private immutable i_operatorStakingPool;
  /// @notice The Community Staking Pool
  CommunityStakingPool private immutable i_communityStakingPool;

  constructor(ConstructorParams memory params)
    PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)
  {
    if (address(params.LINKAddress) == address(0)) revert InvalidZeroAddress();
    if (address(params.v01StakingAddress) == address(0)) {
      revert InvalidZeroAddress();
    }
    if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();
    if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();

    i_LINK = params.LINKAddress;
    i_v01StakingAddress = params.v01StakingAddress;
    i_operatorStakingPool = params.operatorStakingPool;
    i_communityStakingPool = params.communityStakingPool;
  }

  /// @notice LINK transfer callback function called when transferAndCall is called with this
  /// contract as a target.
  /// @dev precondition The v0.1 staking is closed
  /// @dev precondition The v0.2 staking pools are open
  /// @dev precondition The migration proxy is not paused
  /// @dev A redundant check for the Staking V0.1 contract being closed is omitted. This function
  /// can only be called by the V0.1 contract’s migrate function, which can
  /// only be called when the V0.1 pool is closed.
  /// @param source The Staking V0.1 address
  /// @param amount Amount of LINK token transferred
  /// @param data Bytes data received, represents migration path
  /// @inheritdoc ERC677ReceiverInterface
  function onTokenTransfer(
    address source,
    uint256 amount,
    bytes calldata data
  ) external override whenNotPaused validateFromLINK {
    if (source != i_v01StakingAddress) revert InvalidSourceAddress();

    (address staker, bytes memory stakerData) = abi.decode(data, (address, bytes));

    // Full migration
    if (stakerData.length == 0) {
      _migrateToPool({staker: staker, amount: amount, data: data});
      return;
    }

    // Partial migration
    (uint256 amountToStake, uint256 amountToWithdraw) = abi.decode(stakerData, (uint256, uint256));
    if (amountToStake + amountToWithdraw != amount) {
      revert InvalidAmounts(amountToStake, amountToWithdraw, amount);
    }

    // Stake a partial amount
    _migrateToPool({staker: staker, amount: amountToStake, data: data});
    // Withdraw the rest
    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transfer(staker, amountToWithdraw);
  }

  /// @notice Transfers the staker's funds and migration data to a staking pool.
  /// If the staker is a operator, the OperatorStakingPool will be used; otherwise,
  /// the CommunityStakingPool will be used.
  /// @param staker The staker who is migrating
  /// @param amount Amount of LINK token transferred
  /// @param data Bytes data received, represents migration path
  function _migrateToPool(address staker, uint256 amount, bytes calldata data) internal {
    address pool = i_operatorStakingPool.isOperator(staker)
      ? address(i_operatorStakingPool)
      : address(i_communityStakingPool);
    // The return value is not checked since the call will revert if any balance, allowance or
    // receiver conditions fail.
    i_LINK.transferAndCall({to: pool, value: amount, data: data});
  }

  /// @notice Returns the configured addresses
  /// @return The Link token, Staking V0.1, Operator staking pool, and community staking pool.
  function getConfig() external view returns (address, address, address, address) {
    return (
      address(i_LINK),
      i_v01StakingAddress,
      address(i_operatorStakingPool),
      address(i_communityStakingPool)
    );
  }

  // =================
  // IERC165
  // =================

  /// @notice This function allows the calling contract to
  /// check if the contract deployed at this address is a valid
  /// LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
  /// if it implements the onTokenTransfer function.
  /// @param interfaceId The ID of the interface to check against
  /// @return bool True if the contract is a valid LINKTokenReceiver.
  function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
    return interfaceId == this.onTokenTransfer.selector || super.supportsInterface(interfaceId);
  }

  // =======================
  // TypeAndVersionInterface
  // =======================

  /// @inheritdoc TypeAndVersionInterface
  function typeAndVersion() external pure virtual override returns (string memory) {
    return 'MigrationProxy 1.0.0';
  }

  /// @dev Reverts if not sent from the LINK token
  modifier validateFromLINK() {
    if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();
    _;
  }
}
