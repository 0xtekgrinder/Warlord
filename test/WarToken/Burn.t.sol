// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract Burn is WarTokenTest {
  function testBurn() public {
    assertEq(war.balanceOf(bob), 0);
    vm.prank(minter);
    war.mint(bob, 5000);
    assertEq(war.balanceOf(bob), 5000);
    vm.prank(burner);
    war.burn(bob, 2501);
    assertEq(war.balanceOf(bob), 2499);
  }

  function testBurnerGating() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, 100);

    vm.prank(minter);
    war.mint(bob, 100);
    vm.prank(admin);
    war.grantRole(BURNER_ROLE, alice);
    vm.prank(alice);
    war.burn(bob, 100);

    vm.prank(admin);
    war.revokeRole(BURNER_ROLE, alice);
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, 100);
  }

  function testMinterCantBurn() public {
    vm.prank(minter);
    vm.expectRevert(
      "AccessControl: account 0x030f6a4c5baa7350405fa8122cf458070abd1b59 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, 2501);
  }

  function testAdminCantBurn() public {
    vm.prank(admin);
    vm.expectRevert(
      "AccessControl: account 0xaa10a84ce7d9ae517a52c6d5ca153b369af99ecf is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, 2501);
  }

  function testNoRoleCantBurn() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, 2501);
  }
}
