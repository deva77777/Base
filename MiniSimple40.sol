// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniSimple40 {
    bool public done;

    function markDone() external {
        done = true;
    }

    function reset() external {
        done = false;
    }
}
