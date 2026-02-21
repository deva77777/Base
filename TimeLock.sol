// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimeLock {
    address public beneficiary;
    uint256 public releaseTime;

    constructor(address _beneficiary, uint256 _releaseTime) {
        require(_releaseTime > block.timestamp, "Release time in past");
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    function deposit() external payable {}

    function release() external {
        require(block.timestamp >= releaseTime, "Too early");
        uint256 amount = address(this).balance;
        payable(beneficiary).transfer(amount);
    }
}
