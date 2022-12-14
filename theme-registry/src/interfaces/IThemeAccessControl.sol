// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IThemeAccessControl {
    
    function name() external view returns (string memory);    
    
    function initializeWithData(uint256 currentThemeIndex, bytes memory initData) external;
    
    function getAccessLevel(uint256, address) external view returns (uint256);
    
}