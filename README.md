# AgentRadar — Radar Mint Gratis untuk Agent ID

**Binance Agent ID Hackathon** · Submission period: 18 Nov 2026 08:00 UTC – 9 Dec 2026 08:00 UTC
· Total hadiah 60.000 USDC (Project Awards 58.000 + Community Promotion 2.000)

**Project X: [@AgentRadarBNB](https://x.com/AgentRadarBNB)** ("AgentRadar BNB") —
⚠️ akun belum dibuat, Rija yang membuat sendiri; owner X:
[@rezzrizz25](https://x.com/rezzrizz25). Nama "AgentRadar" polos sudah dipakai
proyek trust oracle di Base (vvpro.ai) — itulah alasan suffix BNB.

AgentRadar adalah radar mint NFT gratis di BNB Chain yang **hanya bisa dipakai
holder Binance Agent ID (.ai)**. Daftar mint dikurasi dari pipeline scan Rija
yang sudah berjalan tiap jam atas 4.942 wallet JAGENT early-minter — jadi radar
ini reuse aset nyata, bukan daftar tempelan.

## Kenapa ini menang (jujur)

- **Agent ID Application Depth (30%)** — Agent ID bukan tempelan: `checkIn`
  memverifikasi kepemilikan on-chain di registry (`handleOf` → `keccak256` →
  `ownerOf`) di setiap check-in. Tanpa Agent ID, transaksi revert.
- **Practicality & Feasibility (25%)** — Masalah nyata Rija sendiri: tiap jam
  scan menemukan mint gratis, tapi tidak ada tempat tunggal yang tepercaya
  untuk melihatnya, dan BNB yang seret membuat tiap peluang harus dinilai
  dulu (estimasi gas vs saldo). Radar menampilkan estimasi gas + status
  verifikasi tiap entri.
- **Product Completion (25%)** — Kontrak + frontend statis sudah jadi dan
  bisa dipakai begitu deploy selesai. Tidak ada server, tidak ada bagian
  "coming soon" di jalur utama.
- **Innovation (20%)** — Check-in harian per Agent ID: satu alamat = satu
  identitas = satu suara per hari. Ini juga yang memberi metrik Pioneer Award
  (jumlah alamat Agent ID yang berinteraksi + jumlah transaksi), semuanya
  bisa dihitung siapa saja dari event `CheckedIn`.
- **Kelemahan jujur:** Pioneer top-10 butuh BANYAK holder berinteraksi.
  Sendirian tidak cukup — radar harus dipromosikan (X, Telegram deal-hunt,
  komunitas Agent ID) selama Submission Period, karena hanya data dalam
  periode itu yang dihitung.

## Arsitektur

```
User (MetaMask / Binance Wallet extension, EIP-1193)
  │  connect + sign check-in (approve manual di wallet, tanpa auto-sign)
  ▼
Frontend statis (frontend/index.html + app.js, tanpa server)
  │  baca: registry.handleOf / ownerOf, AgentRadar.getMints / totalCheckIns
  │  tulis: AgentRadar.checkIn / checkInSelf
  ▼
AgentRadar.sol (BNB Chain, chainId 56)          Agent ID registry (SPACE ID)
  │  checkIn / checkInSelf  ──verifikasi──▶     0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F
  │  addMint / updateMint / deactivateMint (owner only — metadata saja)
  ▼
data/mints.json — seed 4 mint terverifikasi-sim (lihat bawah)
```

Tidak ada backend, tidak ada database, tidak ada penyimpanan session.
Frontend membaca `totalSupply` tiap mint **live** dari chain — angka seed hanya snapshot.

## Kontrak

`contracts/AgentRadar.sol` — Solidity `^0.8.20`, tanpa dependensi eksternal
(tidak perlu OpenZeppelin), custom errors, optimizer 200 runs.

| Fungsi | Siapa | Apa |
|---|---|---|
| `checkIn(string agentName)` | siapa saja (harus punya Agent ID itu) | Check-in harian. Terima `"rezzrizz"` atau `"rezzrizz.ai"`. Revert kalau bukan pemilik. 1x per Agent ID per hari. |
| `checkInSelf()` | siapa saja | Sama, tapi handle dibaca dari registry — user tidak perlu mengetik nama. |
| `resolveAgentId(address)` | view | Helper frontend: handle + tokenId + owns? |
| `addMint(Mint)` / `updateMint(id, Mint)` / `deactivateMint(id)` | **owner only** | Kurasi daftar radar (metadata saja). |
| `getMint(id)` / `getMints()` / `getMintRange(start, count)` | view | Baca daftar (paginasi tersedia). |
| `totalCheckIns()` / `uniqueAgents()` / `hasCheckedIn` / `checkedInToday` | view | Metrik Pioneer Award, on-chain. |
| `transferOwnership(address)` | owner only | Pindah hak kurasi (mis. ke wallet Rija bila deployer berbeda). |

**Owner powers (disclosed, sesuai aturan hackathon):** hanya kurasi daftar
(tambah/ubah/nonaktifkan entri) + transfer ownership. Owner **tidak bisa**
mint, memindahkan, atau menyentuh token/BNB siapa pun. Kontrak **tidak
payable**: `receive()`/`fallback()` revert, jadi kontrak tidak pernah bisa
memegang dana. Tidak ada `delegatecall`, `selfdestruct`, approval, atau transfer aset.

**Registry (terverifikasi — bukan karangan):**
`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`
Bukti lengkap: `docs/registry-verification.md` — 9+ sumber proyek independen
(BAS, Horror Protocol, AlphaPulse, Foundry Faces, BDOG, AIBOSS, RazorAgent,
Sidecoo, fastmint, pearl-miner) + `eth_getCode` + `eth_call ownerOf(keccak256("rezzrizz"))`
= `0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A` (wallet Agentic Rija), diverifikasi
live 2026-11-18 ~16:45 +08.

## Seed data (nyata, diberi grade bukti)

`data/mints.json` (juga dicopy ke `frontend/mints.json` untuk hosting statis).
Status `VERIFIED_SIM_ONCHAIN_ONLY` = sim read-only lolos (value 0) + bukti
on-chain, **tanpa halaman resmi terverifikasi, tanpa floor price terverifikasi**.
Jangan pernah menampilkan entri sebagai "official-page-verified".

| # | Mint | Kontrak | Supply seed → live 18 Nov 16:45 | Gas sim | Catatan |
|---|---|---|---|---|---|
| 0 | Glyphs of Xor (XOR) | `0x1577cbaa…ab90c` | 309 → 309 | ~110.858 (~0,00000554 BNB) | Satu-satunya yang MUAT di dompet Rija (0,0000066 BNB). |
| 1 | Ravenhex (RAVENH) | `0xb4405025…ecece2` | 650 → 655 | ~137.251 (~0,00000686 BNB) | Kurang ~0,00000026 BNB. balanceOf 2026-11-02 sempat unverified — cek ulang sebelum mint. |
| 2 | Hivebyte (HIVEBYTE) | `0xae9d85e7…cf8d8` | 311 → 319 | ~136.000 (~0,00000686 BNB) | Kurang ~0,00000026 BNB. Tracked wallet pernah mint tokenId 260 gratis (blok 132283335). |
| 3 | Pixel Agent PC (PXPC) | `0x6a6601f2…1910c8` | 657 → 833 | ~149.000 (~0,0000115 BNB) | Di bawah gas. Bergerak cepat (176 mint sejak 13 Nov). |

Kandidat yang REVERT saat re-sim sengaja **tidak** dimasukkan (ARKT, KAGE,
PXIO, STORM, AN404, Supaboard CALL, Ascension CATTY, PIG, Dragon Agent DAGENT).
Aturan penambahan entri baru: sim read-only lolos + balanceOf + preview bersih
— sama seperti aturan scan Rija selama ini. **Radar tidak pernah mint atas
nama user** — user mint sendiri di wallet-nya setelah preview bersih.

## Repo

```
agent-radar-hackathon/
├── README.md                    # file ini
├── SUBMISSION.md                # isian form hackathon + checklist + draft X
├── package.json                 # compile: npm run compile (solc-js)
├── contracts/
│   ├── AgentRadar.sol           # kontrak utama
│   ├── AgentRadar.t.sol         # Foundry test (12 test)
│   └── MockAgentIdRegistry.sol  # mock untuk testnet/lokal SAJA
├── frontend/
│   ├── index.html  app.js  config.js  mints.json
├── data/mints.json              # seed kanonis
├── docs/
│   ├── registry-verification.md # bukti alamat registry
│   ├── deploy.md                # langkah deploy testnet → mainnet → verifikasi
│   ├── remix-deploy.md          # panduan deploy tap-by-tap (Remix + BscScan + seed)
│   └── submission-full.md       # draft submit lengkap + semua blocker
└── test/
    ├── test-plan.md             # apa yang sudah dites & apa yang belum
    └── e2e-report.md            # laporan E2E lokal chainId 97 (16/16 PASS)
```

## Menjalankan lokal (tanpa deploy, tanpa gas)

```bash
# 1. Compile
npm install && npm run compile        # solc 0.8.38, output ke build/
# 2. Test (butuh Foundry — lihat test/test-plan.md bila forge belum terpasang)
forge test
# 3. Frontend (baca-saja): buka frontend/index.html via server statis, misal:
python3 -m http.server --directory frontend 8000
#    lalu buka http://localhost:8000 — daftar mint tampil; check-in
#    menampilkan "belum di-deploy" sampai CONTRACT_ADDRESS diisi di config.js.
```

## Blocker — UPDATE 2026-11-18 ~16:49 +08: TOP-UP LANDED, deploy terbuka

- **BNB: 0,0000066 → 0,001556803414729652 (~$0,92), terverifikasi live via baw +
  on-chain `eth_getBalance` (exact match).** Di atas floor 0,0015, masih di bawah
  target 0,003 (~0,00144 kurang). Biaya deploy TERUKUR (2026-11-18 ~17:00 +08):
  `eth_estimateGas` mainnet = 2.129.904 gas → **0,0001065 BNB** pada gas live
  0,05 gwei; total deploy + seed 4 mint + 1 check-in ≈ **0,000163 BNB**, sisa
  ≈ 0,00139 BNB — **di bawah floor 0,0015**. Deploy muat dari sisi gas, tapi
  dianjurkan top-up ~0,0015 BNB dulu ke ~0,003. (Estimasi awal 0,00004–0,000075
  sudah dikoreksi — terlalu rendah. Lihat `test/e2e-report.md` §3.)
  Selalu cek `eth_estimateGas` + harga gas live sebelum kirim.
  (Sebelumnya: deploy TIDAK MUNGKIN di 0,0000066 BNB — itu sudah tidak berlaku.)
- **Testnet dulu.** BSC testnet tidak punya registry Agent ID (belum terverifikasi
  ada) — deploy pakai `MockAgentIdRegistry.sol`, register handle `rezzrizz`
  untuk wallet test, baru uji check-in. Lihat `docs/deploy.md`.
- **Alamat kontrak mainnet: TODO-DEPLOY.** Jangan isi `config.js` dengan alamat
  dari chat/tebakan — hanya dari receipt deploy yang diverifikasi di BscScan.
- **Repo GitHub belum dibuat.** Push repo ini ke `github.com/Rezzrizz25/…`
  (nama repo bebas, mis. `agent-radar`) sebelum submit — form hackathon minta
  link repo open-source + kontrak terverifikasi BscScan.
- **Pioneer butuh promosi.** Setelah live, Rija perlu mempromosikan radar ke
  holder Agent ID lain (X, Telegram) — metrik hanya dihitung 18 Nov–9 Des 2026.

## Safety red lines (aturan hackathon) — kepatuhan

- No QR-code / pairing-code login di web pihak ketiga: frontend hanya pakai
  `window.ethereum` (EIP-1193). Tidak ada kolom kode pairing, tidak ada QR.
- Tidak ada bypass konfirmasi transaksi user: setiap check-in adalah transaksi
  normal yang harus di-approve di wallet. Tidak ada relayer/auto-sign.
- Tidak ada transfer aset tanpa izin: kontrak tidak punya transfer/approve/
  payable/withdraw. Daftar radar hanya informasi.
- Kontrak open-source, owner permissions diungkap di atas dan di dalam
  komentar `AgentRadar.sol`.
