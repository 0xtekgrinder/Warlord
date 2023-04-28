//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import "./IncentivizedLocker.sol";
import {IDelegateRegistry} from "interfaces/external/IDelegateRegistry.sol";
import {AuraLocker} from "interfaces/external/aura/vlAura.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";

contract WarAuraLocker is IncentivizedLocker {
  AuraLocker private constant vlAura = AuraLocker(0x3Fa73f1E5d8A792C80F426fc8F84FBF7Ce9bBCAC);
  IERC20 private constant aura = IERC20(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
  IDelegateRegistry private constant registry = IDelegateRegistry(0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446);

  address public governanceDelegate;

  using SafeERC20 for IERC20;

  event SetGaugeDelegate(address oldDelegate, address newDelegate);

  constructor(address _controller, address _redeemModule, address _warMinter, address _delegatee)
    WarBaseLocker(_controller, _redeemModule, _warMinter, _delegatee)
  {
    // constructor delegating only on snapshoht because on chain delegation requires locking first
    registry.setDelegate("aurafinance.eth", _delegatee);
  }

  function token() external pure returns (address) {
    return address(aura);
  }

  function _lock(uint256 amount) internal override {
    aura.safeTransferFrom(msg.sender, address(this), amount);

    if (aura.allowance(address(this), address(aura)) != 0) aura.safeApprove(address(vlAura), 0);
    aura.safeIncreaseAllowance(address(vlAura), amount);

    vlAura.lock(address(this), amount);
  }

  function _harvest() internal override {
    AuraLocker.EarnedData[] memory rewards = vlAura.claimableRewards(address(this));
    uint256 rewardsLength = rewards.length;

    vlAura.getReward(address(this), false); // TODO check for extras

    for (uint256 i; i < rewardsLength;) {
      IERC20 rewardToken = IERC20(rewards[i].token);
      uint256 rewardBalance = rewardToken.balanceOf(address(this));
      rewardToken.safeTransfer(controller, rewardBalance);

      unchecked {
        ++i;
      }
    }
  }

  function _setDelegate(address _delegatee) internal override {
    registry.setDelegate("aurafinance.eth", _delegatee);
  }

  function setGaugeDelegate(address _delegatee) external onlyOwner {
    (,, uint256 lockedBalance,) = vlAura.lockedBalances(address(this));
    if (lockedBalance == 0) revert Errors.DelegationRequiresLock();

    emit SetGaugeDelegate(governanceDelegate, _delegatee);
    governanceDelegate = _delegatee;

    vlAura.delegate(_delegatee);
  }

  function _processUnlock() internal override {
    _harvest();

    (, uint256 unlockableBalance,,) = vlAura.lockedBalances(address(this));
    if (unlockableBalance == 0) return;

    uint256 withdrawalAmount = IWarRedeemModule(redeemModule).queuedForWithdrawal(address(aura));

    // If unlock == 0 relock everything
    if (withdrawalAmount == 0) {
      vlAura.processExpiredLocks(true);
    } else {
      // otherwise withdraw everything and lock only what's left
      vlAura.processExpiredLocks(false);
      withdrawalAmount = Math.min(unlockableBalance, withdrawalAmount);
      aura.transfer(address(redeemModule), withdrawalAmount);
      IWarRedeemModule(redeemModule).notifyUnlock(address(aura), withdrawalAmount);

      uint256 relock = unlockableBalance - withdrawalAmount;
      if (relock > 0) {
        if (aura.allowance(address(this), address(aura)) != 0) aura.safeApprove(address(vlAura), 0);
        aura.safeIncreaseAllowance(address(vlAura), relock);
        vlAura.lock(address(this), relock);
      }
    }
  }

  function _migrate(address receiver) internal override {
    // TODO #19
    // withdraws unlockable balance to receiver
    vlAura.processExpiredLocks(false);
    uint256 unlockedBalance = aura.balanceOf(address(this));
    aura.transfer(receiver, unlockedBalance);

    // withdraws rewards to controller
    _harvest();
  }

  /**
   * @notice Recover ERC2O tokens in the contract
   * @dev Recover ERC2O tokens in the contract
   * @param _token Address of the ERC2O token
   * @return bool: success
   */
  function recoverERC20(address _token) external onlyOwner returns (bool) {
    if (_token == address(aura)) revert Errors.RecoverForbidden();

    if (_token == address(0)) revert Errors.ZeroAddress();
    uint256 amount = IERC20(_token).balanceOf(address(this));
    if (amount == 0) revert Errors.ZeroValue();

    IERC20(_token).safeTransfer(owner(), amount);

    return true;
  }
}
