# E2E Report — AgentRadar (local chain, chainId 97)

Date: 2026-11-18 ~16:55–17:05 +08. Runner: Foundry 1.7.1 (`~/.foundry/bin`).
Chain: **Anvil local, chainId 97** (same chainId as BSC testnet — but this is a
LOCAL chain, not BSC testnet itself; see §4 for the honest distinction).

## 1. Unit tests (re-verified)

`forge test -vv` — **12/12 PASS, 0 failed** (identical to the first build run).
Gas: checkIn ~184k, addMint first ~253k, checkInSelf ~185k.

## 2. Local E2E — deploy + full user flow

| # | Step | Result |
|---|---|---|
| 1 | Deploy `MockAgentIdRegistry` (Anvil acct 0, well-known test key — local test ETH only) | ✅ `0x5FbDB2315678afecb367f032d93F642f64180aa3`, tx `0x2961d9…f137` |
| 2 | `register(0xf39F…, "testagent")` on mock | ✅ status 1, tx `0x52e4f7…04a0` |
| 3 | `handleOf(0xf39F…)` | ✅ `"testagent"` |
| 4 | Deploy `AgentRadar` (registry=mock, owner=0xf39F…) | ✅ `0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0`, gas used **2,111,975**, tx `0xe5cfbc…cc7c7` |
| 5 | `checkIn("testagent")` | ✅ status 1, gas **190,121**, tx `0xcd65b5…706c0`, event `CheckedIn` emitted (agent `testagent`, day `0x5127`) |
| 6 | `totalCheckIns()` / `uniqueAgents()` | ✅ **1 / 1** |
| 7 | `checkIn("testagent")` again, same day | ✅ reverts `AlreadyCheckedInToday` (0xd3d38ea7) |
| 8 | BOB `checkIn("testagent")` (non-owner) | ✅ reverts `NotAgentIdOwner` (0x8a93ed81) |
| 9 | BOB `checkInSelf()` (no handle) | ✅ reverts `NoAgentId` (0xf947691f) |
| 10 | Send 0.01 ETH to contract | ✅ reverts `ContractHoldsNoFunds` (0xc1c07929) |
| 11 | `resolveAgentId(ALICE)` | ✅ `("testagent", 0xb898f9…ef48, true)` |
| 12 | `addMint` ×4 (seeds, supplies 309/655/319/833) | ✅ status 1 each; gas 236,046 / 218,922 / 238,870 / 238,894 (avg ~233k) |
| 13 | `mintCount()` | ✅ **4** |
| 14 | `getMint(0)` | ✅ `(0x1577…ab90c, "Glyphs of Xor", "XOR", 309, 0, 110858, "VERIFIED_SIM_ONCHAIN_ONLY", "seed", …, true)` |
| 15 | `getMintRange(1,2)` | ✅ Ravenhex + Hivebyte returned with correct names/supplies |
| 16 | BOB `addMint` (non-owner) | ✅ reverts `NotOwner` (0x30cd7471) |

**E2E verdict: 16/16 PASS.** No contract bug found. (One earlier `getMint`
call failed only because the cast CLI return-type syntax was wrong, not the
contract — retried with the correct tuple syntax, it returned the entry.)

## 3. Measured gas — mainnet (live, read-only, no tx sent)

- BSC gas price live: **0.05 gwei** (50,000,000 wei, `bsc-dataseed.binance.org`).
- `eth_estimateGas` deploy `AgentRadar` from Rija wallet
  `0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A` on BSC mainnet: **2,129,904 gas**
  (Anvil measured 2,111,975 — consistent, +0.85%).
- Deploy cost at 0.05 gwei: **0.0001065 BNB** (was estimated 0.00004–0.000075
  in the first build — that was too low; this is the corrected, measured number).
- 4× `addMint` ≈ 932,732 gas ≈ **0.0000466 BNB**; 1× `checkIn` test ≈ 190,121
  gas ≈ **0.0000095 BNB**.
- **Total deploy + seed + 1 check-in ≈ 0.000163 BNB.**
- Rija BNB balance (live, re-checked): **0.001556803414729652**.
- Remainder after deploy+seed+test: **≈ 0.001394 BNB — BELOW her 0.0015 floor.**
  Deploy fits, but it breaches the floor. Recommendation: top up ~0.0015 BNB
  first (to ~0.003 total) so the post-deploy balance stays ≈ 0.00284 BNB.
  Do NOT deploy on a gas spike — re-check `eth_gasPrice` + estimate first.

## 4. What this E2E is — and is NOT

- It IS a full deploy + user-flow test on a local chain with chainId 97 and
  the mock registry — the exact flow `docs/deploy.md` §1 prescribes, minus
  the public testnet.
- It is NOT a deploy on BSC testnet 97 itself. A real testnet deploy needs
  tBNB in a test wallet (public faucet, browser interaction) — no tBNB wallet
  exists here, and no faucet call was made. If Rija wants a literal testnet
  deploy, the blocker is: fund a throwaway test wallet with tBNB via
  https://testnet.bnbchain.org/faucet-smart (browser), then run the same
  steps with the testnet RPC. The contract logic is already proven by this
  local E2E + the 12 Foundry tests; a testnet deploy would only re-prove
  plumbing, not logic.

## 5. Live mainnet re-checks (same session)

- `totalSupply` re-read live: XOR **309**, Ravenhex **655**, Hivebyte **319**,
  PXPC **833** — identical to the 16:45 seed values, no movement. Seed data
  is fresh as of this report.
- Registry `handleOf(0x7917…B91A)` = `"rezzrizz"` (already verified 16:45–16:50,
  not re-run here — unchanged on-chain fact).

## 6. Artifacts from this run

- Anvil log + tx list: `/tmp/agent-radar-e2e/anvil.log`,
  `/tmp/agent-radar-e2e/e2e.log` (ephemeral; this file is the durable record).
- Deploy pack (tap-by-tap for Rija): `docs/remix-deploy.md`.
- Full submission draft: `docs/submission-full.md`.
