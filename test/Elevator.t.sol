// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Elevator} from "../src/Elevator.sol";
import {ElevatorExploit} from "./ElevatorExploit.t.sol";

contract ElevatorTest is Test {
    Elevator public elevator;
    ElevatorExploit public exploit;

    function setUp() public {
        elevator = new Elevator();
        exploit = new ElevatorExploit(address(elevator));
    }

    function test_ElevatorExploit() public {
        // Assert initial state is false
        assertEq(elevator.top(), false);

        // Execute the attack
        exploit.attack();

        // Verify the state inconsistency worked
        assertEq(elevator.top(), true);
        assertEq(elevator.floor(), 1);
    }
}
