// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BlindAuction
 * @dev A blind auction where bids are hidden until the reveal period
 */
contract BlindAuction {
    address public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    mapping(address => Bid[]) public bids;
    address[] public bidders;
    mapping(address => bool) public hasBid;

    address public highestBidder;
    uint256 public highestBid;

    event AuctionCreated(uint256 biddingEnd, uint256 revealEnd);
    event BidPlaced(address indexed bidder);
    event BidRevealed(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    modifier onlyDuringBidding() {
        require(block.timestamp <= biddingEnd, "Bidding period ended");
        _;
    }

    modifier onlyDuringReveal() {
        require(block.timestamp > biddingEnd && block.timestamp <= revealEnd, "Reveal period invalid");
        _;
    }

    modifier onlyAfterReveal() {
        require(block.timestamp > revealEnd, "Reveal period not ended");
        _;
    }

    constructor(uint256 _biddingTime, uint256 _revealTime, address _beneficiary) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
        ended = false;
        emit AuctionCreated(biddingEnd, revealEnd);
    }

    function _hashBid(uint256 _amount, uint256 _secret, bool _fake) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_amount, _secret, _fake));
    }

    function placeBid(bytes32 _blindedBid) external payable onlyDuringBidding {
        require(msg.value >= 0.01 ether, "Minimum bid 0.01 ether");

        if (!hasBid[msg.sender]) {
            bidders.push(msg.sender);
            hasBid[msg.sender] = true;
        }

        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));

        emit BidPlaced(msg.sender);
    }

    function reveal(
        uint256[] calldata _amounts,
        uint256[] calldata _secrets,
        bool[] calldata _fakes
    ) external onlyDuringReveal {
        require(_amounts.length == _secrets.length && _amounts.length == _fakes.length, "Array length mismatch");

        Bid[] storage senderBids = bids[msg.sender];
        require(_amounts.length <= senderBids.length, "Too many reveals");

        uint256 refund = 0;

        for (uint256 i = 0; i < _amounts.length; i++) {
            Bid storage bid = senderBids[i];
            uint256 amount = _amounts[i];
            uint256 secret = _secrets[i];
            bool fake = _fakes[i];

            bytes32 expectedHash = _hashBid(amount, secret, fake);

            if (bid.blindedBid == expectedHash) {
                emit BidRevealed(msg.sender, amount);

                if (!fake && amount > highestBid) {
                    if (highestBidder != address(0)) {
                        refund += highestBid;
                    }
                    highestBid = amount;
                    highestBidder = msg.sender;
                } else if (!fake) {
                    refund += amount;
                } else {
                    refund += bid.deposit * 1 / 100;
                }

                bid.blindedBid = bytes32(0);
            } else {
                refund += bid.deposit;
            }
        }

        if (refund > 0) {
            (bool sent, ) = msg.sender.call{value: refund}("");
            require(sent, "Refund failed");
        }
    }

    function endAuction() external onlyAfterReveal {
        require(!ended, "Auction already ended");
        ended = true;

        if (highestBidder != address(0)) {
            (bool sent, ) = beneficiary.call{value: highestBid}("");
            require(sent, "Failed to send to beneficiary");
        }

        emit AuctionEnded(highestBidder, highestBid);
    }

    function getBidCount(address _bidder) external view returns (uint256) {
        return bids[_bidder].length;
    }

    function getBidders() external view returns (address[] memory) {
        return bidders;
    }

    function withdrawRefund() external onlyAfterReveal {
        Bid[] storage senderBids = bids[msg.sender];
        uint256 refund = 0;

        for (uint256 i = 0; i < senderBids.length; i++) {
            if (senderBids[i].blindedBid != bytes32(0)) {
                refund += senderBids[i].deposit;
                senderBids[i].blindedBid = bytes32(0);
            }
        }

        require(refund > 0, "No refund available");
        (bool sent, ) = msg.sender.call{value: refund}("");
        require(sent, "Refund failed");
    }
}
