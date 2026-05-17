# P0 Remaining Gates Execution Runbook

Date: 2026-05-15
Scope: AQ-03, AQ-07, AQ-08, AQ-09, AQ-10
Status: OWNER EXECUTION RUNBOOK
Release decision: NO-SHIP
Tenant execution by this artifact: None

## 1. Current Status

This artifact is a local planning/runbook document only.

No tenant writes, Planner writes, SharePoint writes, Teams posts, Power Automate saves/imports, or Copilot Studio publishes are authorized or performed by creating this file.

Current gate state:

| Gate | Status | Evidence |
|---|---|---|
| AQ-02 SharePoint `Tarefas` schema read-only | DONE_READONLY | `.planning/comms/AQ02_SHAREPOINT_TAREFAS_SCHEMA_READONLY_20260515.md` |
| AQ-04 Planner IDs | PASS OWNER EVIDENCE | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| AQ-03 SharePoint schema write | DONE_TENANT_WRITE | `.planning/comms/AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md` |
| AQ-07 flow save/import | READY FOR OWNER APPROVAL REQUEST | Gemini AQ-07 portal-build package passed CODEX local review; see `.planning/comms/CODEX_REVIEW_GEMINI_AQ07_FINAL_PASS_20260515.md`. No tenant action executed yet. |
| AQ-08 Copilot update/publish | BLOCKED | Requires owner approval and portal/manual evidence |
| AQ-09 runtime smoke and XPIA regression | BLOCKED | Requires AQ-03, AQ-07, and AQ-08 evidence first |
| AQ-10 final release decision | BLOCKED | Requires all non-CI gates tied to the current artifact |

Release remains:

```text
NO-SHIP
```

## 2. Exact Next Sequence

Run the remaining gates in this order only:

1. AQ-03: complete. Schema write evidence is captured.
2. AQ-07: identify the exact importable or portal-build artifact/path, review it locally, obtain flow save/import approval, perform the owner-approved Power Automate portal/import path, then capture flow IDs, import/save evidence, and rollback evidence.
3. AQ-08: obtain Copilot update/publish approval, perform the owner-approved Copilot Studio update/publish path, then capture publish evidence.
4. AQ-09: run runtime smoke from the locally defined smoke queue and capture proof that Copilot/Teams returns bounded card behavior with no raw SharePoint/Planner output, no `ContentFiltered`, and no `openAIIndirectAttack`/XPIA failure.
5. AQ-10: make final SHIP/NO-SHIP decision only after every non-CI gate has current evidence tied to the exact imported/published artifact.

Do not start AQ-09 before AQ-07 and AQ-08 evidence exists.

## 3. AQ-03: SharePoint Schema Write

Status: complete.

Evidence:

```text
.planning/comms/AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md
.planning/comms/aq03_tarefas_schema_update_20260515/evidence/aq03_tarefas_planner_fields_write_summary.json
.planning/comms/aq03_tarefas_schema_update_20260515/evidence/aq03_tarefas_planner_fields_verify.csv
.planning/comms/sharepoint_schema_tarefas_aq03_after_20260515/
```

Purpose: add the missing Planner mapping fields to SharePoint list `Tarefas`.

Fields:

| Internal Name | Type |
|---|---|
| `PlannerTaskId` | Text |
| `PlannerBucketId` | Text |
| `PlannerSyncStatus` | Choice: `Pendente`, `OK`, `Erro`, `Ignorado` |
| `PlannerLastSyncAt` | DateTime |
| `PlannerSyncError` | Note |

Required owner approval text:

```text
Approve CODEX-LEAD to execute AQ-03 and add the Planner mapping fields to SharePoint list Tarefas using .planning/comms/aq03_tarefas_schema_update_20260515/Add-TarefasPlannerFields.ps1 with -ConfirmTenantWrite. No Planner writes, flow saves, imports, publishes, or Teams production posts are authorized.
```

Exact command already defined locally:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass
```

Then:

```powershell
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$env:PNPLEGACYMESSAGE = "false"
Set-Location "D:\VMs\Projetos\STT_Project_Management"
Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin
.\.planning\comms\aq03_tarefas_schema_update_20260515\Add-TarefasPlannerFields.ps1 -SiteUrl $siteUrl -SkipConnection -ConfirmTenantWrite
```

Expected evidence:

```text
.planning/comms/aq03_tarefas_schema_update_20260515/evidence/aq03_tarefas_planner_fields_write_summary.json
.planning/comms/aq03_tarefas_schema_update_20260515/evidence/aq03_tarefas_planner_fields_verify.csv
```

Recommended post-write read-only evidence command already defined locally:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\deploy\Get-SharePointListXmlReadOnly.ps1 -SiteUrl "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital" -ListNames "Tarefas" -OutputDir ".planning\comms\sharepoint_schema_tarefas_aq03_after_20260515"
```

AQ-03 rollback position: non-destructive by default. Stop depending flows and ignore the new fields. Do not remove fields unless the owner gives separate explicit approval after dependency review.

## 4. AQ-07: Flow Save / Import

Purpose: save/import the Power Automate implementation that connects Copilot/card routes to SharePoint, Teams, and Planner behavior.

Required owner approval text:

```text
Approve AQ-07 Power Automate flow save/import for the P0 Adaptive Cards + Planner package through the owner-approved Power Automate or solution import path. Capture import/save evidence, flow IDs, connection references, and rollback evidence. This approval does not authorize Copilot publish, runtime smoke execution, Planner writes beyond the approved flow behavior, Teams production posts outside the approved smoke plan, or final SHIP.
```

Commands: no AQ-07 import/save command is defined in the required local files for this P0 package. Use portal/manual owner execution evidence rather than inventing a command.

Required evidence:

| Evidence | Requirement |
|---|---|
| Import/save proof | Screenshot or export/import log showing success for the current P0 flow artifact |
| Flow identity | Flow display names and IDs for the current imported/saved flows |
| Connection references | Evidence that SharePoint, Teams, and Planner connections are mapped to approved connectors |
| Static output check | Proof Copilot-facing flow outputs are bounded and do not expose raw SharePoint/Planner JSON |
| Rollback | Prior flow/export package or documented disable/revert path |

Stop if any flow import/save fails, uses an unapproved connection, exposes raw connector output to Copilot, or cannot be tied to the current artifact.

## 5. AQ-08: Copilot Update / Publish

Purpose: update/publish the Copilot routing/topic layer after AQ-07 is complete.

Required owner approval text:

```text
Approve AQ-08 Copilot Studio update/publish for the P0 Adaptive Cards + Planner routing topics after AQ-07 flow save/import evidence is complete. Capture publish evidence, topic/action binding evidence, and rollback evidence. This approval does not authorize additional flow imports, SharePoint schema writes, Planner writes outside approved runtime behavior, or final SHIP.
```

Commands: no AQ-08 Copilot publish command is defined in the required local files. Use Copilot Studio portal/manual evidence rather than inventing a command.

Required evidence:

| Evidence | Requirement |
|---|---|
| Publish proof | Screenshot or portal record showing publish success after AQ-07 |
| Binding proof | Topics/actions route to the current P0 flows, not stale flow IDs |
| Output proof | Copilot responses are short acknowledgements and do not contain raw SharePoint/Planner rows |
| Rollback | Prior published version/export or documented revert path |

Stop if publish fails, bindings point to stale flows, topic output contains raw connector payloads, or publish evidence is missing.

## 6. AQ-09: Runtime Smoke and XPIA Regression

Purpose: prove the imported/published runtime behavior in Copilot/Teams with current evidence.

Required owner approval text:

```text
Approve AQ-09 runtime smoke for the P0 Adaptive Cards + Planner package using .planning/comms/P0_RUNTIME_SMOKE_COMMANDS_ADAPTIVE_CARDS_PLANNER_20260514.md. Capture Copilot transcripts or Teams screenshots, route targets, card versions, Power Automate run IDs/URLs, SharePoint before/after evidence for writes, Planner evidence where applicable, and explicit no ContentFiltered/openAIIndirectAttack evidence. Stop on any failed smoke row or unsafe output.
```

Use only the smoke commands/actions already defined in `.planning/comms/P0_RUNTIME_SMOKE_COMMANDS_ADAPTIVE_CARDS_PLANNER_20260514.md`, including:

| Evidence ID | Action |
|---|---|
| `DV-01` | Send `status executivo dos projetos` in Copilot chat |
| `DV-02` | Verify executive portfolio card in `Projetos_Transformacao_Digital` |
| `DV-04` | Click red-projects drilldown action |
| `DV-05` | Click no-update drilldown action |
| `DV-06` | Click PM update request action |
| `PMU-01` | Submit structured status card values |
| `PMU-02` | Submit single-box status text |
| `PMU-03` | Confirm the single-box review card |
| `TPL-01` | Send `listar tarefas do projeto QA Robust 20260513 F` |
| `TPL-01-CARD` | Verify direct-chat task list card |
| `TPL-02` | Submit create-task card only after all write approvals are green |

Required no-XPIA/no-filter evidence:

| Check | Pass condition |
|---|---|
| `ContentFiltered` | The term does not appear in Copilot response, Teams card output, or relevant flow run error output |
| `openAIIndirectAttack` | The known XPIA failure does not appear in runtime output or flow error details |
| Raw output exposure | Copilot does not display raw SharePoint rows, Planner rows, JSON arrays, connector traces, or stack traces |
| Route safety | Cards post only to the approved route/channel/direct chat targets |

Stop if any smoke row produces `ContentFiltered`, `openAIIndirectAttack`, raw connector output, a wrong route, a failed write, stale flow IDs, or evidence tied to a previous publish.

## 7. AQ-10: Final Decision

Purpose: decide SHIP or NO-SHIP from current evidence only.

Required owner approval text:

```text
Approve AQ-10 final release decision review for the P0 Adaptive Cards + Planner package. Use only current evidence tied to the executed AQ-03 schema update, AQ-07 flow save/import, AQ-08 Copilot publish, and AQ-09 runtime smoke. CI remains owner-excluded only for this mission; every other non-CI gate remains mandatory.
```

SHIP is allowed only if all of these are true:

| Gate | Required state |
|---|---|
| AQ-03 | Schema fields exist and evidence is current |
| AQ-07 | Flow save/import succeeded and rollback is documented |
| AQ-08 | Copilot publish succeeded and bindings point to current flows |
| AQ-09 | Runtime smoke passed with screenshots/transcripts/run IDs |
| XPIA | No `ContentFiltered` or `openAIIndirectAttack` evidence |
| Security/output | No raw SharePoint/Planner output to Copilot |
| Rollback | Schema, flow, Copilot, and runtime rollback/stop paths exist |

If any row is missing, stale, failed, or tied to an older artifact, the AQ-10 decision is:

```text
NO-SHIP
```

## 8. Global Stop Criteria

Stop execution and keep `NO-SHIP` if any of the following occurs:

- Owner approval text is missing or narrower than the intended action.
- A command or portal action would exceed the approved gate scope.
- A required local command is not already defined.
- SharePoint schema write fails or post-write read-only evidence does not show all five fields.
- Flow import/save fails, uses unexpected connections, or cannot be mapped to the current artifact.
- Copilot publish fails or bindings point to stale flows/actions.
- Runtime smoke routes to the wrong Teams channel/chat.
- Copilot exposes raw SharePoint/Planner rows, raw JSON, stack traces, or connector diagnostics.
- `ContentFiltered` or `openAIIndirectAttack` appears in runtime evidence.
- SharePoint or Planner write behavior differs from the approved smoke plan.
- Rollback evidence is missing before a write/import/publish gate.

## 9. Rollback Summary

| Area | Default rollback |
|---|---|
| AQ-03 SharePoint schema | Non-destructive: stop depending flows and ignore fields. Field deletion requires separate explicit approval and dependency check. |
| AQ-07 flows | Disable or revert to last known good flow/export through owner-approved Power Automate/solution path. Capture evidence. |
| AQ-08 Copilot | Revert to prior published topic/action binding or prior solution/export through owner-approved Copilot Studio path. Capture evidence. |
| AQ-09 runtime | Stop smoke immediately, preserve failed run IDs/screenshots, do not retry with changed behavior until the failure is triaged. |
| AQ-10 decision | Default to `NO-SHIP` when evidence is incomplete, stale, ambiguous, or not tied to the current artifact. |

No tenant writes were performed while creating this runbook.
