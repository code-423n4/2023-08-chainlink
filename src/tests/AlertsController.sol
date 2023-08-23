// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ConfirmedOwner} from '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import {CommunityStakingPool} from '../pools/CommunityStakingPool.sol';
import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

contract AlertsController is ConfirmedOwner {
  error AlertInvalid();

  struct ConstructorParams {
    uint256 alerterRewardAmount;
    uint256 slashableAmount;
    CommunityStakingPool communityStakingPool;
    OperatorStakingPool operatorStakingPool;
    address[] slashableOperators;
  }

  uint256 private immutable i_alerterRewardAmount;
  uint256 private immutable i_slashableAmount;
  CommunityStakingPool private immutable i_communityStakingPool;
  OperatorStakingPool private immutable i_operatorStakingPool;
  address[] private s_slashableOperators;
  bool private s_alertRaisable;

  constructor(ConstructorParams memory params) ConfirmedOwner(msg.sender) {
    i_alerterRewardAmount = params.alerterRewardAmount;
    i_slashableAmount = params.slashableAmount;
    i_communityStakingPool = params.communityStakingPool;
    i_operatorStakingPool = params.operatorStakingPool;
  }

  function toggleRaisable() external onlyOwner {
    s_alertRaisable = !s_alertRaisable;
  }

  function raiseAlert(address feed) external {
    if (!_canAlert(msg.sender, feed)) revert AlertInvalid();

    i_operatorStakingPool.slashAndReward(
      s_slashableOperators, msg.sender, i_alerterRewardAmount, i_slashableAmount
    );
  }

  function canAlert(address alerter, address feed) external view returns (bool) {
    return _canAlert(alerter, feed);
  }

  function getStakingPools() external view returns (address[] memory) {
    address[] memory pools = new address[](2);
    pools[0] = address(i_operatorStakingPool);
    pools[1] = address(i_communityStakingPool);
    return pools;
  }

  function _canAlert(address alerter, address) internal view returns (bool) {
    return s_alertRaisable
      && (
        i_communityStakingPool.getStakerPrincipal(alerter) != 0
          || i_operatorStakingPool.getStakerPrincipal(alerter) != 0
      );
  }

  function setSlashableOperators(address[] calldata operators, address) external onlyOwner {
    s_slashableOperators = operators;
  }

  function getSlashableOperators(address) public view returns (address[] memory) {
    return s_slashableOperators;
  }
}
