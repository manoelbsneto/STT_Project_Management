Last updated: 2026-05-23 16:42:23 BRT | Codex #2 Sub 2B | Historical fallback validation completed; Owner manual export paths still pending.

# T0 Recovery Backup Inventory - Codex #2 Sub 2B

## Scope

This inventory covers backup readiness only. No tenant write, import, publish, delete, portal/runtime modification, or production data access was performed.

Owner manual export paths are still pending. Until the Owner provides the manual export paths, the only locally validated item in this inventory is the historical fallback archive:

`Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`

This archive is a historical fallback only. It is not the active 3.16 package and not the primary recovery path requested by Decision 2.

## Owner Manual Export Paths

| Item | Status | Path | Validation |
|---|---|---|---|
| Owner manual export - `PMO_v11_Tarefas` | PENDING | TBD by Owner | NOT_RUN |
| Owner manual export - `PMO_AQ07_CopilotBinding` | PENDING | TBD by Owner | NOT_RUN |

## Historical Fallback Validation

| Check | Result | Evidence |
|---|---|---|
| Archive exists | PASS | `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`, 66060 bytes |
| SHA256 | PASS | Expected and actual: `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691` |
| Solution inventory | PASS | Unique name `PMO_v11_Tarefas`, version `3.9`, 12 root components, 12 workflow entries, 21 bot components |
| `Test-SolutionXmlSchemaValidity.ps1` | PASS | Exit 0; `invalidRootComponentCount=0` |
| `Test-SolutionZipP0Contracts.ps1` | PASS | Exit 0; `failedCheckCount=0` |
| `Test-SolutionZipP24Contracts.ps1 -ExpectedVersion 3.9` | FAIL_LEGACY_STATIC_DELTAS | Exit 1; current guard flags legacy `gstf_sharepoint`, `ListarTarefas` content-safe, and `AtualizarTarefa` skip-semantics deltas |

## Evidence Triplet

| Type | Path |
|---|---|
| Text log | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/20260523_164223_Codex2Sub2B_historical_fallback_validation.txt` |
| JSON structured evidence | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/20260523_164223_Codex2Sub2B_historical_fallback_validation.json` |
| Screenshot | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_164223_Codex2Sub2B_historical_fallback_validation.png` |

## Conclusion

The historical fallback archive is present and matches the expected SHA256. Offline schema and P0 package checks pass. The current P24 policy guard does not pass against this historical archive, so this item should remain classified as historical fallback only, not primary recovery readiness. Owner manual export paths remain the open recovery-readiness blocker.
