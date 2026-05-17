# POST-PUBLISH RUNTIME COMMANDS - 3.13

Agent: Codex
Timestamp BRT: 2026-05-14 10:40
Bot: `Assistente PMO V2`
Environment: `ColOfertasBrasilPro`
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
Bot ID: `df148bf8-0a3e-495b-80c4-841dcb61d9a4`

## Import Command

Run only after confirming the package hash below.

```powershell
Get-FileHash -Algorithm SHA256 "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip"
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip" --force-overwrite --publish-changes --async --max-async-wait-time 60
```

Expected SHA256:

```text
B427F3CF64E7471F1C8BD29593888DC1A27F06389EF1FD614FE92684D94FF21E
```

After import, publish `Assistente PMO V2` in Copilot Studio before running the commands below.

## Confirmed Runtime IDs

| Item | Value |
|---|---|
| Project name | `QA Robust 20260513 F` |
| ProjectID | `PRJ-274E5ACC` |
| Project SharePoint item ID | `33` |
| Active regression task ID | `15` |
| Historical soft-deleted task ID | `13` |
| Expected status | `em andamento` |
| Expected responsible input | `mbenicios@minsait.com` |
| Expected due date input | `21/05/2026` |
| Expected persisted due date | `2026-05-21` |
| Expected priority | `media` |
| Expected hours realized | `2` |

## Flow IDs

| Flow | ID |
|---|---|
| PMO_PA_ListarTarefas | `9544f14b-3748-f111-bec7-6045bdf42cae` |
| PMO_PA_AtualizarTarefa | `98408d55-3748-f111-bec7-000d3abc5cc6` |
| PMO_PA_CriarTarefa | `0a5d2a41-24c0-4d5e-9f6d-000000000241` |
| PMO_PA_PedirDecisaoBot | `feb79d54-c64c-f111-bec7-7ced8d955c6c` |
| PMO_PA_AtualizarStatus | `c11a165b-c64c-f111-bec7-7ced8d9559c1` |

## Runtime Queue

### CMD-313-01 - List Tasks Format And Content Filter

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
Projeto PRJ-274E5ACC. Total 2. Concluidas 0.
Tarefa 14. Status Em Andamento. Prioridade Media. Fim 2026-05-20. Horas realizadas 128. Horas estimadas 19.
Tarefa 15. Status Em Andamento. Prioridade Media. Fim 2026-05-21. Horas realizadas 2. Horas estimadas 8.
```

Pass criteria: no `ContentFiltered`, no `openAIIndirectAttack`, no literal `\n`, no pipe-heavy line, task `13` hidden.

### CMD-313-02 - AtualizarTarefa Comma Block

```text
atualizar tarefa
```

Paste as one message:

```text
15, em andamento, 2, mbenicios@minsait.com, 21/05/2026, media, sim
```

Expected:

```text
Tarefa atualizada com sucesso.
ID 15
Projeto PRJ-274E5ACC
Status Em Andamento
Horas realizadas 2
Prazo 2026-05-21
Prioridade Media
Projeto atualizado. Percentual 0%. Total 2. Concluidas 0. Abertas 2. Atrasadas 0.
```

Pass criteria: no repeated ID prompt, no `ContentFiltered`, no title/email leak in final response.

### CMD-313-03 - AtualizarTarefa Multiline Block

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

Expected: same success shape as CMD-313-02.

### CMD-313-04 - Omitted Date Does Not Shift Priority

```text
atualizar tarefa
```

Paste as one message:

```text
15, em andamento, 2, mbenicios@minsait.com, media, sim
```

Expected: Copilot asks for the missing due date. Answer:

```text
nao
```

Pass criteria: priority remains `Media`; `media` is not written into `Prazo`.

### CMD-313-05 - Skip Optional Values

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

Pass criteria: existing responsible, due date, and priority are preserved; response remains content-safe.

### CMD-313-06 - Final List Verification

```text
listar tarefas do projeto QA Robust 20260513 F
```

Pass criteria: task `15` visible, task `13` hidden, no literal `\n`, no `ContentFiltered`, no `openAIIndirectAttack`.

