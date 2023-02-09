// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console2} from "../lib/forge-std/src/Console2.sol";
import {PlatformThemeRegistry} from "../src/PlatformThemeRegistry.sol";

contract PlatformThemeRegistryTest is Test {

    // Setup variables
    address payable public constant DEFAULT_OWNER_ADDRESS =
        payable(address(0x999));
    address payable public constant NON_OWNER_1 =
        payable(address(0x888));        
    address payable public constant NON_OWNER_2 =
        payable(address(0x777));      
    string testContractDocs_1 = "https://docs.public---assembly.com/";
    string testContractDocs_2 = "newDocs/";
    string testThemeInfo_1 = "testThemeInfo_1";
    string testThemeInfo_2 = "testThemeInfo_2";
    PlatformThemeRegistry platformThemeRegistry;

    function setUp() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);

        platformThemeRegistry = new PlatformThemeRegistry();

        vm.stopPrank();
    }

    function test_deploy() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        require(keccak256(bytes(platformThemeRegistry.contractDocs())) == keccak256(bytes(testContractDocs_1)), "theme registry not deployed correctly");
        require(platformThemeRegistry.owner() == DEFAULT_OWNER_ADDRESS, "ownable not set correctly");        
    }

    function test_newContractDocs() public {
        vm.startPrank(NON_OWNER_1);
        vm.expectRevert();
        platformThemeRegistry.setContractDocs(testContractDocs_2);
        vm.stopPrank();
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        platformThemeRegistry.setContractDocs(testContractDocs_2);
        require(keccak256(bytes(platformThemeRegistry.contractDocs())) == keccak256(bytes(testContractDocs_2)), "theme registry not updated correctly");
    }    

    function test_newPlatformIndex() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        platformThemeRegistry.newPlatformIndex(DEFAULT_OWNER_ADDRESS, testThemeInfo_1);
        require(platformThemeRegistry.platformCounter() == 1, "platform counter not working");
        require(platformThemeRegistry.getRole(1, DEFAULT_OWNER_ADDRESS) == PlatformThemeRegistry.Roles.ADMIN, "roles not working");
        require(keccak256(bytes(platformThemeRegistry.getPlatformTheme(1))) == keccak256(bytes(testThemeInfo_1)), "themes not working");
    }

    function test_setPlatformTheme() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        platformThemeRegistry.newPlatformIndex(DEFAULT_OWNER_ADDRESS, testThemeInfo_1);
        platformThemeRegistry.setPlatformTheme(1, testThemeInfo_2);
        require(keccak256(bytes(platformThemeRegistry.getPlatformTheme(1))) == keccak256(bytes(testThemeInfo_2)), "themes not working");
    }    

    function test_grantAndRevokeRoles() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        platformThemeRegistry.newPlatformIndex(DEFAULT_OWNER_ADDRESS, testThemeInfo_1);
        vm.stopPrank();
        vm.startPrank(NON_OWNER_1);
        vm.expectRevert();
        platformThemeRegistry.setPlatformTheme(1, testThemeInfo_2);
        vm.stopPrank();
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        PlatformThemeRegistry.RoleDetails[] memory roleDetails = new PlatformThemeRegistry.RoleDetails[](1);
        roleDetails[0].account = NON_OWNER_1;
        roleDetails[0].role = PlatformThemeRegistry.Roles.MANAGER;
        platformThemeRegistry.grantRoles(1, roleDetails);
        require(platformThemeRegistry.getRole(1, NON_OWNER_1) == PlatformThemeRegistry.Roles.MANAGER, "roles not working");
        vm.stopPrank();
        vm.startPrank(NON_OWNER_1);
        platformThemeRegistry.setPlatformTheme(1, testThemeInfo_2);
        require(keccak256(bytes(platformThemeRegistry.getPlatformTheme(1))) == keccak256(bytes(testThemeInfo_2)), "themes not working");
        // should revert since msg.sender has manager role which doesnt confer ability to grant roles
        vm.expectRevert();        
        platformThemeRegistry.grantRoles(1, roleDetails);
        vm.stopPrank();
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        PlatformThemeRegistry.RoleDetails[] memory newRoleDetails = new PlatformThemeRegistry.RoleDetails[](1);
        newRoleDetails[0].account = NON_OWNER_1;
        newRoleDetails[0].role = PlatformThemeRegistry.Roles.ADMIN;
        platformThemeRegistry.grantRoles(1, newRoleDetails);        
        require(platformThemeRegistry.getRole(1, NON_OWNER_1) == PlatformThemeRegistry.Roles.ADMIN, "roles not working");
        vm.stopPrank();
        vm.startPrank(NON_OWNER_1);
        PlatformThemeRegistry.RoleDetails[] memory moreNewRoleDetails = new PlatformThemeRegistry.RoleDetails[](1);
        moreNewRoleDetails[0].account = NON_OWNER_2;
        moreNewRoleDetails[0].role = PlatformThemeRegistry.Roles.MANAGER;
        platformThemeRegistry.grantRoles(1, moreNewRoleDetails);        
        require(platformThemeRegistry.getRole(1, NON_OWNER_2) == PlatformThemeRegistry.Roles.MANAGER, "roles not working");
        address[] memory accounts = new address[](1);
        accounts[0] = NON_OWNER_2;
        platformThemeRegistry.revokeRoles(1, accounts);
        require(platformThemeRegistry.getRole(1, NON_OWNER_2) == PlatformThemeRegistry.Roles.NO_ROLE, "roles not working");
    }        
}