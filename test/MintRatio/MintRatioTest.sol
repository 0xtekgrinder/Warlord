// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/MintRatio.sol";

contract MintRatioTest is MainnetTest {
  WarMintRatio mintRatio;

  uint256 constant UNIT = 1e18;
  uint256 constant MAX_WAR_SUPPLY_PER_TOKEN = 10_000 * 1e18;

  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    mintRatio = new WarMintRatio();
    mintRatio.addTokenWithSupply(address(cvx), cvxMaxSupply);
    mintRatio.addTokenWithSupply(address(aura), auraMaxSupply);
  }
}