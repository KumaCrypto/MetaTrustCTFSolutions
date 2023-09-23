// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Foo} from "../src/Foo.sol";

contract FooTest is Test {
    Foo public foo;

    function setUp() external {
        foo = new Foo();
    }

    function test_hackFoo() public {
        uint256 salt = findSalt(); // Find such salt for create2 to pass the {setup} check
        Solver solver = new Solver{salt: bytes32(salt)}();
        solver.solve(foo);

        assertTrue(foo.isSolved());
    }

    function findSalt() private view returns (uint256 correctSalt) {
        bytes32 creationCodeHash = keccak256(type(Solver).creationCode);

        for (uint256 salt;; salt++) {
            bytes32 result = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, creationCodeHash));

            if (uint160(uint256(result)) % 1000 == 137) {
                return salt;
            }
        }
    }
}

contract Solver {
    uint256 private sortedTimestamp; // To store sorted array for stage 3

    function solve(Foo foo) external {
        foo.setup();

        bool isSolved;
        while (!isSolved) {
            try foo.stage1() {
                isSolved = true;
            } catch {}
        }

        isSolved = false;

        for (uint256 gas = 40_000; !isSolved; gas += 500) {
            try foo.stage2{gas: gas}() {
                isSolved = true;
            } catch {
                if (gas > 50_000) revert();
            }
        }

        setSortedStorageArr();
        foo.stage3();
        foo.stage4();
    }

    function check() external view returns (bytes32 answer) {
        if (gasleft() & 1 == 0) {
            return keccak256(abi.encodePacked("1337"));
        } else {
            return keccak256(abi.encodePacked("13337"));
        }
    }

    function sort(uint256[] calldata /* arr */ ) external view returns (uint256[] memory) {
        uint256[] memory sortedTimestampArr = new uint[](8);

        uint256 cachedSortedTimestamp = sortedTimestamp;
        for (uint256 i; i < sortedTimestampArr.length; i++) {
            sortedTimestampArr[i] = uint32(cachedSortedTimestamp >> 32 * i);
        }

        return sortedTimestampArr;
    }

    function pos() external view returns (bytes32 slot) {
        uint256 keyValue = 4;
        uint256 mappingSlot = 1;

        bytes32 intermediateSlot = calcMappingSlot(keyValue, mappingSlot);
        return calcMappingSlot(uint160(address(this)), uint256(intermediateSlot));
    }

    function calcMappingSlot(uint256 key, uint256 mappingSlot) private pure returns (bytes32 slot) {
        return keccak256(abi.encodePacked(key, mappingSlot));
    }

    function setSortedStorageArr() private {
        uint256[] memory timestampElements = new uint[](8);

        timestampElements[0] = (block.timestamp & 0xf0000000) >> 28;
        timestampElements[1] = (block.timestamp & 0xf000000) >> 24;
        timestampElements[2] = (block.timestamp & 0xf00000) >> 20;
        timestampElements[3] = (block.timestamp & 0xf0000) >> 16;
        timestampElements[4] = (block.timestamp & 0xf000) >> 12;
        timestampElements[5] = (block.timestamp & 0xf00) >> 8;
        timestampElements[6] = (block.timestamp & 0xf0) >> 4;
        timestampElements[7] = (block.timestamp & 0xf) >> 0;

        timestampElements = bubbleSort(timestampElements);

        for (uint256 i; i < timestampElements.length; i++) {
            sortedTimestamp = timestampElements[i] << 32 * i; // Store all values to 1 slot
        }
    }

    // Bubble sort from task
    function bubbleSort(uint256[] memory arr) private pure returns (uint256[] memory) {
        for (uint256 i = 0; i < 8; i++) {
            for (uint256 j = i + 1; j < 8; j++) {
                if (arr[i] > arr[j]) {
                    uint256 tmp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = tmp;
                }
            }
        }

        return arr;
    }
}
