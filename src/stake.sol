// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Staking is ERC20 {
    using SafeERC20 for IERC20;

    string public constant symbol = "EST";
    uint256 public constant APR = 14;
    uint256 public constant secondsPerYear = 31536000; // 365 days

    // Variables for staking
    uint256 public autoCompoundFeeRate = 1; // 1% auto compounding fee
    uint256 public autoCompoundAccumulatedFee;
    uint256 public minimumStakingPeriod = 30 days; // Minimum staking period of 30 days

    // Mapping to track staked balances and timestamps
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakedTimestamps;

    // Event for staking and unstaking
    event Staked(
        address indexed staker,
        uint256 amount,
        bool isAutoCompounding
    );
    event Unstaked(address indexed staker, uint256 amount);

    // Constructor to initialize the ERC20 token
    constructor() ERC20("Esther Breath Token", "EBT") {}

    function stakeETH(bool autoCompound) external payable {
        require(msg.value > 0, "ETH amount must be greater than 0");

        uint256 wethAmount = convertToWETH(msg.value);
        _mint(msg.sender, wethAmount);
        stakedBalances[msg.sender] += wethAmount;
        stakedTimestamps[msg.sender] = block.timestamp;

        // If auto-compound is enabled, deduct the auto-compound fee
        if (autoCompound) {
            uint256 autoCompoundFee = (wethAmount * autoCompoundFeeRate) / 100;
            autoCompoundAccumulatedFee += autoCompoundFee;
            stakedBalances[msg.sender] -= autoCompoundFee;
        }

        emit Staked(msg.sender, wethAmount, autoCompound);
    }

    function unstake() external {
        require(stakedBalances[msg.sender] > 0, "No staked balance");
        require(
            block.timestamp >=
                stakedTimestamps[msg.sender] + minimumStakingPeriod,
            "Minimum staking period not met"
        );

        uint256 stakedWETH = stakedBalances[msg.sender];
        uint256 rewardWETH = calculateReward(msg.sender, stakedWETH);
        uint256 totalWETH = stakedWETH + rewardWETH;

        // Convert reward back to ETH
        uint256 rewardETH = convertToETH(rewardWETH);

        // Deduct auto-compound fee from the accumulated fee
        if (autoCompoundAccumulatedFee > 0) {
            autoCompoundAccumulatedFee -=
                (rewardWETH * autoCompoundFeeRate) /
                100;
        }

        // Transfer the reward in ETH
        payable(msg.sender).transfer(rewardETH);

        // Burn the staked and reward tokens
        _burn(msg.sender, totalWETH);

        emit Unstaked(msg.sender, totalWETH);
    }

    // Function to calculate the reward based on the APR and staking duration
    function calculateReward(
        address staker,
        uint256 stakedAmount
    ) internal view returns (uint256) {
        uint256 stakingDuration = block.timestamp - stakedTimestamps[staker];
        uint256 rewardRate = (APR * stakedAmount) / 1000; // 1:10 ratio

        // Calculate reward up to seconds
        return (stakingDuration * rewardRate) / secondsPerYear;
    }

    // Function to convert ETH to WETH
    function convertToWETH(uint256 ethAmount) internal returns (uint256) {
        // Perform WETH conversion logic
        // This function will vary based on the actual WETH implementation being used
        // For example, you can use the WETH contract's deposit function to wrap ETH
        // This is a simplified example
        // Assume 1 ETH = 1 WETH
        return ethAmount;
    }

    // Function to convert WETH to ETH
    function convertToETH(uint256 wethAmount) internal returns (uint256) {
        // Perform WETH conversion logic
        // This function will vary based on the actual WETH implementation being used
        // For example, you can use the WETH contract's withdraw function to unwrap WETH
        // This is a simplified example
        // Assume 1 WETH = 1 ETH
        return wethAmount;
    }
}
