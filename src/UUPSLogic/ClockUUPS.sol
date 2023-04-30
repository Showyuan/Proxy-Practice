// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Slots } from "../SlotManipulate.sol";
import { Clock } from "../Logic/Clock.sol";
import { Proxiable } from "../Proxy/Proxiable.sol";

contract ClockUUPS is Clock, Proxiable{

  function upgradeTo(address _newImpl) public {
    // TODO: upgrade to new implementation
    updateCodeAddress(_newImpl);
  }

  function upgradeToAndCall(address _newImpl, bytes memory data) public {
    // TODO: upgrade to new implementation and call initialize
    upgradeTo(_newImpl );
    (bool _ok,) = _newImpl.delegatecall(data);
    require(_ok, "delegatecall failed");
  }
}