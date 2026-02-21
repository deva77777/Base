// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniFaucet48 {
    uint256 public dripAmount = 0.01 ether;

    function setDripAmount(uint256 amount) external {
        dripAmount = amount;
    }

    function drip() external {
        require(address(this).balance >= dripAmount, "Empty");
        payable(msg.sender).transfer(dripAmount);
    }

    receive() external payable {}
}
