// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract SetMintRatio is MinterTest {
  function testDefaultBehavior(address _mintRatio) public {
    vm.assume(_mintRatio != zero);
    vm.prank(admin);
    minter.setMintRatio(_mintRatio);
  }

  function testOnlyOwner(address _mintRatio) public {
    vm.prank(bob);
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setMintRatio(_mintRatio);
  }

  function testZeroAddress() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setMintRatio(zero);
  }
}
