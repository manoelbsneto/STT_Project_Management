# P0 Card-to-Flow Action Contract Fix

Date: 2026-05-15
Owner: CODEX-LEAD
Scope: Local card/flow contract alignment only
Release decision: NO-SHIP
Tenant execution: None

## 1. Trigger

Plato's local review found blocking Card-to-Flow contract drift in:

- `.planning/comms/P0_CARD_FLOW_ACTION_CONTRACT_REVIEW_20260515.md`

The blocking issues were local contract issues only. No tenant execution was required to fix them.

## 2. Files Changed

| File | Change |
|---|---|
| `deploy/cards/AtualizarTarefaCard.json` | Removed user-facing/submitted `plannerTaskId`; normalized status values from `Concluida`/`Cancelada` to `Concluido`/`Cancelado`. |
| `.planning/comms/p0_flow_artifacts_20260514/flow_pseudocode_definitions.json` | Added explicit dispatcher rules, action branches, and input alias mappings for status, task list, create task, and update task card submits. Changed app-facing Copilot response text to static ASCII English. |

## 3. Fix Summary

| Finding | Resolution |
|---|---|
| Status submit action ambiguity | Added `submitStatusUpdate`, `confirmStatusUpdate`, and `cancelStatusUpdate` as explicit status flow operation branches. |
| Status field name drift | Added aliases for `statusRAG`, `percentual`, `resumo`, `risco`, `bloqueio`, and `proximaAcao`. |
| Create task field name drift | Added aliases for `taskTitle`, `taskDescription`, `responsibleUpn`, `plannerBucketName`, and `estimatedHours`. |
| Update task field name drift | Added aliases for `taskStatus`, `actualHours`, `responsibleUpn`, `taskTitle`, and `updateNotes`. |
| `Cancelada` versus `Cancelado` | Normalized the card value to `Cancelado`. |
| Task list quick actions missing branches | Added explicit branches for `createTaskFromProject`, `editTask`, `markTaskInProgress`, `markTaskDone`, and `requestTaskUpdate`. Write-like quick actions remain gated behind owner-approved write gates. |
| `operationId` ambiguity | Documented `operationId` as correlation ID only; dispatch is by `routeKey` plus `action`. |
| Client-submitted `plannerTaskId` risk | Removed `plannerTaskId` from the update task card and added a rule to resolve Planner IDs server-side from SharePoint by `taskId`. |

## 4. Local Verification

| Check | Result |
|---|---|
| `flow_pseudocode_definitions.json` parses with `ConvertFrom-Json` | PASS |
| All six P0 Adaptive Card JSON files parse with `ConvertFrom-Json` | PASS |
| ASCII scan on changed card/flow files | PASS |
| `plannerTaskId` no longer appears in `AtualizarTarefaCard.json` | PASS |
| `Cancelada` no longer appears in `AtualizarTarefaCard.json` | PASS |

## 5. Remaining Gates

This fix does not authorize or complete runtime gates.

Still blocking SHIP:

- AQ-03 SharePoint `Tarefas` schema write approval and evidence.
- AQ-07 owner-approved Power Automate save/import evidence.
- AQ-08 owner-approved Copilot publish/update evidence.
- AQ-09 runtime smoke, Planner write evidence, Teams route evidence, and no `ContentFiltered`/XPIA evidence.
- AQ-10 final release decision.

## 6. Execution Statement

No tenant writes were performed.
No SharePoint writes were performed.
No Planner writes were performed.
No Teams posts were performed.
No Power Automate flow save/import was performed.
No Copilot publish/update was performed.

```text
NO-SHIP
```

## 7. AQ-07 Planner Status Card Alignment

Date: 2026-05-15

After AQ-07 status schema alignment, the task cards were updated to submit the canonical AQ-07 status set expected by FI-04/FI-05:

```text
Pendente
Em Andamento
Testes
Piloto e Implantacao
Concluido
Cancelado
```

Files changed:

| File | Change |
|---|---|
| `deploy/cards/CriarTarefaCard.json` | Made `plannerBucketName` required, defaulted it to `Pendente`, normalized `Em Andamento`, and added `Piloto e Implantacao` plus `Cancelado`. |
| `deploy/cards/AtualizarTarefaCard.json` | Normalized `Em Andamento` and added `Piloto e Implantacao`. |
| `.planning/comms/aq07_power_automate_build_20260515/CARD_ACTION_BINDING_MATRIX.csv` | Expanded expected inputs for FI-04 and FI-05 to include the task bucket/status fields actually submitted by the cards. |

This is a local card contract change only. It does not prove Planner update mutation behavior and does not authorize AQ-07/AQ-08/AQ-09 tenant execution.
