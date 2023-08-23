#!/bin/bash

# run local chain
nohup anvil &

# load env vars
source .env
echo "RPC_URL: ${RPC_URL}"

# deploy contracts and add rewards
forge script scripts/scenarios/Scenario_WithAddedRewards.s.sol:Scenario_WithAddedRewards --broadcast -vvvv --rpc-url $RPC_URL
