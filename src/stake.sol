pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RewardToken.sol";

contract Staking is ERC20 {
    const WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 public autoCompoundFee;
    uint256 public minimumStakingPeriod;

    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public stakingStartTimes;
    mapping(address => bool) public isAutoCompounding;

    constructor() ERC20("EstherOCHE", "EST") {
        autoCompoundFee = 100; // 1%
        minimumStakingPeriod = 30 days; // 1 month
    }

    function stake(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than zero");
        require(stakingStartTimes[msg.sender] == 0, "User is already staking");

        // Convert ETH to WETH
        WETH.deposit{value: amount}();

        // Stake WETH
        stakedAmounts[msg.sender] = amount;
        stakingStartTimes[msg.sender] = block.timestamp;

        // Set auto compounding flag if specified
        if (isAutoCompounding[msg.sender]) {
            isAutoCompounding[msg.sender] = true;
        }
    }

    function withdraw() public {
        require(stakingStartTimes[msg.sender] > 0, "User is not staking");
        require(
            block.timestamp >=
                stakingStartTimes[msg.sender] + minimumStakingPeriod,
            "Minimum staking period has not passed"
        );

        // Calculate reward
        uint256 reward = calculateReward(msg.sender);

        // Mint reward to user
        _mint(msg.sender, reward);

        // Withdraw staked amount
        uint256 stakedAmount = stakedAmounts[msg.sender];
        stakedAmounts[msg.sender] = 0;
        stakingStartTimes[msg.sender] = 0;

        // Convert WETH to ETH
        WETH.withdraw(stakedAmount);

        // Transfer ETH to user
        (bool success, ) = msg.sender.call{value: stakedAmount}("");
        require(success, "Failed to transfer ETH to user");
    }

    function autoCompound() public {
        require(isAutoCompounding[msg.sender], "User is not auto compounding");

        // Calculate reward
        uint256 reward = calculateReward(msg.sender);

        // Calculate auto compound fee
        uint256 autoCompoundFeeAmount = (reward * autoCompoundFee) / 10000;

        // Remove auto compound fee from reward
        reward -= autoCompoundFeeAmount;

        // Mint reward to user
        _mint(msg.sender, reward);

        // Stake reward and principal
        stakedAmounts[msg.sender] += reward;

        // Update staking start time
        stakingStartTimes[msg.sender] = block.timestamp;

        // Charge auto compound fee
        _mint(address(this), autoCompoundFeeAmount);
    }

    function calculateReward(address user) public view returns (uint256) {
        // Calculate APR
        uint256 APR = 1400; // 14%

        // Calculate monthly reward rate
        uint256 monthlyRewardRate = APR / 12;

        // Calculate daily reward rate
        uint256 dailyRewardRate = monthlyRewardRate / 30;

        // Calculate hourly reward rate
        uint256 hourlyRewardRate = dailyRewardRate / 24;

        // Calculate minute reward rate
        uint256 minuteRewardRate = hourlyRewardRate / 60;

        // Calculate second reward rate
        uint256 secondRewardRate = minuteRewardRate / 60;

        // Calculate time since stake started
        uint256 timeSinceStakeStarted = block.timestamp -
            stakingStartTimes[user];

        // Calculate reward
        uint256 reward = stakedAmounts[user] *
            secondRewardRate *
            timeSinceStakeStarted;

        return reward;
    }

    function setAutoCompounding(bool isAutoCompounding) public {
        // Update auto compounding flag
        this.isAutoCompounding[msg.sender] = _isAutoCompounding;
    }
}
