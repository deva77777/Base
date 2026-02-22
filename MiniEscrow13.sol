// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniEscrow13 {
    address public payer;
    address public payee;
    uint256 public amount;

    constructor(address _payee) {
        payer = msg.sender;
        payee = _payee;
    }

    function deposit() external payable {
        require(msg.sender == payer, "Only payer");
        amount += msg.value;
    }

    function release() external {
        require(msg.sender == payer, "Only payer");
        uint256 toSend = amount;
        amount = 0;
        payable(payee).transfer(toSend);
    }
}
