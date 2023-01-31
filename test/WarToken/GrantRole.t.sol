// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract GrantRole is WarTokenTest {
  function testOnlyAdminCanCall() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
    );
    war.grantRole(BURNER_ROLE, bob);
  }

  function testOtherRolesCantCall() public {
    vm.prank(minter);
    vm.expectRevert(
      "AccessControl: account 0x030f6a4c5baa7350405fa8122cf458070abd1b59 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
    );
    war.grantRole(MINTER_ROLE, alice);

    vm.prank(burner);
    vm.expectRevert(
      "AccessControl: account 0xaefbc8c4b051e5a401b27034c18304ae75411b8f is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
    );
    war.grantRole(BURNER_ROLE, bob);
  }
}
