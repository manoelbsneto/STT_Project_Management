# Phase 0 Auth Setup

Status: `PASS`

Date: `2026-05-21` BRT  
Environment: `ColOfertasBrasilPro`  
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`

## Mandatory Document SHA256

The prompt-mandatory files were hashed before tenant access:

| File | SHA256 |
|---|---|
| `.planning/GOLDEN_RULES.md` | `4CD459F8083A0F3FF09E5F97D911CE41DDD38B37CBAB04DBD148A0CDAC2EF732` |
| `.planning/CURRENT_BASELINE.md` | `657A4D78882DE35F6BCEE65AED4163958B5361BEBA0C4EF4D401DDC81C0325A7` |
| `.planning/TENANT_COMMAND_RUNBOOK.md` | `AB7C6EA78372C4FC5444A5B912340330ADB02E94ACF92DE10001FE6F630BAD4F` |
| `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` | `2EE79BA114723D88FB9EE2A42C6D00C4AEA88E6923D90A0ECF7AEB7080E24F47` |
| `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md` | `973FE673873BFC322C5A99ED63FD4A5F09693E9AC04E22845D65228F87D0E23F` |
| `.planning/comms/incident_3_15_1_import_failure_20260521/EXEC_SUMMARY.md` | `C833347009708140A8B2FA7AA8D9E80C90575EDEFFCECBDB43E5E32EBC81663C` |
| `.planning/comms/incident_3_15_1_import_failure_20260521/codex_phd_analysis/FORENSIC_TENANT_STATE.md` | `963149238FDD17101215E2BB815ACE5E0B922D7B8386346D89C79B867AB25936` |
| `.planning/comms/incident_3_15_1_import_failure_20260521/codex_phd_analysis/topology_map/TOPOLOGY_MAP.md` | `A3B50F44D48D1078523112DB90925C9034E6D5D1525FBCF88CA935B8B07DAF06` |

Additional access prerequisites were read before access because `.planning/GOLDEN_RULES.md` lines 5-14 and `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` lines 22-32 require them:

- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
- `docs/TAILSCALE_SSH_CONNECTIVITY_GUIDE.md`
- `docs/MANUAL_OPERACIONAL_PMO.md`

## Runbook Basis

- Mandatory tenant constants and module versions: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 5-28.
- Forbidden access methods: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 30-38 and `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` lines 34-47.
- Phase 0 Power Automate method: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 143-180.
- Required access check-in before commands: `.planning/GOLDEN_RULES.md` lines 22-33 and `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` lines 53-70.

The access check-in for this execution is recorded in `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` under `2026-05-21 23:34 BRT - CODEX-PHD - DATAVERSE_PATCH_REPLAN_IN_PROGRESS`.

## Version Verification

The local verification used Windows PowerShell 5.1 and imported the absolute versioned module paths required by the runbook:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass
Import-Module "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1" -ErrorAction Stop
Import-Module "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1" -ErrorAction Stop
```

Observed:

| Item | Observed | Gate |
|---|---|---|
| Shell edition | `Desktop` | `PASS` |
| Windows PowerShell version | `5.1.26100.8457` | `PASS` |
| `Microsoft.PowerApps.PowerShell` | `1.0.45` | `PASS` |
| `Microsoft.PowerApps.Administration.PowerShell` | `2.0.217` | `PASS` |
| PAC CLI banner | `2.6.4+ga488322 (.NET Framework 4.8.9325.0)` | `PASS` |

Note: the `pac --version` probe prints the required PAC banner and then its legacy parser reports that `--version` is not a valid standalone command. The banner still confirms the installed version required by the runbook.

## Auth Validation

Runbook-compliant auth and validation command:

```powershell
Add-PowerAppsAccount -Endpoint prod
Get-Flow -EnvironmentName "e2d10003-4d8e-e007-9d63-76d5fe89ef56" -Top 5
```

Observed:

- `Add-PowerAppsAccount -Endpoint prod` completed without switching to device code, app registration, service principal, certificate auth, Graph direct, or HTTP Premium paths.
- `Get-Flow` returned live flow inventory from `ColOfertasBrasilPro`.
- Returned flow names included `PM0_PA_Card_ResumoExecutivoPortfolio`, `PM0_PA_Card_AtualizarTarefa`, `PM0_PA_Card_CriarTarefa`, `PM0_PA_Card_ListarTarefas`, and `PM0_PA_Card_AtualizarStatus`.

## Gate

Phase 0 gate result: `PASS`.

Proceed to Phase 1: test whether the runbook-approved `InvokeApi` function can call the Dataverse Web API `botcomponents` route.
