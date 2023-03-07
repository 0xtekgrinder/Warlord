// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Migrate is CvxLockerTest {
  address receiver = makeAddr("receiver");

  function setUp() public override {
    CvxLockerTest.setUp();

    _mockMultipleLocks(1e25);

    vm.startPrank(admin);
    locker.pause();
    vm.stopPrank();
  }

  function testDefaultBehavior() public {
    vm.warp(block.timestamp + 1000 days);
    (uint256 cvxCrvRewards, uint256 cvxFxsRewards) = _getRewards();
    uint256 initialLockedBalance = vlCvx.lockedBalanceOf(address(locker));

    vm.prank(admin);
    locker.migrate(receiver);

    // check cvx balance migration to receiver
    assertEq(vlCvx.lockedBalanceOf(address(locker)), 0, "no more vlCvx should be locked");
    assertEq(cvx.balanceOf(receiver), initialLockedBalance, "balance of receiver should be equal to initial vlCvx");

    // all rewards were claimed
    _assertNoPendingRewards();

    assertEq(cvxCrvRewards, cvxCrv.balanceOf(controller), "check accrued rewards to controller for cvxCrv");
    assertEq(cvxFxsRewards, cvxFxs.balanceOf(controller), "check accrued rewards to controller for cvxFxs");
  }
}
