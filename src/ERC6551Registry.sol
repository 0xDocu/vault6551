// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Minimal ERC-6551 Registry
 * @dev This contract deploys token bound accounts using CREATE2,
 *      following the pattern in EIP-6551. It can compute and return
 *      the account address for a given (implementation, chainId, tokenContract, tokenId, salt).
 *
 * Note: This minimal example does NOT handle upgrades or advanced logic.
 */
contract ERC6551Registry {
    event AccountCreated(
        address indexed account,
        address indexed implementation,
        uint256 indexed chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    );

    /**
     * @notice Deploys a token bound account for a given token.
     * @param implementation The address of the account implementation.
     * @param chainId The chain ID where the token exists.
     * @param tokenContract The contract address of the token (ERC-721, ERC-1155).
     * @param tokenId The token ID.
     * @param salt Arbitrary salt to create unique addresses.
     * @return the deployed account address.
     */
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external returns (address) {
        // Precompute address via create2
        address account = account(implementation, chainId, tokenContract, tokenId, salt);
        if (_isContract(account)) {
            // Already deployed
            return account;
        }

        bytes32 create2Salt = _getSalt(implementation, chainId, tokenContract, tokenId, salt);

        // encode the 'Account' constructor arguments
        bytes memory code = abi.encodePacked(
            type(ERC6551AccountProxy).creationCode,
            abi.encode(implementation, abi.encode(chainId, tokenContract, tokenId))
        );

        // Deploy via CREATE2
        assembly {
            let deployed := create2(0, add(code, 0x20), mload(code), create2Salt)
            if iszero(deployed) {
                revert(0, 0)
            }
        }

        emit AccountCreated(account, implementation, chainId, tokenContract, tokenId, salt);
        return account;
    }

    /**
     * @notice Computes the create2 address for a token bound account
     */
    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) public view returns (address) {
        bytes32 create2Salt = _getSalt(implementation, chainId, tokenContract, tokenId, salt);
        bytes memory code = abi.encodePacked(
            type(ERC6551AccountProxy).creationCode,
            abi.encode(implementation, abi.encode(chainId, tokenContract, tokenId))
        );

        bytes32 codeHash = keccak256(code);
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            create2Salt,
            codeHash
        )))));
    }

    function _getSalt(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(implementation, chainId, tokenContract, tokenId, salt));
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

/**
 * @dev Proxy used by the registry to deploy. Minimal proxy pattern referencing the 'implementation'
 *      for delegatecall. The constructor arguments are the init data for the actual account logic.
 */
contract ERC6551AccountProxy {
    constructor(address implementation, bytes memory initData) payable {
        // delegatecall the implementation's init (if any)
        (bool ok,) = implementation.delegatecall(
            abi.encodeWithSignature("initialize(bytes)", initData)
        );
        require(ok, "Init failed");
        assembly {
            sstore(0, implementation) // store implementation at storage slot0
        }
    }

    fallback() external payable {
        assembly {
            let impl := sload(0) 
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
