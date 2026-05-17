# POST-PUBLISH RUNTIME COMMANDS - SOLUTION 3.14

Run after importing `Solution/PMO_v11_Tarefas_3_14_ULTRA_SAFE_OUTPUT_FIX.zip` and publishing `Assistente PMO V2`.

Verified SharePoint state before this package:

- Project: `QA Robust 20260513 F`
- ProjectID: `PRJ-274E5ACC`
- Active task IDs: `14`, `15`
- Deleted task ID: `13`

## Expected Output Shape

3.14 intentionally uses ultra-safe output:

- `ListarTarefas` should return only ProjectID, total, completed count, and task IDs.
- `AtualizarTarefa` should return only a static success message.
- The detailed task fields remain in SharePoint; they are not echoed to the bot-visible response.

## Commands

### 1. List Active IDs

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
Projeto PRJ-274E5ACC. Total 2. Concluidas 0. IDs 14, 15.
```

Pass:

- No task `13`
- No title/email/status/date/hour details
- No `ContentFiltered`
- No `openAIIndirectAttack`
- No literal `\n`

### 2. One-Line Update

```text
atualizar tarefa
```

Then paste:

```text
15, em andamento, 2, mbenicios@minsait.com, 21/05/2026, media, sim
```

Expected:

```text
Tarefa atualizada com sucesso. Dados gravados no SharePoint. Use listar tarefas para conferir os IDs ativos.
```

Pass:

- No `ContentFiltered`
- No raw email echo
- No detailed dynamic field echo

### 3. Multiline Update

```text
atualizar tarefa
```

Then paste:

```text
15
em andamento
2
mbenicios@minsait.com
21/05/2026
media
sim
```

Expected same static success message.

### 4. Missing-Date Shift Test

```text
atualizar tarefa
```

Then paste:

```text
15, em andamento, 2, mbenicios@minsait.com, media, sim
```

Expected: Copilot asks:

```text
Novo prazo? (responda "nao" para manter o atual)
```

Then answer:

```text
nao
```

Pass:

- Static success message
- No `ContentFiltered`
- `media` is not shifted into the due-date field

### 5. Skip Optional Fields

```text
atualizar tarefa
```

Then paste:

```text
15
em andamento
0
nao
nao
nao
sim
```

Expected same static success message.

Pass:

- No `ContentFiltered`
- Existing responsible, due date, and priority remain preserved in SharePoint

### 6. Final List

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected:

```text
Projeto PRJ-274E5ACC. Total 2. Concluidas 0. IDs 14, 15.
```

Final ship gate:

- If any `ContentFiltered` / `openAIIndirectAttack` appears, output remains NO-SHIP.
- If all six commands pass, this specific content-filter incident can be closed.

