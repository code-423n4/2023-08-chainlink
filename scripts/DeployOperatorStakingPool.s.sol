// forge script scripts/DeployOperatorStakingPool.s.sol:DeployOperatorStakingPool --broadcast -vvvv
// --rpc-url $RPC_URL
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {OperatorStakingPool} from "../src/pools/OperatorStakingPool.sol";
import {StakingPoolBase} from "../src/pools/StakingPoolBase.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {BaseScenario} from "./BaseScenario.s.sol";

contract DeployOperatorStakingPool is BaseScenario {
    function setUp() public virtual {}

    function run() public virtual {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address deployer = vm.addr(deployerPrivateKey);

        console.log(
            "Deploying OperatorStakingPool... (deployer: %s)",
            deployer
        );

        s_LINK = LinkTokenInterface(vm.envAddress("LINK_ADDRESS"));

        // Deploy NOP staking pool
        s_operatorStakingPool = new OperatorStakingPool(
            OperatorStakingPool.ConstructorParams({
                minInitialOperatorCount: vm.envOr(
                    "MIN_INITIAL_OPERATOR_COUNT",
                    MIN_INITIAL_OPERATOR_COUNT
                ),
                baseParams: StakingPoolBase.ConstructorParamsBase({
                    LINKAddress: s_LINK,
                    initialMaxPoolSize: OPERATOR_MAX_POOL_SIZE,
                    initialMaxPrincipalPerStaker: OPERATOR_MAX_PRINCIPAL,
                    minPrincipalPerStaker: OPERATOR_MIN_PRINCIPAL,
                    initialUnbondingPeriod: INITIAL_UNBONDING_PERIOD,
                    maxUnbondingPeriod: MAX_UNBONDING_PERIOD,
                    initialClaimPeriod: INITIAL_CLAIM_PERIOD,
                    minClaimPeriod: MIN_CLAIM_PERIOD,
                    maxClaimPeriod: MAX_CLAIM_PERIOD,
                    adminRoleTransferDelay: ADMIN_ROLE_TRANSFER_DELAY
                })
            })
        );

        s_operatorStakingPool.grantRole(
            s_operatorStakingPool.PAUSER_ROLE(),
            deployer
        );

        s_LINK.approve(
            address(s_operatorStakingPool),
            INITIAL_ALERTING_BUCKET_BALANCE
        );
        s_operatorStakingPool.depositAlerterReward(
            INITIAL_ALERTING_BUCKET_BALANCE
        );

        address operatorStakingPool = vm.envOr(
            "OPERATOR_STAKING_POOL",
            address(0)
        );
        if (operatorStakingPool != address(s_operatorStakingPool)) {
            vm.writeLine(
                ".env",
                string.concat(
                    "OPERATOR_STAKING_POOL=",
                    vm.toString(address(s_operatorStakingPool))
                )
            );
        }

        vm.stopBroadcast();
    }
}
