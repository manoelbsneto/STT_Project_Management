# T0 Gate 4A Import ASK Draft

Last updated: 2026-05-23 16:33:20 BRT | Codex #1 Lead | Drafted locally after Sub 1A platform auth failure.

## Status

Draft status: SIGNATURE-READY AFTER Codex #2 clears Dataverse 403 and publishes the completed preflight rerun manifest.

This draft is not an execution record. Codex #2 owns the actual tenant import after Gate 4 preflight is green.

## Gate Summary

| Field | Value |
|---|---|
| Gate | 4A - tenant solution import |
| Authorization status | 4A standing authorization exists per owner ratification 2026-05-23 16:15 BRT |
| Target environment | `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) |
| Target solution | `PMO_v11_Tarefas` |
| Expected version | `3.16.0.0` |
| Package path | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` |
| Expected SHA256 | `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` |
| Backup paths | `<<TODO_BACKFILL: Owner manual export backup paths TBD (depends on: Owner backup path handoff)>>` |
| Import owner | Codex #2 |
| Publish behavior | Import only. Do not use `--publish-changes`; publish is Gate 4B. |

## Preconditions

- Codex #2 resolves the Dataverse 403 blocker.
- `scripts\Run-Gate4-Preflight.ps1` reaches the end from Step 03.
- Codex #1 peer-review report accepts the preflight rerun manifest.
- Owner backup paths are backfilled or explicitly accepted as TBD by the owner for this Gate 4A execution.
- Codex #2 confirms no post-preflight blocker exists in `T0_PREFLIGHT_RERUN_MANIFEST.md`.

## Pre-Import SHA Verification

```powershell
$PackagePath = ".planning\comms\codex_pm0_remediation_20260522\CODEX2\PACKAGE\package\PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip"
$ExpectedSha = "3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB"
$ActualSha = (Get-FileHash -Algorithm SHA256 -LiteralPath $PackagePath).Hash
if ($ActualSha -ne $ExpectedSha) {
  throw "Gate 4A BLOCKED: package SHA mismatch. Expected $ExpectedSha, got $ActualSha"
}
```

## Import Command

Official Microsoft PAC reference: `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution`

```powershell
pac solution import `
  --path ".planning\comms\codex_pm0_remediation_20260522\CODEX2\PACKAGE\package\PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip" `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --async `
  --max-async-wait-time 60
```

Do not append `--publish-changes`. Gate 4B owns publish.

## Post-Import Read-Back Verification

Decision 3 makes read-back mandatory evidence, not a separate gate. Codex #2 Sub 2C owns the final tool, but the expected command shape is:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\T0_SHA_COMPARE.ps1" `
  -ExpectedSha256 "3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB" `
  -SolutionName "PMO_v11_Tarefas" `
  -Environment "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
```

If the exported/read-back SHA diverges, stop immediately. Do not proceed to Gate 4B.

## Evidence Requirements

Every Gate 4A evidence entry must include:

- Agent name.
- Timestamp BRT in `YYYY-MM-DD HH:MM:SS BRT`.
- Screenshot path to a `.png`.
- Import command transcript with secrets redacted.
- Pre-import SHA verification output.
- Post-import read-back/SHA comparison output.

## ASK Text

Approve Gate 4A import of package SHA `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` into `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) for solution `PMO_v11_Tarefas` expected version `3.16.0.0`, using `pac solution import` without `--publish-changes`, followed by mandatory post-import read-back/SHA evidence before any Gate 4B publish.

## Backfill Manifest

| Placeholder | Upstream evidence | Responsible agent | Trigger |
|---|---|---|---|
| `<<TODO_BACKFILL: Owner manual export backup paths TBD (depends on: Owner backup path handoff)>>` | Owner backup path handoff / Codex #2 Sub 2B inventory | Codex #2 Sub 2B | Owner shares manual export paths |
