// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AgentRadar.sol";

/// @notice Testnet-only mock of the SPACE ID Agent ID registry.
///         NEVER deploy this on mainnet — mainnet uses the real registry
///         0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F.
///         Purpose: BSC testnet has no Agent ID registry, so local/testnet
///         runs of AgentRadar need a stand-in with the same interface.
///         `register` is open on purpose (test only); it lets a test wallet
///         claim any handle. That is exactly why it must never be the
///         registry address passed to AgentRadar on mainnet.
contract MockAgentIdRegistry is IAgentIdRegistry {
    mapping(uint256 => address) public owners;
    mapping(address => string) public handles;

    function register(address wallet, string calldata handle) external {
        handles[wallet] = handle;
        owners[uint256(keccak256(bytes(handle)))] = wallet;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address o = owners[tokenId];
        require(o != address(0), "ERC721: invalid token ID");
        return o;
    }

    function handleOf(address wallet) external view returns (string memory) {
        return handles[wallet];
    }

    function balanceOf(address wallet) external view returns (uint256) {
        return bytes(handles[wallet]).length == 0 ? 0 : 1;
    }
}
