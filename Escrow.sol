// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Escrow
 * @dev A simple escrow contract for secure transactions
 */
contract Escrow {
    enum State { Created, Funded, Completed, Refunded }

    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    State public state;

    event Created(address indexed buyer, address indexed seller, uint256 amount);
    event Funded(uint256 amount);
    event Completed(address indexed seller, uint256 amount);
    event Refunded(address indexed buyer, uint256 amount);

    constructor(address _seller, address _arbiter) payable {
        require(_seller != address(0), "Invalid seller");
        require(_arbiter != address(0), "Invalid arbiter");
        require(msg.value > 0, "Must send funds");

        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        amount = msg.value;
        state = State.Created;

        emit Created(msg.sender, _seller, msg.value);
    }

    function fund() public payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == State.Created, "Invalid state");
        
        amount += msg.value;
        state = State.Funded;
        
        emit Funded(msg.value);
    }

    function release() public {
        require(msg.sender == buyer || msg.sender == arbiter, "Unauthorized");
        require(state == State.Funded, "Invalid state");

        state = State.Completed;
        payable(seller).transfer(amount);
        
        emit Completed(seller, amount);
    }

    function refund() public {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == State.Funded, "Invalid state");

        state = State.Refunded;
        payable(buyer).transfer(amount);
        
        emit Refunded(buyer, amount);
    }

    function getState() public view returns (State) {
        return state;
    }

    function getDetails() public view returns (address, address, address, uint256, State) {
        return (buyer, seller, arbiter, amount, state);
    }
}
