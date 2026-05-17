# Solution 3.11 AtualizarTarefa Response/Date Fix - Master Checklist

Generated: 2026-05-14
Agent: Agent A - Incident Commander / Program Control
Mission: SEV-0 Stop-Ship control for `PMO_PA_AtualizarTarefa` runtime blockers after export 3.10.

## Command Constraints

- Do not make tenant writes, imports, publishes, deletes, commits, or portal/runtime changes.
- Create only:
  - `.planning/comms/solution_3_11_atualizartarefa_response_date_fix_20260514/MASTER_CHECKLIST.md`
  - `.planning/comms/solution_3_11_atualizartarefa_response_date_fix_20260514/RISK_REGISTER.md`
- Release state remains `NO-SHIP` until all mandatory gates pass against the exact imported and published artifact.
- CI gate is excluded by owner for this mission; all other applicable static, package, export, publish, and runtime gates remain mandatory.

## Current Baseline and Evidence

| Area | Status | Evidence |
|---|---|---|
| Mandatory files read | DONE | `.planning/GOLDEN_RULES.md`, `.planning/CURRENT_BASELINE.md`, `.planning/AGENT_CHECKIN_REGISTRY.md`, `docs/MANUAL_OPERACIONAL_PMO.md` |
| Current high-level handoff | REVIEWED | `.planning/START_HERE_CURRENT_STATUS.md` |
| Latest post-cleanup export | PASS STATIC | `.planning/comms/solution_3_8_post_import_export_validation_20260513/EXPORT_3_10_POST_WFSET_CLEAN_REVIEW.md` |
| Latest package under discussion | 3.10 static-pass export | `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`, SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691` |
| Runtime QA blocker evidence | PARTIAL / FAIL | `.planning/comms/solution_3_8_post_import_export_validation_20260513/RUNTIME_QA_20260513_TASK15.md` |
| Existing skip-semantics static test | AVAILABLE | `tests/Test-AtualizarTarefaSkipSemantics.ps1` |
| Prior skip-fix local gate | PASS, superseded by later packages | `.planning/comms/solution_3_5_atualizartarefa_skip_fix_20260513/LOCAL_GATES.md` |

## Incident Scope

| ID | Blocker | Current Evidence | Required Outcome |
|---|---|---|---|
| ISSUE-001 | Bot response shows raw `nao` values instead of effective persisted values on skip inputs. | Runtime QA task 15: SharePoint write preserved values, but Copilot response displayed `Responsavel: nao Prazo: nao Prioridade: nao`. | Response text must use effective values after normalization/preservation, not raw trigger inputs. |
| ISSUE-002 | `dd/MM/yyyy` due date causes `BadGateway` / `OpenApiOperationParameterTypeConversionFailed` because SharePoint date expects ISO `yyyy-MM-dd`. | Runtime QA task 15: run `08584228891053733219995694617CU20` failed on `Update_Tarefa` with bad value `21/05/2026\n`. | `PMO_PA_AtualizarTarefa` must normalize accepted BR date input to `yyyy-MM-dd` before SharePoint update. |

## Control Checklist

| Gate | Owner | Status | Evidence Required |
|---|---|---|---|
| Confirm no tenant/runtime modifications in this command session | Agent A | DONE | This checklist and risk register only. |
| Confirm 3.10 export is the post-cleanup baseline for the 3.11 patch | Agent A / Build owner | OPEN | Package path, SHA256, and source unpack path recorded in 3.11 local gates. |
| Patch ISSUE-001 in local package source only | Build owner | OPEN | Diff or package review showing response message references effective `Responsavel`, `DataFim`, and `Prioridade` values. |
| Patch ISSUE-002 in local package source only | Build owner | OPEN | Diff or package review showing BR date normalization from `dd/MM/yyyy` to `yyyy-MM-dd` before `Update_Tarefa`. |
| Extend/add static regression for response effective values | Build owner | OPEN | Test proves response output does not compose raw skip tokens for preserved fields. |
| Extend/add static regression for BR date normalization | Build owner | OPEN | Test proves `DataFim` accepts BR input and passes ISO date string to SharePoint action. |
| Run `tests/Test-AtualizarTarefaSkipSemantics.ps1` | Build owner | OPEN | PASS output against the 3.11 package. |
| Run stop-ship audit | Build owner | OPEN | `tests/Test-PMOFlowStopShipAudit.ps1` PASS against unpacked 3.11. |
| Run P24 package contract | Build owner | OPEN | `tests/Test-SolutionZipP24Contracts.ps1 -ExpectedVersion 3.11` PASS, unless package metadata remains 3.10 by explicit owner decision. |
| Run P0 package contract | Build owner | OPEN | `tests/Test-SolutionZipP0Contracts.ps1` PASS. |
| Run targeted PMO regression tests other than CI | Build owner | OPEN | CriarTarefa, CriarProjeto, routing, UPN, soft-delete, regex, ASCII, and package hygiene tests PASS where applicable. |
| ASCII app-facing scan | Build owner | OPEN | No non-ASCII in changed flow/topic/card/user-facing artifacts. |
| Import 3.11 package | Owner | BLOCKED | Requires explicit owner action/approval; no agent import in this mission. |
| Publish Copilot bot | Owner | BLOCKED | Requires explicit owner action/approval; no agent publish in this mission. |
| Post-import export validation | Owner + Codex | OPEN | Exported package from tenant matches intended 3.11 and passes static gates. |
| Runtime retest ISSUE-001 | Owner + Codex | OPEN | Update task with skip values; SharePoint preserves values and bot response displays effective values. |
| Runtime retest ISSUE-002 | Owner + Codex | OPEN | Update task with due date like `21/05/2026`; flow succeeds and SharePoint stores ISO-compatible date. |
| Runtime regression CMD-13B/C | Owner + Codex | OPEN | Explicit update and concluded path still pass; project counters recalculate. |
| Remaining non-AtualizarTarefa runtime gates | Owner + Codex | OPEN | CMD-12-H, CMD-09, CMD-08, CMD-15, and accepted/closed CMD-10 decision. |
| Final ship decision | Human/Admin | BLOCKED | Only after static, export, publish, and runtime evidence pass. |

## Required Runtime Acceptance for 3.11

1. Existing task has known `Responsavel`, `DataFim`, `Prioridade`, `HorasRealizadas`, and `HorasEstimadas`.
2. User updates task and answers skip tokens (`nao`, `n`, blank, or equivalent accepted skip) for optional fields.
3. Flow succeeds.
4. SharePoint `Update_Tarefa` inputs and outputs preserve existing values.
5. Bot response displays the effective preserved values, not raw skip tokens.
6. User updates task with `Prazo=21/05/2026`.
7. Flow succeeds and SharePoint receives/stores an ISO-compatible date value.
8. Explicit valid values still overwrite preserved values when supplied.

## Current Decision

Decision: `NO-SHIP`.

Rationale: 3.10 passed static/export hygiene, but `PMO_PA_AtualizarTarefa` still has runtime blockers in response display and BR date normalization. CI is excluded by owner, but that does not waive the local static, package, export, publish, and runtime evidence gates listed above.
