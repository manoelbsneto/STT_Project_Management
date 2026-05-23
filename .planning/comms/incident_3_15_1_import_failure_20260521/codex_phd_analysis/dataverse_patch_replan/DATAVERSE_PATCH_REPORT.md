# Dataverse Patch Report

Final verdict: `BLOCKED_BY_RUNBOOK_LIMITATION`

Agent: `CODEX-PHD`  
Environment: `ColOfertasBrasilPro`  
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`  
Dataverse URL: `https://colofertasbrasilpro.crm4.dynamics.com/`  
Owner write authorization reference: current-thread approval `2026-05-21T23:19:28-03:00`

## Executive Result

The mission stopped at Phase 1 as required.

Phase 0 proved the approved Windows PowerShell 5.1 + PowerApps module access path works for `Add-PowerAppsAccount -Endpoint prod` and `Get-Flow` in `ColOfertasBrasilPro`.

Phase 1 then tested the required runbook-approved `InvokeApi` path against one read-only Dataverse `botcomponents(<id>)` GET. The call failed during `InvokeApi` token acquisition with `AADSTS65002` before any Dataverse topic row was returned.

No auth fallback was attempted because the dispatch and project access rules prohibit improvising an alternate tenant access route.

## Phase Status

| Phase | Result | Output |
|---|---|---|
| Phase 0 - Auth setup | `PASS` | `phase0_auth_setup.md` |
| Phase 1 - `InvokeApi` Dataverse GET gate | `FAIL - STOP` | `phase1_invokeapi_dataverse_test.md` |
| Phase 2 - Drift and format | `NOT_EXECUTED` | Gate blocked before read route was available |
| Phase 3 - Backup snapshot | `NOT_EXECUTED` | Gate blocked before backup read route was available |
| Phase 4 - Dataverse PATCH | `NOT_EXECUTED` | No tenant write attempted |
| Phase 5 - Post-patch verification | `NOT_EXECUTED` | No patch state exists to verify |

## Runbook And Microsoft Basis

Runbook references:

- Tenant constants and installed module versions: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 5-28.
- Forbidden auth paths: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 30-38 and `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` lines 34-47.
- Approved PowerApps auth validation route: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 143-180.
- Existing `InvokeApi -Method PATCH` example is ProcessSimple flow patching only: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 224-294.

Microsoft Learn references for the requested row surface:

- `botcomponent` Web API reference documents the entity set path `/api/data/v9.2/botcomponents`, `GET` and `PATCH` support, and the `data` property: <https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/reference/botcomponent?view=dataverse-latest>
- `botcomponent` table reference documents retrieve and update operations on `/botcomponents(botcomponentid)`: <https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/botcomponent>
- Dataverse Web API row update guidance documents `PATCH` against entity-set row URLs: <https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/update-delete-entities-using-web-api>

The endpoint family is documented by Microsoft. The runbook-approved `InvokeApi` route failed for it in this runtime session and therefore did not satisfy this mission's Phase 1 gate.

## Evidence Summary

### Phase 0

Observed successful approved-path evidence:

- Shell: Windows PowerShell Desktop `5.1.26100.8457`
- `Microsoft.PowerApps.PowerShell`: `1.0.45`
- `Microsoft.PowerApps.Administration.PowerShell`: `2.0.217`
- PAC CLI banner: `2.6.4+ga488322 (.NET Framework 4.8.9325.0)`
- `Add-PowerAppsAccount -Endpoint prod`: completed
- `Get-Flow -EnvironmentName e2d10003-4d8e-e007-9d63-76d5fe89ef56 -Top 5`: returned live flow inventory

Phase output:

- `.planning/comms/incident_3_15_1_import_failure_20260521/codex_phd_analysis/dataverse_patch_replan/phase0_auth_setup.md`

### Phase 1

Attempted read-only row probe:

```powershell
InvokeApi `
  -Method GET `
  -Route "https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/botcomponents(ec4416d0-0744-4e8c-b937-aae4ad9c605b)?`$select=botcomponentid,name,schemaname,data,statecode,statuscode,modifiedon" `
  -ThrowOnFailure
```

Observed failure:

```text
FullyQualifiedErrorId: MsalServiceException,Await-Task
AADSTS65002: Consent between first party application '689e5960-2e49-4505-98d8-369236220fc6' and first party resource '797f4846-ba00-4fd7-ba43-dac1f8f63013' must be configured via preauthorization.
Error timestamp: 2026-05-22 02:39:32Z
```

Phase output:

- `.planning/comms/incident_3_15_1_import_failure_20260521/codex_phd_analysis/dataverse_patch_replan/phase1_invokeapi_dataverse_test.md`

## Five In-Scope Topics

No topic row was patched.

| Topic | Botcomponent ID | Patch result |
|---|---|---|
| `AtualizarStatus` | `ec4416d0-0744-4e8c-b937-aae4ad9c605b` | `NOT_EXECUTED` |
| `AtualizarTarefa` | `6750ff2f-822b-45ab-83ec-058704c7808a` | `NOT_EXECUTED` |
| `ConsultarPortfolio` | `74c5fdcc-c121-452e-85af-24d3f260b3c7` | `NOT_EXECUTED` |
| `CriarTarefa` | `bcbecd76-3158-40ac-b225-5ae7c3874ed1` | `NOT_EXECUTED` |
| `ListarTarefas` | `d58258b4-b17f-4bb9-9e1f-161287a041c4` | `NOT_EXECUTED` |

## Stop Conditions Confirmed

- No Dataverse `PATCH` was attempted.
- No `botcomponent.data` write was executed.
- No other eleven botcomponents were touched or re-fetched in this blocked execution.
- No solution import/export, bot publish, ZIP edit, solution.xml edit, manifest edit, or git commit occurred.
- No MSAL.PS device code, ClientId, app registration, service principal, certificate auth, Graph direct, HTTP Premium connector, or `Connect-PnPOnline -Interactive` path was used.

## Owner Decision Required

The runbook currently proves `InvokeApi -Method PATCH` for ProcessSimple flow endpoints, not direct Dataverse `botcomponents` row endpoints. This execution proved the direct Dataverse GET gate fails in the approved PowerApps PowerShell session before a backup or patch can be performed.

Owner question:

> `InvokeApi` failed the Dataverse `botcomponents` GET gate with `AADSTS65002` under the exact runbook shell and module versions. Should this mission remain stopped pending a runbook update for an approved Dataverse access route, or should the hotfix return to the documented Copilot Studio authoring/export/import path?

## Final Verdict Block

DATAVERSE PATCH FINAL VERDICT

- Verdict: `BLOCKED_BY_RUNBOOK_LIMITATION`
- Topics patcheados: `[]`
- Topics falhados: `[]`
- Topics no-op: `[]`
- Nao-regressao dos 11 demais: `DRIFT_DETECTED` is not asserted; verification was `NOT_EXECUTED` because Phase 1 blocked before the required read route existed.
- Proximo passo Owner: `escalar`
- Rollback ready: `NAO` - no fresh Phase 3 backup path exists because Phase 1 stopped before backup.
- Sign-off (UTC + agent): `2026-05-22T02:39:32Z - CODEX-PHD`
