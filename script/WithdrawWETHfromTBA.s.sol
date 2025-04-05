// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";

interface I6551Account {
    function executeCall(address to, uint256 value, bytes calldata data) external payable returns (bytes memory);
}

contract WithdrawWETHFromTBA is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        address tba = vm.envAddress("TBA_ADDR");
        address weth = vm.envAddress("WETH_ADDRESS");
        address recipient = vm.addr(pk); // 내 지갑 주소
        uint256 amount = 0.01 ether;

        bytes memory transferData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            recipient,
            amount
        );

        I6551Account(tba).executeCall(
            weth,
            0,
            transferData
        );

        vm.stopBroadcast();
    }
}
