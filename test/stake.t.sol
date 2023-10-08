// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Staking} from "../src/stake.sol";

contract StakeTest is Test {
DeployedAddresses = 0x18ca7B243b1f315BBeC55e98C516C1Ce30dcBf87;
    Staking staking = Staking(DeployedAddresses.Staking());

    // Test the stake function
    function testStake() public {
        uint256 amount = 10 ether;

        // Stake
        staking.stake{value: amount}(amount);

        // Check staked amount and staking start time
        Assert.equal(
            staking.stakedAmounts(msg.sender),
            amount,
            "Staked amount is incorrect"
        );
        Assert.notEqual(
            staking.stakingStartTimes(msg.sender),
            0,
            "Staking start time is not set"
        );
    }

    // Test the withdraw function
    function testWithdraw() public {
        // Withdraw
        staking.withdraw();

        // Check staked amount and staking start time after withdrawal
        Assert.equal(
            staking.stakedAmounts(msg.sender),
            0,
            "Staked amount is not reset after withdrawal"
        );
        Assert.equal(
            staking.stakingStartTimes(msg.sender),
            0,
            "Staking start time is not reset after withdrawal"
        );
    }

    // Test the autoCompound function
    function testAutoCompound() public {
        // Auto compound
        staking.autoCompound();

        // Check staked amount and staking start time after auto compounding
        Assert.notEqual(
            staking.stakedAmounts(msg.sender),
            0,
            "Staked amount is not updated after auto compounding"
        );
        Assert.notEqual(
            staking.stakingStartTimes(msg.sender),
            0,
            "Staking start time is not updated after auto compounding"
        );
    }
}
