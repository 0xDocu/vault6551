// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721 is ERC721, Ownable {
    uint256 public currentTokenId;

    constructor() ERC721("MyERC721", "MYT") {}

    function mintTo(address to) external onlyOwner returns (uint256) {
        currentTokenId++;
        _safeMint(to, currentTokenId);
        return currentTokenId;
    }
}
