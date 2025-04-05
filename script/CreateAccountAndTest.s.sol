// createAccount and test
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../src/ERC6551Registry.sol";

contract CreateAccountAndTest is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // Suppose we have the addresses from the previous step:
        address registryAddr = vm.envAddress("REGISTRY_ADDRESS");
        address accountImplAddr = vm.envAddress("ACCOUNT_IMPL_ADDRESS");

        // My NFT info
        uint256 chainId = 11155111; // Sepolia, for example
        address nftAddress = vm.envAddress("ERC721_ADDRESS");
        uint256 tokenId = 1;
        uint256 salt = 0;

        // registry call
        ERC6551Registry registry = ERC6551Registry(registryAddr);

        address tba = registry.createAccount(
            accountImplAddr,
            chainId,
            nftAddress,
            tokenId,
            salt
        );
        console.log("TBA Address:", tba);

        // Now TBA is deployed. 
        // You can transfer some ETH to TBA, and then call `executeCall` from the NFT owner address.
        
        vm.stopBroadcast();
    }
}
