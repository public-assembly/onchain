// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {ThemeRegistry} from "../src/ThemeRegistry.sol";
import {ThemeAdminAccessControl} from "../src/ThemeAdminAccessControl.sol";
import {IThemeAccessControl} from "../src/interfaces/IThemeAccessControl.sol";

contract OnlyAdminAccessControlTest is DSTest {

    // Init Variables
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address payable public constant DEFAULT_OWNER_ADDRESS =
        payable(address(0x999));
    address payable public constant DEFAULT_NON_OWNER_ADDRESS =
        payable(address(0x888));      
    string testTokenURI_1 = "testTokenURI_1";
    string testTokenURI_2 = "testTokenURI_2";
    ThemeRegistry themeRegistry;
    ThemeAdminAccessControl adminAccessControl;

    function setUp() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);

        themeRegistry = new ThemeRegistry();

        adminAccessControl = new ThemeAdminAccessControl(
            address(themeRegistry)
        );                  

        vm.stopPrank();
    }

    function test_InitializeTheme() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        address dataContract = themeRegistry.initializeThemeIndex(
            address(adminAccessControl),
            abi.encode(DEFAULT_OWNER_ADDRESS),
            testTokenURI_1
        );
        assertEq(themeRegistry.themeDataInfo(0), dataContract);
        assertEq(themeRegistry.themeDataAccessControl(0), address(adminAccessControl));
        assertEq(adminAccessControl.getAdminInfo(0), DEFAULT_OWNER_ADDRESS);
        assertEq(themeRegistry.viewThemeURI(0), testTokenURI_1);
    }

    function test_InitializeThemeRevert() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        vm.expectRevert();
        address dataContract = themeRegistry.initializeThemeIndex(
            address(adminAccessControl),
            abi.encode(address(0)),
            testTokenURI_1
        );
    }    

    function test_UpdateTheme() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        address dataContract = themeRegistry.initializeThemeIndex(
            address(adminAccessControl),
            abi.encode(DEFAULT_OWNER_ADDRESS),
            testTokenURI_1
        );
        themeRegistry.updateThemeIndex(
            0,
            testTokenURI_2
        );
        assertEq(themeRegistry.viewThemeURI(0), testTokenURI_2);
    }    

    function test_UpdateThemeRevert() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        address dataContract = themeRegistry.initializeThemeIndex(
            address(adminAccessControl),
            abi.encode(DEFAULT_OWNER_ADDRESS),
            testTokenURI_1
        );
        vm.stopPrank();
        vm.startPrank(DEFAULT_NON_OWNER_ADDRESS);
        vm.expectRevert();
        themeRegistry.updateThemeIndex(
            0,
            testTokenURI_2
        );
    }     

    function test_AccessControlRevert() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        vm.expectRevert();
        adminAccessControl.initializeWithData(0, abi.encode(DEFAULT_OWNER_ADDRESS));
    }       


    // function test_incorrectAdminSetup() public {
    //     vm.startPrank(DEFAULT_OWNER_ADDRESS);
    //     OnlyAdminAccessControl adminAccessControl = new OnlyAdminAccessControl();

    //     OnlyAdminMock mockOnlyAdmin = new OnlyAdminMock();
    //     vm.expectRevert("admin cannot be zero address");
    //     mockOnlyAdmin.initializeAccessControl(
    //         address(adminAccessControl), 
    //         address(0)
    //     );    
    // }       

    // function test_AdminAccess() public {
    //     vm.startPrank(DEFAULT_OWNER_ADDRESS);
    //     OnlyAdminAccessControl adminAccessControl = new OnlyAdminAccessControl();

    //     OnlyAdminMock mockOnlyAdmin = new OnlyAdminMock();
    //     mockOnlyAdmin.initializeAccessControl(
    //         address(adminAccessControl), 
    //         address(DEFAULT_OWNER_ADDRESS)
    //     );
    //     assertTrue(mockOnlyAdmin.accessControlProxy() == address(adminAccessControl));
    //     assertTrue(mockOnlyAdmin.getAccessLevelForUser() == 3);
    //     assertTrue(mockOnlyAdmin.userAccessTest());
    //     assertTrue(mockOnlyAdmin.managerAccessTest());
    //     assertTrue(mockOnlyAdmin.adminAccessTest()); 
    // }        

    // function test_ChangeAdminAccess() public {
    //     vm.startPrank(DEFAULT_OWNER_ADDRESS);
    //     OnlyAdminAccessControl adminAccessControl = new OnlyAdminAccessControl();

    //     OnlyAdminMock mockOnlyAdmin = new OnlyAdminMock();
    //     mockOnlyAdmin.initializeAccessControl(
    //         address(adminAccessControl), 
    //         address(DEFAULT_OWNER_ADDRESS)
    //     );
    //     assertTrue(mockOnlyAdmin.accessControlProxy() == address(adminAccessControl));
    //     assertTrue(mockOnlyAdmin.getAccessLevelForUser() == 3);
    //     assertTrue(mockOnlyAdmin.userAccessTest());
    //     assertTrue(mockOnlyAdmin.managerAccessTest());
    //     assertTrue(mockOnlyAdmin.adminAccessTest()); 

    //     adminAccessControl.updateAdmin(address(mockOnlyAdmin), DEFAULT_NON_OWNER_ADDRESS);
    //     assertTrue(adminAccessControl.getAdminInfo(address(mockOnlyAdmin)) == DEFAULT_NON_OWNER_ADDRESS);
        
    //     vm.stopPrank();
    //     vm.startPrank(DEFAULT_NON_OWNER_ADDRESS);
        
    //     assertTrue(mockOnlyAdmin.accessControlProxy() == address(adminAccessControl));
    //     assertTrue(mockOnlyAdmin.getAccessLevelForUser() == 3);
    //     assertTrue(mockOnlyAdmin.userAccessTest());
    //     assertTrue(mockOnlyAdmin.managerAccessTest());
    //     assertTrue(mockOnlyAdmin.adminAccessTest()); 
    // }          

    // function test_NameTest() public {
    //     OnlyAdminAccessControl adminAccessControl = new OnlyAdminAccessControl();
    //     assertEq(adminAccessControl.name(), "OnlyAdminAccessControl");
    // }    

    // function test_GetAdminInfo() public {
    //     vm.startPrank(DEFAULT_OWNER_ADDRESS);
    //     OnlyAdminAccessControl adminAccessControl = new OnlyAdminAccessControl();

    //     OnlyAdminMock mockOnlyAdmin = new OnlyAdminMock();
    //     mockOnlyAdmin.initializeAccessControl(
    //         address(adminAccessControl), 
    //         address(DEFAULT_OWNER_ADDRESS)
    //     );
    //     assertTrue(mockOnlyAdmin.accessControlProxy() == address(adminAccessControl));        
    //     assertEq(adminAccessControl.getAdminInfo(address(mockOnlyAdmin)),  address(DEFAULT_OWNER_ADDRESS));
    // }        
}