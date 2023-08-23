// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';
import {ConfirmedOwner} from '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

/// @notice This is a sample migration target contract.
/// @dev The Staking v2 contract will need to implement something similar.
contract StakingPoolBaseV2 is IERC165, ConfirmedOwner {
  /// @notice This event is emitted when the contract receives the migration tokens
  /// @param staker Address of the staker migrating
  /// @param amount Amount of LINK token transferred
  /// @param stakerStakedAtTime stakerStakedAtTime
  /// @param data Bytes data received
  /// @param sender Address of previous pool
  event StakerMigrated(
    address staker, uint256 amount, uint256 stakerStakedAtTime, bytes data, address sender
  );

  /// @notice This error is thrown when the owner tries to set the migration source to the
  /// zero address
  error InvalidMigrationSource();

  /// @notice This error is thrown when the sender is not the migration source.
  error SenderNotMigrationSource();

  /// @notice This error is thrown whenever the sender is not the LINK token
  error SenderNotLinkToken();

  /// @notice This struct defines the params required by the StakingPoolBase contract's
  /// constructor.
  struct ConstructorParams {
    /// @notice The LINK Token
    LinkTokenInterface LINKAddress;
    /// @notice The address of the migration source
    address migrationSource;
  }

  /// @notice The LINK token
  LinkTokenInterface internal immutable i_LINK;

  mapping(address => uint256) public migratedAmount;
  mapping(address => bytes) public migratedData;

  address private s_migrationSource;

  constructor(ConstructorParams memory params) ConfirmedOwner(msg.sender) {
    s_migrationSource = params.migrationSource;
    i_LINK = params.LINKAddress;
  }

  /// @notice LINK transfer callback function called when transferAndCall is called with this
  /// contract as a target.
  /// @param sender Pool sending the tokens.
  /// @param amount Amount of LINK token transferred
  /// @param data Bytes data received
  function onTokenTransfer(
    address sender,
    uint256 amount,
    bytes memory data
  ) public onlyMigrationSource validateFromLINK {
    (address staker, uint256 stakerStakedAtTime, bytes memory stakerData) =
      abi.decode(data, (address, uint256, bytes));

    migratedAmount[staker] = amount;
    migratedData[staker] = stakerData;
    emit StakerMigrated(staker, amount, stakerStakedAtTime, stakerData, sender);
  }

  /// @notice This function allows the calling contract to
  /// check if the contract deployed at this address is a valid
  /// LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
  /// if it implements the onTokenTransfer function.
  /// @param interfaceID The ID of the interface to check against
  /// @return bool True if the contract is a valid LINKTokenReceiver.
  function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
    return interfaceID == this.onTokenTransfer.selector;
  }

  /// @dev Reverts if the migration source is not set or the sender is not the migration source.
  modifier onlyMigrationSource() {
    if (s_migrationSource == address(0)) revert InvalidMigrationSource();
    _;
  }

  /// @dev Reverts if not sent from the LINK token
  modifier validateFromLINK() {
    if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();
    _;
  }
}
