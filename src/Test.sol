// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.13;

import {Test as ForgeTest} from "forge-std/Test.sol";
import "./Precompiles.sol";
import "./PrecompileHandler.sol";

contract Test is ForgeTest, Precompiles {
    PrecompileHandler public ph;
    address currentPrank;

    constructor() ForgeTest() public {
        ph = new PrecompileHandler();
    }

    function changePrank(address who) internal {
      currentPrank = who;
      super.changePrank(who);
    }

    function actor(string memory name) public returns (address) {
      uint256 pk = uint256(keccak256(bytes(name)));
      address addr = vm.addr(pk);
      vm.label(addr, name);
      return addr;
    }
}