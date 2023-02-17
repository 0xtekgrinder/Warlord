// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxCrvFarmerTest.sol";

contract Stake is CvxCrvFarmerTest {
  function _stake(address source, uint256 amount) internal {
    uint256 initialTokenBalance = IERC20(source).balanceOf(address(controller));
    //TODO test emits and compare with auraBal

    // Balance amount is non-zero and can't be more than balance
    vm.assume(amount > 0 && amount <= initialTokenBalance);

    // Initial staked amount is 0 in all groups
    assertEq(convexCvxCrvStaker.balanceOf(address(warCvxCrvFarmer)), 0);

    // Initial index is 0
    assertEq(warCvxCrvFarmer.getCurrentIndex(), 0);

    // Initial balance is zero in all reward groups
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvFarmer), 0), 0);
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvFarmer), 1), 0);

    vm.startPrank(controller);
    warCvxCrvFarmer.stake(source, amount);
    vm.stopPrank();

    // Balance gets updated to staked amount
    assertEq(convexCvxCrvStaker.balanceOf(address(warCvxCrvFarmer)), amount);

    // Index increases accordingly
    assertEq(warCvxCrvFarmer.getCurrentIndex(), amount);

    // Amount is deducted accordingly from balance
    assertEq(IERC20(source).balanceOf(address(controller)), initialTokenBalance - amount);

    // Check that everything is staked in the correct rewards group
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvFarmer), 0), amount);
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvFarmer), 1), 0);
  }

  function testDefaultBehaviorCrv(uint256 amount) public {
    _stake(address(crv), amount);
  }

  function testDefaultBehaviorCvxCrv(uint256 amount) public {
    _stake(address(cvxCrv), amount);
  }

  function testWrongSource(address source) public {
    vm.assume(source != address(cvxCrv) && source != address(crv));
    vm.prank(controller);
    vm.expectRevert(Errors.IncorrectToken.selector);
    warCvxCrvFarmer.stake(source, 500);
  }

  function testZeroValue() public {
    vm.startPrank(controller);
    vm.expectRevert(Errors.ZeroValue.selector);
    warCvxCrvFarmer.stake(address(crv), 0);
    vm.expectRevert(Errors.ZeroValue.selector);
    warCvxCrvFarmer.stake(address(cvxCrv), 0);
    vm.stopPrank();
  }

  function testOnlyController() public {
    vm.prank(alice);
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    warCvxCrvFarmer.stake(address(cvx), 0);
  }
}