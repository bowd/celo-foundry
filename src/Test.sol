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
}