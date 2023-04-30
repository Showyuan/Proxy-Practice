// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { Transparent } from "../src/Transparent.sol";
import { Clock } from "../src/Logic/Clock.sol";
import { ClockV2 } from "../src/Logic/ClockV2.sol";

contract TransparentTest is Test {
  
  Clock public clock;
  ClockV2 public clockV2;
  Transparent public transparentProxy;
  uint256 public alarm1Time;

  address admin;
  address user1;

  function setUp() public {
    admin = makeAddr("admin");
    user1 = makeAddr("noobUser");
    clock = new Clock();
    clockV2 = new ClockV2();
    vm.prank(admin);
    transparentProxy = new Transparent(address(clock));
  }

  function testProxyWorks(uint256 _alarm1) public {
    vm.assume(_alarm1 > 0.1 ether);
    
    vm.prank(user1);
    // check Clock functionality is successfully proxied
    Clock(address(transparentProxy)).initialize(_alarm1);
    assertEq(Clock(address(transparentProxy)).alarm1(), _alarm1);
  }

  function testUpgradeToOnlyAdmin(uint256 _alarm1, uint256 _alarm2) public {
    vm.assume(_alarm1 > 0.1 ether);
    vm.assume(_alarm2 > 0.1 ether);

    // check upgradeTo could be called only by admin
    vm.prank(admin);
    transparentProxy.upgradeTo(address(clockV2));
    vm.startPrank(user1);
    ClockV2(address(transparentProxy)).setAlarm1(_alarm1);
    ClockV2(address(transparentProxy)).setAlarm2(_alarm2);
    assertEq(ClockV2(address(transparentProxy)).alarm1(), _alarm1);
    assertEq(ClockV2(address(transparentProxy)).alarm2(), _alarm2);
    vm.stopPrank();
  }

  function testUpgradeToAndCallOnlyAdmin(uint256 _alarm1, uint256 _alarm2) public {
    vm.assume(_alarm1 > 0.1 ether);
    vm.assume(_alarm2 > 0.1 ether);

    // check upgradeToAndCall could be called only by admin
    vm.prank(admin);
    transparentProxy.upgradeToAndCall(address(clockV2), abi.encodeWithSignature("initialize(uint256)", _alarm1));
    vm.startPrank(user1);
    ClockV2(address(transparentProxy)).setAlarm2(_alarm2);
    assertEq(ClockV2(address(transparentProxy)).alarm1(), _alarm1);
    assertEq(ClockV2(address(transparentProxy)).alarm2(), _alarm2);
    vm.stopPrank();
  }

  function testFallbackShouldRevertIfSenderIsAdmin(uint256 _alarm1) public {
    vm.assume(_alarm1 > 0.1 ether);

    // check admin shouldn't trigger fallback
    vm.prank(admin);
    transparentProxy.upgradeTo(address(clockV2));
    ClockV2(address(transparentProxy)).setAlarm1(_alarm1);
  }

  function testFallbackShouldSuccessIfSenderIsntAdmin(uint256 _alarm1) public {
    // check admin shouldn't trigger fallback
    vm.assume(_alarm1 > 0.1 ether);

    // check admin shouldn't trigger fallback
    vm.prank(admin);
    transparentProxy.upgradeTo(address(clockV2));
    vm.prank(user1);
    ClockV2(address(transparentProxy)).setAlarm1(_alarm1);
  }
}