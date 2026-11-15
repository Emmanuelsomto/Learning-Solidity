// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    bytes32 constant SECRET_PASSWORD = bytes32("superSecretPassword123");

    function setUp() public {
        // Deploy the Vault contract with our password in the constructor
        vault = new Vault(SECRET_PASSWORD);
    }

    function testVaultUnlock() public {
        // 1. Read the private password from storage slot 1
        bytes32 extractedPassword = vm.load(address(vault), bytes32(uint256(1)));

        // 2. Call unlock using the extracted password
        vault.unlock(extractedPassword);

        // 3. Assert that the vault is unlocked (locked should now be false)
        assertFalse(vault.locked(), "Vault should be unlocked successfully");
    }
}
