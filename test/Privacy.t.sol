// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Privacy} from "../src/Privacy.sol";

contract PrivacyTest is Test {
    Privacy public privacy;

    function setUp() public {
        // Create 3 sample 32-byte values to pass into Privacy's constructor
        bytes32[3] memory data =
            [bytes32("secret _zero"), bytes32("secret _one"), bytes32("secret_two_key_value_here!!")];

        // Deploy a fresh Privacy contract with the data
        privacy = new Privacy(data);
    }

    function test_UnlockPrivacy() public {
        // 1. Confirm the contract starts locked
        assertEq(privacy.locked(), true);

        // 2. Read raw 32 bytes directly from storage slot 5 (where data[2] lives)
        bytes32 slot5Value = vm.load(address(privacy), bytes32(uint256(5)));

        // 3. Cast bytes32 to bytes16 (keeps the leftmost 16 bytes)
        bytes16 key = bytes16(slot5Value);

        // 4. Call unlock() with the extracted key
        privacy.unlock(key);

        // 5. Verify the contract is now unlocked
        assertEq(privacy.locked(), false);
    }
}
