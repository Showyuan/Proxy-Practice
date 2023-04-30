// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { UUPSProxy } from "../src/UUPSProxy.sol";
import { ClockUUPS } from "../src/UUPSLogic/ClockUUPS.sol";
import { ClockUUPSV2 } from "../src/UUPSLogic/ClockUUPSV2.sol";
import { ClockUUPSV3 } from "../src/UUPSLogic/ClockUUPSV3.sol";

contract UUPSTest is Test {
  
  ClockUUPS public clock;
  ClockUUPSV2 public clockV2;
  ClockUUPSV3 public clockV3;

  UUPSProxy public uupsProxy;
  uint256 public alarm1Time;

  address admin;
  address user1;

  function setUp() public {
    admin = makeAddr("admin");
    user1 = makeAddr("noob");
    clock = new ClockUUPS();
    clockV2 = new ClockUUPSV2();
    clockV3 = new ClockUUPSV3();

    vm.prank(admin);
    // initialize UUPS proxy
    uupsProxy = new UUPSProxy(abi.encodeWithSignature("initialize(uint256)", 123),address(clock));
  }

  function bytes32ToAddress(bytes32 _bytes32) internal pure returns (address) {
    return address(uint160(uint256(_bytes32)));
  }

  function testProxyWorks() public {
    // check Clock functionality is successfully proxied
    vm.prank(admin);
    assertEq(ClockUUPS(address(uupsProxy)).alarm1(),123);
  }

  function testUpgradeToWorks() public {
    // check upgradeTo works aswell
    vm.prank(admin);
    ClockUUPS(address(uupsProxy)).upgradeTo(address(clockV3));
    assertEq(
      bytes32ToAddress(vm.load(address(uupsProxy), (ClockUUPS(address(uupsProxy)).proxiableUUID()))), 
      address(clockV3)
    );
  }

  function testCantUpgrade() public {
    // check upgradeTo should fail if implementation doesn't inherit Proxiable
    vm.expectRevert("Not a Proxiable");

    vm.prank(admin);
    ClockUUPS(address(uupsProxy)).upgradeTo(address(clockV2));
  }
  
  function testCantUpgradeIfLogicDoesntHaveUpgradeFunction() public {
    // check upgradeTo should fail if implementation doesn't implement upgradeTo
    
    vm.startPrank(admin);
    ClockUUPS(address(uupsProxy)).upgradeTo(address(clockV3));
    (bool success, ) = address(uupsProxy).call(abi.encodeWithSignature("upgradeTo(address)", address(clock)));
    assertEq(success, false);
    vm.stopPrank();

  }

}