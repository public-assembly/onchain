// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Ownable} from "openzeppelin-contracts/access/ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {BytecodeStorage} from "./utils/BytecodeStorage.sol";
import {IAccessControlRegistry} from "onchain/interfaces/IAccessControlRegistry.sol";

/**
 * @title ThemeRegistry
 * @notice Facilitates basic onchain data storage for theming content
 * @notice not audited use at own risk
 * @author Max Bochman ---Ⓟ
 *
 */
contract ThemeRegistry is Ownable, ReentrancyGuard
{

    // ||||||||||||||||||||||||||||||||
    // ||| ERRORS |||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||     

    // ||||||||||||||||||||||||||||||||
    // ||| EVENTS |||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||

    // ||||||||||||||||||||||||||||||||
    // ||| STORAGE ||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||     

    mapping(uint256 => address) public themeDataInfo;

    uint256 currentThemeIndex;

    // ||||||||||||||||||||||||||||||||
    // ||| CONSTRUCTOR ||||||||||||||||
    // ||||||||||||||||||||||||||||||||  

    constructor() {
        currentThemeIndex = 1;
    }

    // ||||||||||||||||||||||||||||||||
    // ||| setThemeData |||||||||||||||
    // ||||||||||||||||||||||||||||||||

    function setThemeData(string memory themeUri) public {

        themeDataInfo[currentThemeIndex] = BytecodeStorage.writeToBytecode(
            abi.encode(themeUri)
        );        

        emit ThemeDataSet(
            sender: msg.sender(),
            themeUri: themeUri,
            themeIndex: currentThemeIndex;
            addressDataContract themeDataInfo[currentThemeIndex]
        );

        currentThemeIndex++;
    } 



    function setThemeURI(address contractAddress, string memory uri) public {
        Ownable drop = Ownable(contractAddress);
        require(drop.owner() == msg.sender, "REQUIRE_OWNER");
        _contractThemeURIs[contractAddress] = uri;
    }

    function themeURI(address contractAddress)
        external
        view
        returns (string memory)
    {
        return _contractThemeURIs[contractAddress];
    }

    constructor() {}

    // ||||||||||||||||||||||||||||||||
    // ||| createPublication ||||||||||
    // |||||||||||||||||||||||||||||||| 

    // ||||||||||||||||||||||||||||||||
    // ||| ADMIN FUNCTIONS ||||||||||||
    // ||||||||||||||||||||||||||||||||
}
