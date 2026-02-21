// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleNFT
 * @dev A basic NFT contract with minting capabilities
 */
contract SimpleNFT {
    string public name = "SimpleNFT";
    string public symbol = "SNFT";
    uint256 public totalSupply;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => string) public tokenURI;
    mapping(address => mapping(address => bool)) public isApproved;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event Mint(address indexed to, uint256 indexed tokenId);

    function mint(address to, string memory _tokenURI) public returns (uint256) {
        require(to != address(0), "Invalid address");
        
        uint256 tokenId = totalSupply;
        totalSupply++;
        
        ownerOf[tokenId] = to;
        balanceOf[to]++;
        tokenURI[tokenId] = _tokenURI;

        emit Transfer(address(0), to, tokenId);
        emit Mint(to, tokenId);
        
        return tokenId;
    }

    function transfer(address to, uint256 tokenId) public {
        require(ownerOf[tokenId] == msg.sender, "Not owner");
        require(to != address(0), "Invalid address");

        balanceOf[msg.sender]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;

        emit Transfer(msg.sender, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        require(ownerOf[tokenId] == msg.sender, "Not owner");
        isApproved[msg.sender][to] = true;
        emit Approval(msg.sender, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(ownerOf[tokenId] == from, "Not owner");
        require(isApproved[from][msg.sender] || msg.sender == from, "Not approved");
        
        balanceOf[from]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
}
