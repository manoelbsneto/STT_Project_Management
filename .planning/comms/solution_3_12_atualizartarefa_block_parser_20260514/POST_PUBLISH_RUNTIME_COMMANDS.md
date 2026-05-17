# POST-PUBLISH RUNTIME COMMANDS - 3.12

Agent: Codex
Timestamp BRT: 2026-05-14 09:53
Bot: `Assistente PMO V2`
Environment: `ColOfertasBrasilPro`
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
Bot ID: `df148bf8-0a3e-495b-80c4-841dcb61d9a4`

## Read-Only Query Status

Attempted from this session:

```powershell
m365 status
```

Result:

```text
Logged out
```

The runtime commands below use latest confirmed evidence from Copilot screenshots and local gate files.

## Confirmed IDs

| Item | Value |
|---|---|
| Project name | `QA Robust 20260513 F` |
| ProjectID | `PRJ-274E5ACC` |
| Project SharePoint item ID | `33` |
| Regression task ID | `15` |
| Regression task title | `QA Final Skip 20260513 2105` |
| Expected responsible | `mbenicios@minsait.com` |
| Expected due date | `2026-05-21` |
| Expected priority | `media` |
| Expected status | `em andamento` |
| Expected hours realized | `2` |
| Historical soft-deleted task ID | `13` |

## Flow IDs

| Flow | ID |
|---|---|
| PMO_PA_ListarTarefas | `9544f14b-3748-f111-bec7-6045bdf42cae` |
| PMO_PA_AtualizarTarefa | `98408d55-3748-f111-bec7-000d3abc5cc6` |
| PMO_PA_CriarTarefa | `0a5d2a41-24c0-4d5e-9f6d-000000000241` |
| PMO_PA_PedirDecisaoBot | `feb79d54-c64c-f111-bec7-7ced8d955c6c` |
| PMO_PA_AtualizarStatus | `c11a165b-c64c-f111-bec7-7ced8d9559c1` |

## Runtime Queue

### CMD-312-01

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected: ID 15 visible, ID 13 hidden, no `ContentFiltered`.

### CMD-312-02

```text
atualizar tarefa
```

Paste as one message:

```text
15
em andamento
2
mbenicios@minsait.com
21/05/2026
media
sim
```

Expected: success, no repeated ID prompt.

### CMD-312-03

```text
atualizar tarefa
```

Paste as one message:

```text
15, em andamento, 2, mbenicios@minsait.com, 21/05/2026, media, sim
```

Expected: success, no repeated ID prompt.

### CMD-312-04

```text
atualizar tarefa
```

Paste as one message:

```text
15, em andamento, 2, mbenicios@minsait.com, media, sim
```

Expected: asks `Novo prazo?`; answer:

```text
nao
```

Then expected: priority stays `media`, no date/priority shift.

### CMD-312-05

```text
atualizar tarefa
```

Paste as one message:

```text
15
em andamento
0
nao
nao
nao
sim
```

Expected: existing optional values preserved.

### CMD-312-06

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected: ID 15 active with clean values; ID 13 hidden; no `ContentFiltered`.

