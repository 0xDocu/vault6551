// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../src/ERC6551Registry.sol";
import "../src/Minimal6551Account.sol";

contract DeployERC6551 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // 1) 배포: Registry
        ERC6551Registry registry = new ERC6551Registry();
        console.log("Registry:", address(registry));

        // 2) 배포: Minimal6551Account (implementation)
        Minimal6551Account accountImpl = new Minimal6551Account();
        console.log("Account Implementation:", address(accountImpl));

        vm.stopBroadcast();
    }
}