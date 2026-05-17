---
phase: 2.4
name: CriarProjeto / CriarTarefa / Gerar_Multiplos_Projetos
status: planned
mode: local-only
owner: Codex
prod_changes: prohibited_without_owner_approval
wave: 1
depends_on:
  - Solution/PMO_v11_Tarefas_2_3_EXCLUIRTAREFA_PROJECT_SCOPE_FIX.zip
requirements_addressed:
  - REQ-14
  - REQ-15
  - REQ-16
files_modified:
  - PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md
  - docs/MANUAL_OPERACIONAL_PMO.md
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
  - .planning/TASK_BOARD.md
  - .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/02-04-CONTEXT.md
  - .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/02-04-RESEARCH.md
  - .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/PLAN.md
  - .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/VERIFICATION.md
autonomous: false
---

# Phase 2.4 PLAN

## Objective

Separate project creation from task creation and add a controlled batch project creation capability without breaking the current production baseline.

This phase produces local artifacts only:

- updated documentation;
- a future local solution package 2.4;
- static tests that block the old ambiguous behavior;
- runtime test plan for owner-approved import/publish later.

## Non-Negotiable Constraints

- No PROD import, publish, deploy, flow edit, portal edit, or SharePoint write without explicit owner approval in the current chat.
- Standard connectors only.
- No direct Graph, HTTP with Entra, Premium connectors, custom connectors, Dataverse custom persistence, or Planner Premium.
- Adaptive Cards are Plan A.
- Multiline/STT parser is Plan B.
- All write paths require explicit confirmation.
- `CriarTarefa` must never write to `Projetos`.

## Required Project Skills

| Skill file | Required use in this phase |
|---|---|
| `skills/super/SKILL_COPILOT_STUDIO_AGENT.md` | Audit topics, trigger phrases, action bindings, inputs, outputs, fallback behavior, and "success only after flow response" rules. |
| `skills/super/SKILL_POWER_AUTOMATE_EXPRESSIONS.md` | Validate Cloud Flow expressions, Parse JSON, null/empty handling, date/locale handling, arrays, and runtime-safe alternatives. |
| `skills/super/SKILL_SHAREPOINT_SCHEMA.md` | Validate `Projetos` and `Tarefas` list names, column names/internal names, data types, filters, permissions, and evidence before package changes. |
| `skills/data_expert_skills/software-ui-ux-design.md` | Apply form/card UX gates: clear primary action, validation before failure, state matrix, accessibility, focus, and target size. |
| `skills/data_expert_skills/senior-uiux-data-products.md` | Keep Adaptive Card review screens concise, executive-readable, status-aware, and scannable. |

## Deliverables

| Artifact | Purpose |
|---|---|
| `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md` | Product contract addendum REQ-14/15/16 |
| `docs/MANUAL_OPERACIONAL_PMO.md` | Operational commands and examples |
| `.planning/REQUIREMENTS.md` | GSD requirement tracking |
| `.planning/ROADMAP.md` | Phase 2.4 roadmap entry |
| `.planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/02-04-CONTEXT.md` | Phase context |
| `.planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/02-04-RESEARCH.md` | Microsoft-backed research |
| `.planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/PLAN.md` | Executable phase plan |
| `.planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/VERIFICATION.md` | Plan-check result |

Future execution artifacts:

| Artifact | Purpose |
|---|---|
| `Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip` | Local importable solution candidate |
| `tests/Test-CriarProjetoFlowDefinition.ps1` | Proves `CriarProjeto` targets `Projetos` |
| `tests/Test-CriarTarefaCreatesTarefas.ps1` | Proves `CriarTarefa` targets `Tarefas` |
| `tests/Test-GerarMultiplosProjetosDefinition.ps1` | Proves batch/card/fallback contract |
| `tests/Test-SolutionZipP24Contracts.ps1` | End-to-end static package gate |

## Tasks

## GSD Executable Task Blocks

<task id="P24-T1" wave="1">
  <name>Documentation and skill gate</name>
  <read_first>
    - .planning/GOLDEN_RULES.md
    - .planning/CURRENT_BASELINE.md
    - .planning/SKILLS_MAP.md
    - skills/super/SKILL_COPILOT_STUDIO_AGENT.md
    - skills/super/SKILL_POWER_AUTOMATE_EXPRESSIONS.md
    - skills/super/SKILL_SHAREPOINT_SCHEMA.md
    - skills/data_expert_skills/software-ui-ux-design.md
    - skills/data_expert_skills/senior-uiux-data-products.md
    - PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md
    - docs/MANUAL_OPERACIONAL_PMO.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
  </read_first>
  <action>
    Keep REQ-14, REQ-15, and REQ-16 as the source of truth. Verify the docs state exactly these contracts: CriarProjeto writes only to Projetos; CriarTarefa writes only to Tarefas; Gerar_Multiplos_Projetos uses Adaptive Card review/confirmation first and multiline/STT fallback second. Keep .planning/SKILLS_MAP.md linked to the phase plan.
  </action>
  <acceptance_criteria>
    - `rg -n "REQ-14|REQ-15|REQ-16" .planning/REQUIREMENTS.md PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md` exits 0.
    - `rg -n "SKILL_COPILOT_STUDIO_AGENT|SKILL_POWER_AUTOMATE_EXPRESSIONS|SKILL_SHAREPOINT_SCHEMA" .planning/SKILLS_MAP.md .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/PLAN.md` exits 0.
    - `git diff --check -- .planning/SKILLS_MAP.md PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md docs/MANUAL_OPERACIONAL_PMO.md .planning/REQUIREMENTS.md .planning/ROADMAP.md` exits 0.
  </acceptance_criteria>
</task>

<task id="P24-T2" wave="1">
  <name>Tests before package changes</name>
  <read_first>
    - tests/Test-PMOFlowStopShipAudit.ps1
    - tests/Test-ExcluirSoftDeleteCapability.ps1
    - tests/Test-CriarTarefaFlowDefinition.ps1
    - .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/02-04-CONTEXT.md
    - .planning/SKILLS_MAP.md
  </read_first>
  <action>
    Create local static tests named Test-CriarProjetoFlowDefinition.ps1, Test-CriarTarefaCreatesTarefas.ps1, Test-GerarMultiplosProjetosDefinition.ps1, and Test-SolutionZipP24Contracts.ps1. The tests must fail if CriarTarefa writes to Projetos, if CriarProjeto writes to Tarefas, if Gerar_Multiplos_Projetos has no Adaptive Card confirmation marker, if fallback parser bypasses confirmation, or if Premium/Graph/HTTP connectors appear.
  </action>
  <acceptance_criteria>
    - `Test-CriarProjetoFlowDefinition.ps1` contains `Projetos` and does not allow target list `Tarefas` for CriarProjeto.
    - `Test-CriarTarefaCreatesTarefas.ps1` contains `Tarefas` and rejects target list `Projetos` for CriarTarefa.
    - `Test-GerarMultiplosProjetosDefinition.ps1` contains `Adaptive Card`, `Gerar_Multiplos_Projetos`, and a confirmation assertion.
    - `Test-SolutionZipP24Contracts.ps1` invokes all three feature-specific tests.
  </acceptance_criteria>
</task>

<task id="P24-T3" wave="2">
  <name>Local solution package 2.4</name>
  <read_first>
    - Solution/PMO_v11_Tarefas_2_3_EXCLUIRTAREFA_PROJECT_SCOPE_FIX.zip
    - .planning/comms/solution_2_3_excluirtarefa_project_scope_20260511/unpacked
    - deploy/PA_CriarTarefa_Flow.ps1
    - skills/super/SKILL_COPILOT_STUDIO_AGENT.md
    - skills/super/SKILL_POWER_AUTOMATE_EXPRESSIONS.md
    - skills/super/SKILL_SHAREPOINT_SCHEMA.md
  </read_first>
  <action>
    Build a local-only package named Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip from the 2.3 baseline. Preserve ExcluirTarefa 2.3 guards. Add or rename project creation to PMO_PA_CriarProjeto targeting Projetos. Add PMO_PA_CriarTarefa targeting Tarefas after resolving an active, non-deleted project. Add PMO_PA_Gerar_Multiplos_Projetos with max 10 projects and 10 tasks, preview/confirmation, per-row duplicate checks, and per-row results.
  </action>
  <acceptance_criteria>
    - `Test-SolutionZipP24Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip` exits 0.
    - `Test-PMOFlowStopShipAudit.ps1` exits 0 against the unpacked 2.4 source.
    - No package file contains `runtimeSource=invoker`.
    - No package file contains direct Graph or HTTP with Entra connector references.
  </acceptance_criteria>
</task>

<task id="P24-T4" wave="3">
  <name>Owner runtime evidence plan</name>
  <read_first>
    - docs/MANUAL_OPERACIONAL_PMO.md
    - .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos/PLAN.md
    - .planning/AGENT_CHECKIN_REGISTRY.md
  </read_first>
  <action>
    Prepare owner-run runtime commands only after static PASS and explicit owner approval to import/publish. Commands must prove CriarProjeto creates only Projetos, CriarTarefa creates only Tarefas, Gerar_Multiplos_Projetos confirms via card before writing, ListarTarefas returns created task IDs, and ExcluirTarefa deletes selected tasks logically.
  </action>
  <acceptance_criteria>
    - Runtime plan includes positive and negative tests.
    - Runtime plan includes SharePoint read-only verification after each write.
    - Runtime plan states that only the owner imports/publishes/runs production write validation.
  </acceptance_criteria>
</task>

### Task 1 - Documentation Gate

Update source-of-truth project docs:

- PRD addendum for REQ-14, REQ-15, REQ-16.
- Manual command examples and expected behavior.
- Roadmap phase 2.4.
- Requirements tracker.
- PMO status report.

Acceptance:

- Docs explicitly say `CriarTarefa` writes only to `Tarefas`.
- Docs explicitly say `CriarProjeto` writes only to `Projetos`.
- Docs explicitly say `Gerar_Multiplos_Projetos` uses Adaptive Card first and text/STT fallback.

### Task 2 - Local Contract Tests First

Create tests before package edits:

- `Test-CriarProjetoFlowDefinition.ps1`
- `Test-CriarTarefaCreatesTarefas.ps1`
- `Test-GerarMultiplosProjetosDefinition.ps1`
- `Test-SolutionZipP24Contracts.ps1`

Acceptance:

- Tests fail on old ambiguous package.
- Tests pass only when target lists and topic routing are correct.

### Task 3 - Local Package 2.4

Use `Solution/PMO_v11_Tarefas_2_3_EXCLUIRTAREFA_PROJECT_SCOPE_FIX.zip` as baseline.

Implement local-only unpacked package:

- `PMO_PA_CriarProjeto` or equivalent component that preserves project creation.
- `PMO_PA_CriarTarefa` that creates `Tarefas`.
- `PMO_PA_Gerar_Multiplos_Projetos` for batch.
- Topics:
  - `CriarProjeto`
  - `CriarTarefa`
  - `Gerar_Multiplos_Projetos`

Acceptance:

- `CriarProjeto` triggers project phrases only.
- `CriarTarefa` triggers task phrases only.
- `Gerar_Multiplos_Projetos` triggers batch phrases only.
- Adaptive Card preview/confirm is present for batch.
- Fallback parser markers exist for multiline/STT.

### Task 4 - Static Audit

Run all local gates:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP24Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarProjetoFlowDefinition.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaCreatesTarefas.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-GerarMultiplosProjetosDefinition.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath <unpacked-2.4-temp>
```

Acceptance:

- 0 failed checks.
- No Premium/Graph/HTTP.
- No raw APIM token auth.
- No `runtimeSource=invoker`.
- No physical delete.
- No non-ASCII app-facing flow text where ASCII is required.

### Task 5 - Owner Runtime Plan

Prepare commands for owner runtime testing after import/publish approval:

1. `criar projeto` creates one `Projetos` row and no `Tarefas`.
2. `criar tarefa` creates one `Tarefas` row and no `Projetos`.
3. `gerar multiplos projetos` creates up to 10 projects and paired tasks after card confirmation.
4. `listar tarefas do projeto <nome>` returns new tasks.
5. `excluir tarefa projeto <nome> tarefa <id> motivo <motivo>` deletes only selected tasks logically.

Acceptance:

- Runtime proof includes Copilot screenshot, flow run, SharePoint verification.
- Positive `ExcluirTarefa` can be tested with real tasks.

## Stop-Ship Rules

Stop immediately if:

- `CriarTarefa` writes to `Projetos`.
- `CriarProjeto` writes to `Tarefas`.
- Batch writes without confirmation.
- Card path is missing and only parser path exists.
- Parser path bypasses confirmation.
- Package requires owner to import without passing local tests.
- Any implementation requires a production write before approval.

## Verification Loop

Current checker result: BLOCK until formal plan and gates exist.

Resolution:

- This PLAN formalizes contracts, artifacts, tests, and gates.
- `VERIFICATION.md` must be updated after plan-checker re-review.
