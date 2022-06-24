// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.13;

import "forge-std/Script.sol";
import "Precompiles.sol";
import "contracts/common/GoldToken.sol";

contract PrecompileHelper is Script, Precompiles {
  function run() public {
    console.log("Precompiles Address");
    console.log(address(this));
    string memory transferSig = "transfer(address,address,uint256)";
    bytes4 sig = bytes4(keccak256(abi.encodePacked(transferSig)));
    console.log(transferSig);
    console.logBytes4(sig);

    console.log("transfer ProxyCode");
    bytes memory resp = proxyTo(sig);
    console.logBytes(resp);
    vm.etch(address(0xff - 2), resp);
  }
}
