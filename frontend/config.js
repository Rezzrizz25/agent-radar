// AgentRadar frontend config.
// TODO-DEPLOY: ganti CONTRACT_ADDRESS setelah deploy + verifikasi BscScan.
// Sampai saat itu frontend berjalan dalam mode "baca saja": daftar mint + resolve
// Agent ID tetap jalan, tombol check-in menampilkan pesan "belum di-deploy".
window.AGENT_RADAR_CONFIG = {
  chainId: 56, // BNB Smart Chain mainnet
  chainName: "BNB Smart Chain",
  rpcUrl: "https://bsc-dataseed.binance.org/",
  // TODO-DEPLOY — isi alamat kontrak AgentRadar setelah deploy mainnet.
  // JANGAN isi dengan alamat random / alamat dari chat. Hanya dari receipt deploy.
  contractAddress: "0x0000000000000000000000000000000000000000",
  // Binance / SPACE ID Agent ID registry — terverifikasi on-chain 2026-11-18,
  // lihat ../docs/registry-verification.md
  registryAddress: "0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F",
  bscscanBase: "https://bscscan.com",
  // Data seed: ../data/mints.json (disajikan berdampingan saat hosting statis;
  // kalau di-host dari folder frontend saja, copy file ini ke ./mints.json)
  mintsUrl: "./mints.json",
};
