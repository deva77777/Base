// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DonationBox {
    address public owner;
    uint256 public totalDonations;

    constructor() {
        owner = msg.sender;
    }

    function donate() external payable {
        totalDonations += msg.value;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
    }
}
