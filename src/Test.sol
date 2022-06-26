// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.13;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "./Precompiles.sol";
import "./PrecompileHandler.sol";

contract Test is ForgeTest, Precompiles {
    PrecompileHandler public ph;

    constructor() ForgeTest() public {
        ph = new PrecompileHandler();
    }

    function actor(string memory name) public returns (address) {
      uint256 pk = uint256(keccak256(bytes(name)));
      address addr = vm.addr(pk);
      vm.label(addr, name);
      return addr;
    }

    //function deal(address token, address to, uint256 give, bool adjust) public {
    //  (, bytes memory symbolData) = token.call(0x1f1b7586);
    //  if (keccak256(symbolData) == ) {
    //  } else {
    //    super.deal(token, to, give, adjust);
    //  }
    //}
}