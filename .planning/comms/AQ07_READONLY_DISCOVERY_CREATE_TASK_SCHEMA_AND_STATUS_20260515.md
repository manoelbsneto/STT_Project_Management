# AQ-07 Read-Only Discovery: CreateTask Contract And Status Choices

Date: 2026-05-15
Owner: CODEX-LEAD
Task ID: AQ-07-READONLY-DISCOVERY-CREATETASK-STATUS
Release decision: NO-SHIP

## Verdict

STATUS: BLOCKED_REWORK_REQUIRED

AQ-07 is not green for another build/save/import attempt.

Two blockers remain:

1. Planner `CreateTask_V3` tenant-compatible ProcessSimple parameter shape is still not proven.
2. Live SharePoint `Tarefas.Status` choices do not match the AQ-07 FI-04 status mapping.

## Tenant Actions Performed

Read-only only:

- Power Automate `Get-Flow` inventory through the approved PowerApps PowerShell route.
- SharePoint `Tarefas` schema read through the approved legacy PnP read-only script.

No flow save/import/delete was performed during this discovery.
No Copilot publish was performed.
No AQ-09 runtime smoke test was performed.
No SharePoint item write was performed.
No Planner write was performed.
No Teams production post was performed.
No Microsoft 365 CLI / `m365` was used.
No `pac solution import` was used.

## Evidence

Power Automate read-only inventory:

```text
Get-Flow -EnvironmentName e2d10003-4d8e-e007-9d63-76d5fe89ef56 -Top 20
```

Result:

```text
flowCount=64
Existing task-related flows observed:
- TESTE - Planner - List my tasks / 09fac023-ae01-41e7-ba21-67087f954f25
- PMO_PA_CriarTarefa / b70dc891-7e57-89e7-7494-f2786553893c
- PMO_PA_ExcluirTarefa / 2269a995-6e7f-3ccf-29de-8ecffaee50e1
- PMO_PA_AtualizarTarefa / cf4a5713-68fe-416c-b4e3-562e70fd6708
```

Notes:

- Local repository search found no existing saved `CreateTask_V3` action definition outside the AQ-07 attempted package.
- Existing `.planning/comms/processsimple_criartarefa_request_89050663-1163-b36c-659b-6fcaa0edfee0.json` is a SharePoint project-create flow, not a Planner task-create contract.
- Targeted individual Flow detail calls through the PowerApps module hung and were stopped locally.
- Direct Flow REST with the cached Azure token returned `EnvironmentAccessDenied`; it was read-only but cannot be used as evidence for this tenant's flow definition details.

SharePoint live read-only schema refresh:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\deploy\Get-SharePointListXmlReadOnly.ps1 -SiteUrl "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital" -ListNames "Tarefas" -OutputDir ".planning\comms\aq07_power_automate_build_20260515\read_only_discovery_20260515\sharepoint_tarefas_schema"
```

Evidence folder:

```text
.planning/comms/aq07_power_automate_build_20260515/read_only_discovery_20260515/sharepoint_tarefas_schema/
```

Live list:

```text
List: Tarefas
ListId: 36d78ca1-1f60-4dd3-a4d5-5c94b89969e9
ItemCount: 16
```

Live `Tarefas.Status` field evidence:

```text
.planning/comms/aq07_power_automate_build_20260515/read_only_discovery_20260515/sharepoint_tarefas_schema/Tarefas/fields/Status.xml
```

Observed choices:

```text
Pendente
Em Andamento
Concluida
Cancelada
```

The exported XML shows the accented value with encoding artifacts, but the semantic value is `Concluida`.

AQ-07 FI-04 mapping currently requires:

```text
Pendente
Em andamento
Concluido
Cancelado
Piloto e Implantacao
Testes
```

Mismatch:

| AQ-07 value | Live SharePoint choice status |
|---|---|
| `Em andamento` | Case mismatch with live `Em Andamento` |
| `Concluido` | Not present; live value is feminine/accented `Concluida` |
| `Cancelado` | Not present; live value is `Cancelada` |
| `Piloto e Implantacao` | Not present |
| `Testes` | Not present |
| `Pendente` | Present |

## Blockers

AQ07-BLOCK-12: `CreateTask_V3` parameter shape is still unproven for ProcessSimple save.

AQ07-BLOCK-13: FI-04 can still write a `Tarefas.Status` value that is not a live SharePoint choice.

Because of AQ07-BLOCK-13, even a corrected Planner action could still create inconsistent or failed SharePoint writes.

## Next Owner Decision Needed

Choose one path before another AQ-07 save/import attempt:

1. Update SharePoint `Tarefas.Status` choices to include the AQ-07 workflow statuses, then rerun AQ-07 local validation.
2. Rework AQ-07 FI-04/FI-05 mapping to use the current live `Tarefas.Status` choices exactly.
3. Defer Planner create/update build and implement FI-04/FI-05 manually in the Power Automate portal, capturing screenshots of the portal-generated `CreateTask_V3` and `UpdateTask_V3` parameter names before any ProcessSimple retry.

Recommended path: rework AQ-07 mapping to the live SharePoint choices unless the owner explicitly wants a SharePoint schema change for new workflow statuses.

## Current Status

```text
TASK_ID: AQ-07-READONLY-DISCOVERY-CREATETASK-STATUS
STATUS: BLOCKED_REWORK_REQUIRED
DELIVERY_FORMAT: Evidence report
TENANT_ACTIONS_PERFORMED: read-only Power Automate inventory and read-only SharePoint schema refresh only
FORBIDDEN_ACTIONS_CONFIRMED_NOT_PERFORMED: flow save/import/delete, Copilot publish, AQ-09 runtime smoke, SharePoint item writes, Planner writes, Teams production posts, m365, pac solution import
RELEASE_DECISION: NO-SHIP
```
