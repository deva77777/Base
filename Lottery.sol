// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lottery
 * @dev A simple lottery contract where participants can enter and a winner is selected randomly
 */
contract Lottery {
    address public manager;
    address[] public players;
    uint256 public lotteryId;
    uint256 public entryFee;
    bool public lotteryActive;

    event LotteryStarted(uint256 indexed lotteryId, uint256 entryFee);
    event PlayerEntered(address indexed player, uint256 lotteryId);
    event WinnerSelected(address indexed winner, uint256 lotteryId, uint256 prize);

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this");
        _;
    }

    modifier onlyActive() {
        require(lotteryActive, "Lottery is not active");
        _;
    }

    constructor(uint256 _entryFee) {
        manager = msg.sender;
        entryFee = _entryFee;
        lotteryId = 0;
        lotteryActive = false;
    }

    function startLottery() external onlyManager {
        require(!lotteryActive, "Lottery already active");
        lotteryId++;
        players = new address[](0);
        lotteryActive = true;
        emit LotteryStarted(lotteryId, entryFee);
    }

    function enter() external payable onlyActive {
        require(msg.value >= entryFee, "Insufficient entry fee");
        players.push(msg.sender);
        emit PlayerEntered(msg.sender, lotteryId);
    }

    function getRandomNumber() private view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    players
                )
            )
        );
    }

    function pickWinner() external onlyManager onlyActive {
        require(players.length > 0, "No players in lottery");
        
        uint256 randomIndex = getRandomNumber() % players.length;
        address winner = players[randomIndex];
        uint256 prize = address(this).balance;
        
        lotteryActive = false;
        (bool sent, ) = winner.call{value: prize}("");
        require(sent, "Failed to send prize");
        
        emit WinnerSelected(winner, lotteryId, prize);
    }

    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external onlyManager {
        require(!lotteryActive, "Lottery is active");
        (bool sent, ) = manager.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }
}
