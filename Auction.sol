// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleAuction
 * @dev A basic auction contract
 */
contract SimpleAuction {
    address payable public beneficiary;
    uint256 public auctionEndTime;
    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) public pendingReturns;
    bool public ended;

    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    constructor(uint256 _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        require(block.timestamp < auctionEndTime, "Auction already ended");
        require(msg.value > highestBid, "Bid not high enough");

        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
            return true;
        }
        return false;
    }

    function auctionEnd() public {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!ended, "Auction already ended");

        ended = true;
        beneficiary.transfer(highestBid);
        
        emit AuctionEnded(highestBidder, highestBid);
    }
}
