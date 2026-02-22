// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DecentralizedExchange
 * @dev A simple DEX for swapping between two tokens
 */
contract DecentralizedExchange {
    address public tokenA;
    address public tokenB;
    address public owner;
    
    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public constant FEE_DENOMINATOR = 1000;
    uint256 public constant FEE = 3; // 0.3%

    mapping(address => uint256) public liquidityProviders;
    uint256 public totalLiquidity;

    event Swap(address indexed user, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token addresses");
        require(_tokenA != _tokenB, "Tokens must be different");
        tokenA = _tokenA;
        tokenB = _tokenB;
        owner = msg.sender;
    }

    function addLiquidity(uint256 _amountA, uint256 _amountB) external returns (uint256 liquidity) {
        require(_amountA > 0 && _amountB > 0, "Amounts must be > 0");

        if (totalLiquidity == 0) {
            liquidity = _amountA + _amountB;
        } else {
            liquidity = min(
                (_amountA * totalLiquidity) / reserveA,
                (_amountB * totalLiquidity) / reserveB
            );
        }

        require(liquidity > 0, "Insufficient liquidity minted");

        liquidityProviders[msg.sender] += liquidity;
        totalLiquidity += liquidity;
        reserveA += _amountA;
        reserveB += _amountB;

        emit LiquidityAdded(msg.sender, _amountA, _amountB, liquidity);
    }

    function removeLiquidity(uint256 _liquidity) external returns (uint256 amountA, uint256 amountB) {
        require(liquidityProviders[msg.sender] >= _liquidity, "Insufficient liquidity");
        require(_liquidity > 0, "Amount must be > 0");

        amountA = (_liquidity * reserveA) / totalLiquidity;
        amountB = (_liquidity * reserveB) / totalLiquidity;

        liquidityProviders[msg.sender] -= _liquidity;
        totalLiquidity -= _liquidity;
        reserveA -= amountA;
        reserveB -= amountB;

        emit LiquidityRemoved(msg.sender, amountA, amountB, _liquidity);
    }

    function swapAtoB(uint256 _amountA) external returns (uint256 amountB) {
        require(_amountA > 0, "Amount must be > 0");
        require(reserveA + _amountA <= address(this).balance, "Insufficient reserve");

        uint256 amountAWithFee = _amountA * (FEE_DENOMINATOR - FEE);
        amountB = (amountAWithFee * reserveB) / (reserveA + _amountA);

        require(amountB > 0, "Insufficient output amount");

        reserveA += _amountA;
        reserveB -= amountB;

        emit Swap(msg.sender, tokenA, _amountA, tokenB, amountB);
    }

    function swapBtoA(uint256 _amountB) external returns (uint256 amountA) {
        require(_amountB > 0, "Amount must be > 0");

        uint256 amountBWithFee = _amountB * (FEE_DENOMINATOR - FEE);
        amountA = (amountBWithFee * reserveA) / (reserveB + _amountB);

        require(amountA > 0, "Insufficient output amount");

        reserveB += _amountB;
        reserveA -= amountA;

        emit Swap(msg.sender, tokenB, _amountB, tokenA, amountA);
    }

    function getAmountOut(uint256 _amountIn, bool swapAtoB) external view returns (uint256) {
        if (swapAtoB) {
            uint256 amountAWithFee = _amountIn * (FEE_DENOMINATOR - FEE);
            return (amountAWithFee * reserveB) / (reserveA + _amountIn);
        } else {
            uint256 amountBWithFee = _amountIn * (FEE_DENOMINATOR - FEE);
            return (amountBWithFee * reserveA) / (reserveB + _amountIn);
        }
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    function getLiquidity(address _provider) external view returns (uint256) {
        return liquidityProviders[_provider];
    }

    function getPriceAtoB() external view returns (uint256) {
        if (reserveA == 0) return 0;
        return (reserveB * 1e18) / reserveA;
    }

    function getPriceBtoA() external view returns (uint256) {
        if (reserveB == 0) return 0;
        return (reserveA * 1e18) / reserveB;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    receive() external payable {}
}
