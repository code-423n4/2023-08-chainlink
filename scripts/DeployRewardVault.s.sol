// forge script scripts/DeployRewardVault.s.sol:DeployRewardVault --broadcast -vvvv --rpc-url
// $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {RewardVault} from "../src/rewards/RewardVault.sol";
import {Constants} from "../test/Constants.t.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {OperatorStakingPool} from "../src/pools/OperatorStakingPool.sol";
import {CommunityStakingPool} from "../src/pools/CommunityStakingPool.sol";
import {BaseScenario} from "./BaseScenario.s.sol";

contract DeployRewardVault is BaseScenario {
    function setUp() public virtual {}

    function run() public virtual {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying RewardVault... (deployer: %s)", deployer);

        s_LINK = LinkTokenInterface(vm.envAddress("LINK_ADDRESS"));
        s_communityStakingPool = CommunityStakingPool(
            vm.envAddress("COMMUNITY_STAKING_POOL")
        );
        s_operatorStakingPool = OperatorStakingPool(
            vm.envAddress("OPERATOR_STAKING_POOL")
        );
        string memory key = "OPERATORS";
        string memory delimiter = ",";
        address[] memory OPERATORS = vm.envAddress(key, delimiter);

        s_rewardVault = new RewardVault(
            RewardVault.ConstructorParams({
                linkToken: s_LINK,
                communityStakingPool: s_communityStakingPool,
                operatorStakingPool: s_operatorStakingPool,
                delegationRateDenominator: DELEGATION_RATE_DENOMINATOR,
                initialMultiplierDuration: INITIAL_MULTIPLIER_DURATION,
                adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
            })
        );

        s_rewardVault.grantRole(s_rewardVault.PAUSER_ROLE(), deployer);
        s_rewardVault.grantRole(s_rewardVault.REWARDER_ROLE(), deployer);

        s_LINK.approve(address(s_rewardVault), type(uint256).max);
        s_rewardVault.addReward(address(0), REWARD_AMOUNT, EMISSION_RATE);

        s_communityStakingPool.setRewardVault(s_rewardVault);
        s_operatorStakingPool.setRewardVault(s_rewardVault);
        s_operatorStakingPool.addOperators(OPERATORS);

        s_communityStakingPool.open();
        s_operatorStakingPool.open();

        address rewardVault = vm.envOr("REWARD_VAULT", address(0));
        if (rewardVault != address(s_rewardVault)) {
            vm.writeLine(
                ".env",
                string.concat(
                    "REWARD_VAULT=",
                    vm.toString(address(s_rewardVault))
                )
            );
        }

        vm.stopBroadcast();
    }
}
