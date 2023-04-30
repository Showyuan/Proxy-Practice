// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract Proxiable {

  function proxiableUUID() public pure returns (bytes32) {
    return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
  }

  function updateCodeAddress(address newAddress) internal {
    // TODO: check if target address has proxiableUUID
    // update code address
    
    /*
      檢查新的 Logic 合約，如果沒有繼承 Proxiable 則會 revert
      改寫存在 keccak256("PROXIABLE") slot 的地址
    */

    (bool _ok, bytes memory data)  = newAddress.call(abi.encodeWithSignature("proxiableUUID()"));

    require(_ok, "Not a Proxiable");
    require(bytes32(data) == proxiableUUID() , "Not correct");

    _setSlotToAddress(bytes32(uint256(keccak256("PROXIABLE"))), newAddress);
  }

  function _setSlotToAddress(bytes32 _slot, address value) internal {
    assembly {
      sstore(_slot, value)
    }
  }
}