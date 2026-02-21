// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniLock28 {
    bool public locked;

    function lock() external {
        locked = true;
    }

    function unlock() external {
        locked = false;
    }
}
