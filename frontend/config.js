// AgentRadar frontend config.
// DEPLOYED 2026-11-18 ~17:54 +08 via Arachnid CREATE2 factory.
// Contract: 0x7113970Eb80b0a2b55821236e35a24EA2BC736B1
// Deploy tx: 0xd28685f35440c162ff2dafc22f869f9aa21570927edb124018e76b6988a48f87
// Seeded 17:56 +08, mintCount = 4. BscScan source VERIFIED 2026-11-18 ~18:18 +08 via Etherscan API V2 (guid sy6j9vaj8iqied5j7v369n4mrapiqh89q1yb2uqkszpgctshwa, solc 0.8.38, optimizer 200, EVM osaka, MIT).
window.AGENT_RADAR_CONFIG = {
  chainId: 56, // BNB Smart Chain mainnet
  chainName: "BNB Smart Chain",
  rpcUrl: "https://bsc-dataseed.binance.org/",
  // Live contract from the deploy receipt (verified on-chain: owner = Rija's
  // wallet 0x7917...B91A, registry 0x60B9...022F, mintCount = 4).
  contractAddress: "0x7113970Eb80b0a2b55821236e35a24EA2BC736B1",
  // Binance / SPACE ID Agent ID registry — terverifikasi on-chain 2026-11-18,
  // lihat ../docs/registry-verification.md
  registryAddress: "0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F",
  bscscanBase: "https://bscscan.com",
  // Data seed: ../data/mints.json (disajikan berdampingan saat hosting statis;
  // kalau di-host dari folder frontend saja, copy file ini ke ./mints.json)
  mintsUrl: "./mints.json",
};
