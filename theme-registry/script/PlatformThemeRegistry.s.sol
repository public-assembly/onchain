// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/console2.sol";
import {PlatformThemeRegistry} from "../src/PlatformThemeRegistry.sol";
import {ScriptBase} from "./ScriptBase.sol";
import {stdJson} from "forge-std/stdJson.sol";

contract DeployCore is ScriptBase {
    using stdJson for string;
    function run() public {
        setUp();
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/broadcast/PlatformThemeRegistry.s.sol/1/run-latest.json");
        string memory json = vm.readFile(path);
        bytes memory creationCode = json.readBytes(".transactions[0].arguments[1]");      
        // NOTE: commenting out below code since current version of PlatformThemeRegistry.sol in this repo
        //      does not compile to the same creationCode as original deploys
        // bytes memory creationCode = type(PlatformThemeRegistry).creationCode;
        console2.logBytes32(keccak256(creationCode));
        bytes32 salt = bytes32(0x00000000000000000000000000000000000000004757574f055940000019129c);
        vm.broadcast(deployerPrivateKey);
        IMMUTABLE_CREATE2_FACTORY.safeCreate2(salt, creationCode);
    }
}

// ======= DEPLOY SCRIPTS =====

// source .env
// forge script script/PlatformThemeRegistry.s.sol:DeployCore --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify  -vvvv
// forge script script/PlatformThemeRegistry.s.sol:DeployCore --rpc-url $MAINNET_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify  -vvvv
// forge script script/PlatformThemeRegistry.s.sol:DeployCore --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
