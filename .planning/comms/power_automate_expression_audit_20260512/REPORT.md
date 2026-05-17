# Power Automate Expression Audit - 2026-05-12

Scope: read-only audit of the latest exported/imported solution artifacts after v2.8, focused on Power Automate expressions, workflow schema compatibility, date handling, null/array safety, and Copilot action binding.

Sources:
- Super skill: `skills/super/SKILL_POWER_AUTOMATE_EXPRESSIONS.md`
- Latest UI export unpacked at `.planning/comms/compare_export_2_7_vs_local_2_8_20260512/export_ui`
- Local package: `Solution/PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip`
- Official Microsoft docs:
  - https://learn.microsoft.com/en-us/azure/logic-apps/workflow-definition-language-schema
  - https://learn.microsoft.com/en-us/azure/logic-apps/expression-functions-reference
  - https://learn.microsoft.com/en-us/power-automate/use-expressions-in-conditions

## Decision

NO-SHIP for production until owner publishes and completes runtime smoke. No new critical expression/schema issue was found in the already-tested create/list/delete path.

Important: this audit made no production changes, no imports, no publishes, and no SharePoint writes.

## Official Runtime Surface

The exported Cloud Flow definitions use the Azure Logic Apps Workflow Definition Language schema:

- Evidence: `.planning/comms/compare_export_2_7_vs_local_2_8_20260512/export_ui/Workflows/PMO_PA_CriarTarefa-0A5D2A41-24C0-4D5E-9F6D-000000000241.json:15`
- Schema value: `https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#`

Therefore, flow expressions must be Power Automate / Logic Apps WDL expressions, not Power Fx. Power Fx syntax is expected only in Copilot topic `.data` files.

## Green Evidence

| Area | Result | Evidence |
|---|---:|---|
| Workflow JSON parse / ASCII / no raw invoker auth / no mojibake | PASS | `powershell -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .planning\comms\compare_export_2_7_vs_local_2_8_20260512\export_ui` |
| `CriarTarefa` writes only `Tarefas`, resolves active project, rejects invalid BR date | PASS | `powershell -File tests\Test-CriarTarefaCreatesTarefas.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` |
| `CriarProjeto` writes only `Projetos`, checks duplicates, uses standard connector | PASS | `powershell -File tests\Test-CriarProjetoFlowDefinition.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` |
| `Gerar_Multiplos_Projetos` preview/no-write contract | PASS | `powershell -File tests\Test-GerarMultiplosProjetosDefinition.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` |
| `PedirDecisao` definition | PASS | `powershell -File tests\Test-PedirDecisaoFlowDefinition.ps1` |
| `CriarTarefa` action binding restored | PASS | `customizations.xml:367`, action component `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`, topic `BeginDialog` at `botcomponents/...topic.CriarTarefa/data:94` |

## Findings

### PA-AUDIT-001 - No Unsupported Function Found In Main Runtime Path

Severity: Info

No unsupported `padLeft` or raw Power Fx function was found inside Cloud Flow JSONs for the create/list/delete path. `CriarTarefa` uses supported WDL primitives such as `if`, `and`, `equals`, `length`, `split`, `first`, `skip`, `last`, `contains`, `createArray`, and `concat`.

Evidence:
- `PMO_PA_CriarTarefa-...json:255`
- `Test-CriarTarefaCreatesTarefas.ps1`: PASS
- `Test-PMOFlowStopShipAudit.ps1`: PASS

### PA-AUDIT-002 - `CriarProjeto` Date Parser Is More Permissive Than `CriarTarefa`

Severity: Major risk if `CriarProjeto` must also enforce Brazilian-only dates.

`CriarTarefa` now rejects ISO/user-facing non-BR dates with `INVALID_BR_DATE`. `CriarProjeto` still has a legacy date compose that accepts slash dates and otherwise passes `triggerBody()?['text_3']` through unchanged.

Evidence:
- `PMO_PA_CriarProjeto-...json:116`
- Duplicate lookup then applies `convertTimeZone` and `formatDateTime(addDays(outputs('Compose_DataAlvo'), 1), 'yyyy-MM-dd')` at `PMO_PA_CriarProjeto-...json:161`.

Risk:
- If a user enters `2026-06-30` for project target date, the flow may accept/pass it instead of rejecting it consistently with the Brazilian `dd/MM/yyyy` contract.
- This is not proven as a current runtime failure in v2.8, but it is inconsistent with the new strict task-date behavior.

Recommendation:
- Next hardening phase: align `CriarProjeto` date validation with `CriarTarefa` (`dd/MM/aaaa` only, explicit invalid-date response, no pass-through).
- Add regression tests for ISO reject and `30/06/2026` accept.

### PA-AUDIT-003 - `PedirDecisao` Date Parser Is Legacy/Lenient

Severity: Medium.

`PedirDecisao` has a safe-enough tenant-compatible parser (no `padLeft`), but it is less strict than `CriarTarefa`: it passes empty or non-slash date values through.

Evidence:
- `PMO_PA_PedirDecisaoBot-...json:261`
- `Test-PedirDecisaoFlowDefinition.ps1`: PASS

Recommendation:
- Harden only when `PedirDecisao` returns to critical path. Reuse the validated `CriarTarefa` BR-date pattern, adjusted for decision due date.

### PA-AUDIT-004 - `AtualizarStatus` Uses `int()` For Percentual

Severity: Medium for text/STT fallback; low for Adaptive Card numeric input.

`AtualizarStatus` converts `percentual` with `int(triggerBody()?['percentual'])`.

Evidence:
- `PMO_PA_AtualizarStatus-...json:327`

Risk:
- If STT/free-text sends `35,5`, `35.5`, `%35`, or non-numeric text, WDL `int()` can fail.
- Existing gate says CheckIn percent does not force integer, but this specific `AtualizarStatus` compose still deserves targeted runtime validation if STT becomes the default path.

Recommendation:
- For Adaptive Cards, prefer `Input.Number` and keep value numeric.
- For free text/STT fallback, normalize/validate with an explicit numeric guard before conversion.

### PA-AUDIT-005 - Direct `value[0]` Access Requires Guard Discipline

Severity: Medium audit item, not a current proven failure.

Several flows use the common SharePoint lookup pattern `body('Get_X')?['value']?[0]`. This is acceptable only under a prior `length(value) > 0` branch.

Evidence:
- Counted direct `value[0]` occurrences:
  - `ExcluirTarefa`: 11
  - `ConsultarProjeto`: 10
  - `AtualizarTarefa`: 8
  - `AtualizarStatus`: 5
  - `ListarTarefas`: 4

Current coverage:
- `Test-PMOFlowStopShipAudit.ps1` passes guards for the main known paths: `AtualizarTarefa`, `CheckIn`, `ListarTarefas`, `CriarTarefa`, `ExcluirTarefa`.

Recommendation:
- Do not mass-refactor now. Add focused tests per flow when each returns to the active validation lane.

## No Immediate Flow Change Recommended

Do not patch or import solely from this audit. The current v2.8 package is structurally sound for the recently validated critical path:

1. `CriarTarefa`: action binding exists; date validation is BR-only; runtime create/list/delete has passed user tests.
2. `ExcluirTarefa`: project/task scope and soft delete behavior passed runtime tests.
3. `ListarTarefas`: accepts project name and returns IDs needed for delete.
4. `Gerar_Multiplos_Projetos`: explicitly preview/no-write, so `FlowNotFound` in preview mode is no longer expected if the latest topic is published.

## Next Action

Keep v2.8 as the baseline. Before declaring SHIP:

1. Owner publishes the bot if Copilot Studio still shows unpublished changes.
2. Runtime smoke: `CriarTarefa` with `30/06/2026`, `ListarTarefas`, `ExcluirTarefa`, `ListarTarefas` again.
3. Runtime smoke: `CriarProjeto` with `30/06/2026`.
4. Negative test: `CriarProjeto` with `2026-06-30`; if accepted, open a new isolated hardening issue for project-date validation.

