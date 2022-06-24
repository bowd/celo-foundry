// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.13;

import "forge-std/Test.sol";
import "../precompiles/Precompiles.sol";
import "contracts/common/GoldToken.sol";
import "contracts/common/UsingPrecompiles.sol";

contract PrecompilesTest is Test, UsingPrecompiles {
  GoldToken gold;
  Precompiles prec;

  function setUp() public {
    prec = new Precompiles();
    gold = new GoldToken(true);
  }

  function testTransfer() public {
    address caller = vm.addr(0x23);
    vm.deal(caller, 10000);
    vm.prank(caller);
    gold.transfer(address(200), 500);
    assert(address(200).balance == 500);
    assert(caller.balance == 9500);
  }

  function testEpochSize() public {
    assert(getEpochSize() == 17280);
    prec.setEpochSize(1000);
    assert(getEpochSize() == 1000);
  }

  function testFractionMul() public {
    uint256 aNum = 10;
    uint256 aDen = 5;
    uint256 bNum = 12;
    uint256 bDen = 4;
    uint256 exp = 4;
    uint256 dec = 10;
    prec.mockCall(
      prec.FRACTION_MUL(),
      keccak256(abi.encodePacked(aNum, aDen, bNum, bDen, exp, dec)),
      abi.encodePacked(uint256(100), uint256(12))
    );

    (uint256 rNum, uint256 rDen) = fractionMulExp(aNum, aDen, bNum, bDen, exp, dec);
    assert(rNum == 100);
    assert(rDen == 12);
  }
}