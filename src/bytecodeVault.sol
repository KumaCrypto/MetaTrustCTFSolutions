//SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

contract BytecodeVault {
    address public owner;

    constructor() public payable {
        owner = msg.sender;
    }

    modifier onlyBytecode() {
        require(msg.sender != tx.origin, "No high-level contracts allowed!");
        _;
    }

    function withdraw() external onlyBytecode {
        uint256 sequence = 0xdeadbeef;
        bytes memory senderCode;

        address bytecaller = msg.sender;

        assembly {
            let size := extcodesize(bytecaller)
            senderCode := mload(0x40)
            mstore(0x40, add(senderCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(senderCode, size)
            extcodecopy(bytecaller, add(senderCode, 0x20), 0, size)
        }
        require(senderCode.length % 2 == 1, "Bytecode length must be even!");
        for (uint256 i = 0; i < senderCode.length - 3; i++) {
            if (
                senderCode[i] == bytes1(uint8(sequence >> 24))
                    && senderCode[i + 1] == bytes1(uint8((sequence >> 16) & 0xFF))
                    && senderCode[i + 2] == bytes1(uint8((sequence >> 8) & 0xFF))
                    && senderCode[i + 3] == bytes1(uint8(sequence & 0xFF))
            ) {
                msg.sender.transfer(address(this).balance);
                return;
            }
        }
        revert("Sequence not found!");
    }

    function isSolved() public view returns (bool) {
        return address(this).balance == 0;
    }
}
