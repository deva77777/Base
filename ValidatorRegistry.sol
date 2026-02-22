// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ValidatorRegistry {
    mapping(address => bool) public validators;
    uint256 public totalValidators;

    function register(address validator) external {
        if (!validators[validator]) {
            validators[validator] = true;
            totalValidators += 1;
        }
    }

    function unregister(address validator) external {
        if (validators[validator]) {
            validators[validator] = false;
            totalValidators -= 1;
        }
    }
}
