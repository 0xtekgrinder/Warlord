// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract Mint is WarTokenTest {
  
  function testMint() public {
    vm.prank(admin);
    war.grantRole(MINTER_ROLE, alice);
    vm.prank(alice);
    war.mint(bob, 100);
    assertEq(war.balanceOf(bob), 100);
  }

  function testMinterGating() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 100);

    vm.prank(admin);
    war.grantRole(MINTER_ROLE, alice);
    vm.prank(alice);
    war.mint(bob, 100);

    vm.prank(admin);
    war.revokeRole(MINTER_ROLE, alice);
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 100);
  }
}