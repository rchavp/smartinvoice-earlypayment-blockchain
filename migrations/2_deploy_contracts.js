const SmartInvoice = artifacts.require("./SmartInvoice.sol");

module.exports = function(deployer) {
  deployer.deploy(SmartInvoice);
};
