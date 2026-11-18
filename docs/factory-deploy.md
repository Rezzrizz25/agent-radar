# Factory Deploy — AgentRadar via CREATE2 (no Remix copy-paste needed)

> STATUS: PREVIEW DONE 2026-11-18 ~17:52 +08. NOT EXECUTED YET.
> Rija must confirm the preview below before `execute` runs. `execute`
> broadcasts directly (preview says `requireConfirmation: false`) — there
> is NO extra approve tap in the Binance app. Do NOT run execute without
> her explicit confirmation of THIS preview.

## Why factory, not Remix

- Remix on Rija's phone: file creation worked, but copy-paste of the
  contract from chat/attachment/link is stuck ("Nyangkut"). The baw CLI
  cannot deploy directly either: `contract-call preview` requires `--to`,
  so a deployment (to=null) cannot be expressed — the earlier preview
  (requestId 01ffce7f...) was a call to the zero address, NOT a deploy,
  and was correctly NOT executed.
- Solution: deploy THROUGH the Arachnid deterministic deployment proxy
  (CREATE2 factory), a plain contract call that baw CAN express. The
  factory deploys AgentRadar; the constructor args still set
  registry + owner to Rija's wallet. Same contract, same owner, same
  source verification — only the deploy mechanism differs.

## Deployment parameters (verified live 2026-11-18 ~17:52 +08)

| Item | Value |
|---|---|
| Factory (CREATE2 proxy) | `0x4e59b44847b379578588920cA78FbF26c0B4956C` (eth_getCode non-empty on BSC, verified) |
| Salt | `0xc32b3c268efa7385f5e263bae4574594cbbbcaca651cf8d50a9b39e824bf29a1` = keccak256("AgentRadar-v1") |
| Predicted contract address | `0x7113970Eb80b0a2b55821236e35a24EA2BC736B1` (via `cast create2`) |
| From (deployer) | `0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A` (Rija's Binance Agentic Wallet) |
| Value | 0 BNB |
| Constructor arg 1 (registry) | `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` |
| Constructor arg 2 (owner) | `0x7917A535D0Cb92dC3c16c8d3bcFC4E0F2bDBB91A` |
| Compiler | solc **0.8.38**, optimizer **ON**, runs **200**, EVM osaka |
| Init code | 9,772 bytes (`/tmp/agentradar-initcode.txt`; rebuild: `forge build` with foundry.toml solc 0.8.38 + optimizer) |
| Factory calldata | salt (32B) + init code = 9,804 bytes (`/tmp/agentradar-factory-calldata.txt`) |
| Gas (eth_estimateGas, live) | **2,142,868** gas at 0.05 gwei = **~0.0001071 BNB** |
| Tests | Foundry 12/12 PASS on this exact build (recompiled 2026-11-18 ~17:52) |

## Preview (safe — simulation only, nothing broadcast)

- Command: `baw contract-call preview --binanceChainId 56 --from 0x7917...B91A --to 0x4e59b44847b379578588920cA78FbF26c0B4956C --value 0 --inputData <factory calldata>`
- Result: `success: true`
- **requestId: `79d84a1a398e4d0393b2f4a617aa6b3f`**
- parsedTx: `ContractInteraction`, contractAddress `0x4e59...956C`, action `0xc32b3c26` (salt prefix)
- simulationCode `000000000`, simulationErrorDetail `null`
- balanceChanges `[]`, allowanceChanges `[]`, authorityChanges `[]`
- risks: `riskDetails []`, `addresses {}`, `riskBehaviors []` — NO risks flagged
- `requireConfirmation: false` — execute broadcasts directly
- `expiresAt: 1794995826456` (preview expiry; re-preview if expired)

## Execute (ONLY after Rija confirms this preview)

```bash
baw contract-call execute --requestId 79d84a1a398e4d0393b2f4a617aa6b3f --json
```

Expected: `status: BROADCASTED` + `txHash`. Then:

1. Wait for confirmation; check `eth_getCode(0x7113970Eb80b0a2b55821236e35a24EA2BC736B1)` is non-empty.
2. Read `owner()` on BscScan — must be `0x7917...B91A`.
3. Seed 4 mints via baw `contract-call` (owner only, `addMint`, calldata in `docs/remix-deploy.md` Step 3 — same values; supplies re-read live at seed time).
4. Verify source on BscScan with: Solidity single file, compiler **v0.8.38**, license MIT, optimization **Yes, 200 runs**, source `contracts/AgentRadar.sol` (the 0.8.38 + optimizer build, NOT the old optimizer-off build).
5. Fill `frontend/config.js` with `0x7113970Eb80b0a2b55821236e35a24EA2BC736B1`, host, GitHub, submit form.

## Seed — 4x addMint previews (2026-11-18 ~17:55 +08, NOT executed yet)

- totalSupply re-read live just before: XOR 309, RAVENH 655, HIVEBYTE 319, PXPC 833 (unchanged since 17:00).
- Calldata taken verbatim from `docs/remix-deploy.md` Step 3 and verified by `cast decode-calldata` (mint 0 and mint 3 spot-checked: values match the table exactly).
- Gas price at preview time: 0.05 gwei. Each addMint ≈ 219k–239k gas ≈ 0.000012 BNB; all 4 ≈ 0.000048 BNB total. Balance 0.0057519 BNB.
- All 4 previews: success, ContractInteraction to 0x7113970Eb80b0a2b55821236e35a24EA2BC736B1, action 0x0af5dfd1 (addMint), simulationCode 000000000, no error, no risks, no balance/allowance/authority changes, requireConfirmation false.

| # | Mint | requestId |
|---|---|---|
| 0 | Glyphs of Xor (XOR), supply 309 | `9d03aa639f234b4e8e87e1e63e3e31c4` |
| 1 | Ravenhex (RAVENH), supply 655 | `f8825c256813412db58ec28001a37a0d` |
| 2 | Hivebyte (HIVEBYTE), supply 319 | `5cc5b694ecac424fb05c351a96a0ef90` |
| 3 | Pixel Agent PC (PXPC), supply 833 | `e9cc093e4d124ba5ad99e7834d0835bc` |

Execute (ONLY after Rija confirms these previews), one per mint, in order 0–3:
`baw contract-call execute --requestId <requestId> --json`
Then check `mintCount()` == 4 on-chain.
