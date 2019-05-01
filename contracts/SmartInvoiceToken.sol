pragma solidity >=0.4.21 <0.6.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
 * @title SmartInvoiceToken
 */
contract SmartInvoiceToken is ERC20, ERC20Detailed {
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1000 * (10 ** uint256(DECIMALS));
    address public smartInvoiceAddress;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor (address _smartInvoiceAddress) public ERC20Detailed("SmartInvoiceToken", "SITOK", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
        smartInvoiceAddress = _smartInvoiceAddress;
    }

    // function redeem(address spender, uint256 subtractedValue) public returns (bool) {
       
    // }

}
