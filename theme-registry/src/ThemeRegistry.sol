// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {BytecodeStorage} from "./utils/BytecodeStorage.sol";
import {IThemeAccessControl} from "./interfaces/IThemeAccessControl.sol";

/**
 * @title ThemeRegistry
 * @notice Facilitates access control protected basic onchain data storage for theming content
 * @notice not audited use at own risk
 * @author Max Bochman ---Ⓟ
 *
 */
contract ThemeRegistry is ReentrancyGuard {

    // ||||||||||||||||||||||||||||||||
    // ||| ERRORS |||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||     

    error No_Access();

    // ||||||||||||||||||||||||||||||||
    // ||| EVENTS |||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||

    event ThemeIndexInit(
        address sender,
        address accessControl,
        bytes accessControlInit,
        string themeUri,
        uint256 themeIndex,
        address addressDataContract
    );

    event ThemeIndexUpdated(
        address sender,
        string themeUri,
        uint256 themeIndex,
        address addressDataContract
    );

    // ||||||||||||||||||||||||||||||||
    // ||| STORAGE ||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||     

    mapping(uint256 => address) public themeDataInfo;

    mapping(uint256 => address) public themeDataAccessControl;

    uint256 currentThemeIndex;

    // ||||||||||||||||||||||||||||||||
    // ||| CONSTRUCTOR ||||||||||||||||
    // ||||||||||||||||||||||||||||||||  

    constructor() {
        currentThemeIndex = 0;
    }

    // ||||||||||||||||||||||||||||||||
    // ||| WRITE FUNCTIONS ||||||||||||
    // ||||||||||||||||||||||||||||||||

    function initializeThemeIndex(
        address accessControl, 
        bytes memory accessControlInit, 
        string memory themeUri
    ) external nonReentrant returns (address) {

        IThemeAccessControl(accessControl).initializeWithData(currentThemeIndex, accessControlInit);        

        themeDataAccessControl[currentThemeIndex] = accessControl;

        address dataContract = BytecodeStorage.writeToBytecode(abi.encode(themeUri));

        themeDataInfo[currentThemeIndex] = dataContract;  

        emit ThemeIndexInit({
            sender: msg.sender,
            accessControl: accessControl,
            accessControlInit: accessControlInit,
            themeUri: themeUri,
            themeIndex: currentThemeIndex,
            addressDataContract: dataContract
        });

        currentThemeIndex++;

        return dataContract;
    } 

    function updateThemeIndex(
        uint256 themeIndex, 
        string memory newThemeUri
    ) external nonReentrant returns (address) {

        if (IThemeAccessControl(themeDataAccessControl[themeIndex]).getAccessLevel(themeIndex, msg.sender) < 1) {
            revert No_Access();
        }

        address dataContract = themeDataInfo[themeIndex];

        if (dataContract != address(0x0)) {
            BytecodeStorage.purgeBytecode(dataContract);
        }        

        themeDataInfo[themeIndex] = BytecodeStorage.writeToBytecode(
            abi.encode(newThemeUri)
        );        

        emit ThemeIndexUpdated({
            sender: msg.sender,
            themeUri: newThemeUri,
            themeIndex: themeIndex,
            addressDataContract: themeDataInfo[themeIndex]
        });

        return themeDataInfo[themeIndex];
    } 

    // ||||||||||||||||||||||||||||||||
    // ||| VIEW FUNCTIONS |||||||||||||
    // ||||||||||||||||||||||||||||||||    

    function viewThemeURI(uint256 themeIndex) public view returns (string memory) {

        string memory themeUri = abi.decode(
            BytecodeStorage.readFromBytecode(themeDataInfo[themeIndex]),
            (string)
        );

        return themeUri;
    }
}
