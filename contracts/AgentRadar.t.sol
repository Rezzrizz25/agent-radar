// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/AgentRadar.sol";
import "../contracts/MockAgentIdRegistry.sol";

contract AgentRadarTest is Test {
    MockAgentIdRegistry registry;
    AgentRadar radar;
    address owner = address(0xBEEF);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        registry = new MockAgentIdRegistry();
        registry.register(alice, "alice");
        registry.register(bob, "bob");
        vm.prank(owner);
        radar = new AgentRadar(address(registry), owner);
    }

    function testCheckInByName() public {
        vm.prank(alice);
        radar.checkIn("alice");
        assertEq(radar.totalCheckIns(), 1);
        assertEq(radar.uniqueAgents(), 1);
        bytes32 id = bytes32(uint256(keccak256(bytes("alice"))));
        assertTrue(radar.hasCheckedIn(id, block.timestamp / 1 days));
    }

    function testCheckInAcceptsAiSuffix() public {
        vm.prank(alice);
        radar.checkIn("alice.ai");
        assertEq(radar.totalCheckIns(), 1);
    }

    function testCheckInSelfResolvesHandle() public {
        vm.prank(bob);
        radar.checkInSelf();
        assertEq(radar.totalCheckIns(), 1);
        assertEq(radar.uniqueAgents(), 1);
    }

    function testCheckInRevertsForNonOwner() public {
        vm.prank(bob);
        vm.expectRevert(AgentRadar.NotAgentIdOwner.selector);
        radar.checkIn("alice");
    }

    function testCheckInRevertsForUnknownName() public {
        vm.prank(alice);
        vm.expectRevert(AgentRadar.NotAgentIdOwner.selector);
        radar.checkIn("nobody");
    }

    function testCheckInRevertsForInvalidName() public {
        vm.prank(alice);
        vm.expectRevert(AgentRadar.InvalidAgentName.selector);
        radar.checkIn("ALICE"); // uppercase is not a valid on-chain handle
        vm.expectRevert(AgentRadar.InvalidAgentName.selector);
        radar.checkIn("ab"); // too short
    }

    function testOneCheckInPerDay() public {
        vm.prank(alice);
        radar.checkIn("alice");
        vm.prank(alice);
        vm.expectRevert(AgentRadar.AlreadyCheckedInToday.selector);
        radar.checkIn("alice");
        // Next day works again.
        vm.warp(block.timestamp + 1 days);
        vm.prank(alice);
        radar.checkIn("alice");
        assertEq(radar.totalCheckIns(), 2);
        assertEq(radar.uniqueAgents(), 1); // same Agent ID, not a new unique
    }

    function testAddMintOnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert(AgentRadar.NotOwner.selector);
        radar.addMint(
            AgentRadar.Mint({
                mintContract: address(0x1234),
                name: "X",
                symbol: "X",
                supplyAtSeed: 0,
                maxSupply: 0,
                gasEstimate: 0,
                status: "LEAD",
                source: "test",
                addedAt: 0,
                active: false
            })
        );
        vm.prank(owner);
        uint256 id = radar.addMint(
            AgentRadar.Mint({
                mintContract: address(0x1234),
                name: "Glyphs of Xor",
                symbol: "XOR",
                supplyAtSeed: 309,
                maxSupply: 0,
                gasEstimate: 110858,
                status: "VERIFIED_SIM_ONCHAIN_ONLY",
                source: "test",
                addedAt: 0,
                active: false
            })
        );
        assertEq(id, 0);
        assertEq(radar.mintCount(), 1);
        AgentRadar.Mint memory m = radar.getMint(0);
        assertEq(m.name, "Glyphs of Xor");
        assertTrue(m.active);
    }

    function testUpdateAndDeactivateMint() public {
        vm.prank(owner);
        radar.addMint(
            AgentRadar.Mint({
                mintContract: address(0x1234),
                name: "X",
                symbol: "X",
                supplyAtSeed: 1,
                maxSupply: 0,
                gasEstimate: 0,
                status: "LEAD",
                source: "test",
                addedAt: 0,
                active: false
            })
        );
        vm.prank(owner);
        radar.updateMint(
            0,
            AgentRadar.Mint({
                mintContract: address(0x1234),
                name: "X",
                symbol: "X",
                supplyAtSeed: 2,
                maxSupply: 0,
                gasEstimate: 0,
                status: "VERIFIED_SIM_ONCHAIN_ONLY",
                source: "test",
                addedAt: 0,
                active: false
            })
        );
        assertEq(radar.getMint(0).supplyAtSeed, 2);
        vm.prank(owner);
        radar.deactivateMint(0);
        assertFalse(radar.getMint(0).active);
    }

    function testGetMintRangePagination() public {
        vm.startPrank(owner);
        radar.addMint(_mint(address(0x1), "A"));
        radar.addMint(_mint(address(0x2), "B"));
        radar.addMint(_mint(address(0x3), "C"));
        vm.stopPrank();
        AgentRadar.Mint[] memory page = radar.getMintRange(1, 2);
        assertEq(page.length, 2);
        assertEq(page[0].name, "B");
        assertEq(page[1].name, "C");
    }

    function testContractRejectsBnb() public {
        vm.deal(address(this), 1 ether);
        (bool ok, ) = address(radar).call{value: 1 ether}("");
        assertFalse(ok); // receive() reverts — the contract can never hold funds
    }

    function testResolveAgentId() public view {
        (string memory handle, bytes32 tokenId, bool owns) = radar.resolveAgentId(alice);
        assertEq(handle, "alice");
        assertEq(tokenId, bytes32(uint256(keccak256(bytes("alice")))));
        assertTrue(owns);
    }

    function _mint(address c, string memory n) internal pure returns (AgentRadar.Mint memory) {
        return
            AgentRadar.Mint({
                mintContract: c,
                name: n,
                symbol: n,
                supplyAtSeed: 0,
                maxSupply: 0,
                gasEstimate: 0,
                status: "LEAD",
                source: "t",
                addedAt: 0,
                active: false
            });
    }
}
