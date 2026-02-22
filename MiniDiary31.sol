// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniDiary31 {
    string[] private entries;

    function addEntry(string calldata entry) external {
        entries.push(entry);
    }

    function entryCount() external view returns (uint256) {
        return entries.length;
    }

    function getEntry(uint256 index) external view returns (string memory) {
        return entries[index];
    }
}
