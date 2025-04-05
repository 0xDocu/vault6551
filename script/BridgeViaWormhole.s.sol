// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import {Minimal6551Account} from "../src/Minimal6551Account.sol";

interface IWormholePortal {
    function transferTokens(
        address token,
        uint256 amount,
        uint16 recipientChain,
        bytes32 recipient,
        uint256 fee,
        uint32 nonce
    ) external returns (uint64 sequence);
}

interface I6551Account {
    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory);
}

contract BridgeViaWormhole is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        string memory rpc = vm.envString("SEPOLIA_RPC_URL");
        vm.createSelectFork(rpc);
        vm.startBroadcast(pk);

        // 1) 준비
        address tba = vm.envAddress("TBA_ADDR");
        address wormholePortal = vm.envAddress("WORMHOLE_PORTAL");
        address WETH = vm.envAddress("WETH_ADDRESS");
        uint16 solanaChainId = uint16(vm.envUint("SOLANA_CHAIN_ID"));
        bytes32 solanaRecipient = vm.envBytes32("SOLANA_RECIPIENT_HEX");
        uint256 bridgeAmount = 0.01 ether;

        // 2) 먼저 TBA가 WETH approve(Portal) 해줘야 한다면...
        //    encoding the call data for WETH.approve(...)
        bytes memory approveData = abi.encodeWithSignature(
            "approve(address,uint256)",
            wormholePortal,
            bridgeAmount
        );

        I6551Account(tba).executeCall(
            WETH,
            0,
            approveData
        );

        // 3) 그 다음, Portal.transferTokens(...)
        bytes memory transferData = abi.encodeWithSelector(
            IWormholePortal.transferTokens.selector,
            WETH,
            bridgeAmount,
            solanaChainId,
            solanaRecipient,
            0,   // fee
            0    // nonce
        );

        // TBA -> executeCall
        I6551Account(tba).executeCall(
            wormholePortal,
            0,
            transferData
        );

        vm.stopBroadcast();
    }
}
