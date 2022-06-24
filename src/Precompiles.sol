// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.13;

import "forge-std/Vm.sol";
import "forge-std/console2.sol";

contract Precompiles {
  address constant private VM_ADDRESS =
    address(bytes20(uint160(uint256(keccak256('hevm cheat code')))));

  Vm public constant vm = Vm(VM_ADDRESS);

  address public constant TRANSFER = address(0xff - 2);
  address public constant FRACTION_MUL = address(0xff - 3);
  address public constant PROOF_OF_POSSESSION = address(0xff - 4);
  address public constant GET_VALIDATOR = address(0xff - 5);
  address public constant NUMBER_VALIDATORS = address(0xff - 6);
  address public constant EPOCH_SIZE = address(0xff - 7);
  address public constant BLOCK_NUMBER_FROM_HEADER = address(0xff - 8);
  address public constant HASH_HEADER = address(0xff - 9);
  address public constant GET_PARENT_SEAL_BITMAP = address(0xff - 10);
  address public constant GET_VERIFIED_SEAL_BITMAP = address(0xff - 11);

  bytes4 constant TRANSFER_SIG = bytes4(keccak256("transfer(address,address,uint256)"));
  bytes4 constant EPOCH_SIZE_SIG = bytes4(keccak256("epochSize()"));
  bytes4 constant CATCHALL_SIG = bytes4(keccak256("catchAll()"));

  uint256 public epochSize = 17280;
  bool public debug = false;
  mapping(address => mapping(bytes32 => bytes)) mockedCalls;

  constructor() public {
    vm.etch(TRANSFER, proxyTo(TRANSFER_SIG));
    vm.label(TRANSFER, "TRANSFER");
    vm.etch(EPOCH_SIZE, proxyTo(EPOCH_SIZE_SIG));
    vm.label(EPOCH_SIZE, "EPOCH_SIZE");
    vm.etch(FRACTION_MUL, proxyTo(CATCHALL_SIG));
    vm.label(FRACTION_MUL, "FRACTION_MUL");
  }

  function transfer(address from, address to, uint256 amount) public returns (bool) {
    vm.deal(from, from.balance - amount);
    vm.deal(to, to.balance + amount);
    return true;
  }

  function setEpochSize(uint256 epochSize_) public {
    epochSize = epochSize_;
  }

  function setDebug(bool debug_) public {
    debug = debug_;
  }

  function mockCall(address prec, bytes32 callHash, bytes memory returnData) public {
    if (debug) {
      console2.log(prec);
      console2.logBytes32(callHash);
      console2.logBytes(returnData);
    }

    mockedCalls[prec][callHash] = returnData;
  }

  function catchAll() public view {
    bytes memory cd;
    assembly {
      cd := mload(0x40)
      let cds := sub(calldatasize(), 0x4)
      mstore(cd, cds)
      calldatacopy(add(cd, 0x20), 0x4, cds)
      mstore(0x40, add(cd, add(cds, 0x20)))
    }

    bytes32 cdh = keccak256(cd);
    bytes memory returnData = mockedCalls[msg.sender][cdh];

    if (returnData.length == 0) {
      console2.log(msg.sender);
      console2.logBytes(cd);
      console2.logBytes32(cdh);
      revert("unexpected precompile call");
    }

    assembly {
      let rds := mload(returnData)
      return(add(returnData, 0x20), rds)
    }
  }

  function proxyTo(bytes4 sig) internal view returns (bytes memory) {
    address prec = address(this);
    bytes memory ptr;

    assembly {
      ptr := mload(0x40)
      mstore(ptr, 0x60)
      let mc := add(ptr, 0x20)
      let addrPrefix := shl(0xf8, 0x73)
      let addr := shl(0x58, prec)
      let sigPrefix := shl(0x50, 0x63)
      let shiftedSig := shl(0x30, shr(0xe0, sig))
      let suffix := 0x600060043601
      mstore(mc, or(addrPrefix, or(addr, or(sigPrefix, or(shiftedSig, suffix)))))
      mc := add(mc, 0x20)
      mstore(mc, 0x8260e01b82523660006004840137600080828434885af13d6000816000823e82)
      mc := add(mc, 0x20)
      mstore(mc, 0x60008114604a578282f35b8282fd000000000000000000000000000000000000)
      mstore(0x40, add(ptr, 0x80))
    }

    return ptr;
  }
}