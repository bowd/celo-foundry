// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.13 <0.8.20;

import "../Test.sol";
import "./UsingPrecompiles.sol";

contract PrecompilesTest is Test, UsingPrecompiles {
    function testTransfer() public {
        address caller = vm.addr(0x23);
        address dest = vm.addr(0x24);
        vm.deal(caller, 10000);
        bool success;

        (success, ) = TRANSFER.call{value: 0, gas: gasleft()}(
            abi.encode(caller, dest, 500)
        );
        require(success, "CELO transfer failed");

        assert(dest.balance == 500);
        assert(caller.balance == 9500);
    }

    function testEpochSize() public {
        assert(getEpochSize() == 17280);
        ph.setEpochSize(1000);
        assert(getEpochSize() == 1000);
    }

    function testFractionMul() public {
        ph.mockReturn(
            FRACTION_MUL,
            keccak256(
                abi.encodePacked(
                    uint256(10),
                    uint256(5),
                    uint256(12),
                    uint256(4),
                    uint256(4),
                    uint256(10)
                )
            ),
            abi.encode(uint256(100), uint256(12))
        );

        (uint256 rNum, uint256 rDen) = fractionMulExp(10, 5, 12, 4, 4, 10);
        assert(rNum == 100);
        assert(rDen == 12);
    }

    function testProofOfPossession() public {
        address sender = address(0x999);
        bytes memory blsKey = abi.encodePacked("ExampleKey");
        bytes memory blsPop = abi.encodePacked("ExampleKeyPop");

        ph.mockSuccess(
            PROOF_OF_POSSESSION,
            keccak256(abi.encodePacked(sender, blsKey, blsPop))
        );
        assert(checkProofOfPossession(sender, blsKey, blsPop));

        ph.mockRevert(
            PROOF_OF_POSSESSION,
            keccak256(abi.encodePacked(sender, blsKey, blsPop))
        );
        assert(checkProofOfPossession(sender, blsKey, blsPop));
    }

    function testGetValidator() public {
        uint256 index = 10;
        address validator = address(0x989899);
        ph.mockReturn(
            GET_VALIDATOR,
            keccak256(abi.encodePacked(index, block.number)),
            abi.encode(validator)
        );
        assert(validatorSignerAddressFromCurrentSet(index) == validator);
    }

    function testGetValidatorAtBlock() public {
        uint256 index = 10;
        uint256 blockNumber = 1000;
        address validator = address(0x989899);
        ph.mockReturn(
            GET_VALIDATOR,
            keccak256(abi.encodePacked(index, blockNumber)),
            abi.encode(validator)
        );
        assert(validatorSignerAddressFromSet(index, blockNumber) == validator);
    }

    function testNumberValidatorsInSet() public {
        ph.mockReturn(
            NUMBER_VALIDATORS,
            keccak256(abi.encodePacked(block.number)),
            abi.encode(uint256(12))
        );
        assert(numberValidatorsInCurrentSet() == 12);
    }

    function testNumberValidatorsInSetAtBlock() public {
        uint256 blockNumber = 1000;
        ph.mockReturn(
            NUMBER_VALIDATORS,
            keccak256(abi.encodePacked(blockNumber)),
            abi.encode(uint256(12))
        );
        assert(numberValidatorsInSet(blockNumber) == 12);
    }

    function testBlockNumberFromHeader() public {
        uint256 blockNumber = 1000;
        bytes memory header = abi.encodePacked("MockHeader");
        ph.mockReturn(
            BLOCK_NUMBER_FROM_HEADER,
            keccak256(abi.encodePacked(header)),
            abi.encode(blockNumber)
        );
        assert(getBlockNumberFromHeader(header) == blockNumber);
    }

    function testHashHeader() public {
        bytes memory header = abi.encodePacked("MockHeader");
        bytes32 headerHash = keccak256(header);
        ph.mockReturn(
            HASH_HEADER,
            keccak256(abi.encodePacked(header)),
            abi.encode(headerHash)
        );
        assert(hashHeader(header) == headerHash);
    }

    function testGetParentSealBitmap() public {
        uint256 blockNumber = 1000;
        bytes32 bitmap = bytes32(uint256(0x12345679));
        ph.mockReturn(
            GET_PARENT_SEAL_BITMAP,
            keccak256(abi.encodePacked(blockNumber)),
            abi.encode(bitmap)
        );
        assert(getParentSealBitmap(blockNumber) == bitmap);
    }

    function testGetVerifiedSealBitmapFromHeader() public {
        bytes memory header = abi.encodePacked("MockHeader");
        bytes32 bitmap = bytes32(uint256(0x12345679));
        ph.mockReturn(
            GET_VERIFIED_SEAL_BITMAP,
            keccak256(abi.encodePacked(header)),
            abi.encode(bitmap)
        );
        assert(getVerifiedSealBitmapFromHeader(header) == bitmap);
    }
}
