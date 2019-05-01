pragma solidity >=0.4.21 <0.6.0;
/**
 * @title SmartInvoice
 */

import './ERC20.sol';

contract SmartInvoice {

  enum Status { OPEN, REJECTED, SETTLED }

  address private NULL_ADDRESS = 0x0000000000000000000000000000000000000000;
  address payable private daiAddress = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
  uint256 private amount;
  uint256 private due_date;
  Status  private status;
  address private holderAccount;
  address private beneficiary;
  bytes32 private reference_hash;

  // Make sure the caller (sender) is the account holding the funds.
  modifier senderIsHolder() {
    require(msg.sender == holderAccount);
    _;    
  }

  modifier hasCorrectStatus() {
    require(status == Status.OPEN);
    _;    
  }

  modifier isPastDueDate() {
    require(due_date <= now);
    _;    
  }

  event InvoiceSettled(address holderAccount, address beneficiary, uint amount);

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor (uint256 _amount,
      uint256 _due_date,
      address _holderAccount,
      address _beneficiary,
      bytes32 _reference_hash,
      address payable _daiAddress)
  public {
    amount = _amount;
    due_date = _due_date;
    holderAccount = _holderAccount;
    beneficiary = _beneficiary;
    reference_hash = _reference_hash;
    if (_daiAddress != NULL_ADDRESS) {
      daiAddress = _daiAddress;
    }
    status = Status.OPEN;
  }

  function settle()
  senderIsHolder
  hasCorrectStatus
  isPastDueDate
  public {
    // if tokenized then call the 
    ERC20 daiContract = ERC20(daiAddress);
    uint256 balance = daiContract.balanceOf(holderAccount);
    require(balance >= amount);
    daiContract.transfer(beneficiary, amount);
    status = Status.SETTLED;
    emit InvoiceSettled(holderAccount, beneficiary, amount);
  }
}

