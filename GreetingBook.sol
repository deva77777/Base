// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GreetingBook {
    string[] private greetings;

    function addGreeting(string calldata greeting) external {
        greetings.push(greeting);
    }

    function getGreeting(uint256 index) external view returns (string memory) {
        require(index < greetings.length, "Out of bounds");
        return greetings[index];
    }

    function totalGreetings() external view returns (uint256) {
        return greetings.length;
    }
}
