// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

contract RecoveryTest is Test {
    SimpleToken public token;
    Recovery public recovery;
    address public attacker;

    function setUp() public {
        attacker = makeAddr("attacker");
        recovery = new Recovery();
        recovery.generateToken("TestToken", 1000e18);

        // Compute and bind the SimpleToken with nonce e.g., 1
        // Assign the computed address to token
        token = SimpleToken(payable(vm.computeCreateAddress(address(recovery), 1)));
    }

    function testRecoveryEth() public {
        // 1. Attacker incited
        vm.prank(attacker);
        token.destroy(payable(attacker));

        // 2. Assert attack
        assertEq(address(token).balance, 0);
        assertEq(attacker.balance, 0);
    }
}
