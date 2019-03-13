const Migrations = artifacts.require("./Migrations");
// const SmartInvoice = artifacts.require("./SmartInvoice.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  // deployer.deploy(SmartInvoice, { value: 30000000000000000000 });
};
