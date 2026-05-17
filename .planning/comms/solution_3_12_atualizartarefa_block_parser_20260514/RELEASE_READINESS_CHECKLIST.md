# RELEASE READINESS CHECKLIST - SOLUTION 3.12

Decision: NO-SHIP until runtime gates pass.

CI gate is excluded by owner instruction for this mission only. All other gates remain mandatory.

## Import Candidate

```text
Package: Solution/PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip
SHA256: E2EA3C8D009C177230DF0E4BC9890E2CB5506CB9462E39C4B1A9BACC890C5DB3
Version: 3.12
Environment: ColOfertasBrasilPro
Environment ID: e2d10003-4d8e-e007-9d63-76d5fe89ef56
Bot: Assistente PMO V2
Bot ID: df148bf8-0a3e-495b-80c4-841dcb61d9a4
```

## Owner Import Command

Run from repo root:

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path "Solution\PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip" --force-overwrite --publish-changes --async --max-async-wait-time 60
```

Then publish `Assistente PMO V2` in Copilot Studio.

## Gate Status

| Gate | Status | Evidence |
|---|---|---|
| Critical issue reproduced | PASS | Copilot runtime screenshot showed pasted block re-prompting for task ID |
| Surgical fix implemented | PASS LOCAL | `AtualizarTarefa` topic parser updated in 3.12 |
| Automated regression tests | PASS LOCAL | `Test-AtualizarTarefaBlockParser.ps1` |
| Skip semantics regression | PASS LOCAL | `Test-AtualizarTarefaSkipSemantics.ps1` |
| Package contracts | PASS LOCAL | P0/P24 ZIP tests |
| Stop-ship source audit | PASS LOCAL | `Test-PMOFlowStopShipAudit.ps1` |
| CI | EXCLUDED | Owner explicitly excluded CI gate in current mission |
| Tenant import | PENDING | Run import command above |
| Copilot publish | PENDING | Publish after import |
| Runtime proof | PENDING | Run commands below |
| Content filter runtime | PENDING | `ListarTarefas` must not end in `ContentFiltered` |
| Rollback plan | READY | Reimport 3.11 or 3.10 if 3.12 runtime fails |

## Runtime Stop Rule

Stop immediately and classify NO-SHIP if any of these appear:

```text
FlowActionBadGateway
NoResponse
FlowActionInternalServerError
ContentFiltered
openAIIndirectAttack
Responsavel: nao
Prazo: nao
Prioridade: nao
Repeated prompt for task ID after a valid pasted block
```

## Post-Publish Runtime Commands

Use a new Copilot Studio test session after publish.

### Test 1 - Baseline List

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
Must include ID 15 / QA Final Skip 20260513 2105.
Must show project PRJ-274E5ACC or QA Robust 20260513 F.
Must not show ID 13 as active.
Must not end with ContentFiltered/openAIIndirectAttack.
```

### Test 2 - Full Multiline Block

Send:

```text
atualizar tarefa
```

Paste this as one single message:

```text
15
em andamento
2
mbenicios@minsait.com
21/05/2026
media
sim
```

Expected:

```text
No repeated task ID prompt.
Tarefa #15 atualizada.
Status: em andamento
Horas: 2
Responsavel: mbenicios@minsait.com
Prazo: 2026-05-21
Prioridade: media
```

### Test 3 - Full Comma Block

Send:

```text
atualizar tarefa
```

Paste this as one single message:

```text
15, em andamento, 2, mbenicios@minsait.com, 21/05/2026, media, sim
```

Expected: same result as Test 2.

### Test 4 - Omitted Date Does Not Shift Fields

Send:

```text
atualizar tarefa
```

Paste this as one single message:

```text
15, em andamento, 2, mbenicios@minsait.com, media, sim
```

Expected:

```text
Copilot must ask: Novo prazo?
It must not treat media as the date.
Answer: nao
Then it should update with Prioridade media.
```

### Test 5 - Skip Optional Fields

Send:

```text
atualizar tarefa
```

Paste this as one single message:

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
Tarefa #15 atualizada.
Responsavel remains mbenicios@minsait.com.
Prazo remains 2026-05-21.
Prioridade remains media.
Horas remains 2.
```

Forbidden:

```text
Responsavel: nao
Prazo: nao
Prioridade: nao
Horas: 0
```

### Test 6 - Final List Confirmation

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
ID 15 remains active.
ID 13 remains hidden.
Task 15 shows status em andamento, responsible mbenicios@minsait.com, due date 2026-05-21, priority media.
No ContentFiltered/openAIIndirectAttack.
```

## Rollback Plan

If import or runtime test fails, stop the QA queue and reimport the prior release candidate:

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path "Solution\PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip" --force-overwrite --publish-changes --async --max-async-wait-time 60
```

Then publish `Assistente PMO V2` and retest only the last known passing runtime commands.

