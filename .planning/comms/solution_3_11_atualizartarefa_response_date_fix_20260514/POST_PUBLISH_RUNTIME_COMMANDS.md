# Post-Publish Runtime Commands - 3.11

Agent: Codex
Timestamp: 2026-05-14 08:55 BRT
Bot: `Assistente PMO V2`
Environment: `ColOfertasBrasilPro`
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
Bot ID: `df148bf8-0a3e-495b-80c4-841dcb61d9a4`

## Read-Only Data Source Status

SharePoint read-only query was attempted from this session:

```powershell
m365 status
```

Result:

```text
Logged out
```

PnP read-only query was also attempted:

```powershell
Get-PnPListItem -List 'Tarefas' -PageSize 5 -Fields 'ID','Title','ProjectID','TaskID','Status','Responsavel','DataFim','Prioridade','Deleted'
```

Result:

```text
You are not signed in. Please use Connect-PnPOnline to connect.
```

Therefore, current runtime commands below use the latest confirmed project/task evidence from Copilot runtime screenshots and repository gate files.

## Confirmed IDs For This Runtime Pass

| Item | Value |
| --- | --- |
| Active project name | `QA Robust 20260513 F` |
| Active ProjectID | `PRJ-274E5ACC` |
| Project SharePoint item ID | `33` |
| Current regression task item ID | `15` |
| Current regression task title | `QA Final Skip 20260513 2105` |
| Expected responsible | `mbenicios@minsait.com` |
| Expected due date | `2026-05-21` |
| Expected priority | `media` |
| Expected status | `em andamento` |
| Expected hours realized | `2` |
| Historical soft-deleted task ID | `13` |

## Relevant Flow IDs

| Flow | ID |
| --- | --- |
| PMO_PA_ListarTarefas | `9544f14b-3748-f111-bec7-6045bdf42cae` |
| PMO_PA_AtualizarTarefa | `98408d55-3748-f111-bec7-000d3abc5cc6` |
| PMO_PA_CriarTarefa | `0a5d2a41-24c0-4d5e-9f6d-000000000241` |
| PMO_PA_PedirDecisaoBot | `feb79d54-c64c-f111-bec7-7ced8d955c6c` |
| PMO_PA_AtualizarStatus | `c11a165b-c64c-f111-bec7-7ced8d9559c1` |

## Stop Rule

Stop immediately on any `FlowActionBadGateway`, `NoResponse`, `FlowActionInternalServerError`, wrong SharePoint write, or response showing raw skipped values such as `Responsavel: nao`, `Prazo: nao`, or `Prioridade: nao`.

## P0 Runtime Queue

### CMD-311-01 - Baseline List

Send in a new Copilot Studio test session:

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
Must include ID 15 / QA Final Skip 20260513 2105.
Must show ProjectID PRJ-274E5ACC or project QA Robust 20260513 F.
Must not show ID 13 as an active task.
```

### CMD-311-02 - BR Date Normalization

Send:

```text
atualizar tarefa
```

Answer prompts exactly:

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
Tarefa #15 atualizada.
Status: em andamento
Horas: 2
Responsavel: mbenicios@minsait.com
Prazo: 2026-05-21
Prioridade: media
```

### CMD-311-03 - Skip Optional Fields

Send:

```text
atualizar tarefa
```

Answer prompts exactly:

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
Status: em andamento
Horas: 2
Responsavel: mbenicios@minsait.com
Prazo: 2026-05-21
Prioridade: media
```

Forbidden:

```text
Responsavel: nao
Prazo: nao
Prioridade: nao
Horas: 0
FlowActionBadGateway
NoResponse
```

### CMD-311-04 - Confirm List After Updates

Send:

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
ID 15 remains active.
ID 13 remains hidden.
Task 15 shows status em andamento, responsible mbenicios@minsait.com, due date 2026-05-21, priority media.
```

## P1 Runtime Queue

### CMD-09 - Invalid UPN Guard

Send:

```text
solicitar decisao: projeto=QA Robust 20260513 F, descricao=QA invalid UPN guard 3.11, impacto=Alto, prazo=31/05/2026, aprovador=UPN ?
```

If prompted for missing fields, answer:

```text
QA Robust 20260513 F
QA invalid UPN guard 3.11
Alto
31/05/2026
UPN ?
sim
```

Expected:

```text
Controlled validation rejection for invalid UPN.
No FlowActionInternalServerError.
No decision created.
```

### CMD-08 - Valid Decision Request

Run only after CMD-09 rejects correctly.

Send:

```text
solicitar decisao: projeto=QA Robust 20260513 F, descricao=QA valid decision 3.11 publish proof, impacto=Alto, prazo=31/05/2026, aprovador=mbenicios@minsait.com
```

If prompted, answer:

```text
QA Robust 20260513 F
QA valid decision 3.11 publish proof
Alto
31/05/2026
mbenicios@minsait.com
sim
```

Expected:

```text
Decision created successfully.
ApproverUPN: mbenicios@minsait.com
ProjectID: PRJ-274E5ACC
StatusDecisao: Pendente
```

### CMD-15 - Portfolio Read Recheck

Send:

```text
consultar portfolio
```

Expected:

```text
No error.
Totals are returned.
No deleted test rows are counted as active work.
```

### CMD-10 - AtualizarStatus Multiline Parser

Send:

```text
atualizar status
```

Use this payload if the bot asks for the status text:

```text
Projeto: QA Robust 20260513 F
Resumo: QA 3.11 multiline parser proof. Linha 1 ok.
Linha 2 deve continuar no resumo sem quebrar os campos.
Risco: Baixo
Bloqueio: Sem bloqueios
Proxima acao: finalizar QA 3.11
Percentual: 40
```

Expected:

```text
Status Diario created or updated without dropping multiline resumo.
Structured fields should be captured: Risco=Baixo, Bloqueio=Sem bloqueios, ProximaAcao=finalizar QA 3.11, Percentual=40.
```

Known risk:

```text
This was partial before 3.11. If structured fields remain blank but resumo is preserved, classify as PARTIAL and decide whether it blocks full ship.
```

## Fresh Task Fallback

Use only if task `15` is not visible or cannot be updated.

Create a fresh task:

```text
criar tarefa: projeto=QA Robust 20260513 F, titulo=QA 3.11 Fresh Runtime 20260514, responsavel=mbenicios@minsait.com, prazo=21/05/2026, horas=2, prioridade=Media
```

If prompted:

```text
2
sim
```

Capture the returned SharePoint task item ID, then rerun `CMD-311-02` and `CMD-311-03` using the new task ID instead of `15`.
