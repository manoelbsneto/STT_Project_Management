# RELEASE READINESS CHECKLIST - 2026-05-14

Decision: NO-SHIP

CI gate is excluded by owner instruction for this mission only. All other gates remain mandatory.

## Gate Status

| Gate | Status | Evidence |
|---|---|---|
| Critical issues reproduced | PASS | `RUNTIME_QA_20260513_TASK15.md`, `FORENSICS_NOTES.md` |
| Surgical fix implemented | PASS | 3.11 unpacked source paths in `EVIDENCE_LOG.md` |
| Automated regression tests | PASS LOCAL | `Test-AtualizarTarefaSkipSemantics.ps1` passed |
| P0 package contract | PASS LOCAL | `Test-SolutionZipP0Contracts.ps1` passed |
| P24 package contract | PASS LOCAL | `Test-SolutionZipP24Contracts.ps1 -ExpectedVersion 3.11` passed |
| Stop-ship source audit | PASS LOCAL | `Test-PMOFlowStopShipAudit.ps1` passed |
| CI | EXCLUDED | Owner explicitly excluded CI gate in current mission |
| Import into tenant | PENDING OWNER | Package ready |
| Copilot publish | PENDING OWNER | Required after import |
| Fresh runtime proof | PENDING OWNER + CODEX REVIEW | Required before SHIP |
| Performance regression | NOT APPLICABLE LOCAL | No new loops/connectors; runtime duration must be watched in post-publish tests |
| Backward compatibility | PASS LOCAL | Same flow IDs/action IDs retained |
| Rollback plan | READY | Import prior clean package if runtime fails |

## Import Candidate

```text
Solution/PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip
SHA256: D1752B089424ACA6C571374B8897AD12F8A8304DF228A17C8C591BD1EEF1CDAF
```

## Owner Import Command

Run from repo root:

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path "Solution\PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip" --force-overwrite --publish-changes --async --max-async-wait-time 60
```

Then publish `Assistente PMO V2` in Copilot Studio.

## Post-Publish Copilot Runtime Commands

Use a new Copilot test session after publish.

### Test 1 - Verify current task before update

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
ID 15 | Titulo: QA Final Skip 20260513 2105 | Status Em Andamento | Prioridade Media | Responsavel mbenicios@minsait.com | Fim 2026-05-21
```

### Test 2 - BR date normalization

```text
atualizar tarefa
```

Answer prompts:

```text
15
em andamento
2
nao
21/05/2026
media
sim
```

Expected:

```text
Tarefa atualizada com sucesso
ID: 15
Status: Em Andamento
Horas realizadas: 2
Responsavel: mbenicios@minsait.com
Prazo: 2026-05-21
Prioridade: Media
```

### Test 3 - Skip display does not show raw nao

```text
atualizar tarefa
```

Answer prompts:

```text
15
em andamento
0
nao
nao
nao
sim
```

Expected:

```text
Responsavel: mbenicios@minsait.com
Prazo: 2026-05-21
Prioridade: Media
```

Forbidden in final bot response:

```text
Responsavel: nao
Prazo: nao
Prioridade: nao
```

### Test 4 - Confirm with list

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
ID 15
Status Em Andamento
Prioridade Media
Responsavel mbenicios@minsait.com
Fim 2026-05-21
```

## Rollback Plan

If import or runtime test fails:

1. Do not continue broader QA.
2. Re-import the last clean package:

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path "Solution\PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip" --force-overwrite --publish-changes --async --max-async-wait-time 60
```

3. Publish `Assistente PMO V2`.
4. Export and send the import log/export zip for review.

