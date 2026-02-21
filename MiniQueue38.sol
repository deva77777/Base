// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniQueue38 {
    uint256[] private queue;
    uint256 public head;

    function enqueue(uint256 value) external {
        queue.push(value);
    }

    function dequeue() external returns (uint256) {
        require(head < queue.length, "Empty");
        uint256 value = queue[head];
        head += 1;
        return value;
    }

    function size() external view returns (uint256) {
        return queue.length - head;
    }
}
