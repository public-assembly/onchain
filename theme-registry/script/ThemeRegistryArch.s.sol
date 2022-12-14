// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {ThemeRegistry} from "../src/ThemeRegistry.sol";
import {ThemeAdminAccessControl} from "../src/ThemeAdminAccessControl.sol";

contract DeployCore is Script {

    function setUp() public {}

    function run() public {
        

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ThemeRegistry themeRegistry = new ThemeRegistry();

        new ThemeAdminAccessControl(address(themeRegistry));

        vm.stopBroadcast();
    }
}


// ======= DEPLOY SCRIPTS =====

// source .env
// forge script script/ThemeRegistryArch.s.sol:DeployCore --rpc-url $GOERLI_RPC_URL --broadcast --verify  -vvvv
// forge script script/ThemeRegistryArch.s.sol:DeployCore --rpc-url $MAINNET_RPC_URL --broadcast --verify  -vvvv

