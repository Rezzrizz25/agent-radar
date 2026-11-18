# Agent ID registry — verification record

Date: 2026-11-18 ~16:45 +08 (Asia/Kuala_Lumpur)
Chain: BNB Smart Chain (chainId 56)

## Result: FOUND and VERIFIED ON-CHAIN

| Item | Value |
|---|---|
| Registry address | `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` |
| Kind | SPACE ID / Binance Agent ID registry — ERC-721, one Agent ID per wallet, non-transferable |
| Rija's Agent ID | `rezzrizz.ai` (handle on-chain: `rezzrizz`, no `.ai` suffix) |
| tokenId | `uint256(keccak256("rezzrizz"))` = `112788715237877097353538825768910494292983489955201987227481223794658637852673` |
| tokenId (hex) | `0xf95c268ae278f5444006a15cf98b5c7f610974cc35f7234c135fd174f8813001` |
| ownerOf(tokenId) — live RPC | `0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A` (Rija's Binance Agentic Wallet) |

## How it was verified (no address was invented)

1. **Cross-source consensus (web search, 2026-11-18).** The same address
   `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` is cited independently by:
   - BAS / Medium — "Binance Agent ID" (contract `0x60B9…022F`, deployment block 127,950,748, Oct 16, 2026; 182,040 IDs claimed by Nov 11)
   - Horror Protocol — "SPACE ID Agent ID holders only `0x60B9…022F`"
   - AlphaPulse presale — "Agent ID registry: `0x60B9…022F`"
   - Foundry Faces — "Confirm I hold an Agent ID (SPACE ID registry `0x60B9…022F`)"
   - BDOG agent brief — "registry = `0x60B9…022F` … `handleOf(wallet)` → non-empty, `ownerOf(keccak256(bytes(handle))) == wallet`"
   - AIBOSS ($BOSS) — same address, same `handleOf` → `keccak256` → `ownerOf` gate
   - RazorAgent whitepaper v1.0 — same address as "Agent ID registrar"
   - Sidecoo / CharmMine — same address, gate `balanceOf(wallet) > 0`
   - fastmint-fcfs-agentic, pearl-miner — same address
   - Unrelated lookalike tokens (e.g. `0x4783…4444` ".AI" tax token, `0xe0e3…022f` 4AGENT) were
     REJECTED: they share only a name/ticker, not the registry role, and no independent
     Agent ID project cites them as the registry.

2. **Live on-chain check (eth_call, bsc-dataseed.binance.org).**
   - `eth_getCode(0x60B9…022F)` → non-empty deployed bytecode (starts `0x60806040…`),
     confirmed on 3 RPC endpoints (bsc-dataseed, bsc-dataseed1, bsc-dataseed1.defibit.io).
   - `eth_call ownerOf(0xf95c268a…8813001)` → `0x0000000000000000000000007917a535d0cb92dc3c16c8d3bcfc4e0f2bdbb91a`.
     That is the owner of Rija's `rezzrizz` Agent ID — it matches the expectation that
     the token belongs to her Binance Agentic Wallet, and the tokenId hex matches the
     value recorded in MEMORY.md (`uint256(keccak256("rezzrizz"))`).

3. **Gate pattern (used by AgentRadar.sol).**
   ```solidity
   string memory handle = registry.handleOf(msg.sender); // "rezzrizz"
   uint256 tokenId = uint256(keccak256(bytes(handle)));
   require(registry.ownerOf(tokenId) == msg.sender);
   ```
   `checkIn(string)` additionally accepts `"rezzrizz.ai"` and strips the `.ai`
   suffix before hashing. `checkInSelf()` resolves the handle on-chain so the
   user does not have to type anything.

## What was NOT verified (honest limits)

- No official Binance docs page publishing the registry address was found in
  search (Binance announces the feature in-app, not via a contract-address doc).
  The address above rests on 9+ independent project sources + live on-chain proof,
  which is the strongest available evidence. If Binance ever rotates the registry,
  the constructor takes the registry address as a parameter — redeploy, do not edit
  a deployed contract.

## UPDATE 2026-11-18 ~16:50 +08 — `handleOf` now verified live too

Via `cast` (Foundry 1.7.1) against `bsc-dataseed.binance.org`:

- `cast call <registry> "handleOf(address)(string)" 0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A`
  → `"rezzrizz"`
- `cast call <registry> "balanceOf(address)(uint256)" 0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A`
  → `1`
- `cast keccak "rezzrizz"` → `0xf95c268ae278f5444006a15cf98b5c7f610974cc35f7234c135fd174f8813001`
  → decimal `112788715237877097353538825768910494292983489955201987227481223794658637852673`
  (exactly the tokenId in MEMORY.md), and `handleOf` selector = `0xc50a1514`.

So the FULL gate is now proven live: `handleOf` = `"rezzrizz"`,
`ownerOf(keccak256("rezzrizz"))` = Rija's wallet, `balanceOf` = 1.

## Seed-mint live re-check (same run, eth_call totalSupply)

| Mint | Contract | Supply at seed | Live 2026-11-18 16:45 |
|---|---|---|---|
| Glyphs of Xor (XOR) | `0x1577cbaa…ab90c` | 309 | 309 |
| Ravenhex (RAVENH) | `0xb4405025…ecece2` | 650 | 655 (+5) |
| Hivebyte (HIVEBYTE) | `0xae9d85e7…cf8d8` | 311 | 319 (+8) |
| Pixel Agent PC (PXPC) | `0x6a6601f2…1910c8` | 657 | 833 (+176) |

Supplies move — the frontend must re-read `totalSupply` live, never trust the seed number.
