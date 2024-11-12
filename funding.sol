// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract Funding {

    //this map keep track of money in the address of each contributer 
    mapping(address=>uint) public contributor;
    address public manager;
    uint public target;
    uint public minContribution;
    uint public deadline;
    uint public raisedAmount; // used for compaired current amount collected and should be collected amount
    uint public noOfContributors; //used while voting 

    struct Request {
        string description; //business, charity, flood... for fund purpose
        address payable recipient;
        uint noOfVotes;
        uint value;
        bool completed;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) requests;
    uint public numRequests; //to inc in maps
    

    constructor(uint _target, uint _deadline, uint _minContribution) {
        manager = msg.sender;
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = _minContribution;
    } 

    function sendAmout() public payable {
        require(msg.value >= minContribution,"The amount does not reaches to the min contribution for this fund");
        require(deadline  > block.timestamp, "Amount can't be transfered now"); 

        if (contributor[msg.sender]==0) { //new contributer, till now we have address but no value in it, if value already exit in this address then its an old contributor 
        // contributor[msg.sender] contain value pointing to the value only  
            noOfContributors++;
        }

        contributor[msg.sender] += msg.value; //key value, (key)sender address -> (value)amount
        raisedAmount += msg.value;
    }

    function getBalance() view public returns(uint) {
        return address(this).balance;
    }

    function claimReturn() public {
        require(raisedAmount < target && block.timestamp > deadline, "you are not eligible for this claim"); //if amount raised is less and deadline is exceeded...
        require(contributor[msg.sender]>0); //there should be any value amount in the address provided
        address payable user = payable(msg.sender); //to get the address of the sender and making it eligible for accepting the amount by doing payable 
        user.transfer(contributor[msg.sender]);
        contributor[msg.sender] = 0;
    }

    modifier onlyManager() {
        require(msg.sender==manager, "Only manager can call this number");
        _; //next ??
    }
    
    //now contributer make request, they telling in which they want their ether to give
    function createRequest(string memory _description, address payable _recepient, uint _value) public onlyManager {
        Request storage newRequest = requests[numRequests]; 
        //here value is retrieved for requests[numRequests] into newrequest from request struct
        numRequests++;
        newRequest.description = _description; //overriding for retrieved key -> value
        newRequest.recipient = _recepient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVotes = 0;
    }

    function vote(uint _requestNo) public {
        require(contributor[msg.sender]>0, "You should be a contributor for voting"); //checking that if in this address the value for money is greater than 0?
        Request storage thisRequest = requests[_requestNo]; //which ever request struct is at request no, that value is now been used or changes using thisRequest
        require(thisRequest.voters[msg.sender]=false, "You have already voted");
        thisRequest.voters[msg.sender]=true; //bool value declared in the starting of contract
        thisRequest.noOfVotes++;
    }

    function fundTransfer(uint requestNo) public onlyManager {
        require(raisedAmount>=target, "target is not reached");
        Request storage thisRequest = requests[requestNo];
        require(thisRequest.completed==false, "This request has been already completed");
        require(thisRequest.noOfVotes > noOfContributors/2, "Majority was not formed for this request");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed==true; 
    }
}
