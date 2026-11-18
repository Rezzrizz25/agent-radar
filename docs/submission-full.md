# Full Submission Draft — AgentRadar (Binance Agent ID Hackathon)

> Status: **DRAFT — BELUM SUBMIT.** Deadline: **9 Des 2026 08:00 UTC**.
> Jangan submit sebelum kontrak mainnet live + terverifikasi BscScan dan
> website live. Field bertanda TODO adalah blocker — bukan nilai untuk diisi.

## I. Basic Project Information (sesuai form Binance)

### 1. Project Name
**AgentRadar**

### 2. Project Overview (1–3 kalimat)
AgentRadar is an Agent ID-gated free-mint radar on BNB Chain. Only verified
Binance Agent ID holders can check in on-chain — one check-in per Agent ID
per day — to unlock a curated list of verified free NFT mints, filtering out
paid, scam, and expired mints that flood Agent ID users.

### 3. Project Contract Address(es)
**TODO-DEPLOY** — isi link BscScan setelah deploy mainnet + verifikasi:
`https://bscscan.com/address/<CONTRACT_ADDRESS>#code`
JANGAN isi dari tebakan. Kontrak: `AgentRadar`, Solidity 0.8.38, optimizer
200 runs, MIT, single file (`contracts/AgentRadar.sol`).
Registry yang dipakai kontrak (bukan kontrak project):
`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (SPACE ID / Binance Agent ID).

### 4. Project Website / Product Access Link
**TODO-HOSTING** — isi URL setelah frontend di-host (rencana: GitHub Pages
dari repo public, `https://rezzrizz25.github.io/agent-radar/` — pastikan
nama repo final sebelum menulis URL ini ke form).

### 5. Project Social Media Link (X)
**Project: https://x.com/AgentRadarBNB** — handle **@AgentRadarBNB**,
display name "AgentRadar BNB".
⚠️ **PENDING — akun belum dibuat.** Rija membuat akunnya sendiri di X;
link ini belum live sampai dia konfirmasi.
Bio saat membuat akun: "Agent ID-gated free-mint radar on BNB Chain.
Verified free mints only. Built for Binance Agent ID Hackathon."
**Owner (fallback): https://x.com/rezzrizz25** — akun personal Rija
(Agent ID `rezzrizz.ai`).

## II. Agent ID Usage Description

Agent ID is the gate and the identity of the radar, not a label:
1. Every `checkIn` / `checkInSelf` verifies ownership on-chain:
   `registry.handleOf(msg.sender)` → `keccak256(handle)` →
   `registry.ownerOf(tokenId) == msg.sender`. Without an Agent ID the
   transaction reverts (`NoAgentId` / `NotAgentIdOwner`).
2. One check-in per Agent ID per UTC day — the counted unit is the identity,
   not an anonymous address. `uniqueAgents` and the `CheckedIn` event give
   Pioneer Award metrics anyone can audit on-chain.
3. The radar list is curated from Rija's hourly scan pipeline over 4,942
   JAGENT early-minter wallets; an entry is listed only after a read-only
   mint simulation passes at value 0. The radar never mints on a user's
   behalf and never touches user assets (no transfer/approve/payable/
   withdraw in the contract; `receive()`/`fallback()` revert).
4. Owner powers (disclosed): curate the mint list (add/update/deactivate)
   and transfer ownership only. The owner cannot mint, move, or touch any
   user's token or BNB.

## III. Team & Contact

- Team: Rija — solo. Agent ID: `rezzrizz.ai`
  (wallet `0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A`).
- Project X: https://x.com/AgentRadarBNB (pending creation — see §I.5).
- Owner X: https://x.com/rezzrizz25.
- GitHub repo: **TODO-GITHUB** — `github.com/Rezzrizz25/agent-radar`
  (public, MIT). Repo belum di-push: tidak ada remote, `gh` belum login —
  pembuatan repo + push butuh Rija di browser (lihat §V).

## IV. Why the BNB suffix (name note)

The plain name "AgentRadar" is already used by an unrelated project: an
on-chain trust oracle for the agent economy on Base (vvpro.ai — ERC-8004,
EAS attestations, live on Base Sepolia/Mainnet, verified by web search
2026-11-18). That project is not us and has no relationship with this one.
The `BNB` suffix in `@AgentRadarBNB` / "AgentRadar BNB" exists to avoid
confusion. The on-chain project name stays "AgentRadar" (the hackathon
form asks for the project name, not the X handle).

## V. Blockers before submit (all must clear)

| # | Blocker | Status | Who |
|---|---|---|---|
| 1 | Top-up BNB to ~0.003 (now 0.0015568; deploy+seed ≈ 0.000163, remainder ≈ 0.00139 < 0.0015 floor) | Recommended, not hard-blocking | Rija |
| 2 | Deploy `AgentRadar` mainnet (Remix pack: `docs/remix-deploy.md`) | Not done | Rija (tap approve di wallet) |
| 3 | Verify source on BscScan | Not done | Rija (follows deploy) |
| 4 | Seed 4 mints via `addMint` (supplies live 309/655/319/833 re-checked ~17:00 +08) | Not done | Rija (owner wallet) |
| 5 | Fill `frontend/config.js`, host frontend (GitHub Pages) | Not done | Needs repo (blocker 6) |
| 6 | Create GitHub repo `Rezzrizz25/agent-radar` (public) + push + enable Pages | **Not done — needs Rija in browser.** `gh` CLI not logged in, no remote configured. Local repo is commit-ready (see below). | Rija |
| 7 | **Create X account @AgentRadarBNB** (display "AgentRadar BNB", bio §I.5) | **Not done — Rija creates it herself** | Rija |
| 8 | Submit the Binance form with §§I–II | Blocked on 2–7 | Rija / agent with live links |

Local repo state (2026-11-18 ~17:05 +08): `git init` done, no commits yet
before this session; commit with all source + docs prepared by the
finish-everything run. Push commands once the remote exists:
`git remote add origin https://github.com/Rezzrizz25/agent-radar.git`
then `git push -u origin master`. Enable Pages: repo Settings → Pages →
Source: Deploy from branch, branch `master`, folder `/frontend` (or root
with the frontend copied — decide at hosting time; `frontend/` is
self-contained: `index.html` + `app.js` + `config.js` + `mints.json`).

## VI. Community Promotion draft (2,000 USDC pool, 20 winners)

Post from **@AgentRadarBNB** once the account exists AND the contract is
live (209 chars, under the 280 limit):

> Built AgentRadar: a free-mint radar on BNB Chain gated by Binance Agent ID. Only .ai holders can check in — 1 per Agent ID per day, all on-chain. My Agent ID: rezzrizz.ai
> #BinanceWalletHackathon #AgenticWallet

Then submit the post link via the official campaign survey. Do not post
before the contract is live.
