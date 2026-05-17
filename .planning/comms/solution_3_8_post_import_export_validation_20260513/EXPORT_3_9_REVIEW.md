# Export 3.9 Review - 2026-05-13 20:45 BRT

Agent: Codex
Artifact: `C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_3_9.zip`
SHA256: `E6BADA85D454F48E2C60B9B97276ACAE139D1F99A1E1D4B6B48A2061FFBCDC27`
Size: `66069` bytes
Solution: `PMO_v11_Tarefas`
Display name: `PMO v1.1 - Task Management Topics`
Version: `3.9`

## Decision

Status: **NO-PUBLISH YET**

3.9 is materially cleaner than 3.8, but one stale workflowset mapping remains and must be resolved or explicitly accepted before publishing Copilot Studio.

## Completed / Passed

| Gate | Result | Evidence |
|---|---|---|
| Package exists and opens | PASS | Zip extracted successfully. |
| Solution metadata | PASS | `solution.xml` has `UniqueName=PMO_v11_Tarefas`, `Version=3.9`. |
| Removed legacy adaptive card flows | PASS | No workflow files or XML references remain for `PMO_PA_CheckInOnDemand`, `PMO_PA_EscalarRiscoCritico`, `PMO_PA_RegistrarDecisaoBoard`. |
| Removed orphan batch flow | PASS | No workflow file or XML reference remains for `PMO_PA_Gerar_Multiplos_Projetos`. |
| Missing dependency scan | PASS | No matches for `MissingDependency`, `cat_CopilotStudioKitOutlook`, or `cat_sharedteams_1ef7e`. |
| Core workflow count | PASS | 12 PMO workflow files remain. |
| Core botcomponent count | PASS | 21 botcomponent directories remain. |
| `AtualizarTarefa` skip logic | PASS STATIC | Flow keeps existing values when inputs are blank or equal to `n`, `no`, or `nao` for responsible, due date, and priority fields. |
| PMO workflow SharePoint connection | PASS | All 12 workflow files reference `pmo_sharedsharepointonline_6e373`; none reference `gstf_sharepoint`. |

## Failed / Pending

| Priority | Issue | Evidence | Release impact |
|---|---|---|---|
| P0 | Stale workflowset mapping remains | `Assets/botcomponent_workflowset.xml` still contains `pmo_AssistentePMO_V2.topic.CriarTarefa -> workflowid 3104124d-364a-f111-bec7-7ced8d955c6c`. That workflow id belongs to `PMO_PA_CriarProjeto`. | Keep NO-PUBLISH until corrected or owner explicitly accepts it as non-runtime residue. |
| P1 | Extra connection reference remains | `customizations.xml` still contains `<connectionreference connectionreferencelogicalname="gstf_sharepoint">`. No PMO workflow references it. Physical deletion is blocked by 11 unrelated published processes. | Not a runtime blocker by itself, but still package hygiene debt if it remains in the PMO solution export. |
| P1 | Dataverse MCP read verification unavailable | Read-only `dataverse_whoami` / entity resolution timed out. Local PAC auth is available as `COLQA0424 / mbenicios@minsait.com / ColOfertasBrasilPro`. | MCP unavailable, but PAC FetchXML read verified the exact stale association row. |

## Exact Stale Mapping

Do not delete `pmo_AssistentePMO_V2.topic.CriarTarefa`.
Do not delete workflow `3104124d-364a-f111-bec7-7ced8d955c6c`, because that is the kept `PMO_PA_CriarProjeto` flow.

The incorrect item is only this workflowset relationship:

```xml
<botcomponent_workflow botcomponentid.schemaname="pmo_AssistentePMO_V2.topic.CriarTarefa" workflowid.workflowid="3104124d-364a-f111-bec7-7ced8d955c6c">
  <iscustomizable>1</iscustomizable>
</botcomponent_workflow>
```

PAC FetchXML read-only check identified the tenant row:

```text
entity: botcomponent_workflow
botcomponent_workflowid: 678fae11-394a-f111-bec7-6045bdf42cae
botcomponentid: bcbecd76-3158-40ac-b225-5ae7c3874ed1
botcomponent schemaname: pmo_AssistentePMO_V2.topic.CriarTarefa
workflowid: 3104124d-364a-f111-bec7-7ced8d955c6c
workflow name: PMO_PA_CriarProjeto
solutionid shown by PAC: fd140aae-4df4-11dd-bd17-0019b9312238
```

Correct rows also verified:

```text
pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto -> workflowid 3104124d-364a-f111-bec7-7ced8d955c6c
pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa -> workflowid 0a5d2a41-24c0-4d5e-9f6d-000000000241
```

The correct create-task action is present:

```text
pmo_AssistentePMO_V2.topic.CriarTarefa/data -> dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa
pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa/data -> flowId: 0a5d2a41-24c0-4d5e-9f6d-000000000241
```

## Next Step

1. If Power Platform UI exposes a botcomponent workflow/association row, remove only the stale association above.
2. If the UI does not expose it, use a targeted technical cleanup path. Do not delete either the topic or the `PMO_PA_CriarProjeto` flow.
3. Export again after cleanup.
4. Codex will re-scan for:

```text
MissingDependency
cat_CopilotStudioKitOutlook
cat_sharedteams_1ef7e
PMO_PA_CheckInOnDemand
PMO_PA_EscalarRiscoCritico
PMO_PA_RegistrarDecisaoBoard
PMO_PA_Gerar_Multiplos_Projetos
pmo_AssistentePMO_V2.topic.CriarTarefa -> workflowid 3104124d-364a-f111-bec7-7ced8d955c6c
```
