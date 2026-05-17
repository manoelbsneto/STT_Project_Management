# PMO v1.1 Task Management Topics 3.0 - Local Gates

## Package

- Path: `Solution/PMO_v11_Tarefas_3_0_CRIARTAREFA_INLINE_PARSER_FIX.zip`
- SHA256: `B10D5AFD5764505D76139302307CE1EA539FFE8CB401948B1C31FC5BE7E2229C`
- Import status: not imported by Codex. Owner-only manual import required.

## Change Scope

- `CriarTarefa` topic now parses one-shot fields before questions:
  - `projeto`
  - `titulo`
  - `responsavel`
  - `prazo`
  - `horas`
  - `prioridade`
- `CriarTarefa` still calls `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`; no direct CloudFlow binding was added.
- No SharePoint schema change.
- No physical delete operation.

## Local Gate Results

All gates below passed locally on 2026-05-13.

| Gate | Result |
|---|---|
| `tests/Test-SolutionZipP24Contracts.ps1` | PASS |
| `tests/Test-CriarTarefaTopicParser.ps1` | PASS |
| `tests/Test-CriarTarefaPublishBinding.ps1` | PASS |
| `tests/Test-CriarTarefaCreatesTarefas.ps1` | PASS |
| `tests/Test-CriarProjetoTopicParser.ps1` | PASS |
| `tests/Test-PMOFlowStopShipAudit.ps1` | PASS |
| `git diff --check` | PASS with pre-existing CRLF warnings only |

## Runtime Test After Manual Import

Use a new Copilot Studio test session.

```text
criar tarefa: projeto=Teste Data BR Projeto 2.9, titulo=Smoke task 3.0 clean, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=1, prioridade=Baixa
```

Expected behavior:

- Bot should not ask `Quem e o responsavel pela tarefa?`
- Bot should go directly to confirmation.
- After `sim`, task should be created in `Tarefas`.

Then validate:

```text
listar tarefas do projeto Teste Data BR Projeto 2.9
```

Expected behavior:

- Response includes `Smoke task 3.0 clean` with returned task ID.

