// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {ByteDance} from "../src/byteDance.sol";

contract ByteDanceTest is Test {
    ByteDance private dancer;
    address private solver;

    function setUp() external {
        dancer = new ByteDance();
        solver = address(new Solver());
    }

    function test_hackByteDancer() external {
        dancer.checkCode(solver);
        assertTrue(dancer.isSolved());
    }
}

contract Solver {
    constructor() {
        bytes memory contractCode = hex"61ffff61fffd5155";
        assembly {
            return(add(contractCode, 0x20), mload(contractCode))
        }
    }
}
