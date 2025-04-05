// createAccount and test
contract CreateAccountAndTest is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // Suppose we have the addresses from the previous step:
        address registryAddr = 0xREGISTRY_ADDRESS;
        address accountImplAddr = 0xACCOUNT_IMPL_ADDRESS;

        // My NFT info
        uint256 chainId = 11155111; // Sepolia, for example
        address nftAddress = 0xMyERC721Address;
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
