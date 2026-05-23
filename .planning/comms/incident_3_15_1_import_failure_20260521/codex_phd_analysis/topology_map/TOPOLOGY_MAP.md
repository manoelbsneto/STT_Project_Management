# Incident 3.15.1 Solution Topology Map

Date: 2026-05-21 BRT  
Environment: `ColOfertasBrasilPro`  
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`  
Surface: Dataverse `solutioncomponent` membership queried through PAC CLI FetchXML read-only.

## Decision

**Scenario identified: 1 - already consolidated for the in-scope 3.15.1 set.**

The five in-scope topic `botcomponent` rows, the twelve in-scope `workflow` rows, and the `pmo_AssistentePMO_V2` bot row all have a `solutioncomponent` row in `PMO_v11_Tarefas`. None of those eighteen in-scope objects has a `solutioncomponent` row in the AQ-07 solution. The tenant unique name of the AQ-07 solution is `PMO_AQ07_CopilotBinding`; the incident prompt/file naming uses `PMO_AQ07_Copilot_Binding`.

`PMO_AQ07_CopilotBinding` is not an empty pointer-only bridge. Its inventory is a separate AQ-07 action layer: six `PM0_*` workflows, six `botcomponent` action rows, six `botcomponent_workflow` binding rows, and one SharePoint `connectionreference`.

## Evidence Route

Read-only commands used:

```powershell
pac auth list
pac env who
pac solution list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <fetch_*.xml>
```

Primary evidence folder:

```text
.planning/comms/incident_3_15_1_import_failure_20260521/codex_phd_analysis/topology_map/evidence/
```

Key raw outputs:

- `solution_inventory_PMO_v11_Tarefas.txt`
- `solution_inventory_PMO_AQ07_Copilot_Binding.txt`
- `pac_fetch_topic_solution_membership.txt`
- `pac_fetch_workflow_solution_membership.txt`
- `pac_fetch_bot_pmo_AssistentePMO_V2.txt`
- `pac_fetch_agent_solution_membership.txt`
- `pac_fetch_PMO_AQ07_CopilotBinding_solutioncomponent_inventory.txt`

Structured membership outputs:

- `topic_solution_membership.json`
- `workflow_solution_membership.json`
- `agent_solution_membership.json`

## Microsoft Schema Basis

Microsoft Learn documents `solutioncomponent.objectid` as the associated object ID, `solutioncomponent.solutionid` as a lookup to `solution`, `solutioncomponent.componenttype` as the component object type code, and `rootcomponentbehavior` as the root include behavior:

- https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/solutioncomponent

The membership FetchXML joins `solutioncomponent.solutionid` to `solution.solutionid` with `link-entity` and returns `solution.uniquename`. Microsoft Learn documents `link-entity` as the FetchXML join mechanism:

- https://learn.microsoft.com/en-us/power-apps/developer/data-platform/fetchxml/reference/link-entity

Bot resolution uses Microsoft-documented Dataverse tables:

- `bot`: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/bot
- `botcomponent`: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/botcomponent
- `botcomponent_workflow`: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/botcomponent_workflow
- `connectionreference`: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/connectionreference

## Target Solution Rows

| Solution | Solution ID | Friendly name | Version | Query |
|---|---|---|---|---|
| `PMO_v11_Tarefas` | `717abee5-98e8-45e7-8ce9-264b83b7faa5` | `PMO v1.1 - Task Management Topics` | `3.15` | `fetch_solution_PMO_v11_Tarefas.xml` |
| `PMO_AQ07_CopilotBinding` | `aef5aea2-cee2-4039-8087-f66c8574a201` | `PMO AQ07 Copilot Binding` | `1.0.0.0` | `fetch_solution_PMO_AQ07_CopilotBinding.xml` |

## In-Scope Membership Matrix

`Other returned solution rows` are kept visible because the request required every `solutioncomponent` row found by `objectid`. They are not evidence of membership in the two incident target solutions.

| Kind | Name / schema | Object ID | `PMO_v11_Tarefas` | `PMO_AQ07_CopilotBinding` | Other returned solution rows |
|---|---|---|---|---|---|
| Topic | `pmo_AssistentePMO_V2.topic.AtualizarStatus` | `ec4416d0-0744-4e8c-b937-aae4ad9c605b` | Yes | No | `Default` |
| Topic | `pmo_AssistentePMO_V2.topic.AtualizarTarefa` | `6750ff2f-822b-45ab-83ec-058704c7808a` | Yes | No | `Default` |
| Topic | `pmo_AssistentePMO_V2.topic.ConsultarPortfolio` | `74c5fdcc-c121-452e-85af-24d3f260b3c7` | Yes | No | `Default` |
| Topic | `pmo_AssistentePMO_V2.topic.CriarTarefa` | `bcbecd76-3158-40ac-b225-5ae7c3874ed1` | Yes | No | `Default` |
| Topic | `pmo_AssistentePMO_V2.topic.ListarTarefas` | `d58258b4-b17f-4bb9-9e1f-161287a041c4` | Yes | No | `Default` |
| Workflow | `PMO_PA_CriarTarefa` | `0a5d2a41-24c0-4d5e-9f6d-000000000241` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_ExcluirProjeto` | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_CriarProjeto` | `3104124d-364a-f111-bec7-7ced8d955c6c` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_ConsultarPortfolio` | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_RegistrarBloqueioBot` | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_ConsultarProjeto` | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_ExcluirTarefa` | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_ListarTarefas` | `9544f14b-3748-f111-bec7-6045bdf42cae` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_AtualizarTarefa` | `98408d55-3748-f111-bec7-000d3abc5cc6` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_AtualizarStatus` | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_RegistrarRiscoBot` | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | Yes | No | `Active`, `Default` |
| Workflow | `PMO_PA_PedirDecisaoBot` | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | Yes | No | `Active`, `Default` |
| Bot | `pmo_AssistentePMO_V2` / `Assistente PMO V2` | `df148bf8-0a3e-495b-80c4-841dcb61d9a4` | Yes | No | `Default` |

## Raw Membership Row Counts

| Slice | Query | Raw rows | Completeness result |
|---|---|---:|---|
| 5 topic object IDs | `fetch_topic_solution_membership.xml` | 10 | 5 unique topic IDs returned; each has `PMO_v11_Tarefas` and `Default` rows |
| 12 workflow object IDs | `fetch_workflow_solution_membership.xml` | 36 | 12 unique workflow IDs returned; each has `PMO_v11_Tarefas`, `Active`, and `Default` rows |
| Bot object ID | `fetch_agent_solution_membership.xml` | 2 | Bot returned `PMO_v11_Tarefas` and `Default` rows |

## Complete AQ-07 Inventory

All nineteen rows below came from `fetch_PMO_AQ07_CopilotBinding_solutioncomponent_inventory.xml`.

For `solutioncomponent.componenttype`, PAC rendered the workflow rows with the label `Flujo de trabajo`; Microsoft Learn documents value `29` as `Workflow`. PAC rendered the AQ-07 `botcomponent`, `botcomponent_workflow`, and `connectionreference` solutioncomponent labels blank. Their numeric object type codes were verified by exact FetchXML componenttype probes:

- `10163`: `fetch_PMO_AQ07_componenttype_botcomponent_10163_probe.xml`
- `10169`: `fetch_PMO_AQ07_componenttype_botcomponent_workflow_10169_probe.xml`
- `10120`: `fetch_PMO_AQ07_componenttype_connectionreference_10120_probe.xml`

| Solutioncomponent ID | Object ID | Componenttype numeric | Label / resolver | Root behavior | Resolved component |
|---|---|---:|---|---|---|
| `ecba2bc9-a350-f111-bec7-000d3abc5cc6` | `9531fbc7-a250-f111-bec7-000d3abc5cc6` | `29` | `Workflow` | Include subcomponents | Workflow `PM0_PA_OpsFailureHandling` |
| `ffba2bc9-a350-f111-bec7-000d3abc5cc6` | `48b72cbd-a350-f111-bec7-000d3abc5cc6` | `10169` | PAC label blank; `botcomponent_workflow` row | Include subcomponents | Binding `PM0_PA_Card_AtualizarStatus` -> workflow `PM0_PA_Card_AtualizarStatus` |
| `f5ba2bc9-a350-f111-bec7-000d3abc5cc6` | `bd507ab1-7455-400e-8379-153ce34427f8` | `10163` | PAC label blank; `botcomponent` row | Include subcomponents | Action `pmo_AssistentePMO_V2.action.PM0_PA_OpsFailureHandling` |
| `07bb2bc9-a350-f111-bec7-000d3abc5cc6` | `ca7233c3-a350-f111-bec7-000d3abc5cc6` | `10169` | PAC label blank; `botcomponent_workflow` row | Include subcomponents | Binding `PM0_PA_Card_CriarTarefa` -> workflow `PM0_PA_Card_CriarTarefa` |
| `03bb2bc9-a350-f111-bec7-000d3abc5cc6` | `c37233c3-a350-f111-bec7-000d3abc5cc6` | `10169` | PAC label blank; `botcomponent_workflow` row | Include subcomponents | Binding `PM0_PA_Card_AtualizarTarefa` -> workflow `PM0_PA_Card_AtualizarTarefa` |
| `05bb2bc9-a350-f111-bec7-000d3abc5cc6` | `c57233c3-a350-f111-bec7-000d3abc5cc6` | `10169` | PAC label blank; `botcomponent_workflow` row | Include subcomponents | Binding `PM0_PA_Card_ListarTarefas` -> workflow `PM0_PA_Card_ListarTarefas` |
| `01bb2bc9-a350-f111-bec7-000d3abc5cc6` | `c27233c3-a350-f111-bec7-000d3abc5cc6` | `10169` | PAC label blank; `botcomponent_workflow` row | Include subcomponents | Binding `PM0_PA_Card_ResumoExecutivoPortfolio` -> workflow `PM0_PA_Card_ResumoExecutivoPortfolio` |
| `09bb2bc9-a350-f111-bec7-000d3abc5cc6` | `cd7233c3-a350-f111-bec7-000d3abc5cc6` | `10169` | PAC label blank; `botcomponent_workflow` row | Include subcomponents | Binding `PM0_PA_OpsFailureHandling` -> workflow `PM0_PA_OpsFailureHandling` |
| `fbba2bc9-a350-f111-bec7-000d3abc5cc6` | `0956d0c0-05f1-429c-8893-6352a927d535` | `10163` | PAC label blank; `botcomponent` row | Include subcomponents | Action `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` |
| `f9ba2bc9-a350-f111-bec7-000d3abc5cc6` | `f6afac82-ec2b-47fb-a3d6-4aebad708702` | `10163` | PAC label blank; `botcomponent` row | Include subcomponents | Action `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` |
| `16a292de-a850-f111-bec7-7ced8d955c6c` | `b59678d8-a850-f111-bec7-7ced8d955c6c` | `10120` | PAC label blank; `connectionreference` row | Include subcomponents | Connection reference `pmo_cat_DataverseIndexerSharePoint` / SharePoint connector |
| `d17233c3-a350-f111-bec7-000d3abc5cc6` | `8333bd91-a250-f111-bec7-000d3abc5cc6` | `29` | `Workflow` | Include subcomponents | Workflow `PM0_PA_Card_ResumoExecutivoPortfolio` |
| `fdba2bc9-a350-f111-bec7-000d3abc5cc6` | `0635831a-6b13-45d6-b10e-983fcc63eefe` | `10163` | PAC label blank; `botcomponent` row | Include subcomponents | Action `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` |
| `d27233c3-a350-f111-bec7-000d3abc5cc6` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` | `29` | `Workflow` | Include subcomponents | Workflow `PM0_PA_Card_AtualizarStatus` |
| `d37233c3-a350-f111-bec7-000d3abc5cc6` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` | `29` | `Workflow` | Include subcomponents | Workflow `PM0_PA_Card_ListarTarefas` |
| `f7ba2bc9-a350-f111-bec7-000d3abc5cc6` | `beb83cc5-c09c-4cd3-a279-20846686ea3e` | `10163` | PAC label blank; `botcomponent` row | Include subcomponents | Action `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` |
| `d57233c3-a350-f111-bec7-000d3abc5cc6` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` | `29` | `Workflow` | Include subcomponents | Workflow `PM0_PA_Card_AtualizarTarefa` |
| `f3ba2bc9-a350-f111-bec7-000d3abc5cc6` | `3f9abdf2-8801-4602-83dd-002a31f0b53e` | `10163` | PAC label blank; `botcomponent` row | Include subcomponents | Action `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` |
| `d47233c3-a350-f111-bec7-000d3abc5cc6` | `7f662db7-a250-f111-bec7-000d3abc5cc6` | `29` | `Workflow` | Include subcomponents | Workflow `PM0_PA_Card_CriarTarefa` |

Name resolution evidence:

- Workflows: `fetch_PMO_AQ07_workflow_resolution.xml`
- Actions: `fetch_PMO_AQ07_botcomponent_resolution.xml`
- Action-to-workflow bindings: `fetch_PMO_AQ07_botcomponent_workflow_resolution.xml`
- Connection reference: `fetch_PMO_AQ07_connectionreference_resolution.xml`

## Technical Recommendation

Do **not** consolidate both solutions solely to answer the 3.15.1 topology question. The in-scope 3.15.1 set is already together in `PMO_v11_Tarefas`; AQ-07 contains a different PM0 action/binding slice and did not supply any of the five topics, twelve PMO workflows, or the bot row in this membership query.

Microsoft documents two constraints that fit this decision:

1. Work in the custom solution context for the components being customized and transported:
   - https://learn.microsoft.com/en-us/power-platform/alm/update-solutions-alm
2. Include the components actually needed by the solution and avoid unnecessary solution complexity/dependency surface:
   - https://learn.microsoft.com/en-us/troubleshoot/power-platform/dataverse/working-with-solutions/missing-dependency-on-solution-import

If the Owner decides that the AQ-07 PM0 action layer must ship in the same future carrier as PMO v11, that is a separate supported solution-authoring and dependency-review decision. This topology evidence does not justify merging AQ-07 into PMO v11 as a prerequisite for the current five-topic incident path.

For Copilot agent transport, the existing Microsoft-documented route remains solution-based authoring/export/import for agents and their components:

- https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export
- https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution

## Quality Gates

| Gate | Result | Evidence |
|---|---|---|
| Gate A - PAC compatibility | Pass | `pac_help.txt` shows PAC `2.6.4+ga488322`; `pac_org_fetch_usage.txt` shows the `pac org fetch --xmlFile` surface; every `fetch_*.xml` used for the topology capture has a corresponding PAC output file. |
| Gate B - FetchXML syntax and joins | Pass | Membership joins returned `solution.uniquename`, `solution.solutionid`, and friendly names in `pac_fetch_topic_solution_membership.txt`, `pac_fetch_workflow_solution_membership.txt`, and `pac_fetch_agent_solution_membership.txt`. |
| Gate C - Completeness | Pass | Topics: 5 unique IDs and 10 rows. Workflows: 12 unique IDs and 36 rows. Bot: 1 bot discovered by schema and 2 membership rows. No in-scope object returned zero membership rows. |
| Gate D - Cross-check | Pass | The new topic membership raw output contains 10 topic `solutioncomponent` rows, matching the ten rows already recorded in the prior forensic mission. |
| Gate E - Topology | Pass | All eighteen in-scope objects are in `PMO_v11_Tarefas`; zero of them are in `PMO_AQ07_CopilotBinding`; AQ-07 inventory is separately resolved as 19 PM0 action-layer components. Scenario 1 fits the tenant state. |

## Residual Risk

This report proves current Dataverse solution membership for the queried objects. It does not prove package scope of a future Microsoft-generated export, import side effects, or post-import Copilot runtime behavior. Those remain gated by package review and post-import/runtime evidence.
