// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IThemeAccessControl} from "./interfaces/IThemeAccessControl.sol";
import {IThemeRegistry} from "./interfaces/IThemeRegistry.sol";

contract ThemeAdminAccessControl is IThemeAccessControl {

    // ||||||||||||||||||||||||||||||||
    // ||| ERRORS |||||||||||||||||||||
    // |||||||||||||||||||||||||||||||| 

    error YouAreNotThemeRegistry();
    error Access_OnlyAdmin();
    error AccessRole_NotInitialized();

    // ||||||||||||||||||||||||||||||||
    // ||| EVENTS |||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||

    /// @notice Event for updated admin
    event AdminUpdated(
        uint256 indexed accessMappingTarget,
        address newAdmin
    );

    /// @notice Event for a new access control initialized
    /// @dev admin function indexer feedback
    event AccessControlInitialized(
        uint256 indexed accessMappingTarget,
        address admin
    );

    // ||||||||||||||||||||||||||||||||
    // ||| STORAGE ||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||

    string public constant name = "OnlyAdminAccessControl";

    address public immutable themeRegistry;

    /// @notice access information mapping storage
    /// @dev themeIndex index => admin address
    mapping(uint256 => address) public accessMapping;

    // ||||||||||||||||||||||||||||||||
    // ||| CONSTRUCTOR ||||||||||||||||
    // ||||||||||||||||||||||||||||||||

    constructor(address _themeRegistry) {
        themeRegistry = _themeRegistry;
    }

    // ||||||||||||||||||||||||||||||||
    // ||| WRITE FUNCTIONS ||||||||||||
    // ||||||||||||||||||||||||||||||||

    /// @notice updates admin address
    function updateAdmin(uint256 accessMappingTarget, address newAdmin) external {

        if (accessMapping[accessMappingTarget] != msg.sender) {
            revert Access_OnlyAdmin();
        }

        require(newAdmin != address(0), "admin cannot be zero address");

        accessMapping[accessMappingTarget] = newAdmin;

        emit AdminUpdated({accessMappingTarget: accessMappingTarget, newAdmin: newAdmin});
    }

    /// @notice initializes mapping of access control
    /// @dev contract initializing access control => admin address
    /// @dev called by other contracts initiating access control
    /// @dev data format: admin
    function initializeWithData(uint256 currentThemeIndex, bytes memory data) external {

        if (msg.sender != themeRegistry) {
            revert YouAreNotThemeRegistry();
        }
        
        (address admin) = abi.decode(data, (address));

        require(admin != address(0), "admin cannot be zero address");

        accessMapping[currentThemeIndex] = admin;

        emit AccessControlInitialized({
            accessMappingTarget: currentThemeIndex,
            admin: admin
        });
    }

    // ||||||||||||||||||||||||||||||||
    // ||| VIEW FUNCTIONS |||||||||||||
    // ||||||||||||||||||||||||||||||||

    /// @notice returns access level of a user address calling function
    /// @dev called via the external contract initializing access control
    function getAccessLevel(uint256 accessMappingTarget, address addressToGetAccessFor)
        external
        view
        returns (uint256)
    {

        if (accessMapping[accessMappingTarget] == addressToGetAccessFor) {
            return 1;
        }

        return 0;
    }

    /// @notice returns the address declared as admin by a given contract
    function getAdminInfo(uint256 accessMappingTarget)
        external
        view
        returns (address)
    {
        return accessMapping[accessMappingTarget];
    }
}
