// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract Events {
 
    //what are the things our event should have
    struct Event {
        address organiser;
        string name;
        uint date;
        uint price;
        uint ticketcount;
        uint ticketremain;
    }

    mapping(uint=>Event) public events;

    /* for inserting price (uint) for a user(address) into a show no(uint)*/
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextID;

    function createEvent(string memory name, uint date, uint price, uint ticketcount) public {
        require(date>block.timestamp, "You can crete future events only");
        require(ticketcount>0, "Ticket count must be more than 0");

        events[nextID] = Event(msg.sender, name, date, price, ticketcount, ticketcount);
        nextID++;
    }

    function buyTicket(uint id, uint quantity) public payable {
        require(events[id].date>block.timestamp, "Event already happened");
        require(events[id].date!=0, "No matching event");
        //struct is the data type, not uint bool... storage is for struct, array or mapping
        Event storage _event = events[id];
        require(msg.value!=(_event.price*quantity), "Please enter valid amount");
        require(_event.ticketremain>quantity, "This no of ticket is not available");
        /*after checking all the necessary conditions, we finally update no of ticket in users data
        kisi show ke liye us address me itne quantity add krni h 
        a quantity of tickets was booked by vansh(address) for 3rd(id) show */
        tickets[msg.sender][id]+=quantity;
    }

    function transferTicket(uint id, address receiver, uint quantity) public {
        require(events[id].date>block.timestamp, "Event already happened");
        require(events[id].date!=0, "No matching event");
        require(tickets[msg.sender][id]>quantity, "you don't have enough quantity of tickets");
        tickets[msg.sender][id]-=quantity; //ticket count dec from the sender
        tickets[receiver][id]+=quantity; //ticket count inc to the receiver
    }
}