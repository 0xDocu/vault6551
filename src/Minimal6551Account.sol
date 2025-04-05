// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Minimal ERC-6551 Account Implementation
 * @dev This contract is meant to be used behind a proxy. 
 *      "initialize" is called via the proxy's constructor.
 */
contract Minimal6551Account {
    // Chain id of the token
    uint256 public chainId;
    // Token contract address
    address public tokenContract;
    // Token id
    uint256 public tokenId;

    // ============ Events ============
    event ExecutedCall(address to, uint256 value, bytes data);
    event ReceivedETH(address from, uint256 value);

    /**
     * @dev This function is called (delegatecall) by the proxy's constructor
     *      passing the initData = abi.encode(chainId, tokenContract, tokenId).
     */
    function initialize(bytes memory initData) public {
        require(chainId == 0, "Already initialized");

        (uint256 _chainId, address _tokenContract, uint256 _tokenId) 
            = abi.decode(initData, (uint256, address, uint256));

        chainId = _chainId;
        tokenContract = _tokenContract;
        tokenId = _tokenId;
    }

    /**
     * @notice Returns the NFT's current owner from the tokenContract
     * @dev For an ERC-721, it can be `IERC721(tokenContract).ownerOf(tokenId)`.
     */
    function owner() public view returns (address) {
        // We assume tokenContract is ERC721. For a robust approach, handle ERC1155 or other logic.
        (bool success, bytes memory result) = tokenContract.staticcall(
            abi.encodeWithSignature("ownerOf(uint256)", tokenId)
        );
        if (!success || result.length == 0) {
            return address(0);
        }
        return abi.decode(result, (address));
    }

    /**
     * @notice Execute arbitrary call from this contract
     *         Restrict to the current NFT owner, or the contract itself if needed.
     */
    function executeCall(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external payable returns (bytes memory result) {
        // Simple ownership check: msg.sender must be the NFT's current owner
        // Alternatively: add more robust signature-based auth, or session keys, etc.
        require(msg.sender == owner(), "Not NFT owner");

        // low-level call
        (bool ok, bytes memory resp) = _to.call{value: _value}(_data);
        require(ok, "Call failed");

        emit ExecutedCall(_to, _value, _data);
        return resp;
    }

    // fallback to receive ETH
    receive() external payable {
        emit ReceivedETH(msg.sender, msg.value);
    }
}
