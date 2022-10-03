// contracts/SoulboundHeart.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

/*
 * We use an ERC721 "NFT" token (vs. a fungible ERC20) to differentiate not just
 * the owner, but the underlying asset. Is this necessary for our gating needs?
 *
 * DECISION: using ERC721 for now; reconsider ERC20, ERC777, ERC1155
 */

/*
 * Thinking we should use the ERC721 base (for compatibility's sake), although
 * for the soulbound tokens we maybe don't need the "batch mint" optimizations?
 *
 * DECISION: using ERC721 for now; reconsider Upgradeable; 721A; && other optimizations
 */

/*
 * We're going to simply block transfers for now. Is that even ideal? What if
 * someone wants to move their token to another account they own?
 *
 * DECISION: blocking all transfers because it's easiest; consider `reclaimable`
 *           e.g. https://github.com/kassandraoftroy/ERC721Soulbound
 */

// TODO - do we save costs by overriding the `approve` and `transfer` functions?
contract SoulboundHeart is ERC721, Ownable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;

  constructor() ERC721("Heart", "HRT") {}

  error SoulboundHeartsCannotBeCollected();
  error SoulboundHeartsCannotBeTraded();
  error SoulboundHeartsCost25DAI();

  function _baseURI() internal pure override returns (string memory) {
    return "heartbeats.bigcomputer.xyz@";
  }

  function issueSoulboundHeart() payable external {
    if (balanceOf(msg.sender) > 0) {
      revert SoulboundHeartsCannotBeCollected();
    }

    // assert msg value is 25 DAI
    // todo - figure out the DAI conversion
    if (msg.value != 25 * 10 ** 18) {
      revert SoulboundHeartsCost25DAI();
    }

    // we are ready to issue! increment counter && mint
    uint256 tokenId = _tokenIds.current();
    _tokenIds.increment();
    _safeMint(msg.sender, tokenId);
  }

  /// @notice disables trading for SoulboundHeart tokens
  function _beforeTokenTransfer(
    address from,
    address,
    uint256
  ) internal virtual override {
      if (from != address(0)) revert SoulboundHeartsCannotBeTraded();
  }
}
