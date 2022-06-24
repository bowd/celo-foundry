# Celo Foundry Library • [![tests](https://github.com/bowd/celo-foundry/actions/workflows/tests.yml/badge.svg)](https://github.com/bowd/celo-foundry/actions/workflows/tests.yml)

Celo Foundry Library is a collection of helpful contracts for use with [`forge` and `foundry`](https://github.com/foundry-rs/foundry). It uses `forge`'s cheatcodes to get around the need to implement Celo's custom precompiles internally in `foundry`.

## Install

```bash
forge install bowd/celo-foundry
```

## Precompile support

In order to support precompiles we make use of `vm.etch` which is a Forge cheatcode that allows us to write any code at any specific address. This means that we can deploy arbitrary code to the precompile addresses.
To use this we craft a `precompileProxy` (lib/proxy.yul), this bytecode takes incoming calldata and forwards it to a function on another contract, the `PrecompileHandler`.

Using the above we forward any call to precompiles to a contract, where we can either mimic or mock the precompile results.

### TRANSFER

The most immediate precompile needed in most cases is TRANSFER (0xff - 2) which wraps a balance change in the EVM, this enables writing a ERC20 contract that manages the native token, without a need for wCELO.

This is a precompile we can mimic, by using `vm.deal` to change the underlying native balances.
See [tests](./src/test/Precompiles.t.sol) for examples.

### EPOCH_SIZE

This is implemented as a variable that defaults to 17280, but can be set.
See [tests](./src/test/Precompiles.t.sol) for examples.

### Mocking

For the rest of the precompiles there's a generic mocking setup that allows us to mock the precompile return. For example:

```solidity
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
```

In the example above we're telling the `PrecompileHandler` to mock a call to `GET_VALIDATOR` with arguments `index` and `block.number`, and return a specific validator address.

## Contracts

This library includes a fork of [`forge-std`](github.com/bowd/forge-std) pointing to a branch that's compatible with solidity `0.5.13` to make it work with the current Celo protocol contracts.

It exposes 3 contracts:

- `Precompiles` - contains constants for the precompile addresses
- `PrecompileHandler` - the contract responsible for building and registering the `precompileProxy`s and handling the precompile calls.
- `Test` - extends the `Test` contract from `forge-std` and injects the `PrecompileHandler`

## Using the Library

Usually you just need to use `Test` as the base of your tests:

```solidity
import "celo-foundery/Test.sol";

contract SomeTest is Test {
    // you have access to `ph` as the `PrecompileHandler` in your tests
    // and in the context of the tests all precompiles are deployed
}
```

For more complex usages you can leverage `PrecompileHandler` and `Precompiles` directly.
