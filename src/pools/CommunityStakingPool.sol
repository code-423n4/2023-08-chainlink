// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC677ReceiverInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';
import {TypeAndVersionInterface} from
  '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

import {IMerkleAccessController} from '../interfaces/IMerkleAccessController.sol';
import {OperatorStakingPool} from './OperatorStakingPool.sol';
import {StakingPoolBase} from './StakingPoolBase.sol';

/// @notice This contract manages the staking of LINK tokens for the community stakers.
/// @dev This contract inherits the StakingPoolBase contract and interacts with the MigrationProxy,
/// OperatorStakingPool, and RewardVault contracts.
/// @dev invariant Operators cannot stake in the community staking pool.
contract CommunityStakingPool is StakingPoolBase, IMerkleAccessController, TypeAndVersionInterface {
  /// @notice This error is thrown when the pool is opened with an empty
  /// merkle root
  error MerkleRootNotSet();

  /// @notice This event is emitted when the operator staking pool
  /// @param oldOperatorStakingPool The old operator staking pool
  /// @param newOperatorStakingPool The new operator staking pool
  event OperatorStakingPoolChanged(
    address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
  );

  /// @notice This struct defines the params required by the Staking contract's
  /// constructor.
  struct ConstructorParams {
    /// @notice The base staking pool constructor parameters
    ConstructorParamsBase baseParams;
    /// @notice The operator staking pool contract
    OperatorStakingPool operatorStakingPool;
  }

  /// @notice The operator staking pool contract
  OperatorStakingPool private s_operatorStakingPool;
  /// @notice The merkle root of the merkle tree generated from the list
  /// of staker addresses with early acccess.
  bytes32 private s_merkleRoot;

  constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams) {
    if (address(params.operatorStakingPool) == address(0)) {
      revert InvalidZeroAddress();
    }

    s_operatorStakingPool = params.operatorStakingPool;
  }

  // ===============
  // StakingPoolBase
  // ===============

  /// @inheritdoc StakingPoolBase
  function _validateOnTokenTransfer(
    address sender,
    address staker,
    bytes calldata data
  ) internal view override {
    // check if staker has access
    // if the sender is the migration proxy, the staker is allowed to stake
    // if currently in public phase (merkle root set to empty bytes) data is ignored
    // if in the access limited phase data is the merkle proof
    // if in migrations only phase, the merkle root is set to double hash of the migration proxy
    // address. This is essentially only used as a placeholder to differentiate between the open
    // phase (empty merkle root) and access limited phase (merkle root generated from allowlist)
    if (
      sender != address(s_migrationProxy) && s_merkleRoot != bytes32(0)
        && !_hasAccess(staker, abi.decode(data, (bytes32[])))
    ) {
      revert AccessForbidden();
    }

    // check if the sender is an operator
    if (s_operatorStakingPool.isOperator(staker) || s_operatorStakingPool.isRemoved(staker)) {
      revert AccessForbidden();
    }
  }

  /// @inheritdoc StakingPoolBase
  function _handleOpen() internal view override(StakingPoolBase) {
    if (s_merkleRoot == bytes32(0)) {
      revert MerkleRootNotSet();
    }
  }

  // =======================
  // IMerkleAccessController
  // =======================

  /// @inheritdoc IMerkleAccessController
  function hasAccess(
    address staker,
    bytes32[] calldata proof
  ) external view override returns (bool) {
    return _hasAccess(staker, proof);
  }

  /// @notice Util function that validates if a community staker has access to an
  /// access limited community staking pool
  /// @param staker The community staker's address
  /// @param proof Merkle proof for the community staker's allowlist
  /// @return bool True if the community staker has access to the access limited
  /// community staking pool
  function _hasAccess(address staker, bytes32[] memory proof) private view returns (bool) {
    if (s_merkleRoot == bytes32(0)) return true;
    return MerkleProof.verify({
      proof: proof,
      root: s_merkleRoot,
      leaf: keccak256(bytes.concat(keccak256(abi.encode(staker))))
    });
  }

  /// @inheritdoc IMerkleAccessController
  /// @dev precondition The caller must have the default admin role.
  function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    s_merkleRoot = newMerkleRoot;
    emit MerkleRootChanged(newMerkleRoot);
  }

  /// @inheritdoc IMerkleAccessController
  function getMerkleRoot() external view override returns (bytes32) {
    return s_merkleRoot;
  }

  /// @notice This function sets the operator staking pool
  /// @param newOperatorStakingPool The new operator staking pool
  /// @dev precondition The caller must have the default admin role.
  function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();
    address oldOperatorStakingPool = address(s_operatorStakingPool);
    s_operatorStakingPool = newOperatorStakingPool;
    emit OperatorStakingPoolChanged(oldOperatorStakingPool, address(newOperatorStakingPool));
  }

  // =======================
  // TypeAndVersionInterface
  // =======================

  /// @inheritdoc TypeAndVersionInterface
  function typeAndVersion() external pure virtual override returns (string memory) {
    return 'CommunityStakingPool 1.0.0';
  }
}
