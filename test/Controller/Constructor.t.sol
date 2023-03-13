// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract Constructor is ControllerTest {
  function testDefaultBehavior() public {
    assertEq(controller.war(), address(war), "war token should be assigned correctly");
    assertEq(address(controller.minter()), address(minter), "minter should be assigned correctly");
    assertEq(address(controller.staker()), address(staker), "staker should be assigned correctly");
    assertEq(controller.swapper(), address(swapper), "swapper should be assigned correctly");
    assertEq(
      controller.incentivesClaimer(), address(incentivesClaimer), "incentives claimer should be assigned correctly"
    );
  }

  function testZeroAddressWarToken() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    controller = new Controller(zero, address(minter), address(staker), swapper, incentivesClaimer);
  }

  function testZeroAddressMinter() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    controller = new Controller(address(war), zero, address(staker), swapper, incentivesClaimer);
  }

  function testZeroAddressStaker() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    controller = new Controller(address(war), address(minter), zero, swapper, incentivesClaimer);
  }

  function testZeroAddressSwapper() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    controller = new Controller(address(war), address(minter), address(staker), zero, incentivesClaimer);
  }

  function testZeroAddressIncentivesClaimer() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    controller = new Controller(address(war), address(minter), address(staker), swapper, zero);
  }
}
