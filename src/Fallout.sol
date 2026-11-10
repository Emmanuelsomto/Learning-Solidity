// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Fallout {
    mapping(address => uint256) public allocations;
    address payable public owner;

    // The typo is right here: Fal1out instead of Fallout
    function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
    }

    function allocate() public payable {
        allocations[msg.sender] += msg.value;
    }

    function sendAllocation(address payable allocator) public {
        require(allocations[allocator] > 0);
        allocator.transfer(allocations[allocator]);
    }

    function collectAllocations() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }
}

