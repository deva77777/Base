// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessList {
    mapping(address => bool) public allowed;
    address public owner;

    event AccessSet(address indexed account, bool allowed);

    constructor() {
        owner = msg.sender;
    }

    function setAccess(address account, bool isAllowed) external {
        require(msg.sender == owner, "Only owner");
        allowed[account] = isAllowed;
        emit AccessSet(account, isAllowed);
    }
}
