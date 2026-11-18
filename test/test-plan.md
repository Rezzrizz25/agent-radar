# Test plan — AgentRadar

## Yang SUDAH dijalankan (2026-11-18, VM ini)

| # | Uji | Hasil |
|---|---|---|
| 1 | `npm install` + `npx solc --version` | ✅ solc **0.8.38** terpasang via `solc` npm package |
| 2 | `npx solc --bin --abi --optimize --optimize-runs 200 -o build contracts/AgentRadar.sol` | ✅ **COMPILE LULOS** setelah perbaikan stack-too-deep (lihat bawah). Output: `AgentRadar.bin` 19.416 byte, `AgentRadar.abi` 9.513 byte. |
| 3 | `node --check frontend/app.js` + `node --check frontend/config.js` | ✅ syntax OK |
| 4 | `python3 -m json.tool data/mints.json` | ✅ JSON valid |
| 5 | Live RPC `eth_getCode` registry `0x60B9…022F` (3 endpoint) | ✅ bytecode ter-deploy (prefix `0x60806040…`) |
| 6 | Live RPC `eth_call ownerOf(keccak256("rezzrizz"))` | ✅ `0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A` (wallet Rija) |
| 7 | Live RPC `eth_call totalSupply()` 4 mint seed | ✅ Glyphs 309, Ravenhex 655, HIVEBYTE 319, PXPC 833 (lihat `data/mints.json`) |
| 8 | `forge test` (Foundry 1.7.1, forge-std v1.17.0) | ✅ **12/12 PASS** — `Ran 1 test suite: 12 tests passed, 0 failed`. Gas check-in ~184k, `addMint` ~253k. Lihat `test/test-plan.md` §A. |
| 9 | `cast keccak "rezzrizz"` + `cast call handleOf/balanceOf` live | ✅ `keccak` = `0xf95c26…13001` = tokenId persis di MEMORY.md; `handleOf(0x7917…b91a)` = `"rezzrizz"`, `balanceOf` = 1 |

### Bug yang ketemu & diperbaiki saat compile
1. **Stack too deep** di `addMint` (8 param + struct literal). Perbaikan:
   `addMint(Mint calldata)` / `updateMint(uint256, Mint calldata)` — 1 struct
   param, `addedAt`/`active` diisi kontrak. Test ikut diubah ke struct literal.
2. **`ownerOf` revert mentah** untuk nama yang tidak pernah di-mint (ERC-721
   revert biasa). Perbaikan: `_verifyOwnedName` membungkus `ownerOf` dengan
   `try/catch` → revert `NotAgentIdOwner()` supaya frontend bisa menjelaskan.
3. **Satu pemanggilan test salah argumen** (`updateMint` tanpa `mintId`) — diperbaiki.
4. **`testContractRejectsBnb`** — tambah `vm.deal(address(this), 1 ether)` supaya
   penolakan benar-benar diuji di `receive()`, bukan gagal karena saldo test 0.

## Yang BELUM (harus sebelum deploy mainnet)

### A. Foundry test — ✅ SELESAI 2026-11-18 ~16:51 +08
`forge test` dijalankan dengan Foundry 1.7.1 + forge-std v1.17.0:
**12/12 PASS, 0 failed** (lihat tabel § "Yang SUDAH", baris 8). File:
`contracts/AgentRadar.t.sol` + mock `contracts/MockAgentIdRegistry.sol` +
`foundry.toml` (`src`/`test` = `contracts/`). Ulangi kapan saja dengan
`forge test -vv` dari root repo.

| Test | Menguji |
|---|---|
| testCheckInByName | `checkIn("alice")` → total 1, unique 1, `hasCheckedIn` hari ini |
| testCheckInAcceptsAiSuffix | `checkIn("alice.ai")` diterima (suffix di-strip) |
| testCheckInSelfResolvesHandle | `checkInSelf()` membaca handle dari registry |
| testCheckInRevertsForNonOwner | `bob` check-in `"alice"` → `NotAgentIdOwner` |
| testCheckInRevertsForUnknownName | `checkIn("nobody")` → `NotAgentIdOwner` (bukan revert mentah) |
| testCheckInRevertsForInvalidName | `"ALICE"` (huruf besar) / `"ab"` (terlalu pendek) → `InvalidAgentName` |
| testOneCheckInPerDay | check-in ke-2 di hari sama → `AlreadyCheckedInToday`; besok bisa lagi; unique tetap 1 |
| testAddMintOnlyOwner | non-owner → `NotOwner`; owner → id 0, `mintCount` 1, `active` true |
| testUpdateAndDeactivateMint | update supply; deactivate → `active` false |
| testGetMintRangePagination | `getMintRange(1,2)` → entri B, C |
| testContractRejectsBnb | kirim 1 ether → gagal (`receive()` revert) |
| testResolveAgentId | `resolveAgentId(alice)` → handle/tokenId/owns benar |

Cara menjalankan:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
cd agent-radar-hackathon
forge install foundry-rs/forge-std   # bila belum ada lib/
forge test -vv
```
Catatan: `AgentRadar.t.sol` mengimpor `forge-std/Test.sol` — perlu `forge install`
atau `lib/forge-std` tersedia. Bila instalasi Foundry gagal di VM ini, jalankan
di mesin lain / GitHub Actions sebelum deploy.

### B. Testnet end-to-end
Lihat `docs/deploy.md` §1 — deploy mock + AgentRadar di BSC testnet (97),
uji semua jalur dari frontend. **Wajib lolos sebelum mainnet.**

### C. Uji manual frontend (setelah deploy)
- Connect MetaMask/Binance Wallet → Agent ID tampil `rezzrizz.ai`, terverifikasi.
- Check-in → approve → tx di BscScan → statistik bertambah.
- Wallet tanpa Agent ID → pesan "belum punya Agent ID", tombol check-in ditolak kontrak.
- Daftar mint: `totalSupply` live terbaca (bukan hanya angka seed).
- Tanpa wallet extension → pesan instalasi, bukan crash.

### D. Yang TIDAK diuji di sini (dan kenapa)
- Deploy mainnet sungguhan — dilarang oleh tugas (tanpa top-up BNB + tanpa
  private key). Hanya persiapan deploy.
- Mint NFT seed (Glyphs of Xor dll.) — radar tidak mint; itu aksi Rija sendiri
  dengan perintah eksplisit + preview bersih, sesuai aturan yang berlaku.
- `handleOf` live — belum dibaca langsung (lihat `docs/deploy.md` §1 untuk
  calldata verifikasinya). `ownerOf` sudah membuktikan kepemilikan.
