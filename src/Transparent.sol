// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Slots } from "./SlotManipulate.sol";
import { BasicProxy } from "./BasicProxy.sol";

contract Transparent is Slots, BasicProxy {

  bytes32 internal constant _ONLYADMIN_SLOT = bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1);

  constructor(address _implementation) BasicProxy(_implementation) {
    // set admin address to Admin slot
    _setSlotToAddress(_IMPLEMENTATION_SLOT, _implementation);
    _setSlotToAddress(_ONLYADMIN_SLOT, msg.sender);
  }

  function getAdminAddr() internal view returns(address) {
    return _getSlotToAddress(_ONLYADMIN_SLOT);
  }

  modifier onlyAdmin {
    // finish onlyAdmin modifier
    address addr = getAdminAddr();
    if( addr == msg.sender){
      _;
    } else{
      _fallback();
    }
  }

  function _fallback() internal {
    _delegate(_getSlotToAddress(_IMPLEMENTATION_SLOT));
  }

  function upgradeTo(address _newImpl) public override onlyAdmin {
    // rewriet upgradeTo
    _setSlotToAddress(_IMPLEMENTATION_SLOT, _newImpl);
  }

  function upgradeToAndCall(address _newImpl, bytes memory data) public override onlyAdmin {
    // rewriet upgradeToAndCall
    upgradeTo(_newImpl);
    (bool _ok,) = _newImpl.delegatecall(data);
    require(_ok, "delegatecall failed");
  }

  fallback() external payable override {
    // rewrite fallback
    require(getAdminAddr() != msg.sender, "admin not allow");
    _delegate(_getSlotToAddress(_IMPLEMENTATION_SLOT));
  }
}