# Clean Bot Schema Fix - Final Review

Date: 2026-05-06

Environment: `ColOfertasBrasilPro`

Bot: `Assistente PMO Clean`

Bot ID: `77cfb838-6ed1-4488-9e57-ab98751081d3`

Status: **BOT PUBLISH FIXED; T-007 CHAT CREATE/CANCEL STILL NEEDS USER RUNTIME TEST**

## Root Cause

The old bot `Assistente_PMO` was deleted, but active solution/package artifacts still contained references and relationship rows for the deleted schema:

- old schema: `pmo_AssistentePMO.*`
- active schema: `pmo_AssistentePMO_Clean.*`

Two separate defects were present:

1. Active package/source still had old-schema references in `Assets/botcomponent_workflowset.xml` and `deploy/copilot/AssistentePMO.template.yaml`.
2. Live Dataverse still had a stale topic-level `botcomponent_workflow` row binding `pmo_AssistentePMO_Clean.topic.CriarTarefa` directly to cloud flow `71f62da4-9748-f111-bec7-6045bdf42cae`.

That stale topic-level CloudFlow relationship caused Copilot Studio topic checker/publish to report:

```text
InvalidReferenceError
referenceType: CloudFlow
referenceId: 71f62da4-9748-f111-bec7-6045bdf42cae
errorCode: NotFound
componentDisplayName: CriarTarefa
```

Even though the flow itself existed and was active, the topic checker was validating the wrong level of binding. The topic must call the `_Clean` action component; only the action component should own the CloudFlow binding.

## Fixes Applied

### Source/package cleanup

- `deploy/copilot/AssistentePMO.template.yaml`
  - changed `call_criar_tarefa` to `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa`

- `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_src/botcomponents/pmo_AssistentePMO_Clean.topic.CriarTarefa/data`
  - replaced direct `InvokeFlowAction`/`flowId` call with:
    - `BeginDialog`
    - `dialog: pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa`

- `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_src/Assets/botcomponent_workflowset.xml`
  - removed every `pmo_AssistentePMO.*` workflow binding
  - removed topic-level `pmo_AssistentePMO_Clean.topic.CriarTarefa -> workflow` binding
  - kept only `_Clean.action.* -> workflow` bindings

- `deploy/CS_G4_AddKnowledge.ps1`
  - default bot schema changed to `pmo_AssistentePMO_Clean`
  - default knowledge schema changed to `pmo_AssistentePMO_Clean.topic.PMOSharePointKnowledge`

- `deploy/MASTER_RUNBOOK/MASTER_RUNBOOK.md`
  - updated schema examples to `_Clean`

### Test hardening

- `tests/Test-CriarTarefaContract.ps1`
  - now requires `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa`
  - rejects old `pmo_AssistentePMO.` references
  - rejects direct topic `InvokeFlowAction` / `flowId`

- `tests/Test-CriarTarefaRawDataverse.ps1`
  - now scopes validation to the live `_Clean.topic.CriarTarefa` row
  - rejects old schema references
  - rejects direct topic CloudFlow binding
  - validates `dialog: pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa`

- `tests/Test-PMOFlowStopShipAudit.ps1`
  - now scans full solution text for deleted original bot schema references
  - validates `botcomponent_workflowset.xml` has only `_Clean.action.*` bindings
  - rejects `.topic.CriarTarefa` workflow binding

## Dataverse Actions Taken

Backup export:

- `.planning/canonical/PMO_v11_Tarefas_PRE_CLEAN_SCHEMA_FIX_20260506.zip`

Imported corrected package:

- `.planning/canonical/PMO_v11_Tarefas_CLEAN_SCHEMA_FIX_20260506.zip`

PAC import result:

```text
Solution Imported successfully.
The original workflow definition has been deactivated and replaced.
Published All Customizations.
```

Stale relationship deleted:

- table: `botcomponent_workflow`
- deleted row:
  - `botcomponentid = c746c335-ada5-48d4-8e6a-f91cf2a8b096`
  - `workflowid = 71f62da4-9748-f111-bec7-6045bdf42cae`

Bulk delete job:

- job ID: `bf5035e3-8049-f111-bec7-6045bdf42cae`
- result: `Records Deleted: 1`
- failures: `0`

Post-delete live binding state:

```text
pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa -> PMO_PA_CriarTarefa
```

No `pmo_AssistentePMO_Clean.topic.CriarTarefa -> workflow` row remains.

## Publish Result

PAC bot publish now succeeds:

```text
Published successfully! 77cfb838-6ed1-4488-9e57-ab98751081d3 Succeeded [06/05/2026 19:17:20].
```

This is the key signal that the Copilot Studio publish-blocking `CloudFlow NotFound` diagnostic has been cleared.

## Verification Passed

Live raw Dataverse topic check:

```text
tests/Test-CriarTarefaRawDataverse.ps1
passed: true
failedCheckCount: 0
```

Post-export solution audit:

```text
tests/Test-PMOFlowStopShipAudit.ps1
passed: true
failedCheckCount: 0
```

CriarTarefa flow definition audit:

```text
tests/Test-CriarTarefaFlowDefinition.ps1
passed: true
failedCheckCount: 0
```

Contract audit:

```text
tests/Test-CriarTarefaContract.ps1
passed: true
failedCheckCount: 0
```

Hard grep checks:

```text
rg 'pmo_AssistentePMO(?!_Clean)\.' active source/export/deploy/tests
no matches

rg 'kind:\s*InvokeFlowAction|botcomponentid.schemaname="pmo_AssistentePMO\.|\.topic\.CriarTarefa" workflowid'
no matches
```

Post-fix export:

- `.planning/canonical/PMO_v11_Tarefas_POST_CLEAN_SCHEMA_FIX_20260506.zip`
- unpacked: `.planning/canonical/PMO_v11_Tarefas_POST_CLEAN_SCHEMA_FIX_20260506`

Post-export `Assets/botcomponent_workflowset.xml` contains only:

- `pmo_AssistentePMO_Clean.action.PMO_PA_AtualizarTarefa`
- `pmo_AssistentePMO_Clean.action.PMO_PA_CheckInOnDemand`
- `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa`
- `pmo_AssistentePMO_Clean.action.PMO_PA_EscalarRiscoCritico`
- `pmo_AssistentePMO_Clean.action.PMO_PA_ListarTarefas`
- `pmo_AssistentePMO_Clean.action.PMO_PA_RegistrarDecisaoBoard`

## Remaining Required Runtime Tests

The publish blocker is fixed, but release remains **NO-SHIP** until the bot is tested in Copilot Studio chat.

### T-007 Create

Message:

```text
Criar tarefa: Titulo=Teste Clean Schema T007 20260506, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=336, Prioridade=Alta
```

Expected:

- bot selects `CriarTarefa`
- bot asks confirmation
- reply `sim`
- no `FlowNotFound`
- a new `PMO_PA_CriarTarefa` run appears
- flow run is green
- SharePoint `Projetos` row is created

### T-007 Cancel

Message:

```text
Criar tarefa: Titulo=Teste Clean Schema Cancel 20260506, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=1, Prioridade=Baixa
```

Expected:

- bot asks confirmation
- reply `nao`
- no flow run is created
- no SharePoint row is created
- bot returns cancellation response

## Release Decision

Technical publish blocker: **fixed**

Bot runtime UAT: **pending**

Final release remains **NO-SHIP** until T-007 create and cancel pass in Copilot Studio test chat.
