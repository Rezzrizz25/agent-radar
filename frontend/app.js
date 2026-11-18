// AgentRadar frontend — static, no server, no session storage.
// Wallet: injected EIP-1193 provider only (MetaMask / Binance Wallet extension).
// NEVER asks for seed phrase, private key, or a pairing/QR code.
(function () {
  "use strict";
  const cfg = window.AGENT_RADAR_CONFIG;
  const $ = (id) => document.getElementById(id);
  const ZERO = "0x0000000000000000000000000000000000000000";
  const REGISTRY_ABI = [
    "function ownerOf(uint256 tokenId) view returns (address)",
    "function handleOf(address wallet) view returns (string)",
    "function balanceOf(address wallet) view returns (uint256)",
  ];
  const RADAR_ABI = [
    "function checkIn(string calldata agentName) external",
    "function checkInSelf() external",
    "function resolveAgentId(address wallet) view returns (string handle, bytes32 tokenId, bool owns)",
    "function totalCheckIns() view returns (uint256)",
    "function uniqueAgents() view returns (uint256)",
    "function totalCheckInsByWallet(address) view returns (uint256)",
    "function checkedInToday(bytes32) view returns (bool)",
    "function mintCount() view returns (uint256)",
  ];
  const ERC721_ABI = [
    "function totalSupply() view returns (uint256)",
    "function name() view returns (string)",
    "function symbol() view returns (string)",
  ];

  let provider = null;
  let signer = null;
  let account = null;
  let agentTokenId = null;

  function setStatus(msg, cls) {
    const el = $("status");
    el.textContent = "Status: " + msg;
    el.className = cls || "muted";
  }
  function short(addr) { return addr ? addr.slice(0, 6) + "…" + addr.slice(-4) : "—"; }
  function bscLink(addr) { return cfg.bscscanBase + "/address/" + addr; }
  function bscTx(hash) { return cfg.bscscanBase + "/tx/" + hash; }
  function isDeployed() { return cfg.contractAddress && cfg.contractAddress !== ZERO; }

  async function ensureChain() {
    const net = await provider.getNetwork();
    if (Number(net.chainId) !== cfg.chainId) {
      try {
        await window.ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: "0x38" }], // 56
        });
      } catch (e) {
        throw new Error("Gagal pindah ke BNB Smart Chain (56): " + (e && e.message ? e.message : e));
      }
    }
  }

  async function connect() {
    if (!window.ethereum) {
      setStatus("Tidak ada wallet terdeteksi. Pasang MetaMask / Binance Wallet extension dulu, lalu refresh.", "bad");
      return;
    }
    if (typeof ethers === "undefined") {
      setStatus("Library ethers.js (CDN) gagal dimuat. Cek koneksi internet lalu refresh.", "bad");
      return;
    }
    try {
      provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      signer = await provider.getSigner();
      account = await signer.getAddress();
      await ensureChain();
      $("wallet-status").innerHTML =
        "Terhubung: <span class='mono'>" + account + "</span> (" + short(account) + ") • " + cfg.chainName;
      $("btn-connect").textContent = "Terhubung ✓";
      $("btn-connect").disabled = true;
      await resolveAgent();
      await loadStats();
    } catch (e) {
      setStatus("Gagal connect wallet: " + (e && e.message ? e.message : e), "bad");
    }
  }

  async function resolveAgent() {
    try {
      const reg = new ethers.Contract(cfg.registryAddress, REGISTRY_ABI, provider);
      const handle = await reg.handleOf(account);
      if (!handle) {
        $("agent-box").style.display = "block";
        $("agent-name").textContent = "(tidak punya Agent ID)";
        $("agent-verified").textContent = "NO AGENT ID";
        $("agent-verified").className = "pill bad";
        setStatus("Wallet ini belum punya Agent ID. Klaim dulu di Binance App (Web3 Wallet → Agent ID), baru check-in.", "warn");
        return;
      }
      const tokenId = ethers.keccak256(ethers.toUtf8Bytes(handle));
      const owner = await reg.ownerOf(tokenId);
      const owns = owner.toLowerCase() === account.toLowerCase();
      agentTokenId = tokenId;
      $("agent-box").style.display = "block";
      $("agent-name").textContent = handle + ".ai";
      $("agent-verified").textContent = owns ? "TERVERIFIKASI ON-CHAIN ✓" : "BUKAN PEMILIK ✗";
      $("agent-verified").className = "pill " + (owns ? "ok" : "bad");
      $("agent-token").textContent =
        "handle: " + handle + " • tokenId: " + BigInt(tokenId).toString() + " • ownerOf: " + owner;
      $("input-agent").value = handle + ".ai";
      if (isDeployed()) {
        const radar = new ethers.Contract(cfg.contractAddress, RADAR_ABI, provider);
        const today = await radar.checkedInToday(tokenId);
        const total = await radar.totalCheckInsByWallet(account);
        $("agent-today").textContent = today ? "sudah ✓" : "belum";
        $("agent-total").textContent = total.toString();
      } else {
        $("agent-today").textContent = "— (kontrak belum deploy)";
        $("agent-total").textContent = "—";
      }
      if (owns) setStatus("Agent ID " + handle + ".ai terverifikasi. Siap check-in.", "ok");
      else setStatus("Registry bilang Agent ID ini bukan milik wallet yang terhubung.", "bad");
    } catch (e) {
      setStatus("Gagal membaca Agent ID dari registry: " + (e && e.message ? e.message : e), "bad");
    }
  }

  async function loadStats() {
    if (!isDeployed()) {
      $("stats").textContent = "Kontrak belum di-deploy (config.js masih TODO-DEPLOY). Statistik muncul setelah deploy.";
      return;
    }
    try {
      const radar = new ethers.Contract(cfg.contractAddress, RADAR_ABI, provider);
      const total = await radar.totalCheckIns();
      const uniq = await radar.uniqueAgents();
      const count = await radar.mintCount();
      $("stats").innerHTML =
        "Total check-in: <b>" + total + "</b> • Agent ID unik: <b>" + uniq + "</b> • Entri radar: <b>" + count + "</b>";
    } catch (e) {
      $("stats").textContent = "Gagal membaca statistik kontrak: " + (e && e.message ? e.message : e);
    }
  }

  async function doCheckIn(useSelf) {
    if (!signer) { setStatus("Connect wallet dulu.", "warn"); return; }
    if (!isDeployed()) {
      setStatus("Kontrak AgentRadar belum di-deploy — check-in belum bisa. Blocker: deploy butuh BNB untuk gas (dompet Rija sekarang 0.0000066 BNB, tidak cukup). Top-up dulu, lalu deploy, lalu isi alamatnya di config.js.", "warn");
      return;
    }
    try {
      await ensureChain();
      const radar = new ethers.Contract(cfg.contractAddress, RADAR_ABI, signer);
      let tx;
      if (useSelf) {
        setStatus("Mengirim checkInSelf() — approve di wallet kamu…", "");
        tx = await radar.checkInSelf();
      } else {
        const name = ($("input-agent").value || "").trim();
        if (!name) { setStatus("Isi nama Agent ID dulu (contoh: rezzrizz.ai).", "warn"); return; }
        setStatus("Mengirim checkIn(" + name + ") — approve di wallet kamu…", "");
        tx = await radar.checkIn(name);
      }
      setStatus("Tx terkirim: " + tx.hash + " — menunggu konfirmasi…", "");
      const rc = await tx.wait();
      setStatus("Check-in CONFIRMED di block " + rc.blockNumber + ". Tx: " + bscTx(tx.hash), "ok");
      await resolveAgent();
      await loadStats();
    } catch (e) {
      const msg = e && e.message ? e.message : String(e);
      if (/user rejected|User denied/i.test(msg)) setStatus("Kamu membatalkan transaksi di wallet. Tidak ada yang berubah di chain.", "warn");
      else if (/AlreadyCheckedInToday/i.test(msg)) setStatus("Agent ID ini sudah check-in hari ini. Balik besok.", "warn");
      else if (/NotAgentIdOwner|NoAgentId|InvalidAgentName/i.test(msg)) setStatus("Check-in ditolak kontrak: wallet ini tidak memiliki Agent ID tersebut (atau namanya tidak valid).", "bad");
      else setStatus("Check-in gagal: " + msg, "bad");
    }
  }

  async function loadMints() {
    const box = $("mint-list");
    let data;
    try {
      const res = await fetch(cfg.mintsUrl);
      if (!res.ok) throw new Error("HTTP " + res.status);
      data = await res.json();
    } catch (e) {
      box.innerHTML = "<p class='bad'>Gagal memuat mints.json (" + (e && e.message ? e.message : e) + "). Kalau hosting hanya folder frontend, copy ../data/mints.json ke ./mints.json.</p>";
      return;
    }
    box.innerHTML = "";
    for (const m of data.mints || []) {
      const div = document.createElement("div");
      div.className = "card mint";
      div.innerHTML =
        "<h3>" + esc(m.name) + " <small>(" + esc(m.symbol) + ")</small> " +
        "<span class='pill'>" + esc(m.status) + "</span></h3>" +
        "<div class='mono'>Kontrak: <a target='_blank' rel='noopener' href='" + bscLink(m.contract) + "'>" + esc(m.contract) + "</a></div>" +
        "<div class='muted'>Supply saat seed: <b class='supply'>" + esc(String(m.supplyAtSeed)) + "</b>" +
        (m.maxSupply ? " / " + esc(String(m.maxSupply)) : " (maks tidak diketahui)") +
        " • Gas sim: ~" + esc(String(m.gasEstimateUnits)) + " units (~" + esc(String(m.gasEstimateBNB)) + " BNB)" +
        " • Live: <span class='live'>membaca…</span></div>" +
        "<div class='muted'>" + esc(m.evidence || "") + "</div>" +
        "<div class='muted'>Sumber: " + esc(m.source || "") + "</div>";
      box.appendChild(div);
      // Re-read totalSupply live — seed number is only a snapshot.
      if (window.ethereum && typeof ethers !== "undefined") {
        (async () => {
          try {
            const p = provider || new ethers.BrowserProvider(window.ethereum);
            const c = new ethers.Contract(m.contract, ERC721_ABI, p);
            const ts = await c.totalSupply();
            const live = div.querySelector(".live");
            if (live) live.textContent = "totalSupply live: " + ts.toString();
          } catch (e) { /* leave seed value; contract may not expose totalSupply */ }
        })();
      }
    }
    const note = document.createElement("p");
    note.className = "muted";
    note.textContent = "Diperbarui: " + (data.updated || "—") + ". " + (data.note || "");
    box.appendChild(note);
  }

  function esc(s) {
    return String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  }

  document.addEventListener("DOMContentLoaded", () => {
    $("footer-contract").textContent = isDeployed() ? cfg.contractAddress : "TODO-DEPLOY (belum di-deploy)";
    $("btn-connect").addEventListener("click", connect);
    $("btn-checkin").addEventListener("click", () => doCheckIn(false));
    $("btn-checkin-self").addEventListener("click", () => doCheckIn(true));
    if (window.ethereum) {
      window.ethereum.on && window.ethereum.on("accountsChanged", () => window.location.reload());
      window.ethereum.on && window.ethereum.on("chainChanged", () => window.location.reload());
    }
    loadMints();
    loadStats();
  });
})();
