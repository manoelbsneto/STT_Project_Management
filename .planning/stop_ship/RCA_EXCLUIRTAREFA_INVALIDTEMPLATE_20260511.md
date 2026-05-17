# RCA - PMO_PA_ExcluirTarefa InvalidTemplate Save Failure

Date: 2026-05-11
Environment: ColOfertasBrasilPro (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
Flow: `PMO_PA_ExcluirTarefa`
Workflow ID: `70b39334-5926-4fb1-bd22-f10bd99f0f6d`
Related solution package: `Solution/PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip`
Status: fixed in local package, pending live re-import/publish/runtime proof.

## Incident Summary

Power Automate refused to save `PMO_PA_ExcluirTarefa` with `InvalidTemplate`.

Error observed in the designer:

```text
Error al guardar el flujo con el codigo "InvalidTemplate" y el mensaje
"The template validation failed: 'The inputs of template action
'Update_Projeto_Counters' at line '1 and column '6038' cannot reference
action 'Filter_Concluidas'. Action 'Filter_Concluidas' must either be in
'runAfter' path or within a scope action on the 'runAfter' path of action
'Update_Projeto_Counters', or be a Trigger.'.".
```

The failure was captured in the user-provided Word file:

`C:\Users\dataops-lab\Documents\PMO_PA_ExcluirTarefa_errors_11_05.docx`

The screenshots were extracted into the repository evidence folder:

`.planning/stop_ship/evidence/excluirtarefa_invalidtemplate_20260511/`

## Screenshots Preserved

| Screenshot | Evidence |
|---|---|
| 1 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_1.png` |
| 2 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_2.png` |
| 3 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_3.png` |
| 4 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_4.png` |
| 5 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_5.png` |
| 6 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_6.png` |
| 7 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_7.png` |
| 8 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_8.png` |
| 9 | `evidence/excluirtarefa_invalidtemplate_20260511/PMO_PA_ExcluirTarefa_InvalidTemplate_screenshot_9.png` |

## Root Cause

`Update_Projeto_Counters` referenced outputs from `Filter_Concluidas`, but the action did not declare `Filter_Concluidas` in its `runAfter` path.

Power Automate validation requires that any referenced sibling action be reachable through the current action's `runAfter` chain or through a scope action on that chain. The visual designer showed `Filter_Concluidas` as an earlier branch, but the JSON definition did not make that dependency explicit for `Update_Projeto_Counters`.

The same area had additional transitive dependencies that were likely to produce follow-up validation errors after the first one was resolved:

- `Calc_Percentual` referenced `Filter_Nao_Canceladas` and `Filter_Concluidas`.
- `Update_Projeto_Counters` referenced `Get_All_Tarefas_Projeto`, `Get_Projeto_Item`, `Filter_Concluidas`, `Filter_Abertas`, and `Filter_Atrasadas`.

## Fix Applied

File patched:

`.planning/comms/solution_1_14_soft_delete_20260511/unpacked/Workflows/PMO_PA_ExcluirTarefa-70B39334-5926-4FB1-BD22-F10BD99F0F6D.json`

Changes:

- Added `Filter_Nao_Canceladas` and `Filter_Concluidas` to `Calc_Percentual.runAfter`.
- Added `Get_All_Tarefas_Projeto`, `Get_Projeto_Item`, and `Filter_Concluidas` to `Update_Projeto_Counters.runAfter`.
- Kept existing dependencies on `Calc_Percentual`, `Filter_Abertas`, `Filter_Atrasadas`, and `Condition_Projeto_Encontrado`.

The corrected package was rebuilt:

```powershell
pac solution pack --zipfile Solution\PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip --folder .planning\comms\solution_1_14_soft_delete_20260511\unpacked --packagetype Unmanaged
```

Final package hash:

```text
E4C59E36812DD8B3CA00D5E18EFB7F46185E2C950213DACD6523A446FADB2BBA
```

## Verification

The packed ZIP was validated directly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ExcluirSoftDeleteCapability.ps1 -PackagePath Solution\PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip
```

Result:

```text
passed: true
failedCheckCount: 0
```

The test confirms:

- `PMO_PA_ExcluirTarefa` exists in the packed solution.
- It uses the SharePoint Standard connector.
- It uses `PatchItem` update semantics.
- It has no physical `DeleteItem`, raw `DELETE`, recycle, or `Remove-PnPListItem` path.
- It writes `Deleted`, `DeletedAt`, `DeletedReason`, and `DeletedByUPN`.
- The `ExcluirTarefa` topic exists, asks for explicit confirmation, and calls the soft-delete flow only behind the affirmative branch.

## Residual Risk

Static/package validation is green, but live validation is still required:

1. Re-import `Solution/PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip`.
2. Publish the solution and bot.
3. Confirm Power Automate can save/open `PMO_PA_ExcluirTarefa` without `InvalidTemplate`.
4. Run a live `ExcluirTarefa` test against one exact task ID.
5. Verify the SharePoint `Tarefas` row remains physically present and has:
   - `Deleted=true`
   - `DeletedAt` populated
   - `DeletedReason` populated
   - `DeletedByUPN` populated
6. Verify active task/project views exclude the logically deleted task.

## Lessons Learned

- Power Automate visual layout is not sufficient evidence of template validity. JSON dependency paths must be validated explicitly when branches merge.
- Any action that references outputs from sibling actions must include those actions directly or transitively in `runAfter`.
- Static tests for soft-delete safety should be complemented by a template dependency validator for `runAfter` reachability.
- When a flow has branch fan-out/fan-in logic, place dependent actions inside a scope or make all referenced action dependencies explicit in `runAfter`.
- Screenshots of designer errors should be preserved in repo evidence immediately, not left only in transient Word documents or browser sessions.

## Follow-Up Test Recommendation

Add a dedicated static validator that scans workflow JSON and fails when an action expression references another action by name but the referenced action is not reachable from the current action's `runAfter` graph.
