//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import {Harvestable} from "./Harvestable.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";
import {IWarRedeemModule} from "interfaces/IWarRedeemModule.sol";
import {WarMinter} from "src/Minter.sol";

abstract contract WarBaseLocker is IWarLocker, Pausable, Owner, ReentrancyGuard, Harvestable {
  address public delegate;
  address public redeemModule;
  address public controller;
  address public warMinter;
  bool public isShutdown;

  event SetController(address newController);
  event SetRedeemModule(address newRedeemModule);
  event SetDelegate(address newDelegatee);
  event Shutdown();

  constructor(address _controller, address _redeemModule, address _warMinter, address _delegatee) {
    if (_controller == address(0) || _redeemModule == address(0) || _warMinter == address(0)) {
      revert Errors.ZeroAddress();
    }
    warMinter = _warMinter;
    controller = _controller;
    redeemModule = _redeemModule;
    delegate = _delegatee;
  }

  function setController(address _controller) external onlyOwner {
    if (_controller == address(0)) revert Errors.ZeroAddress();
    if (_controller == controller) revert Errors.AlreadySet();
    controller = _controller;

    emit SetController(_controller);
  }

  function setRedeemModule(address _redeemModule) external onlyOwner {
    if (_redeemModule == address(0)) revert Errors.ZeroAddress();
    if (_redeemModule == address(redeemModule)) revert Errors.AlreadySet();
    redeemModule = _redeemModule;

    emit SetRedeemModule(_redeemModule);
  }

  function _setDelegate(address _delegatee) internal virtual;

  function setDelegate(address _delegatee) external onlyOwner {
    delegate = _delegatee;
    _setDelegate(_delegatee);

    emit SetDelegate(_delegatee);
  }

  function _lock(uint256 amount) internal virtual;

  function lock(uint256 amount) external nonReentrant whenNotPaused {
    if (warMinter != msg.sender) revert Errors.CallerNotAllowed();
    if (amount == 0) revert Errors.ZeroValue();
    _lock(amount);
  }

  function _processUnlock() internal virtual;

  function processUnlock() external nonReentrant whenNotPaused {
    _processUnlock();
  }

  function _harvest() internal virtual;

  function harvest() external whenNotPaused {
    _harvest();
  }

  function _migrate(address receiver) internal virtual;

  function migrate(address receiver) external onlyOwner whenPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    _migrate(receiver);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    if (isShutdown) revert Errors.LockerShutdown();
    _unpause();
  }

  function shutdown() external onlyOwner whenPaused {
    isShutdown = true;

    emit Shutdown();
  }
}
