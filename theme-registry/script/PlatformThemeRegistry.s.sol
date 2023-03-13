// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/console2.sol";
import {PlatformThemeRegistry} from "../src/PlatformThemeRegistry.sol";
import {ScriptBase} from "./ScriptBase.sol";

contract DeployCore is ScriptBase {
    function run() public {
        setUp();
        bytes memory creationCode = type(PlatformThemeRegistry).creationCode;
        console2.logBytes32(keccak256(creationCode));
        bytes32 salt = bytes32(0x00000000000000000000000000000000000000004757574f055940000019129c);
        vm.broadcast(deployer);
        IMMUTABLE_CREATE2_FACTORY.safeCreate2(salt, creationCode);
    }
}

// ======= DEPLOY SCRIPTS =====

// source .env
// forge script script/PlatformThemeRegistry.s.sol:DeployCore --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify  -vvvv
// forge script script/PlatformThemeRegistry.s.sol:DeployCore --rpc-url $MAINNET_RPC_URL --broadcast --verify  -vvvv
