
const solc = require("solc");

// file system - read and write files to your computer
const fs = require("fs");

// web3 interface
const {Web3} = require("web3");

// setup a http provider
let web3 = new Web3(new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545"));

// reading the file contents of the smart  contract

fileContent = fs.readFileSync("mydemo.sol").toString();
console.log(fileContent);

// create an input structure for my solidity compiler
var input = {
  language: "Solidity",
  sources: {
    "mydemo.sol": {
      content: fileContent,
    },
  },

  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

var output = JSON.parse(solc.compile(JSON.stringify(input)));
console.log("Output: ", output);

ABI = output.contracts["mydemo.sol"]["Demo"].abi;
bytecode = output.contracts["mydemo.sol"]["Demo"].evm.bytecode.object;
console.log("Bytecode: ", bytecode);
console.log("ABI: ", ABI);

let contract = new web3.eth.Contract(ABI);
let defaultAccount;
web3.eth.getAccounts().then((accounts) => {
  console.log("Accounts:", accounts); //it will show all the ganache accounts

  defaultAccount = accounts[3];
  console.log("Default Account:", defaultAccount);  //to deploy the contract from default Account
  contract
    .deploy({ data: bytecode })
    .send({ from: defaultAccount, gas: 400000})
    .then((demoContract) => {
      demoContract.methods.x().call((err, data) => {
        
        console.log("Initial Value:", data);
      });
    });
  
});



