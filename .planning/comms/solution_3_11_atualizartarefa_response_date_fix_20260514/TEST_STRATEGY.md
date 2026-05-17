# Test Strategy - Solution 3.11 AtualizarTarefa Response Date Fix

Date: 2026-05-14
Owner role: Agent D - QA / Test Architect
Scope: `PMO_PA_AtualizarTarefa` runtime blockers after export 3.10
Release state: NO-SHIP until post-publish runtime evidence passes

## Guardrails

- No tenant writes, imports, publishes, deletes, commits, portal edits, runtime edits, or production data changes were performed by Agent D.
- This document is the only repository file created for this assignment.
- CI gate is explicitly excluded by owner for this cycle.
- Local static/package gates and post-publish Copilot/Power Automate runtime gates remain mandatory.
- Test evidence must tie to the exact artifact under validation, not an older export or old bot publish.

## Baseline Artifact

Export 3.10 under review:

```text
Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip
SHA256: 37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691
Solution unique name: PMO_v11_Tarefas
Solution metadata version observed in 3.10 review: 3.9
```

Existing 3.10 review:

```text
.planning/comms/solution_3_8_post_import_export_validation_20260513/EXPORT_3_10_POST_WFSET_CLEAN_REVIEW.md
Decision there: GO FOR OWNER PUBLISH + RUNTIME QA, not final ship approval.
```

3.11 import candidate:

```text
Solution/PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip
SHA256: D1752B089424ACA6C571374B8897AD12F8A8304DF228A17C8C591BD1EEF1CDAF
Solution metadata version: 3.11
```

## Microsoft Source Rules

Runtime behavior must be validated against tenant evidence plus official Microsoft documentation:

- Copilot Studio publish behavior: https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-fundamentals-publish-channels
- Copilot Studio test panel/evidence: https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-test-bot
- Power Automate date formatting: https://learn.microsoft.com/en-us/power-automate/date-time-values
- Workflow expression functions, including `formatDateTime`, `convertTimeZone`, and `parseDateTime`: https://learn.microsoft.com/en-us/azure/logic-apps/workflow-definition-language-functions-reference
- SharePoint connector actions: https://learn.microsoft.com/en-us/sharepoint/dev/business-apps/power-automate/sharepoint-connector-actions-triggers

## Local Gate Results Observed

Executed locally against 3.11:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-AtualizarTarefaSkipSemantics.ps1 -PackagePath "Solution/PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-SolutionZipP0Contracts.ps1 -PackagePath "Solution/PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-SolutionZipP24Contracts.ps1 -PackagePath "Solution/PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip" -ExpectedVersion "3.11"
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath ".planning/comms/solution_3_11_atualizartarefa_response_date_fix_20260514/unpacked"
```

Result:

- SHA256 recorded as `D1752B089424ACA6C571374B8897AD12F8A8304DF228A17C8C591BD1EEF1CDAF`.
- `tests/Test-AtualizarTarefaSkipSemantics.ps1` passed with `failedCheckCount = 0`.
- `tests/Test-SolutionZipP0Contracts.ps1` passed with `failedCheckCount = 0`.
- `tests/Test-SolutionZipP24Contracts.ps1 -ExpectedVersion "3.11"` passed with `failedCheckCount = 0`.
- `tests/Test-PMOFlowStopShipAudit.ps1` passed with `failedCheckCount = 0`.
- The 3.11 package no longer carries the stale `gstf_sharepoint` connection reference.

## 3.11 Local Static/Package Gates

Run before any owner publish decision:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-AtualizarTarefaSkipSemantics.ps1 -PackagePath <3.11-package.zip>
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-SolutionZipP0Contracts.ps1 -PackagePath <3.11-package.zip>
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-SolutionZipP24Contracts.ps1 -PackagePath <3.11-package.zip> -ExpectedVersion <3.11-solution-version>
```

Required targeted checks for `PMO_PA_AtualizarTarefa`:

- JSON parses cleanly.
- No non-ASCII app-facing text in workflow/client data.
- No `runtimeSource: invoker`.
- No raw APIM token or connection key material.
- Update action targets `Tarefas`.
- `Status` and `Prioridade` use SharePoint choice `/Value` paths.
- Project counter recalculation remains guarded by project lookup and `PROJECT_NOT_FOUND`.
- Overdue comparison remains normalized with `formatDateTime(..., 'yyyy-MM-dd')`.
- `DataFim` non-skip inputs are normalized from `dd/MM/yyyy` to an ISO-safe date before SharePoint update.
- Response text shows the normalized date, not an unparsed raw `dd/MM/yyyy` string when the flow writes ISO format.

## Regression Mapping

| Risk | Input | Expected persisted value | Required static evidence | Required runtime evidence |
|---|---|---|---|---|
| Responsible skip overwrites person/text field | `Responsavel=nao` | Existing `Responsavel` remains unchanged | `text_1` branch returns `body('Get_Tarefa_Atual')?['Responsavel']` for blank/`n`/`no`/`nao`/short n-token | SharePoint item before/after shows unchanged `Responsavel`; run history shows update action received persisted value |
| Due-date skip overwrites date field | `DataFim=nao` | Existing `DataFim` remains unchanged | `text_2` branch returns `body('Get_Tarefa_Atual')?['DataFim']` for blank/`n`/`no`/`nao`/short n-token | SharePoint item before/after shows unchanged `DataFim`; bot response must not report `nao` as date |
| Priority skip overwrites choice field | `Prioridade=nao` | Existing `Prioridade` remains unchanged | `text_3` branch returns current `Prioridade` choice for blank/`n`/`no`/`nao`/short n-token | SharePoint item before/after shows unchanged `Prioridade`; run history shows valid choice value |
| Hours skip overwrites numeric field | `HorasRealizadas=0` or omitted | Existing `HorasRealizadas` remains unchanged | `number_1` branch returns current value when null or `0` | SharePoint item before/after shows unchanged hours |
| Brazilian due date fails SharePoint update | `DataFim=31/12/2026` | `DataFim` stored as the intended 2026-12-31 date | Non-skip `text_2` branch composes `yyyy-MM-dd` or ISO-safe equivalent before `Update_Tarefa` | Run succeeds; SharePoint date displays 31/12/2026 or tenant equivalent for the same date |
| ISO date regresses | `DataFim=2026-12-31` | `DataFim` stored as 2026-12-31 | ISO input path remains accepted | Run succeeds; no day/month inversion |
| Invalid date creates corrupt write | `DataFim=31/02/2026` | No successful SharePoint update | SharePoint date conversion rejects invalid timestamp | Flow failure is acceptable only if no item mutation occurs |

## Post-Publish Runtime Gates

These must run only after the owner imports/publishes 3.11 in Copilot Studio. Capture Copilot chat transcript/screenshot, Power Automate run URL, run inputs/outputs, and SharePoint before/after item evidence for each write test.

1. `AtualizarTarefa` skip preservation smoke.
   - Use a known active task with non-empty `Responsavel`, `DataFim`, `Prioridade`, and `HorasRealizadas`.
   - Ask to update status only, with `Responsavel=nao`, `DataFim=nao`, `Prioridade=nao`, `HorasRealizadas=0`.
   - Expected: flow run succeeds, status changes, skipped fields keep persisted values, project counters recalculate.

2. `AtualizarTarefa` date normalization smoke.
   - Update the same or fresh task with `DataFim=31/12/2026`.
   - Expected: flow run succeeds, SharePoint stores the intended date, bot response shows the intended normalized date.

3. `AtualizarTarefa` ISO compatibility.
   - Update with `DataFim=2026-12-31`.
   - Expected: stored date is 2026-12-31 and no parser regression occurs.

4. `AtualizarTarefa` invalid date guard.
   - Attempt `DataFim=31/02/2026`.
   - Expected: no SharePoint mutation; run evidence proves the update action did not corrupt `DataFim`.

5. `ListarTarefas` after update.
   - Query tasks for the affected project.
   - Expected: updated task appears once, active/non-deleted only, due date and status match SharePoint.

6. Create/update integration sanity.
   - Create a fresh task through `CriarTarefa`, then update it through `AtualizarTarefa`.
   - Expected: create writes only `Tarefas`; update modifies the same task; no project row is created or overwritten.

7. `PedirDecisao` UPN guard regression.
   - Invalid UPN must be rejected before flow call/write.
   - Valid UPN must create the decision request correctly.

8. `ConsultarPortfolio` sanity.
   - Expected totals and names match active non-deleted SharePoint rows after the task update.

## Ship Decision Rule

Keep NO-SHIP if any of these are true:

- 3.11 package hash and version are not recorded.
- Any mandatory local static/package gate fails without explicit owner acceptance.
- Copilot Studio is not published after import.
- Runtime evidence is missing, stale, or tied to a previous publish.
- `nao` is persisted into `Responsavel`, `DataFim`, or `Prioridade`.
- `dd/MM/yyyy` input fails, writes the wrong date, or returns a misleading date in the bot response.
- Power Automate run succeeds but SharePoint before/after evidence does not match the expected mutation.
- Any write topic is confirm-only, placeholder-only, or bound to an old/stale flow ID.
