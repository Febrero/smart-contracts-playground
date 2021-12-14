
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor () {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

pragma solidity ^0.8.0;


/**
 * @title A shop accepting a specific ERC20 token as payment
 * @author clemlak https://github.com/clemlak
 * @dev This contract must be linked to a token
 */
contract TestShop is Ownable {
  mapping (bytes4 => uint) public itemsToStocks;
  mapping (bytes4 => uint) public itemsToPrices;
  mapping (address => bytes4[]) public playersToItems;

  address public tokenContratAddress;

  function setTokenContractAddress(address _newTokenContratAddress) external onlyOwner() {

  }

  function buy(address buyer, uint price, bytes4 data) external {
    require(msg.sender == tokenContratAddress, "Function must be calleed from the token contract");

    require(itemsToPrices[data] == price, "Price is to low to buy this item");
    require(itemsToStocks[data] > 0, "Item is sold out");

    addPlayerItem(buyer, data);
  }

  function updateItemStock(bytes4 item, uint newStock) external onlyOwner() {
    itemsToStocks[item] = newStock;
  }

  function updateItemPrice(bytes4 item, uint newPrice) external onlyOwner() {
    itemsToPrices[item] = newPrice;
  }

  function addNewItem(bytes4 item, uint stock, uint price) external onlyOwner() {
    itemsToPrices[item] = price;
    itemsToStocks[item] = stock;
  }

  function getItem(bytes4 item) external view returns (
    uint,
    uint
  ) {
    return (itemsToStocks[item], itemsToPrices[item]);
  }

  function getPlayerItems(address playerAddress) external view returns (bytes4[]) {
    return playersToItems[playerAddress];
  }

  function addPlayerItem(address playerAddress, bytes4 data) internal {
    playersToItems[playerAddress].push(data);
    itemsToStocks[data] -= 1;
  }

  function isContract(address to) private view returns (bool) {
    uint32 size;

    /* solhint-disable-next-line */
    assembly {
      size := extcodesize(to)
    }

    return (size > 0);
  }
}
