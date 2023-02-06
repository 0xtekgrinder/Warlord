// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IMintRatio} from "interfaces/IMintRatio.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Errors} from "utils/Errors.sol";
import {Owner} from "utils/Owner.sol";

contract WarMintRatio is IMintRatio, Owner {
  uint256 private constant UNIT = 1e18;
  mapping(address => uint256) _maxSupply;

  function addTokenWithSupply(address token, uint256 maxSupply) public onlyOwner {
    if (token == address(0)) revert Errors.ZeroAddress();
    if (maxSupply == 0) revert Errors.ZeroValue();
    uint256 tokenMaxSupply = _maxSupply[token];
    if (tokenMaxSupply != 0) revert Errors.SupplyAlreadySet();
    _maxSupply[token] = maxSupply;
  }

  function getMintAmount(address token, uint256 amount) public view returns (uint256) {
    // TODO tackle overflows
    if (token == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    // TODO should I check if amount is bigger than the maxSupply
    // uint256 totalWarForHundredPercent = 10_000e18;

    // uint256 maxSupply = 100_000_000 * UNIT; // cvx supply
    uint256 maxSupply = _maxSupply[token]; // TODO should I make a specific error for unset mapping or is this already covered by the other check
    uint256 mintRatio = (amount * UNIT) / maxSupply;
    // uint256 mintAmount = (mintRatio * totalWarForHundredPercent)
    return mintRatio;
  }
}
