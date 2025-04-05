// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../src/MyERC721.sol";

/**
 * Deploy and mint an ERC-721 on Sepolia
 */
contract DeployERC721 is Script {
    function run() external {
        // 1) 준비
        uint256 pk = vm.envUint("PRIVATE_KEY");
        string memory rpc = vm.envString("SEPOLIA_RPC_URL");
        vm.createSelectFork(rpc);

        vm.startBroadcast(pk);

        // 2) 배포
        MyERC721 myNft = new MyERC721();
        console.log("MyERC721 deployed at:", address(myNft));

        // 3) NFT 민팅 (owner는 현재 컨트랙트가 됨 → transferOwnership 등)
        //    여기서는 그냥 contract가 ownable. 아래에서 만약 msg.sender==owner 였다면 mint가 가능
        myNft.mintTo(msg.sender);
        console.log("Minted tokenId=1 for EOA:", msg.sender);

        vm.stopBroadcast();
    }
}
