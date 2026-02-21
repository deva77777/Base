// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniSwitch34 {
    enum State {
        Off,
        On
    }

    State public state = State.Off;

    function toggle() external {
        if (state == State.Off) {
            state = State.On;
        } else {
            state = State.Off;
        }
    }
}
