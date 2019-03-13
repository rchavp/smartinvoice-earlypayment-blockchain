/*
 * Main tests for the SmartInvoice contract
 *
 * Author: Ricardo C
 * March 2019
 *
 * */


const Func = artifacts.require('SmartInvoice.sol')
const tryCatch = require("./exceptions.js").tryCatch;
const errTypes = require("./exceptions.js").errTypes;




contract('Func', (accounts) => {

  const l = (label, msg) => {
    console.log(label + (!msg?'':': '+msg))
  }

  const tryCatch = require("./exceptions.js").tryCatch;
  const errTypes = require("./exceptions.js").errTypes;

  const acc1 = accounts[0]
  const acc2 = accounts[1]
  let contract

  //create new smart contract instance before each test method
  beforeEach(async () => {
    contract = await Func.deployed();
  })

  // it("should add x + y", async () => {
  //   const sum = await contract.add(1, 2)
  //   assert.equal(sum.toString(), '3')
  // })

  // it("should multiply x * y", async () => {
  //   const mult = await contract.mult(2, 3)
  //   assert.equal(mult.toString(), 6)
  // })

})

