Last updated: 2026-05-22 16:56:42 BRT | Codex sub-2B | Existing static gates executed against local 3.16 package.

# Existing Static Gates Results

Agent: Codex sub-2B
Timestamp BRT: 2026-05-22 16:56:42 BRT
Package: `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip`
SHA256: `FE45D69201154BC9A2CBF54DD86F7CCE7200969C31965F8333CF0FE61FCDBE1D`
Unpacked source for source-path audit: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/VERIFIERS/package_unpacked_20260522_165123`
Tenant writes: none

| Gate | Exit | Result | Report/output | Evidence PNG | Notes |
|---|---:|---|---|---|---|
| `tests/Test-PMOFlowStopShipAudit.ps1` | 1 | FAIL | `outputs/20260522_165152_Codex_sub-2B_static_pmo_flow_stop_ship_audit_output.txt` | `evidence/20260522_165152_Codex_sub-2B_static_pmo_flow_stop_ship_audit_fail.png` | Six failures: raw APIM token auth in four PM0 card workflows, `runtimeSource=invoker` in `PM0_PA_Card_ListarTarefas`, unresolved Teams/Outlook kit references. |
| `tests/Test-SolutionZipP0Contracts.ps1` | 1 | FAIL | `outputs/20260522_165246_Codex_sub-2B_static_solution_zip_p0_output.txt` | `evidence/20260522_165246_Codex_sub-2B_static_solution_zip_p0_fail.png` | Three failures: `ListarTarefas` ZIP workflow fails legacy `NomeProjeto`, project-resolution, and not-found guard checks. |
| `tests/Test-SolutionZipP24Contracts.ps1` | 1 | FAIL | `outputs/20260522_165406_Codex_sub-2B_static_solution_zip_p24_output.txt` | `evidence/20260522_165406_Codex_sub-2B_static_solution_zip_p24_fail.png` | Ten failures: UTF-8 BOM in PM0 workflow JSON entries, runtimeSource invoker, raw APIM token auth, unresolved Teams/Outlook kit references, CriarTarefa subtests, ListarTarefas content-safe subtest. |
| `tests/Test-CopilotRoutingInstructions.ps1` | 0 | PASS | `outputs/20260522_165512_Codex_sub-2B_static_copilot_routing_output.txt` | `evidence/20260522_165512_Codex_sub-2B_static_copilot_routing_pass.png` | 12/12 checks passed. |
| `tests/Test-CopilotPowerFxRegexSafety.ps1` | 0 | PASS | `outputs/20260522_165559_Codex_sub-2B_static_powerfx_regex_output.txt` | `evidence/20260522_165559_Codex_sub-2B_static_powerfx_regex_pass.png` | Regex hyphen safety check passed. |

## Blockers

- `BLOCKER_PACKAGE_STATIC_GATES`: 3.16 ZIP exists, so no ZIP gate was blocked waiting for package, but package-level static gates are not green.
- `BLOCKER_STOP_SHIP_AUDIT`: package contains unsupported connection/auth/reference hygiene findings.
- `BLOCKER_LEGACY_CONTRACT_TESTS`: P0/P24 tests still assert legacy contract details that the 3.16 ZIP does not satisfy for `ListarTarefas` and `CriarTarefa`.

