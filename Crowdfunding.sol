// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Crowdfunding
 * @dev A crowdfunding campaign contract where backers can contribute and goal must be met
 */
contract Crowdfunding {
    address public creator;
    uint256 public goal;
    uint256 public deadline;
    uint256 public totalRaised;
    bool public goalReached;
    bool public fundsWithdrawn;

    struct Backer {
        uint256 amount;
        bool claimed;
    }

    mapping(address => Backer) public backers;
    address[] public backerList;

    event CampaignCreated(address indexed creator, uint256 goal, uint256 deadline);
    event Contribution(address indexed backer, uint256 amount);
    event GoalReached(uint256 totalRaised);
    event FundsWithdrawn(address indexed creator, uint256 amount);
    event RefundClaimed(address indexed backer, uint256 amount);

    modifier onlyCreator() {
        require(msg.sender == creator, "Only creator can call this");
        _;
    }

    modifier campaignEnded() {
        require(block.timestamp >= deadline, "Campaign not ended yet");
        _;
    }

    constructor(uint256 _goal, uint256 _duration) {
        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
        totalRaised = 0;
        goalReached = false;
        fundsWithdrawn = false;
        emit CampaignCreated(creator, _goal, deadline);
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign has ended");
        require(msg.value > 0, "Must contribute something");

        if (backers[msg.sender].amount == 0) {
            backerList.push(msg.sender);
        }

        backers[msg.sender].amount += msg.value;
        totalRaised += msg.value;

        if (totalRaised >= goal && !goalReached) {
            goalReached = true;
            emit GoalReached(totalRaised);
        }

        emit Contribution(msg.sender, msg.value);
    }

    function withdraw() external onlyCreator campaignEnded {
        require(goalReached, "Goal not reached");
        require(!fundsWithdrawn, "Funds already withdrawn");

        fundsWithdrawn = true;
        (bool sent, ) = creator.call{value: totalRaised}("");
        require(sent, "Failed to withdraw");

        emit FundsWithdrawn(creator, totalRaised);
    }

    function claimRefund() external campaignEnded {
        require(!goalReached, "Goal was reached");
        require(backers[msg.sender].amount > 0, "No contribution");
        require(!backers[msg.sender].claimed, "Already claimed");

        uint256 refund = backers[msg.sender].amount;
        backers[msg.sender].claimed = true;

        (bool sent, ) = msg.sender.call{value: refund}("");
        require(sent, "Failed to send refund");

        emit RefundClaimed(msg.sender, refund);
    }

    function getBackers() external view returns (address[] memory) {
        return backerList;
    }

    function getBackerInfo(address _backer) external view returns (uint256 amount, bool claimed) {
        Backer memory backer = backers[_backer];
        return (backer.amount, backer.claimed);
    }

    function getTimeRemaining() external view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
}
