# Deploy guide — AgentRadar

> UPDATE 2026-11-18 ~16:49 +08: TOP-UP LANDED — BNB 0,001556803414729652
> (~$0,92), di atas floor 0,0015, di bawah target 0,003. Deploy mainnet
> sekarang dimungkinkan dari sisi gas (estimasi di bawah), tapi akan menggerus
> saldo ke sekitar floor — cek `eth_estimateGas` + harga gas live sebelum kirim,
> dan top-up ke 0,003 dulu bila memungkinkan. Tidak ada private key di repo ini;
> deploy dilakukan dari wallet Rija sendiri (Remix + wallet extension,
> atau `forge create` dengan key dari env — jangan pernah paste key ke chat/file).

## 0. Ringkasan biaya (TERUKUR 2026-11-18 ~17:00 +08 — bukan perkiraan)

- Creation bytecode `AgentRadar`: 19.416 byte (hasil `npm run compile`).
- `eth_estimateGas` deploy di mainnet (dari wallet Rija, read-only, tanpa tx):
  **2.129.904 gas** → **0,0001065 BNB** pada gas live 0,05 gwei
  (Anvil lokal mengukur 2.111.975 gas — konsisten). Estimasi awal
  0,00004–0,000075 BNB sudah dikoreksi — terlalu rendah.
- Seed 4 entri `addMint`: 932.732 gas total ≈ **0,0000466 BNB**; 1× check-in
  test ≈ 190.121 gas ≈ **0,0000095 BNB**.
- **Total deploy + seed + 1 check-in ≈ 0,000163 BNB. Sisa saldo ≈ 0,00139 BNB
  — di bawah floor 0,0015.** Deploy muat, tapi dianjurkan top-up ~0,0015 BNB
  dulu ke ~0,003. Harga gas BSC berubah — selalu cek `eth_estimateGas` +
  harga gas live sebelum kirim.
- Saldo saat ini 0,0015568 BNB sudah di atas floor 0,0015, jadi deploy tidak
  lagi terblokir gas.
- Tidak ada biaya lain: kontrak tidak payable, tidak ada withdraw.

## 1. Testnet dulu (BSC testnet, chainId 97)

Kenapa: registry Agent ID **tidak ada** di testnet (belum ada bukti registry
di testnet — semua sumber menunjuk mainnet). Jadi di testnet pakai mock.

1. Ambil tBNB dari faucet BSC testnet ke wallet test (bukan wallet utama).
2. Deploy `contracts/MockAgentIdRegistry.sol`.
3. `register(walletTest, "testagent")` di mock (fungsi mock terbuka — test only).
4. Deploy `contracts/AgentRadar.sol` dengan constructor:
   - `_agentIdRegistry` = alamat mock yang baru di-deploy
   - `_owner` = wallet test (atau wallet Rija bila mau uji kurasi)
5. Uji dari frontend (ganti `config.js`: `chainId: 97`, `registryAddress` = mock,
   `contractAddress` = AgentRadar testnet, `rpcUrl` = testnet RPC):
   - Connect → Agent ID terbaca `testagent`
   - `checkIn("testagent")` → sukses, `totalCheckIns` = 1
   - `checkIn("testagent")` lagi di hari yang sama → revert `AlreadyCheckedInToday`
   - `checkIn("alice")` dari wallet test → revert `NotAgentIdOwner`
   - `checkInSelf()` → sukses (hari berikutnya / wallet lain)
   - Kirim BNB ke kontrak → revert (contract holds no funds)
6. Bila semua lolos, lanjut mainnet. Bila ada yang gagal, STOP — jangan deploy mainnet.

### Verifikasi `handleOf` sebelum mainnet (satu eth_call)

`handleOf(address)` selector = `0xc50a1514` (dihitung via `cast sig "handleOf(address)"`).
Status 2026-11-18 ~16:50 +08: **SUDAH DIVERIFIKASI LIVE** —

```bash
cast call 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F "handleOf(address)(string)" \
  0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A --rpc-url https://bsc-dataseed.binance.org/
# → "rezzrizz"
cast call 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F "balanceOf(address)(uint256)" \
  0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A --rpc-url https://bsc-dataseed.binance.org/
# → 1
```

Yang sudah diverifikasi live 2026-11-18 (lengkap): `eth_getCode`
registry non-empty + `handleOf` = `"rezzrizz"` + `ownerOf(keccak256("rezzrizz"))` =
`0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A` + `balanceOf` = 1.
Lihat `docs/registry-verification.md`.

## 2. Mainnet (BNB Chain, chainId 56)

### Opsi A — Remix (disarankan untuk Rija; tanpa key di disk)
1. Buka remix.ethereum.org → buat file `AgentRadar.sol` → paste isi
   `contracts/AgentRadar.sol` (atau hubungkan repo).
2. Compile: Solidity 0.8.38 (atau ^0.8.20), optimizer ON, runs 200.
3. Deploy & Run: Environment = "Injected Provider — MetaMask" (atau Binance
   Wallet extension) → pastikan network = BNB Smart Chain (56), akun = wallet Rija.
4. Deploy dengan constructor:
   - `_agentIdRegistry` = `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`
   - `_owner` = alamat wallet Rija (sama dengan akun deploy — cek di preview
     Remix sebelum confirm; **periksa alamat registry & owner karakter per karakter**).
5. Confirm di wallet. Simpan: alamat kontrak + tx hash + block.
6. Verifikasi di BscScan (lihat §3), lalu seed (§4).

### Opsi B — forge (bila Foundry terpasang)
```bash
forge create contracts/AgentRadar.sol:AgentRadar \
  --rpc-url https://bsc-dataseed.binance.org/ \
  --private-key "$DEPLOY_KEY" \
  --constructor-args 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F <WALLET_RIJA> \
  --verify --etherscan-api-key "$BSCSCAN_API_KEY"
# $DEPLOY_KEY hanya dari env, tidak pernah ditulis di file/chat.
```

## 3. Verifikasi BscScan (wajib — syarat hackathon)

- BscScan → alamat kontrak → "Verify and Publish".
- Compiler: solc 0.8.38 (versi yang dipakai `npm run compile`), optimizer ON,
  runs 200, license MIT.
- Bila verifikasi multi-file gagal, gunakan flattened source (Remix: "Flatten"
  atau `npx solc --combined-json` + paste) — kontrak ini tanpa import eksternal
  (hanya 1 file + interface di dalamnya), jadi verifikasi seharusnya mudah.
- Cek hasil: tab "Contract" menampilkan source + "Read/Write Contract" aktif.
- Simpan link BscScan — itu yang dimasukkan ke form submit.

## 4. Seed 4 entri (owner only, setelah deploy)

Panggil `addMint` 4x dari wallet owner, dengan data `data/mints.json` v1 —
**tapi baca ulang `totalSupply` live dulu** (supply bergerak: Ravenhex 650→655,
HIVEBYTE 311→319, PXPC 657→833 antara scan dan 18 Nov 16:45). Urutan entri
harus sama dengan `mints.json` (id 0–3) supaya frontend konsisten.

Per entri, isi struct `Mint`:
`mintContract, name, symbol, supplyAtSeed (live), maxSupply (0 bila tak diketahui),
gasEstimate (unit), status ("VERIFIED_SIM_ONCHAIN_ONLY"), source, addedAt: 0, active: true`
(`addedAt`/`active` diisi kontrak — input diabaikan).

Lalu perbarui `frontend/config.js` (`contractAddress` = alamat mainnet) dan
host frontend. Uji end-to-end dari browser: connect → Agent ID `rezzrizz.ai`
terverifikasi → check-in → tx muncul di BscScan → `totalCheckIns` bertambah.

## 5. Setelah live

- Promosikan selama Submission Period (sampai 9 Des 2026 08:00 UTC).
- Tambah entri baru hanya bila lolos sim + preview (aturan Rija).
- Bila ada entri mati / sold out / gagal re-check: `deactivateMint(id)`.
- Jangan pernah memindahkan ownership ke alamat yang bukan milik Rija.
