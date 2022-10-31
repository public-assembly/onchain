// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface ERC721DropMinterInterface {
    function adminMint(address recipient, uint256 quantity)
        external
        returns (uint256);

    function hasRole(bytes32, address) external returns (bool);

    function isAdmin(address) external returns (bool);
}

/**
 * @notice Adds custom pricing tier logic to standard ZORA Drop contracts
 * @dev Only compatible with ZORA Drop contracts that inherit ERC721Drop
 * @author max@ourzora.com
 *
 */

contract CustomPricingMinter is Ownable, ReentrancyGuard {
    // ===== ERRORS =====
    /// @notice Action is unable to complete because msg.value is incorrect
    error WrongPrice();

    /// @notice Action is unable to complete because minter contract has not recieved minting role
    error MinterNotAuthorized();

    /// @notice Funds transfer not successful to drops contract
    error TransferNotSuccessful();

    // ===== EVENTS =====
    /// @notice mint with quantity below bundle cutoff has occurred
    event NonBundleMint(address minter, uint256 quantity, uint256 totalPrice);

    /// @notice mint with quantity at or above bundle cutoff has occurred
    event BundleMint(address minter, uint256 quantity, uint256 totalPrice);

    /// @notice nonBundle price per token has been updated
    event NonBundlePricePerTokenUpdated(address owner, uint256 newPrice);

    /// @notice bundle price per token has been updated
    event BundlePricePerTokenUpdated(address owner, uint256 newPrice);

    /// @notice bundleQuantity cutoff has been updated
    event BundleQuantityUpdated(address owner, uint256 newQuantity);

    // ===== CONSTANTS =====
    bytes32 public immutable MINTER_ROLE = keccak256("MINTER");
    bytes32 public immutable DEFAULT_ADMIN_ROLE = 0x00;
    uint256 public immutable FUNDS_SEND_GAS_LIMIT = 300_000;

    // ===== PUBLIC VARIABLES =====
    uint256 public nonBundlePricePerToken;
    uint256 public bundlePricePerToken;
    uint256 public bundleQuantity;

    // ===== CONSTRUCTOR =====
    constructor(
        uint256 _nonBundlePricePerToken,
        uint256 _bundlePricePerToken,
        uint256 _bundleQuantity
    ) {
        nonBundlePricePerToken = _nonBundlePricePerToken;
        bundlePricePerToken = _bundlePricePerToken;
        bundleQuantity = _bundleQuantity;
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***      PUBLIC MINTING FUNCTIONS      ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    /// @dev calls nonBundle or bundle mint function depending on quantity entered
    /// @param zoraDrop ZORA Drop contract to mint from
    /// @param mintRecipient address to recieve minted tokens
    /// @param quantity number of tokens to mint
    function flexibleMint(
        address zoraDrop,
        address mintRecipient,
        uint256 quantity
    ) external payable nonReentrant returns (uint256) {
        // check if CustomPricingMinter contract has MINTER_ROLE on target ZORA Drop contract
        if (
            !ERC721DropMinterInterface(zoraDrop).hasRole(
                MINTER_ROLE,
                address(this)
            )
        ) {
            revert MinterNotAuthorized();
        }

        // check if mint quantity is below bundleQuantity cutoff
        if (quantity < bundleQuantity) {
            // check if total mint price is correct for nonBundle quantities
            if (msg.value != quantity * nonBundlePricePerToken) {
                revert WrongPrice();
            }

            _nonBundleMint(zoraDrop, mintRecipient, quantity);

            // Transfer funds to zora drop contract
            (bool nonBundleSuccess, ) = zoraDrop.call{value: msg.value}("");
            if (!nonBundleSuccess) {
                revert TransferNotSuccessful();
            }            

            return quantity;
        }

        // check if total mint price is correct for bundle quantities
        if (msg.value != quantity * bundlePricePerToken) {
            revert WrongPrice();
        }

        _bundleMint(zoraDrop, mintRecipient, quantity);

        // Transfer funds to zora drop contract
        (bool bundleSuccess, ) = zoraDrop.call{value: msg.value}("");
        if (!bundleSuccess) {
            revert TransferNotSuccessful();
        }

        return quantity;
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***     INTERNAL MINTING FUNCTIONS     ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    function _nonBundleMint(
        address zoraDrop,
        address mintRecipient,
        uint256 quantity
    ) internal {
        // call admintMint function on target ZORA contract
        ERC721DropMinterInterface(zoraDrop).adminMint(mintRecipient, quantity);
        emit NonBundleMint(
            msg.sender,
            quantity,
            quantity * nonBundlePricePerToken
        );
    }

    function _bundleMint(
        address zoraDrop,
        address mintRecipient,
        uint256 quantity
    ) internal {
        // call admintMint function on target ZORA contract
        ERC721DropMinterInterface(zoraDrop).adminMint(mintRecipient, quantity);
        emit NonBundleMint(
            msg.sender,
            quantity,
            quantity * bundlePricePerToken
        );
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***          ADMIN FUNCTIONS           ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    /// @dev updates nonBundlePricePerToken variable
    /// @param newPrice new nonBundlePricePerToken value
    function setNonBundlePricePerToken(uint256 newPrice) public onlyOwner {
        nonBundlePricePerToken = newPrice;

        emit NonBundlePricePerTokenUpdated(msg.sender, newPrice);
    }

    /// @dev updates bundlePricePerToken variable
    /// @param newPrice new bundlePricePerToken value
    function setBundlePricePerToken(uint256 newPrice) public onlyOwner {
        bundlePricePerToken = newPrice;

        emit BundlePricePerTokenUpdated(msg.sender, newPrice);
    }

    /// @dev updates bundleQuantity variable
    /// @param newQuantity new bundleQuantity value
    function setBundleQuantity(uint256 newQuantity) public onlyOwner {
        bundleQuantity = newQuantity;

        emit BundleQuantityUpdated(msg.sender, newQuantity);
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***           VIEW FUNCTIONS           ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    function fullBundlePrice() external view returns (uint256) {
        return bundlePricePerToken * bundleQuantity;
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

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
        emit CustomPricingMinterCreated(newCustomPricingMinter, msg.sender);
    }
}
