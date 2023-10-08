// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract rewardToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint _ammount,
        address stakingContract
    ) ERC20("estheroche", "EST") {
        _mint(stakingContract, _ammount);
    }
}
