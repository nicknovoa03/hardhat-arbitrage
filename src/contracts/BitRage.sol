// SPDX-License-Identifier: MIT
pragma solidity <=0.8.0;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

//import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
//import "@uniswap/v2-periphery/contracts/UniswapV2Router02.sol";

contract BitRage {
    ISwapRouter public uniswapRouter;
    ISwapRouter public sushiswapRouter;

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    constructor() {}

    function uniRouter(ISwapRouter _address) public {
        uniswapRouter = _address;
    }

    function sushiRouter(ISwapRouter _address) public {
        sushiswapRouter = _address;
    }

    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @param buyToken The token address when recieving in the swap
    /// @param sellToken The token address when sending in the swap
    /// @param router Flag for determing Uniswap or Sushiswap router
    /// @return amountOut The amount received.
    function brr(
        uint256 amountIn,
        address buyToken,
        address sellToken,
        uint16 router
    ) external returns (uint256 amountOut) {
        // Approve the router to spend DAI.
        if (router == 0) {
            TransferHelper.safeApprove(sellToken, address(uniswapRouter), amountIn);
        } else {
            TransferHelper.safeApprove(sellToken, address(sushiswapRouter), amountIn);
        }

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: buyToken,
                tokenOut: sellToken,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        if (router == 0) {
            amountOut = uniswapRouter.exactInputSingle(params);
        } else {
            amountOut = sushiswapRouter.exactInputSingle(params);
        }
    }
}
