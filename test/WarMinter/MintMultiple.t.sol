// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract MintMultiple is WarMinterTest {
	function testMintMultiple(uint256 amount1, uint256 amount2) public {
		vm.assume(amount1 > 0 && amount2 > 0);
		vm.assume(amount1 < cvx.balanceOf(alice) && amount2 < aura.balanceOf(alice));
		address[] memory lockers = new address[](2);
		lockers[0] = address(aura);
		lockers[1] = address(cvx);
		uint256[] memory amounts = new uint256[](2);
		amounts[0] = amount1;
		amounts[1] = amount2;
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), 0);
		vm.prank(alice);
		minter.mintMultiple(lockers, amounts, bob);
    assertEq(war.totalSupply(), amount1 + amount2);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), amount1 + amount2);
	}

	function testCantMintWithDifferentLengths(address[] calldata lockers, uint256[] calldata amounts) public {
		vm.assume(lockers.length != amounts.length);
		vm.prank(alice);
		vm.expectRevert(abi.encodeWithSelector(DifferentSizeArrays.selector, lockers.length, amounts.length));
		minter.mintMultiple(lockers, amounts, bob);
	}

	function testMintWithImplicitReceiver(uint256 amount1, uint256 amount2) public {
		vm.assume(amount1 > 0 && amount2 > 0);
		vm.assume(amount1 < cvx.balanceOf(alice) && amount2 < aura.balanceOf(alice));
		address[] memory lockers = new address[](2);
		lockers[0] = address(aura);
		lockers[1] = address(cvx);
		uint256[] memory amounts = new uint256[](2);
		amounts[0] = amount1;
		amounts[1] = amount2;
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), 0);
		vm.prank(alice);
		minter.mintMultiple(lockers, amounts);
    assertEq(war.totalSupply(), amount1 + amount2);
    assertEq(war.balanceOf(bob), 0);
    assertEq(war.balanceOf(alice), amount1 + amount2);
	}
	// TODO do some token agnostic tests
}