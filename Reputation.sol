// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reputation
 * @dev A reputation system where addresses can gain or lose reputation points
 */
contract Reputation {
    address public admin;
    
    struct ReputationInfo {
        int256 score;
        uint256 level;
        uint256 totalEarned;
        uint256 totalLost;
        bool isRegistered;
    }

    mapping(address => ReputationInfo) public reputations;
    address[] public registeredUsers;

    uint256 public constant LEVEL_THRESHOLD = 100;

    event ReputationUpdated(address indexed user, int256 newScore, uint256 newLevel);
    event UserRegistered(address indexed user);
    event AdminChanged(address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    modifier isRegistered() {
        require(reputations[msg.sender].isRegistered, "Not registered");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function register() external {
        require(!reputations[msg.sender].isRegistered, "Already registered");
        
        reputations[msg.sender] = ReputationInfo({
            score: 0,
            level: 0,
            totalEarned: 0,
            totalLost: 0,
            isRegistered: true
        });
        
        registeredUsers.push(msg.sender);
        emit UserRegistered(msg.sender);
    }

    function addReputation(address _user, uint256 _amount) external onlyAdmin {
        require(reputations[_user].isRegistered, "User not registered");
        
        reputations[_user].score += int256(_amount);
        reputations[_user].totalEarned += _amount;
        
        _updateLevel(_user);
        emit ReputationUpdated(_user, reputations[_user].score, reputations[_user].level);
    }

    function removeReputation(address _user, uint256 _amount) external onlyAdmin {
        require(reputations[_user].isRegistered, "User not registered");
        
        uint256 actualAmount = _amount;
        if (uint256(reputations[_user].score) < _amount) {
            actualAmount = uint256(reputations[_user].score);
        }
        
        reputations[_user].score -= int256(actualAmount);
        reputations[_user].totalLost += actualAmount;
        
        _updateLevel(_user);
        emit ReputationUpdated(_user, reputations[_user].score, reputations[_user].level);
    }

    function _updateLevel(address _user) private {
        uint256 newLevel = uint256(reputations[_user].score >= 0 
            ? reputations[_user].score 
            : 0) / LEVEL_THRESHOLD;
        reputations[_user].level = newLevel;
    }

    function getReputation(address _user) external view returns (
        int256 score,
        uint256 level,
        uint256 totalEarned,
        uint256 totalLost,
        bool isRegistered
    ) {
        ReputationInfo memory rep = reputations[_user];
        return (rep.score, rep.level, rep.totalEarned, rep.totalLost, rep.isRegistered);
    }

    function getScore(address _user) external view returns (int256) {
        return reputations[_user].score;
    }

    function getLevel(address _user) external view returns (uint256) {
        return reputations[_user].level;
    }

    function hasMinimumReputation(address _user, int256 _minimum) external view returns (bool) {
        return reputations[_user].score >= _minimum;
    }

    function getRegisteredUsersCount() external view returns (uint256) {
        return registeredUsers.length;
    }

    function getAllRegisteredUsers() external view returns (address[] memory) {
        return registeredUsers;
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
        emit AdminChanged(_newAdmin);
    }
}
