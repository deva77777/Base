// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    string[] public options;
    mapping(uint256 => uint256) public votes;
    mapping(address => bool) public hasVoted;

    constructor(string[] memory initialOptions) {
        options = initialOptions;
    }

    function vote(uint256 optionIndex) external {
        require(!hasVoted[msg.sender], "Already voted");
        require(optionIndex < options.length, "Invalid option");
        hasVoted[msg.sender] = true;
        votes[optionIndex] += 1;
    }

    function getOptions() external view returns (string[] memory) {
        return options;
    }
}
