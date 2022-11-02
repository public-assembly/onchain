// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {CustomPricingMinter} from "./CustomPricingMinter.sol";
import {Clones} from "openzeppelin-contracts/proxy/Clones.sol";

contract CustomPricingMinterFactory {
    // The address of the base CustomPricingMinter implementation
    address public immutable customPricingMinterImpl;

    event CustomPricingMinterCreated(address newCustomPricingMinter, address deployer);

    /**
     * @notice Default constructor.
     */
    constructor(address _customPricingMinterImpl) {
        customPricingMinterImpl = _customPricingMinterImpl;
    }

    /**
     * @notice Initializes a new CustomPricingMinter contract using the CREATE opcode.
     */
    function createCustomPricingMinter(
        uint256 _nonBundlePricePerToken,
        uint256 _bundlePricePerToken,
        uint256 _bundleQuantity
    ) external returns (address newCustomPricingMinter) {
        newCustomPricingMinter = Clones.clone(customPricingMinterImpl);
        CustomPricingMinter(newCustomPricingMinter).initialize(
            _nonBundlePricePerToken, _bundlePricePerToken, _bundleQuantity
        );
        emit CustomPricingMinterCreated(newCustomPricingMinter, msg.sender);
    }
}
