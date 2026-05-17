# Export 3.10 Post Workflowset Cleanup Review - 2026-05-13 21:02 BRT

Agent: Codex
Artifact: `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`
SHA256: `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`
Size: `66060` bytes
Solution unique name: `PMO_v11_Tarefas`
Solution display name: `PMO v1.1 - Task Management Topics`
Solution metadata version: `3.9`

## Tenant Write Performed

Owner approval:

```text
Approved: remove only botcomponent_workflowid 678fae11-394a-f111-bec7-6045bdf42cae. Do not delete the topic or any flow.
```

Execution:

```text
Command: pac data bulk-delete schedule --entity botcomponent_workflow --fetchxml <exact botcomponent_workflowid filter>
Bulk delete Job ID returned by schedule command: 5aef7732-274f-f111-bec7-7ced8d9559c1
Bulk delete Job ID shown by PAC status: 00969442-9948-4bf7-b62b-f9417f1b517a
Job name: PMO remove stale CriarTarefa workflowset 678fae11
Status: Correcto
State: Completado
Records Deleted: 1
Records Failed: 0
```

Post-delete verification:

```text
FetchXML query for botcomponent_workflowid 678fae11-394a-f111-bec7-6045bdf42cae returned no rows.
```

No topic or flow was deleted.

## Static Gate Result

Status: **PASS FOR OWNER PUBLISH AND RUNTIME QA**

This is not final production ship approval. Runtime evidence is still required after Copilot Studio publish.

## Passed Checks

| Gate | Result | Evidence |
|---|---|---|
| Export after tenant cleanup | PASS | `pac solution export --name PMO_v11_Tarefas` succeeded. |
| Stale workflowset row removed | PASS | `Assets/botcomponent_workflowset.xml` no longer contains `pmo_AssistentePMO_V2.topic.CriarTarefa -> 3104124d-364a-f111-bec7-7ced8d955c6c`. |
| Deleted row ID absent | PASS | No package reference to `678fae11-394a-f111-bec7-6045bdf42cae`. |
| Workflowset count | PASS | Dropped from 13 rows in 3.9 to 12 rows after cleanup. |
| Correct create-project action mapping | PASS | `pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto -> 3104124d-364a-f111-bec7-7ced8d955c6c`. |
| Correct create-task action mapping | PASS | `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa -> 0a5d2a41-24c0-4d5e-9f6d-000000000241`. |
| Missing dependency scan | PASS | No `MissingDependency`, `cat_CopilotStudioKitOutlook`, or `cat_sharedteams_1ef7e`. |
| Legacy adaptive components removed | PASS | No `PMO_PA_CheckInOnDemand`, `PMO_PA_EscalarRiscoCritico`, or `PMO_PA_RegistrarDecisaoBoard`. |
| Orphan batch flow removed | PASS | No `PMO_PA_Gerar_Multiplos_Projetos`. |
| AtualizarTarefa skip guards | PASS STATIC | `Responsavel`, `DataFim`, and `Prioridade` preserve existing values when input is blank or `n` / `no` / `nao`. |
| PMO workflow SharePoint connection | PASS | All 12 workflows reference `pmo_sharedsharepointonline_6e373`; none reference `gstf_sharepoint`. |

## Accepted Residue

| Item | Status | Reason |
|---|---|---|
| `gstf_sharepoint` in `customizations.xml` | Accepted as non-runtime residue for this cycle | No PMO workflow references it. Physical deletion was blocked by 11 unrelated published processes, so it must not be deleted from the environment. |

## Remaining Runtime QA

After owner publishes Copilot Studio, run these tests in order:

| Priority | Test | Expected result |
|---:|---|---|
| 1 | `listar tarefas do projeto QA Robust 20260513 F` | Deleted/hidden tasks do not appear; current active task state is visible. |
| 2 | Create a fresh task in `QA Robust 20260513 F` | Task is created in `Tarefas`, not `Projetos`; project binding is correct. |
| 3 | Update that task and answer `nao` for responsible and due date | Existing `Responsavel` and `DataFim` are preserved, not overwritten with `nao`. |
| 4 | Update priority/status explicitly | Status and priority update as requested; project counters recalculate. |
| 5 | Invalid UPN in `PedirDecisao` | Bot rejects before flow call/write. |
| 6 | Valid UPN in `PedirDecisao` | Decision request is created correctly. |
| 7 | `consultar portfolio` | Totals match active non-deleted SharePoint rows. |

## Decision

Codex decision: **GO FOR OWNER PUBLISH + RUNTIME QA**.

Production ship remains **NO-SHIP** until runtime tests pass on the newly published bot.

