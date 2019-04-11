// const SmartInvoice = artifacts.require("./SmartInvoice.sol");
const SmartInvoiceToken = artifacts.require("./SmartInvoiceToken.sol");

module.exports = function(deployer) {
  // deployer.deploy(SmartInvoice);
  deployer.deploy(SmartInvoiceToken);
};
