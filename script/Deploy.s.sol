// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "forge-std/Script.sol";
import "test/MainnetTest.sol";

// Token
import {WarToken} from "src/Token.sol";

// Lockers
import {WarAuraLocker} from "src/AuraLocker.sol";
import {WarCvxLocker} from "src/CvxLocker.sol";

// Farmers
import {WarAuraBalFarmer} from "src/AuraBalFarmer.sol";
import {WarCvxCrvFarmer} from "src/CvxCrvFarmer.sol";

// Enter/Exit
import {WarMinter} from "src/Minter.sol";
import {Redeemer} from "src/Redeemer.sol";

// Infrastructure
import {Controller} from "src/Controller.sol";
import {HolyPaladinDistributor} from "src/Distributor.sol";
import {WarRatios} from "src/Ratios.sol";
import {WarStaker} from "src/Staker.sol";

contract Deployment is Script, MainnetTest {
  // Delegation
  address auraDelegate = makeAddr("auraDelegate");
  address cvxDelegate = makeAddr("cvxDelegate");

  // Fees
  address redemptionFeeReceiver = makeAddr("redemptionFeeReceiver");
  address protocolFeeReceiver = makeAddr("protocolFeeReceiver");

  // Multisig/Protocol's admins
  address swapper = makeAddr("swapper");
  address incentivesClaimer = makeAddr("incentivesClaimer");
  address distributionManager = makeAddr("distributionManager");

  // Initial values
  uint256 constant REDEMPTION_FEE = 500;

  // Token
  WarToken war;

  // Lockers
  WarAuraLocker auraLocker;
  WarCvxLocker cvxLocker;

  // Farmers
  WarAuraBalFarmer auraBalFarmer;
  WarCvxCrvFarmer cvxCrvFarmer;

  // Enter/Exit
  WarMinter minter;
  Redeemer redeemer;

  // Infrastracture
  Controller controller;
  HolyPaladinDistributor distributor;
  WarRatios ratios;
  WarStaker staker;

  function run() public {
    // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(0x218A6903Fc15f71e06263b8e3C4638d927c02227);

    // Deploy the whole protocol
    war = new WarToken();
    ratios = new WarRatios();
    minter = new WarMinter(address(war), address(ratios));
    redeemer = new Redeemer(address(war), address(ratios), redemptionFeeReceiver, REDEMPTION_FEE);
    staker = new WarStaker(address(war));
    controller =
      new Controller(address(war), address(minter), address(staker), swapper, incentivesClaimer, protocolFeeReceiver);
    auraLocker = new WarAuraLocker(address(controller), address(redeemer), address(minter), auraDelegate);
    cvxLocker = new WarCvxLocker(address(controller), address(redeemer), address(minter), cvxDelegate);

    // CVX mint config
    minter.setLocker(address(cvx), address(cvxLocker));
    ratios.addTokenWithSupply(address(cvx), CVX_MAX_SUPPLY);

    // AURA mint config
    minter.setLocker(address(aura), address(auraLocker));
    ratios.addTokenWithSupply(address(aura), AURA_MAX_SUPPLY);

    auraBalFarmer = new WarAuraBalFarmer(address(controller), address(staker));
    cvxCrvFarmer = new WarCvxCrvFarmer(address(controller), address(staker));

    // Controller config
    controller.setLocker(address(aura), address(auraLocker));
    controller.setLocker(address(cvx), address(cvxLocker));

    controller.setFarmer(address(auraBal), address(auraLocker));
    controller.setFarmer(address(cvxCrv), address(cvxLocker));

    // Redeemer config
    redeemer.setLocker(address(aura), address(auraLocker));
    redeemer.setLocker(address(cvx), address(cvxLocker));

    // Staker config
    staker.setRewardFarmer(address(cvxCrv), address(cvxCrvFarmer));
    staker.setRewardFarmer(address(auraBal), address(auraBalFarmer));

    staker.addRewardDepositor(address(controller));
    staker.addRewardDepositor(swapper);

    vm.stopBroadcast();
  }
}
