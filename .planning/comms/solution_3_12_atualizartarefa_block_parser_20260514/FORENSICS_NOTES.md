# PMO_PA_AtualizarTarefa Forensics Notes - 2026-05-14

Agent: Agent B - Reproduction & Forensics
Scope: Runtime blockers after export 3.10
Mode: Read-only tenant posture. No tenant writes, imports, publishes, deletes, commits, or portal/runtime changes performed.

## Mandatory Files Read

- `.planning/GOLDEN_RULES.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `docs/MANUAL_OPERACIONAL_PMO.md`

## Local Evidence Inspected

- `.planning/comms/solution_3_8_post_import_export_validation_20260513/RUNTIME_QA_20260513_TASK15.md`
- `.planning/comms/solution_3_8_post_import_export_validation_20260513/EXPORT_3_10_POST_WFSET_CLEAN_REVIEW.md`
- `.planning/comms/solution_3_5_atualizartarefa_skip_fix_20260513/LOCAL_GATES.md`
- `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/Workflows/PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json`
- `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data`
- `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa/data`
- `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/Assets/botcomponent_workflowset.xml`
- `tests/Test-AtualizarTarefaSkipSemantics.ps1`

Note: No local file or folder named with `3_10`, `3.10`, or either failing/succeeding run ID was found except the 3.10 review note inside the 3.8 post-import validation folder. The available unpacked export folder still has 3.8 naming, while `EXPORT_3_10_POST_WFSET_CLEAN_REVIEW.md` records artifact `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`, SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`, and solution metadata version `3.9`.

## Reproducibility

### Runtime Run CU12 - Skip Semantics Succeeded, Chat Display Wrong

Known runtime evidence:

- Run ID: `08584228880469441067904651966CU12`
- Status: `Succeeded`
- Test task: SharePoint Tarefas item `ID 15`, `ProjectID PRJ-274E5ACC`
- Before update values:
  - `Responsavel: mbenicios@minsait.com`
  - `DataFim: 2026-05-21`
  - `HorasRealizadas: 2`
  - `Prioridade: Media`
- `Update_Tarefa` inputs during skip test:
  - `item/Responsavel: mbenicios@minsait.com`
  - `item/DataFim: 2026-05-21`
  - `item/Prioridade/Value: Media`
  - `item/HorasRealizadas: 2`
- `Update_Tarefa` outputs preserved the same values.

Reproduced from local artifact by static inspection:

- `PMO_PA_AtualizarTarefa` action `Update_Tarefa` uses skip guards for `item/Responsavel`, `item/DataFim`, and `item/Prioridade/Value`.
- These expressions treat blank, `n`, `no`, `nao`, and short `n*` tokens as "keep current value".
- This matches the successful runtime write behavior in CU12.

Observed blocker:

- The bot displayed `Responsavel: nao Prazo: nao Prioridade: nao` even though SharePoint values were preserved.
- The local topic `pmo_AssistentePMO_V2.topic.AtualizarTarefa` has a post-flow `SendActivity` action `atualizar_done` that prints raw topic variables:
  - `Responsavel: {Topic.Responsavel}`
  - `Prazo: {Topic.DataFim}`
  - `Prioridade: {Topic.Prioridade}`
- Therefore, if the user answers `nao` to skip optional fields, the bot can display `nao` after a successful flow run even when the flow wrote the correct effective values.

### Runtime Run CU20 - BR Date Conversion Failed

Known runtime evidence:

- Run ID: `08584228891053733219995694617CU20`
- Failed action: `Update_Tarefa`
- Error area: `item/DataFim` conversion
- Bad value: `21/05/2026\n`
- Temporary workaround recorded in evidence: use ISO date `2026-05-21`.

Reproduced from local artifact by static inspection:

- `PMO_PA_AtualizarTarefa` action `Update_Tarefa` maps `item/DataFim` as:
  - skip token -> `body('Get_Tarefa_Atual')?['DataFim']`
  - otherwise -> `triggerBody()?['text_2']`
- There is no BR date normalization compose before `Update_Tarefa`.
- The expression does not trim the non-skip date before sending it to SharePoint.
- The SharePoint `DataFim` column is documented as DateTime DateOnly in `docs/SCHEMA_SHAREPOINT_PMO.md`.

This explains why a raw `dd/MM/yyyy` value with trailing newline, `21/05/2026\n`, reaches the SharePoint update action and fails conversion.

## Suspected Root Cause

Two distinct issues are present:

1. Display-only response bug: The Copilot topic `AtualizarTarefa` echoes raw user inputs after the flow call. This is independent of the flow write result and can show skip tokens like `nao` as if they were persisted values.
2. Date input normalization bug: The flow `PMO_PA_AtualizarTarefa` does not normalize non-skip `text_2` from `dd/MM/yyyy` to ISO `yyyy-MM-dd` before `Update_Tarefa`.

The CU12 runtime run proves the 3.5 skip-write fix worked for persisted data. It does not prove the user-facing response is correct.

The CU20 runtime run proves `DataFim` still accepts an unnormalized raw user string into the SharePoint update path.

## Affected Files and Actions

Local export artifacts inspected:

- Workflow file:
  - `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/Workflows/PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json`
- Topic file:
  - `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data`
- Action binding file:
  - `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa/data`
- Workflowset file:
  - `.planning/comms/solution_3_8_post_import_export_validation_20260513/unpacked/Assets/botcomponent_workflowset.xml`

Affected runtime/definition actions:

- `pmo_AssistentePMO_V2.topic.AtualizarTarefa`
  - `atualizar_done`: sends raw `{Topic.Responsavel}`, `{Topic.DataFim}`, and `{Topic.Prioridade}` after the flow result.
  - `call_atualizar_tarefa`: invokes `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa`.
- `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa`
  - `flowId: 98408d55-3748-f111-bec7-000d3abc5cc6`
  - Manual inputs:
    - `text_1 = Global.PMO_Atualizar_Responsavel`
    - `text_2 = Global.PMO_Atualizar_DataFim`
    - `text_3 = Global.PMO_Atualizar_Prioridade`
- `PMO_PA_AtualizarTarefa`
  - `Update_Tarefa`: writes `item/Responsavel`, `item/DataFim`, `item/Prioridade/Value`, and other task fields.
  - `Respond_Success`: returns a flow message, but current local result does not include effective `Responsavel`, `DataFim`, or `Prioridade`.

## Proof Needed After Fix

Production ship remains NO-SHIP until fresh evidence exists after the fixed package is imported and the bot is published.

Minimum proof required:

1. Static export proof after fix:
   - `PMO_PA_AtualizarTarefa` has an explicit normalized effective date path for `DataFim`.
   - Non-skip `dd/MM/yyyy` input is trimmed and converted to `yyyy-MM-dd` before `Update_Tarefa`.
   - Skip tokens still preserve existing `DataFim`, `Responsavel`, and `Prioridade`.
   - The topic no longer sends a raw-input success summary, or it displays effective values returned by the flow.
2. Runtime proof for skip display:
   - Fresh Copilot test updates a known task and answers `nao` for `Responsavel`, `DataFim`, and `Prioridade`.
   - Power Automate run succeeds.
   - `Update_Tarefa` inputs/outputs preserve previous values.
   - Bot-visible final response shows the effective persisted values, not `nao`.
3. Runtime proof for BR date:
   - Fresh Copilot test updates `DataFim` with `21/05/2026` or another `dd/MM/yyyy` value.
   - Power Automate run succeeds.
   - `Update_Tarefa` receives/sends ISO `yyyy-MM-dd` or another SharePoint-accepted DateOnly representation.
   - SharePoint item shows the expected date.
4. Regression proof:
   - Explicit priority update still maps `Baixa`, `Media`, `Alta`, and `Critica`.
   - Explicit responsible update still writes text value.
   - Project counter recalculation still runs after task update.
   - Existing `tests/Test-AtualizarTarefaSkipSemantics.ps1` remains passing and is extended or paired with a date-normalization/static response test.

## Current Decision

NO-SHIP for `PMO_PA_AtualizarTarefa` until both blockers have fresh post-fix runtime evidence:

- The bot response must not display raw skip tokens as effective field values.
- `DataFim` must accept supported BR date input without SharePoint conversion failure.
