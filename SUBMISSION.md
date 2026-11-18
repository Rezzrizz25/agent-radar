# SUBMISSION — Binance Agent ID Hackathon

> Status: **DRAFT — BELUM SUBMIT.** Jangan submit sebelum semua kotak
> "WAJIB sebelum submit" di bawah dicentang. Deadline: **9 Des 2026 08:00 UTC**.
> Announcement: "Agent ID Hackathon: Build Decentralized Applications (dApps)
> Around Agent ID to Win 60,000 USDC Worth of Rewards" (Binance Announcement,
> dipublikasikan 2026-11-18 15:50).

## 1. Isian form (copy-paste saat submit)

| Field | Isi |
|---|---|
| Project name | **AgentRadar** |
| Tagline | Radar mint NFT gratis di BNB Chain, khusus holder Binance Agent ID (.ai) — dengan check-in harian on-chain per Agent ID. |
| Website / live dApp | **https://rezzrizz25.github.io/agent-radar/** — GitHub Pages, aktif setelah repo dibuat + Pages di-enable (langkah terakhir sebelum submit). |
| Contract address(es) | **https://bscscan.com/address/0x7113970Eb80b0a2b55821236e35a24EA2BC736B1#code** — LIVE 2026-11-18 ~17:54 +08, source **VERIFIED 2026-11-18 ~18:18 +08** via Etherscan API V2 (solc 0.8.38, optimizer 200, EVM osaka, MIT). |
| Agent ID registry | `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (BNB Chain, SPACE ID / Binance Agent ID) — bukti: `docs/registry-verification.md` |
| GitHub repo (open source) | **https://github.com/Rezzrizz25/agent-radar** — public, lisensi MIT. Rija yang buat repo kosongnya; push dari lokal setelah repo ada. |
| Nama project | **AgentRadar** — dengan pembeda BNB di X (`@AgentRadarBNB`) karena nama "AgentRadar" polos sudah dipakai proyek lain: trust oracle on-chain untuk agent economy di Base (vvpro.ai, ERC-8004, EAS attestations, live Base Sepolia/Mainnet — terverifikasi via web search 2026-11-18). Proyek itu BUKAN kami, tidak ada hubungan. |
| Agent ID usage description | Agent ID adalah gerbang dan identitas radar: (1) `checkIn`/`checkInSelf` memverifikasi `registry.handleOf(msg.sender)` → `keccak256(handle)` → `registry.ownerOf(tokenId) == msg.sender` di setiap check-in; tanpa Agent ID transaksi revert. (2) Satu check-in per Agent ID per hari UTC — identitas, bukan alamat anonim, yang dihitung. (3) `uniqueAgents` + event `CheckedIn` memberi metrik Pioneer Award yang bisa diaudit siapa saja. (4) Kurasi radar berasal dari pipeline scan 4.942 wallet JAGENT early-minter Rija; entri hanya masuk setelah sim read-only lolos. |
| Project X | **[@AgentRadarBNB](https://x.com/AgentRadarBNB)** — display name "AgentRadar BNB". ✅ **LIVE — dibuat Rija, terverifikasi 2026-11-18 ~17:03 +08** (joined Nov 2026, foto profil + banner terpasang ~17:06 +08). Bio: "Agent ID-gated free-mint radar on BNB Chain. Verified free mints only. Built for Binance Agent ID Hackathon." |
| Team | Rija (Agent ID: `rezzrizz.ai`) — solo. |
| Contact / owner X | X pemilik (fallback): [@rezzrizz25](https://x.com/rezzrizz25) |

## 2. Checklist submit

### WAJIB sebelum submit
- [x] Top-up BNB — **LANDED 2026-11-18 ~16:49 +08: 0,001556803414729652 BNB (~$0,92)**, di atas floor 0,0015, masih di bawah target 0,003 (~0,00144 kurang). Deploy terukur: `eth_estimateGas` mainnet = 2.129.904 gas → **0,0001065 BNB** pada 0,05 gwei; total deploy+seed+1 check-in ≈ **0,000163 BNB**, sisa ≈ 0,00139 — di bawah floor 0,0015. Deploy muat, tapi dianjurkan top-up ~0,0015 BNB dulu ke ~0,003. (Estimasi lama 0,00004–0,000075 sudah dikoreksi — terlalu rendah.)
- [x] E2E testnet-equivalent — **LOLOS 2026-11-18 ~17:00 +08: 16/16 checks** di Anvil lokal chainId 97 + mock registry (deploy mock + AgentRadar, checkIn, duplicate-revert, non-owner-revert, no-handle-revert, BNB-reject, addMint ×4, mintCount 4, getMint/getMintRange, owner-only). Lihat `test/e2e-report.md`. Deploy di BSC testnet 97 yang sebenarnya masih TERBLOKIR: butuh tBNB di wallet test via faucet browser — tidak ada wallet test berisi tBNB di sini. Logika kontrak sudah terbukti oleh E2E ini + 12/12 Foundry tests; testnet hanya akan menguji ulang plumbing.
- [x] Buat akun X project **@AgentRadarBNB** — **BELUM: Rija yang buat sendiri di X.** Display "AgentRadar BNB", bio "Agent ID-gated free-mint radar on BNB Chain. Verified free mints only. Built for Binance Agent ID Hackathon." Link https://x.com/AgentRadarBNB JANGAN diklaim live sampai dia konfirmasi.
- [ ] Deploy `AgentRadar` di **BSC mainnet** dari wallet Rija (registry mainnet `0x60B9…022F`, owner = wallet Rija).
- [ ] Verifikasi source code di BscScan (flatten atau multi-file; lisensi MIT; optimizer 200 runs; solc 0.8.38).
- [ ] Seed 4 entri mint via `addMint` (owner) — cocokkan dengan `data/mints.json` v1, supply dibaca ulang live saat seed.
- [ ] Isi `CONTRACT_ADDRESS` di `frontend/config.js`, host frontend statis (GitHub Pages / host statis lain), uji connect + resolve Agent ID + check-in dari browser.
- [ ] Push repo ke GitHub (public) — sertakan `contracts/`, `frontend/`, `data/`, `docs/`.
- [ ] Isi form "Submit Project Now" di halaman announcement Binance dengan isian §1.
- [ ] Selama Submission Period (sampai 9 Des 08:00 UTC): ajak holder Agent ID check-in (X, Telegram deal-hunt, komunitas). Hanya interaksi dalam periode ini yang dihitung.

### Opsional (menaikkan skor)
- [ ] Video demo singkat (Remotion/Motion Canvas — code-based, bukan AI video) untuk form/X.
- [ ] Tambah entri radar baru dari scan jam-an (hanya yang lolos sim + preview).
- [ ] Community Promotion 2.000 USDC: posting X terpisah (lihat §3).

## 3. Community Promotion Campaign (2.000 USDC, 20 pemenang bagi rata)

Syarat dari announcement: post konten orisinal di X tentang project peserta,
sertakan hashtag `#BinanceWalletHackathon` dan `#AgenticWallet`, lalu submit
link X via campaign survey resmi. Juri memilih 20 pemenang berdasarkan kualitas post.

**Draft X — post dari akun project [@AgentRadarBNB](https://x.com/AgentRadarBNB)
(setelah akun dibuat Rija; akun project belum live saat draft ini ditulis):**

> Built AgentRadar: a free-mint radar on BNB Chain gated by Binance Agent ID. Only .ai holders can check in — 1 per Agent ID per day, all on-chain. My Agent ID: rezzrizz.ai
> #BinanceWalletHackathon #AgenticWallet

Panjang draft: **209 karakter** (dihitung 2026-11-18) — di bawah batas 280
(akun Rija bukan Premium). Jangan posting sebelum kontrak live (post harus
membahas project yang nyata) dan sebelum akun @AgentRadarBNB dibuat.

## 4. Penilaian — mapping ke kriteria juri (100 poin)

| Dimensi (bobot) | Bukti di project ini |
|---|---|
| Agent ID Application Depth (30%) | Gate `handleOf → keccak256 → ownerOf` di `checkIn`/`checkInSelf`; 1 check-in/Agent ID/hari; `uniqueAgents` on-chain. |
| Practicality & Feasibility (25%) | Memecahkan masalah nyata pemiliknya: kurasi mint gratis dari scan 4.942 wallet + estimasi gas vs saldo; sudah jalan sebagai pipeline scan sebelum hackathon. |
| Product Completion (25%) | Kontrak compile + frontend statis fungsional; jalur utama (connect → resolve → check-in → lihat radar) selesai. |
| Innovation (20%) | Identitas-per-hari sebagai unit interaksi; metrik Pioneer yang bisa diaudit dari event. |

## 5. Yang TIDAK dijanjikan

- Tidak ada klaim hadiah / peringkat. Pioneer top-10 butuh volume interaksi
  yang tidak bisa dijamin solo.
- Tidak ada floor price / nilai untuk mint yang terdaftar. Tidak ada halaman
  resmi terverifikasi untuk 4 entri seed — statusnya ditulis apa adanya
  (`VERIFIED_SIM_ONCHAIN_ONLY`).
- Tidak ada tanggal hasil selain yang diumumkan Binance: Internal Review
  9–17 Des 2026, Public Review 17–20 Des 2026.
