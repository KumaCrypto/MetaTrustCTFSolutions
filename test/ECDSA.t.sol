// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import {SECP256R1_Verify} from "src/ECDSA_Solidity/contracts/Verify.sol";

// FYI: Forge is incompatible with solc versions below 0.6.2, so we can't use the 'Test' contract.
contract ECDSA_Test {
    SECP256R1_Verify private checker;

    function setUp() external {
        checker = new SECP256R1_Verify();
    }

    function test_hackECDSA() external {
        // Retrieved from: src/ECDSA_Solidity/solution.py
        uint256 r = 63607537464833691735591749192264666949015507649778588617129415496363033470442;
        uint256 s = 81151975433876942679411788898193316173687189598528750465766591194135989506938;

        checker.solve(r, s);
        assertTrue(checker.isSolved());
    }

    function assertTrue(bool value) private pure {
        if (!value) {
            revert("NOT SOLVED!");
        }
    }
}
