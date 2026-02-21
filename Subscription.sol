// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Subscription
 * @dev A subscription service contract with recurring payments
 */
contract Subscription {
    address public owner;
    uint256 public subscriptionPrice;
    uint256 public subscriptionDuration;

    struct Subscriber {
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        uint256 totalPaid;
    }

    mapping(address => Subscriber) public subscribers;
    address[] public subscriberList;

    event Subscribed(address indexed user, uint256 startTime, uint256 endTime);
    event Renewed(address indexed user, uint256 newEndTime);
    event Cancelled(address indexed user);
    event PriceUpdated(uint256 newPrice);
    event DurationUpdated(uint256 newDuration);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier isActiveSubscriber() {
        require(subscribers[msg.sender].isActive, "Not an active subscriber");
        require(block.timestamp <= subscribers[msg.sender].endTime, "Subscription expired");
        _;
    }

    constructor(uint256 _price, uint256 _duration) {
        owner = msg.sender;
        subscriptionPrice = _price;
        subscriptionDuration = _duration;
    }

    function subscribe() external payable {
        require(msg.value >= subscriptionPrice, "Insufficient payment");

        if (!subscribers[msg.sender].isActive) {
            subscriberList.push(msg.sender);
        }

        uint256 start = block.timestamp;
        if (subscribers[msg.sender].endTime > block.timestamp) {
            start = subscribers[msg.sender].endTime;
        }

        uint256 end = start + subscriptionDuration;

        subscribers[msg.sender] = Subscriber({
            startTime: start,
            endTime: end,
            isActive: true,
            totalPaid: subscribers[msg.sender].totalPaid + msg.value
        });

        emit Subscribed(msg.sender, start, end);
    }

    function renew() external payable {
        require(subscribers[msg.sender].isActive, "Not a subscriber");
        require(msg.value >= subscriptionPrice, "Insufficient payment");

        uint256 start = block.timestamp;
        if (subscribers[msg.sender].endTime > block.timestamp) {
            start = subscribers[msg.sender].endTime;
        }

        subscribers[msg.sender].endTime = start + subscriptionDuration;
        subscribers[msg.sender].totalPaid += msg.value;
        subscribers[msg.sender].isActive = true;

        emit Renewed(msg.sender, subscribers[msg.sender].endTime);
    }

    function cancel() external {
        require(subscribers[msg.sender].isActive, "Not a subscriber");
        subscribers[msg.sender].isActive = false;
        emit Cancelled(msg.sender);
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        subscriptionPrice = _newPrice;
        emit PriceUpdated(_newPrice);
    }

    function setDuration(uint256 _newDuration) external onlyOwner {
        subscriptionDuration = _newDuration;
        emit DurationUpdated(_newDuration);
    }

    function getSubscriberInfo(address _user) external view returns (
        uint256 startTime,
        uint256 endTime,
        bool isActive,
        uint256 totalPaid,
        uint256 timeRemaining
    ) {
        Subscriber memory sub = subscribers[_user];
        uint256 remaining = 0;
        if (sub.endTime > block.timestamp && sub.isActive) {
            remaining = sub.endTime - block.timestamp;
        }
        return (sub.startTime, sub.endTime, sub.isActive, sub.totalPaid, remaining);
    }

    function isSubscribed(address _user) external view returns (bool) {
        Subscriber memory sub = subscribers[_user];
        return sub.isActive && block.timestamp <= sub.endTime;
    }

    function getSubscriberCount() external view returns (uint256) {
        return subscriberList.length;
    }

    function withdraw() external onlyOwner {
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }
}
