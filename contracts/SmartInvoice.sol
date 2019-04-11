pragma solidity >=0.4.21 <0.6.0;

/**
 * @title SmartInvoice
 */

contract SmartInvoice {
    uint8 public constant DECIMALS = 18;
    enum Status { NEW, REJECTED, APPROVED, CLOSED }

    uint256 public amount;
    uint256 public due_date;
    Status  public status;
    address public beneficiary;
    bytes32 public reference_hash;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor (uint256 _amount,
                 uint256 _due_date,
                 Status  _status,
                 address _beneficiary,
                 bytes32 _reference_hash) public {
        amount = _amount;
        due_date = _due_date;
        status = _status;
        beneficiary = _beneficiary;
        reference_hash = _reference_hash;
    }
}

