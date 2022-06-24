object "PrecompileProxy" {
  code {
    let precompilesAddr := 0x9999999999999999999999999999999999999999
    let sig := 0x88888888

    let ptr := 0x0
    let cds := add(calldatasize(), 0x4)
    mstore(ptr, shl(0xe0, sig))
    calldatacopy(add(ptr, 0x4), 0, calldatasize())

    let callSuccess := call(
      gas(),
      precompilesAddr,
      callvalue(),
      ptr,
      cds,
      0,
      0
    )

    let returnDataSize := returndatasize()
    let returnDataPosition := 0x0
    returndatacopy(returnDataPosition, 0, returnDataSize)

    // Revert or return depending on whether or not the call was successful.
    switch callSuccess
      case 0 {
        revert(returnDataPosition, returnDataSize)
      }
      default {
        return(returnDataPosition, returnDataSize)
      }
  }
}
