// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract lottery {
    uint public x=10;
    address public manager; //in the beginning of code who deploied the contract is the manager
    address payable[] public participants; //array for all the participants

    //constructor fn is the first fn to run, only run once
    constructor() { 
        manager = msg.sender; //manager ke andr wo address stored h, jitne(manager ke address) ne abhi ye deploy kiya, constructor ko call kiya
    }

    receive() external payable { //this amount was pushded into the address of manager
        require(msg.value == 1 ether); //type of if else
        participants.push(payable(msg.sender)); //jisne abhi ye msg bhja h uska address nikalo or participants array me dalo
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager, "only manager can involke this"); 
        return address(this).balance; //whoever is calling this function that account's balance is shown, in our case only manager can call this fn actually
    }

    function random() public view returns (uint) {
        //Combine block properties (difficulty -> prevrandao, timestamp) and msg.sender(array length) as a seed for randomness  
        uint randomHash = uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, participants.length)));
        return randomHash;
    }

    function selectWinner() public {
        require(participants.length >= 3, "there should be atleast 3 participants");
        require(msg.sender == manager, "the one who select the winner should be the manager"); 
        uint number = random(); //to generate long int
        uint index = number%participants.length; //to get either 0 1 or 2
        address payable winner = participants[index]; //we get the address of winner
        winner.transfer(getBalance()); //we transfer the lottery amount to the winner
        participants = new address payable[](0); //reseting for another lottery round
    }
} 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
