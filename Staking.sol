// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Staking
 * @dev A simple staking contract with rewards
 */
contract Staking {
    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) public stakes;
    uint256 public rewardRate = 10; // 10% annual
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);

    function stake() public payable {
        require(msg.value > 0, "Must stake something");

        Stake storage userStake = stakes[msg.sender];
        
        if (userStake.amount > 0) {
            uint256 reward = calculateReward(msg.sender);
            userStake.amount += reward;
        }

        userStake.amount += msg.value;
        userStake.timestamp = block.timestamp;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    function unstake() public {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No stake found");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = userStake.amount + reward;
        
        totalStaked -= userStake.amount;
        userStake.amount = 0;
        userStake.timestamp = 0;

        payable(msg.sender).transfer(totalAmount);
        
        emit Unstaked(msg.sender, userStake.amount, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        Stake memory userStake = stakes[user];
        if (userStake.amount == 0) return 0;

        uint256 timeStaked = block.timestamp - userStake.timestamp;
        uint256 reward = (userStake.amount * rewardRate * timeStaked) / (365 days * 100);
        return reward;
    }

    function getStakeInfo(address user) public view returns (uint256 amount, uint256 reward, uint256 timestamp) {
        Stake memory userStake = stakes[user];
        return (userStake.amount, calculateReward(user), userStake.timestamp);
    }
}
