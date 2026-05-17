# Agent 2 Live Inventory - Ghost/Duplicate Bot and Bindings

Date: 2026-05-11  
Environment: `e2d10003-4d8e-e007-9d63-76d5fe89ef56` / `ColOfertasBrasilPro`  
Active bot checked: `df148bf8-0a3e-495b-80c4-841dcb61d9a4`  
Method: PAC/Dataverse FetchXML only. No browser used.

## Status

GREEN for live ghost/duplicate inventory.

Live Dataverse currently exposes one PMO bot family only:

| Bot | Schema | State | Status | Modified |
|---|---|---|---|---|
| `df148bf8-0a3e-495b-80c4-841dcb61d9a4` | `pmo_AssistentePMO_V2` | `Activo` | `Aprovisionado` | `11/05/2026 10:30` |

All fetched active PMO bot components belong to parent bot `Assistente PMO V2` and use schema prefix `pmo_AssistentePMO_V2.`. No live `pmo_AssistentePMO_Clean.*` or legacy `pmo_AssistentePMO.*` bot components were returned by the PMO family query.

## Active V2 Bindings

`botcomponent_workflow` returned only V2 bindings:

| Component | Workflow | Workflow ID | Workflow status |
|---|---|---|---|
| `pmo_AssistentePMO_V2.topic.CriarTarefa` | `PMO_PA_CriarTarefa_V3` | `3104124d-364a-f111-bec7-7ced8d955c6c` | `Activado` |
| `pmo_AssistentePMO_V2.topic.AtualizarStatus` | `PMO_PA_AtualizarStatus` | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | `Activado` |
| `pmo_AssistentePMO_V2.topic.ConsultarPortfolio` | `PMO_PA_ConsultarPortfolio` | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | `Activado` |
| `pmo_AssistentePMO_V2.topic.ConsultarProjeto` | `PMO_PA_ConsultarProjeto` | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | `Activado` |
| `pmo_AssistentePMO_V2.topic.PedirDecisao` | `PMO_PA_PedirDecisaoBot` | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | `Activado` |
| `pmo_AssistentePMO_V2.topic.RegistrarBloqueio` | `PMO_PA_RegistrarBloqueioBot` | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | `Activado` |
| `pmo_AssistentePMO_V2.topic.RegistrarRisco` | `PMO_PA_RegistrarRiscoBot` | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | `Activado` |
| `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` | `PMO_PA_AtualizarTarefa` | `98408d55-3748-f111-bec7-000d3abc5cc6` | `Activado` |
| `pmo_AssistentePMO_V2.action.PMO_PA_CheckInOnDemand` | `PMO_PA_CheckInOnDemand` | `f5aab85e-ff46-f111-bec7-7ced8d955c6c` | `Activado` |
| `pmo_AssistentePMO_V2.action.PMO_PA_EscalarRiscoCritico` | `PMO_PA_EscalarRiscoCritico` | `e5381002-0547-f111-bec7-000d3abc5cc6` | `Activado` |
| `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` | `PMO_PA_ListarTarefas` | `9544f14b-3748-f111-bec7-6045bdf42cae` | `Activado` |
| `pmo_AssistentePMO_V2.action.PMO_PA_RegistrarDecisaoBoard` | `PMO_PA_RegistrarDecisaoBoard` | `b308fe0b-0547-f111-bec7-7ced8d955c6c` | `Activado` |

Explicit non-V2 PMO binding query returned no rows.

## Orphan/Duplicate Findings

No live orphan bot components found under `pmo_AssistentePMO.*`.

No live duplicate PMO bot rows found. Query by `schemaname LIKE pmo_AssistentePMO%` and `name LIKE %Assistente PMO%` returned only `pmo_AssistentePMO_V2`.

Previous duplicate/unbound workflow cleanup candidates from `.planning/comms/v2_cleanup_baseline_20260511_002257/FLOW_CLEANUP_CANDIDATES.md` no longer exist in live Dataverse. Exact old IDs queried and returned no rows:

| Old candidate | Workflow ID |
|---|---|
| `Clean_PMO_PA_CriarTarefa` | `42d9abd1-8849-f111-bec7-7ced8d955c6c` |
| `PMO_PA_AtualizarStatus` duplicate | `d2645ec7-c84c-f111-bec7-000d3abc5cc6` |
| `PMO_PA_ConsultarPortfolio` duplicate | `e4c43bb3-c84c-f111-bec7-7ced8d955c6c` |
| `PMO_PA_ConsultarProjeto` duplicate | `f9c43bb3-c84c-f111-bec7-000d3abc5cc6` |
| `PMO_PA_PedirDecisaoBot` duplicate | `81917ec0-c84c-f111-bec7-000d3abc5cc6` |
| `PMO_PA_RegistrarBloqueioBot` duplicate | `68917ec0-c84c-f111-bec7-000d3abc5cc6` |
| `PMO_PA_RegistrarRiscoBot` duplicate | `e14ca9b9-c84c-f111-bec7-7ced8d955c6c` |

Live `workflow` query for `PMO_PA_%` / `Clean_PMO_PA_%` returned only the 12 active V2-bound workflow rows listed above. No unbound duplicate rows were returned.

## Commands Run

```powershell
pac auth list
```

```powershell
pac --version
```

Note: this PAC version rejects `--version` as a top-level command, but the output identified `Microsoft PowerPlatform CLI Version: 2.6.4+ga488322`.

```powershell
Get-Content .planning\comms\v2_cleanup_baseline_20260511_002257\FLOW_CLEANUP_CANDIDATES.md
```

```powershell
Import-Csv .planning\comms\v2_cleanup_baseline_20260511_002257\flow_binding_inventory.csv | Format-Table -AutoSize | Out-String -Width 240
```

```powershell
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\active_bot.xml
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\active_bot_components.xml
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\pmo_component_families.xml
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\pmo_workflow_bindings.xml
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\pmo_workflows.xml
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\pmo_bots.xml
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\old_duplicate_workflow_ids.xml
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <temp>\non_v2_pmo_bindings.xml
```

Temporary XML files were created under `%TEMP%` and removed after execution.

## Blockers

None for live PAC/Dataverse inventory.

Not covered by this inventory: browser publish proof, Copilot runtime chat proof, Power Automate run proof, or SharePoint write proof. Those remain separate acceptance gates if the sprint requires runtime validation beyond binding inventory.

## Cleanup Recommendation

Do not delete any current bot components or active workflows. Live evidence shows the active bot and all active bindings point to `pmo_AssistentePMO_V2` only.

No additional ghost botcomponent cleanup is recommended now. No duplicate/unbound flow cleanup remains from the prior baseline candidate list because the old workflow IDs no longer resolve in Dataverse.

## Acceptance Recommendation

Accept the ghost/duplicate bot and active binding inventory as closed for the PAC/Dataverse layer.

Exact acceptance statement:

`ACCEPT: Active bot df148bf8-0a3e-495b-80c4-841dcb61d9a4 is pmo_AssistentePMO_V2, all live PMO botcomponent_workflow rows point to pmo_AssistentePMO_V2 components, non-V2 PMO bindings return zero rows, and prior duplicate workflow cleanup candidates are absent from live Dataverse.`

Keep runtime SHIP/NO-SHIP dependent on separate post-publish Copilot chat, flow run, and SharePoint evidence if not already captured.
