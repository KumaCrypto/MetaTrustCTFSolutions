// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GuessGame, SetUp} from "../src/A.sol";

contract GuessGameTest is Test {
    SetUp public _setUp;

    function setUp() external {
        _setUp = new SetUp();
    }

    function test_hackGuessGame() public {
        GuessGame game = _setUp.guessGame();
        // Explanation:
        // 0. How are immutable variables stored?
        // - In contract bytecode.
        // How is contract bytecode specified for contract?
        // - The byte array returned by the constructor is taken as bytecode.
        //
        // All variables stored in the GuessGame contract are immutable,
        // and when a constructor is called they are initialized in memory
        // due to the immutable variable specification they can be changed before the end of the constructor.
        // `pureFunc` changes values which are stored in the places where values were initialized in constructor.
        // -> So real values for random01,..., random03 are 1, 2, 32 respectively.
        // ----------------------------------------------------------------
        // 1. First arg eq 96 and value eq 1:
        // Default memory layout:
        //      0x00 - 0x3f = scratch space for hashing (0 and 1 slot)
        //      0x40 - 0x5f = free memory pointer (2 slot)
        //      0x60 - 0x7f = space for initializing empty arrays (3 slot)
        // In the contract we see: uint256[] memory arr;
        // This means that this empty array is allocated at 0x60
        // Array layout in memory: length | item 0 | item 1 | ...
        // So the length of the array is 0x60 and we have to write the random01 value into it, which is 1.
        // So 0x60 is 96 in decimal.
        uint256 arrMemoryPosition = 0x60;

        // 2. uint256 y = ( uint160(address(msg.sender)) + random01 + random02 + random03 + _random02) & 0xff;
        // We can see that only the last byte is taken and we can manipulate the result value with _random02.
        // Imagine the number in bin: 0b...10010100111001010101010100011111111
        // We need the last 8 bits to be 00000010 (2).                |||||||| < these bits
        // So we can calculate such _random02 that result will be 0b...00000010.
        uint256 preY = (uint160(address(this)) + 1 + 2 + 32) & 0xff;
        uint256 answerTo2dTask = 256 - preY + 2;

        // 3. To pass the 3d check, we need to provide an address with a large amount of leading zeros
        // which will return a word from the fallback function.
        // It is possible to compute such an address, but it is computationally intensive and can take a long time.
        // But maybe there are some addresses that can be used in a local chain that meet the requirements?
        // Yes! They are precompiles! More about precompiles: https://ethereum.stackexchange.com/a/68058/123519
        // For example, we can use a 0x2 address (SHA256), which returns the hash of the given message (one word - 32 bytes).
        uint256 SHA256_ADDRESS = 0x2;

        // 4. And finally 10 - the number which is returned from random04.number() call.
        game.guess{value: 1}(arrMemoryPosition, answerTo2dTask, SHA256_ADDRESS, 10);

        assertTrue(_setUp.isSolved());
    }

    receive() external payable {}
}
