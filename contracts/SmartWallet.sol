pragma solidity >=0.4.21 <0.6.0;

import './SmartInvoice.sol';

contract SmartWallet {

  enum OwnerStatus { ACTIVE, INACTIVE }
  enum CommitmentStatus { COMMITED, UNCOMMITED }

  address payable private _owner;
  mapping(address => OwnerStatus) private _owners; 
  mapping(address => CommitmentStatus) private _commitToPay;

  modifier isOwner() {
    require(msg.sender == _owner);
    _;
  }

  modifier validOwner() {
    require(msg.sender == _owner || _owners[msg.sender] == OwnerStatus.ACTIVE);
    _;
  }

  event DepositFunds(address from, uint amount);
  event WithdrawFunds(address to, uint amount);
  event TransferFunds(address from, address to, uint amount);
  event CommitedToPaySmartInvoice(address smartInvoiceAddress);

  constructor(address payable _realOwnerAddress)
  public {
    _owner = _realOwnerAddress;
  }

  function addOwner(address owner)
  isOwner
  public {
    _owners[owner] = OwnerStatus.ACTIVE;
  }

  function removeOwner(address owner)
  isOwner
  public {
    _owners[owner] = OwnerStatus.INACTIVE;
  }

  function ()
  external
  payable {
    emit DepositFunds(msg.sender, msg.value);
  }

  function withdraw(uint amount)
  validOwner
  public {
    require(address(this).balance >= amount);
    msg.sender.transfer(amount);
    emit WithdrawFunds(msg.sender, amount);
  }

  function transferTo(address payable to, uint amount) 
  validOwner
  public {
    require(address(this).balance >= amount);
    to.transfer(amount);
    emit TransferFunds(msg.sender, to, amount);
  }
        
  function commitToPayment(address _smartInvoiceAddress)
  validOwner
  public {
    _commitToPay[_smartInvoiceAddress] = CommitmentStatus.COMMITED;
    emit CommitedToPaySmartInvoice(_smartInvoiceAddress);
  }

  function settleInvoice(address _smartInvoiceAddress)
  public {
    require(_commitToPay[_smartInvoiceAddress] == CommitmentStatus.COMMITED);
    SmartInvoice si = SmartInvoice(_smartInvoiceAddress);
    si.settle();
  }
}

