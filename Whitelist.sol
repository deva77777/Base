// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Whitelist {
    mapping(address => bool) public approved;
    address public owner;

    constructor() {
        owner = msg.sender;
        approved[msg.sender] = true;
    }

    function setApproved(address user, bool status) external {
        require(msg.sender == owner, "Not owner");
        approved[user] = status;
    }

    function isApproved(address user) external view returns (bool) {
        return approved[user];
    }
}
