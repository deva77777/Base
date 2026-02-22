// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniSeed23 {
    uint256 public seed;

    function setSeed(uint256 newSeed) external {
        seed = newSeed;
    }

    function next() external {
        seed = uint256(keccak256(abi.encode(seed, block.timestamp)));
    }
}
