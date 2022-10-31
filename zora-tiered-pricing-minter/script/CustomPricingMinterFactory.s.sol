// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {CustomPricingMinterFactory} from "../src/CustomPricingMinterFactory.sol";

contract DeployCore is Script {
    // ===== CONSTRUCTOR INPUTS =====
    address public customPricingMinterImpl = 0x8EbA2f3Da35e71359F8D1CD22DAB32271Cdf8e44; // Goerli address from broadcast/5/run-latest.json

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new CustomPricingMinterFactory(
            customPricingMinterImpl
        );

        vm.stopBroadcast();
    }
}

// ======= DEPLOY SCRIPTS =====

// source .env
// forge script script/CustomPricingMinter.s.sol:DeployCore --rpc-url $GOERLI_RPC_URL --broadcast --verify  -vvvv
// forge script script/CustomPricingMinter.s.sol:DeployCore --rpc-url $MAINNET_RPC_URL --broadcast --verify  -vvvv
