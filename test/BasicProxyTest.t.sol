// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { Clock } from "../src/Logic/Clock.sol";
import { ClockV2 } from "../src/Logic/ClockV2.sol";
import { BasicProxy } from "../src/BasicProxy.sol";

contract BasicProxyTest is Test {

  Clock public clock;
  ClockV2 public clockV2;
  BasicProxy public basicProxy;
  uint256 public alarm1Time;
  address user = address(1);

  function setUp() public {
    clock = new Clock();
    clockV2 = new ClockV2();
    basicProxy = new BasicProxy(address(clock));
  }

  function testProxyWorks() public {
    // check Clock functionality is successfully proxied
    assertEq(Clock(address(basicProxy)).initialized(), false);
  }

  function testInitialize() public {
    // check initialize works
    Clock(address(basicProxy)).initialize(123);
    assertEq(Clock(address(basicProxy)).alarm1(), 123);
    assertEq(Clock(address(basicProxy)).initialized(), true);
  }

  function testUpgrade() public {

    // check Clock functionality is successfully proxied
    // upgrade Logic contract to ClockV2
    // check state hadn't been changed
    // check new functionality is available

    basicProxy.upgradeTo(address(clockV2));
    ClockV2(address(basicProxy)).setAlarm2(111);
    assertEq(ClockV2(address(basicProxy)).alarm2(), 111);
  }

  function testUpgradeAndCall() public {
    // TODO: calling initialize right after upgrade
    // check state had been changed according to initialize
    basicProxy.upgradeToAndCall(address(clockV2), abi.encodeWithSignature("initialize(uint256)", 100));
    assertEq(ClockV2(address(basicProxy)).alarm1(),100);
  }

  function testChangeOwnerWontCollision() public {
    // TODO: call changeOwner to update owner
    // check Clock functionality is successfully proxied
    basicProxy.upgradeToAndCall(address(clockV2), abi.encodeWithSignature("changeOwner(address)", user));
    assertEq(ClockV2(address(basicProxy)).owner(),user); 
  }
}