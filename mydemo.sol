// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0 < 0.9.0;

contract Demo {
    uint public x = 1000;
    function set(uint num) public {
        x = num;
    }
}