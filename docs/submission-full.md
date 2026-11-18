# Full Submission Draft — AgentRadar (Binance Agent ID Hackathon)

> Status: **SUBMITTED 2026-11-18 ~19:13 +08** ("Submitted Successfully", no
> reference number). Deadline: **9 Des 2026 08:00 UTC**.
> UPDATE 2026-11-18 ~17:56 +08: kontrak SUDAH LIVE + 4 mint ter-seed.
> UPDATE 2026-11-18 ~18:18 +08: BscScan source **VERIFIED** ("Pass - Verified"
> via Etherscan API V2, guid sy6j9vaj8iqied5j7v369n4mrapiqh89q1yb2uqkszpgctshwa).
> Jangan submit sebelum website live. Field bertanda TODO adalah blocker —
> bukan nilai untuk diisi.

## I. Basic Project Information (sesuai form Binance)

### 1. Project Name
**AgentRadar**

### 2. Project Overview (1–3 kalimat)
AgentRadar is an Agent ID-gated free-mint radar on BNB Chain. Only verified
Binance Agent ID holders can check in on-chain — one check-in per Agent ID
per day — to unlock a curated list of verified free NFT mints, filtering out
paid, scam, and expired mints that flood Agent ID users.

### 3. Project Contract Address(es)
**LIVE — deployed 2026-11-18 ~17:54 +08** via Arachnid CREATE2 factory
(`0x4e59b44847b379578588920cA78FbF26c0B4956C`, salt `keccak256("AgentRadar-v1")`):
`https://bscscan.com/address/0x7113970Eb80b0a2b55821236e35a24EA2BC736B1#code`
Deploy tx: `0xd28685f35440c162ff2dafc22f869f9aa21570927edb124018e76b6988a48f87`
(status 0x1, gas 2,115,130). Verified on-chain: owner = Rija's wallet,
`mintCount()` = 4 (seeded 17:56 +08). Kontrak: `AgentRadar`, Solidity 0.8.38,
optimizer 200 runs, MIT, single file (`contracts/AgentRadar.sol`).
BscScan source verification: **VERIFIED 2026-11-18 ~18:18 +08** — "Pass -
Verified" via Etherscan API V2 (guid
sy6j9vaj8iqied5j7v369n4mrapiqh89q1yb2uqkszpgctshwa), dikonfirmasi ulang lewat
`getsourcecode` (source lengkap, EVM osaka).
Registry yang dipakai kontrak (bukan kontrak project):
`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (SPACE ID / Binance Agent ID).

### 4. Project Website / Product Access Link
**https://rezzrizz25.github.io/agent-radar/** — GitHub Pages dari repo
public `Rezzrizz25/agent-radar`, folder `/frontend`. Aktif setelah repo
dibuat + Pages di-enable; cek live sebelum submit.

### 5. Project Social Media Link (X)
**Project: https://x.com/AgentRadarBNB** — handle **@AgentRadarBNB**,
display name "AgentRadar BNB".
✅ **LIVE — dibuat Rija, terverifikasi 2026-11-18 ~17:03 +08** (joined Nov
2026). Logo + banner terpasang ~17:06 +08 (file di `assets/`).
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
- Project X: https://x.com/AgentRadarBNB (LIVE since 2026-11-18 ~17:03 +08, see §I.5).
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
| 1 | Top-up BNB to ~0.003 | ✅ DONE — two top-ups landed; BNB 0.0056856 after deploy+seed, above floor | Rija |
| 2 | Deploy `AgentRadar` mainnet (factory path: `docs/factory-deploy.md`; Remix abandoned — copy-paste stuck) | ✅ DONE 17:54 +08 — `0x7113970Eb80b0a2b55821236e35a24EA2BC736B1`, tx `0xd28685f3…48f87` | Rija (tapped execute) |
| 3 | Verify source on BscScan (solc 0.8.38, optimizer Yes 200 runs) | ⏳ IN PROGRESS (main agent) | Agent |
| 4 | Seed 4 mints via `addMint` (XOR 309, RAVENH 655, HIVEBYTE 319, PXPC 833) | ✅ DONE 17:56 +08 — 4/4 success, mintCount = 4, ~0.0000662 BNB total | Rija (tapped execute) |
| 5 | Fill `frontend/config.js`, host frontend (GitHub Pages) | `config.js` ✅ DONE (live contract address set 18:01 +08); hosting still blocked on repo (blocker 6) | Needs repo (blocker 6) |
| 6 | Create GitHub repo `Rezzrizz25/agent-radar` (public) + push + enable Pages | **Not done — needs Rija in browser.** `gh` CLI not logged in, no remote configured. Local commit `196da21` ready (see below). | Rija |
| 7 | **Create X account @AgentRadarBNB** (display "AgentRadar BNB", bio §I.5) | ✅ DONE — live since ~17:03 +08, logo + banner installed ~17:06 | Rija |
| 8 | Submit the Binance form with §§I–II | Blocked on 2–7 | Rija / agent with live links |

Local repo state (2026-11-18 ~18:01 +08): local commit `196da21` exists
(all source + docs); contract address in `frontend/config.js` now points at
the live contract. Push commands once the remote exists:
`git remote add origin https://github.com/Rezzrizz25/agent-radar.git`
then `git push -u origin master`. Enable Pages: repo Settings → Pages →
Source: Deploy from branch, branch `master`, folder `/frontend` (or root
with the frontend copied — decide at hosting time; `frontend/` is
self-contained: `index.html` + `app.js` + `config.js` + `mints.json`).

## VI. Community Promotion draft (2,000 USDC pool, 20 winners)

Post from **@AgentRadarBNB** — account AND contract are both live now.
X login for @AgentRadarBNB was temporarily limited on 2026-11-18 ~19:23,
so post from the X app on Rija's phone (already signed in there).

RECOMMENDED version (263 X-counted chars, under the 280 limit).
NOTE 2026-11-18 ~19:28: the first posted version ended with bare
"rezzrizz.ai" — X auto-linked it, but rezzrizz.ai is an Agent ID name,
NOT a website (ERR_NAME_NOT_RESOLVED), so the link was dead. Fixed
version links the live radar site instead (drives check-ins):

> Paid. Scam. Expired. That's what floods Agent ID users every day. AgentRadar cuts through it — a free-mint radar on BNB Chain, gated by Binance Agent ID. 1 check-in per day, verified free mints only.
> https://rezzrizz25.github.io/agent-radar/
> #BinanceWalletHackathon #AgenticWallet

Attach the banner image: assets/agent-radar-promo.png (PNG of the clean
banner). Then delete the old post and submit the new post link via the
official campaign survey.

STATUS 2026-11-18 ~19:43 +08: Rija reposted the corrected version herself
(https://x.com/AgentRadarBNB/status/2123017348252852700, radar link + banner)
and submitted the campaign survey HERSELF from her phone with the correct
UID 1043310502 — "Submitted Successfully". NOTE: an earlier browser
submission ~19:40 used the WRONG UID 1250741538 (from the browser session's
dashboard, account "User-f581f") and could not be corrected — the survey
allows one submission per session and resubmission was blocked
("Survey already completed"). Two entries now exist; the correct one is
Rija's phone submission.

Alternative (253 chars):

> Agent ID users are drowning in paid, scam & expired "free" mints. So I built AgentRadar — a free-mint radar on BNB Chain, gated by Binance Agent ID. Check in once a day, unlock verified free mints only. rezzrizz.ai
> #BinanceWalletHackathon #AgenticWallet

Original draft (209 chars, plainer):

> Built AgentRadar: a free-mint radar on BNB Chain gated by Binance Agent ID. Only .ai holders can check in — 1 per Agent ID per day, all on-chain. My Agent ID: rezzrizz.ai
> #BinanceWalletHackathon #AgenticWallet

Then submit the post link via the official campaign survey. Do not post
before the contract is live.
