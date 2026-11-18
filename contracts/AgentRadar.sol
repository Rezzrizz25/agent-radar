// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AgentRadar — Agent ID-gated free-mint radar (Binance Agent ID Hackathon)
/// @author Rija (rezzrizz.ai) — built for the Agent ID Hackathon
/// @notice A read-mostly registry + check-in log. It NEVER moves user assets,
///         NEVER requests approvals, NEVER stores a login session, and holds no funds.
///         The only state-changing user action is `checkIn`, a gas-only log that
///         proves an Agent ID holder interacted with the radar. That is the metric
///         the hackathon's Pioneer Award counts: interacting Agent ID addresses
///         and transaction count — all verifiable on-chain from emitted events.
///
/// @dev Agent ID registry (BNB Chain, chainId 56):
///      0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F  (SPACE ID / Binance Agent ID)
///      Verified 2026-11-18 by live eth_call on bsc-dataseed.binance.org:
///        - eth_getCode(registry) returns deployed bytecode (non-empty)
///        - ownerOf(uint256(keccak256("rezzrizz"))) =
///          0x7917a535d0cb92dc3c16c8d3bcfc4e0f2bdbb91a  (Rija's Binance Agentic Wallet)
///      Gate pattern (same as other Agent ID projects — BDOG, AIBOSS, RazorAgent,
///      Sidecoo/CharmMine, Horror Protocol, AlphaPulse):
///        handle = registry.handleOf(wallet)            // e.g. "rezzrizz", no ".ai"
///        tokenId = uint256(keccak256(bytes(handle)))
///        registry.ownerOf(tokenId) == wallet
///      `checkIn(string)` also accepts the ".ai" suffixed form ("rezzrizz.ai")
///      and strips it before hashing, because users type the suffixed name.
///
/// Safety red lines (Binance hackathon rules) — how this contract complies:
///  - No web-based QR-code login: this contract has no login at all. The frontend
///    connects only via the user's own injected wallet (EIP-1193, MetaMask /
///    Binance Wallet extension). It never asks for a pairing/QR code and never
///    stores a session server-side (there is no server).
///  - No bypass of user transaction confirmation: every check-in is a normal
///    user-signed transaction the wallet shows for approval. No skill, relayer,
///    or auto-sign path exists in this repo.
///  - No unauthorized asset transfers: there is no transfer, no approve, no
///    payable function, no withdraw, no delegatecall, no selfdestruct.
///    `receive()`/`fallback()` explicitly revert, so the contract can never
///    hold BNB by accident.
///  - Open source + disclosed owner permissions: source is MIT, to be verified
///    on BscScan at deploy. The ONLY owner powers are curating the radar list
///    (add/update/deactivate a mint entry) and transferring ownership. The
///    owner cannot mint, move, or touch any user's token or BNB.
interface IAgentIdRegistry {
    function ownerOf(uint256 tokenId) external view returns (address);
    function handleOf(address wallet) external view returns (string memory);
    function balanceOf(address wallet) external view returns (uint256);
}

contract AgentRadar {
    // ------------------------------------------------------------------------
    // Errors (custom errors = cheaper than revert strings)
    // ------------------------------------------------------------------------
    error NoAgentId();
    error NotAgentIdOwner();
    error AlreadyCheckedInToday();
    error InvalidAgentName();
    error RegistryCallFailed();
    error InvalidAddress();
    error MintNotFound();
    error EmptyString();
    error NotOwner();
    error ContractHoldsNoFunds();

    // ------------------------------------------------------------------------
    // Events — the Pioneer Award metrics are derived from these on-chain
    // ------------------------------------------------------------------------
    /// @dev One event per Agent ID per day. Indexing tokenId + wallet lets
    ///      anyone count unique interacting Agent IDs and total check-ins.
    event CheckedIn(
        address indexed wallet,
        bytes32 indexed agentTokenId,
        string agentName,
        uint256 indexed day,
        uint256 totalCheckIns
    );
    event MintAdded(uint256 indexed mintId, address indexed mintContract, string name);
    event MintUpdated(uint256 indexed mintId, address indexed mintContract, string name);
    event MintDeactivated(uint256 indexed mintId);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ------------------------------------------------------------------------
    // Types
    // ------------------------------------------------------------------------
    /// @notice One curated radar entry. This is INFORMATION only: the radar
    ///         never calls the mint contract and never mints on a user's behalf.
    ///         A user who wants the NFT mints it themselves, in their own wallet,
    ///         after a fresh preview — exactly as Rija's hourly scan requires.
    struct Mint {
        address mintContract; // the third-party NFT contract (0x... on BSC)
        string name;          // e.g. "Glyphs of Xor"
        string symbol;        // e.g. "XOR"
        uint256 supplyAtSeed; // totalSupply observed when the entry was seeded
        uint256 maxSupply;    // 0 = unknown / not published
        uint256 gasEstimate;  // gas units observed in a read-only sim (not a promise)
        string status;        // "VERIFIED_SIM_ONCHAIN_ONLY" | "LEAD"
        string source;        // where the evidence came from (scan run / memory ref)
        uint64 addedAt;       // block.timestamp when added
        bool active;          // false = delisted (kept for history, hidden by UI)
    }

    // ------------------------------------------------------------------------
    // Immutable config + owner
    // ------------------------------------------------------------------------
    /// @notice Binance / SPACE ID Agent ID registry on BNB Chain mainnet.
    ///         Immutable after deploy. Pass the mock registry address on testnet.
    address public immutable agentIdRegistry;
    address public owner;

    // ------------------------------------------------------------------------
    // State
    // ------------------------------------------------------------------------
    Mint[] private mints;

    uint256 public totalCheckIns; // all check-ins ever (drives tx-count metric)
    uint256 public uniqueAgents; // distinct Agent IDs that ever checked in

    /// @notice agentTokenId => day (UTC day number) => checked in that day
    mapping(bytes32 => mapping(uint256 => bool)) public hasCheckedIn;
    /// @notice agentTokenId => lifetime check-in count
    mapping(bytes32 => uint256) public checkInCountByAgent;
    /// @notice wallet => agentTokenId it checked in with (last one)
    mapping(address => bytes32) public agentIdByWallet;
    /// @notice wallet => lifetime check-in count
    mapping(address => uint256) public totalCheckInsByWallet;
    /// @notice agentTokenId => first check-in timestamp (0 = never)
    mapping(bytes32 => uint256) public firstCheckInAt;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address _agentIdRegistry, address _owner) {
        if (_agentIdRegistry == address(0) || _owner == address(0)) revert InvalidAddress();
        agentIdRegistry = _agentIdRegistry;
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    // The contract must never hold funds. Reject plain BNB transfers.
    receive() external payable {
        revert ContractHoldsNoFunds();
    }

    fallback() external payable {
        revert ContractHoldsNoFunds();
    }

    // ------------------------------------------------------------------------
    // Check-in — the core Agent ID integration (gas-only, no value)
    // ------------------------------------------------------------------------
    /// @notice Check in with an explicit Agent ID name, e.g. "rezzrizz" or
    ///         "rezzrizz.ai". Reverts unless msg.sender owns that Agent ID in
    ///         the registry. One check-in per Agent ID per UTC day.
    function checkIn(string calldata agentName) external {
        (bytes32 tokenId, string memory cleanName) = _verifyOwnedName(msg.sender, agentName);
        _recordCheckIn(msg.sender, tokenId, cleanName);
    }

    /// @notice Check in using the handle the registry already has for
    ///         msg.sender — no typing needed. Same gate, resolved on-chain:
    ///         handleOf(msg.sender) -> keccak256 -> ownerOf == msg.sender.
    ///         If the registry reverts (e.g. wallet has no Agent ID), the
    ///         check-in reverts with RegistryCallFailed / NoAgentId.
    function checkInSelf() external {
        string memory handle;
        try IAgentIdRegistry(agentIdRegistry).handleOf(msg.sender) returns (
            string memory h
        ) {
            handle = h;
        } catch {
            revert RegistryCallFailed();
        }
        if (bytes(handle).length == 0) revert NoAgentId();
        (bytes32 tokenId, string memory cleanName) = _verifyOwnedName(msg.sender, handle);
        _recordCheckIn(msg.sender, tokenId, cleanName);
    }

    /// @dev Shared gate: normalize + validate the name, hash it, and require
    ///      the registry to say msg.sender owns that tokenId.
    function _verifyOwnedName(
        address wallet,
        string memory agentName
    ) internal view returns (bytes32 tokenId, string memory cleanName) {
        cleanName = _stripAiSuffix(agentName);
        if (!_isValidHandle(cleanName)) revert InvalidAgentName();
        tokenId = bytes32(uint256(keccak256(bytes(cleanName))));
        // ownerOf reverts for a tokenId that was never minted (ERC-721).
        // Convert that into our own error so the frontend can explain it.
        try IAgentIdRegistry(agentIdRegistry).ownerOf(uint256(tokenId)) returns (
            address tokenOwner
        ) {
            if (tokenOwner != wallet) revert NotAgentIdOwner();
        } catch {
            revert NotAgentIdOwner();
        }
    }

    function _recordCheckIn(
        address wallet,
        bytes32 tokenId,
        string memory cleanName
    ) internal {
        uint256 day = block.timestamp / 1 days;
        if (hasCheckedIn[tokenId][day]) revert AlreadyCheckedInToday();

        hasCheckedIn[tokenId][day] = true;
        if (checkInCountByAgent[tokenId] == 0) {
            uniqueAgents += 1;
            firstCheckInAt[tokenId] = block.timestamp;
        }
        unchecked {
            checkInCountByAgent[tokenId] += 1;
            totalCheckInsByWallet[wallet] += 1;
            totalCheckIns += 1;
        }
        agentIdByWallet[wallet] = tokenId;

        emit CheckedIn(wallet, tokenId, cleanName, day, totalCheckIns);
    }

    // ------------------------------------------------------------------------
    // Radar curation — owner only, metadata only, no asset powers
    // ------------------------------------------------------------------------
    /// @notice Add a radar entry. Only the owner (Rija) can curate the list.
    ///         Listing is not an endorsement and not a mint: see Mint docs.
    ///         Takes one struct (instead of 8 separate params) to keep the
    ///         function compilable without via-IR and gas-cheap.
    ///         `addedAt`/`active` in the input are ignored and set here.
    function addMint(Mint calldata m) external onlyOwner returns (uint256 mintId) {
        if (m.mintContract == address(0)) revert InvalidAddress();
        if (bytes(m.name).length == 0) revert EmptyString();
        mintId = mints.length;
        Mint memory nm = m;
        nm.addedAt = uint64(block.timestamp);
        nm.active = true;
        mints.push(nm);
        emit MintAdded(mintId, m.mintContract, m.name);
    }

    /// @notice Correct an entry (supply moved, status changed, source added).
    ///         `addedAt` is preserved; `active` is preserved (use
    ///         deactivateMint to delist).
    function updateMint(uint256 mintId, Mint calldata m) external onlyOwner {
        if (mintId >= mints.length) revert MintNotFound();
        if (m.mintContract == address(0)) revert InvalidAddress();
        Mint storage s = mints[mintId];
        s.mintContract = m.mintContract;
        s.name = m.name;
        s.symbol = m.symbol;
        s.supplyAtSeed = m.supplyAtSeed;
        s.maxSupply = m.maxSupply;
        s.gasEstimate = m.gasEstimate;
        s.status = m.status;
        s.source = m.source;
        emit MintUpdated(mintId, m.mintContract, m.name);
    }

    /// @notice Delist an entry (dead / sold out / failed re-check). History kept.
    function deactivateMint(uint256 mintId) external onlyOwner {
        if (mintId >= mints.length) revert MintNotFound();
        mints[mintId].active = false;
        emit MintDeactivated(mintId);
    }

    /// @notice Transfer curation rights. Intended once, to Rija's own wallet
    ///         if the deployer is a different deploy wallet.
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    // ------------------------------------------------------------------------
    // Views
    // ------------------------------------------------------------------------
    function mintCount() external view returns (uint256) {
        return mints.length;
    }

    function getMint(uint256 mintId) external view returns (Mint memory) {
        if (mintId >= mints.length) revert MintNotFound();
        return mints[mintId];
    }

    /// @notice All entries (fine for a small curated list; use getMintRange
    ///         for pagination once the list grows).
    function getMints() external view returns (Mint[] memory) {
        return mints;
    }

    /// @notice Paginated read: entries [start, start+count).
    function getMintRange(
        uint256 start,
        uint256 count
    ) external view returns (Mint[] memory out) {
        if (start >= mints.length) return new Mint[](0);
        uint256 end = start + count;
        if (end > mints.length) end = mints.length;
        out = new Mint[](end - start);
        for (uint256 i = start; i < end; ) {
            out[i - start] = mints[i];
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Has this wallet ever checked in (any day)?
    function hasEverCheckedIn(address wallet) external view returns (bool) {
        return totalCheckInsByWallet[wallet] > 0;
    }

    /// @notice Did this Agent ID check in today? (day = UTC day number)
    function checkedInToday(bytes32 agentTokenId) external view returns (bool) {
        return hasCheckedIn[agentTokenId][block.timestamp / 1 days];
    }

    /// @notice Read-only Agent ID lookup helper for the frontend: returns the
    ///         caller's handle, tokenId, and whether they own it. Reverts
    ///         with NoAgentId when the wallet has no handle registered.
    function resolveAgentId(
        address wallet
    ) external view returns (string memory handle, bytes32 tokenId, bool owns) {
        handle = IAgentIdRegistry(agentIdRegistry).handleOf(wallet);
        if (bytes(handle).length == 0) revert NoAgentId();
        tokenId = bytes32(uint256(keccak256(bytes(handle))));
        owns = IAgentIdRegistry(agentIdRegistry).ownerOf(uint256(tokenId)) == wallet;
    }

    // ------------------------------------------------------------------------
    // Name helpers
    // ------------------------------------------------------------------------
    /// @dev Strip a trailing ".ai" so "rezzrizz.ai" and "rezzrizz" hash alike.
    function _stripAiSuffix(
        string memory name
    ) internal pure returns (string memory) {
        bytes memory b = bytes(name);
        if (b.length > 3) {
            if (b[b.length - 3] == bytes1(".") && b[b.length - 2] == bytes1("a") && b[b.length - 1] == bytes1("i")) {
                bytes memory out = new bytes(b.length - 3);
                for (uint256 i = 0; i < b.length - 3; ) {
                    out[i] = b[i];
                    unchecked {
                        ++i;
                    }
                }
                return string(out);
            }
        }
        return name;
    }

    /// @dev On-chain handles are 3–20 chars, lowercase a–z and digits 0–9.
    function _isValidHandle(string memory name) internal pure returns (bool) {
        bytes memory b = bytes(name);
        if (b.length < 3 || b.length > 20) return false;
        for (uint256 i = 0; i < b.length; ) {
            bytes1 c = b[i];
            bool ok = (c >= bytes1("a") && c <= bytes1("z")) ||
                (c >= bytes1("0") && c <= bytes1("9"));
            if (!ok) return false;
            unchecked {
                ++i;
            }
        }
        return true;
    }
}
