// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Proxy } from "./Proxy/Proxy.sol";
import { Slots } from "./SlotManipulate.sol";

contract BasicProxy is Proxy, Slots {

  bytes32 internal constant _IMPLEMENTATION_SLOT = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);

  constructor(address _implementation) {
    _setSlotToAddress(_IMPLEMENTATION_SLOT, _implementation);
  }

  fallback() external payable virtual {
    _delegate(_getSlotToAddress(_IMPLEMENTATION_SLOT));
  }

  receive() external payable {}

  function upgradeTo(address _newImpl) public virtual {
    _setSlotToAddress(_IMPLEMENTATION_SLOT, _newImpl);
  }

  function upgradeToAndCall(address _newImpl, bytes memory data) public virtual {
    upgradeTo(_newImpl);
    (bool _ok,) = _newImpl.delegatecall(data);
    require(_ok, "delegatecall failed");
  }
}