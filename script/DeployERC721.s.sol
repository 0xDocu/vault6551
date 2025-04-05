// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../src/MyERC721.sol";

/**
 * Deploy and mint an ERC-721 on Sepolia
 */
contract DeployERC721 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        MyERC721 nft721 = new MyERC721("Vault6551 NFT", "V6551", deployer);
        nft721.mint(deployer, 1);

        console.log("NFT deployed at:", address(nft721));

        vm.stopBroadcast();
    }
}
