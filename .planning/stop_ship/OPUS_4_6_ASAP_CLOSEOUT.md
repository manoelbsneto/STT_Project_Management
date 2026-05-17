# Opus 4.6 ASAP Closeout Prompt

Date: 2026-05-11 01:30 BRT
Status: NO-SHIP until V2 runtime gates pass

## Copy/Paste Prompt For Opus 4.6

You are taking over a Stop-Ship closeout for a Microsoft Copilot Studio + Power Automate + SharePoint PMO bot. Work as a senior Microsoft Power Platform solution architect. Do not invent patterns. Use only official Microsoft GA documentation and the validated local project patterns already present in this repo.

### Non-Negotiable Rules

- Target bot is `Assistente PMO V2`. Do not work on `Assistente PMO Clean`; it is an older/broken bot and is not the release target.
- Environment: `ColOfertasBrasilPro` / `e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
- Repo: `d:\VMs\Projetos\STT_Project_Management`.
- SharePoint site: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`.
- Standard connectors only. No Premium, no Graph API, no HTTP with Entra ID.
- Operational bot/flow text must stay ASCII-only.
- All write topics must confirm before action using `StringPrebuiltEntity` and an explicit `Or(Lower(Trim(...)) = "sim", ...)` condition.
- Never use `BooleanPrebuiltEntity`.
- All SharePoint writes must set `Deleted=false`.
- All SharePoint reads must exclude logically deleted rows with `Deleted ne true` or the equivalent connector-supported filter already validated in the flow.
- CI gate is waived by the user. Runtime Copilot Studio, Power Automate run, and SharePoint data validation are not waived.

### Official Documentation Basis

Use these official Microsoft references when validating any syntax or product behavior:

- Copilot Studio topic code editor:
  `https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/topics-code-editor`
- Power Fx `IsMatch` / `Match`:
  `https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-ismatch`
- Power Fx regular expressions:
  `https://learn.microsoft.com/en-us/power-platform/power-fx/regular-expressions`
- Power Automate SharePoint connector:
  `https://learn.microsoft.com/en-us/connectors/sharepointonline/`
- Power Automate expressions:
  `https://learn.microsoft.com/en-us/power-automate/use-expressions-in-conditions`

### Current Verified State

The correct active bot is `Assistente PMO V2`.

The latest locally prepared package is:

- `Solution\PMO_v11_Tarefas_1_8_ATUALIZAR_STATUS_RAG_FIX.zip`
- SHA256: `58276EF084576971035D83B74CF243570FAAD0BD6B036E4DB7ACEF6EDBB17CAF`
- Version in `Other/Solution.xml`: `1.8`
- Built from: `.planning\comms\solution_1_8_atualizar_status_rag_fix_20260511\unpacked`
- Verification unpack: `.planning\comms\solution_1_8_atualizar_status_rag_fix_20260511\verify_unpacked`

The 1.8 package has not yet been runtime-proven after import. Import it over the existing unmanaged `PMO_v11_Tarefas` solution before testing the RAG fix.

Local package checks already completed:

- `AtualizarStatus` `parse_rag` fixed to prefer `rag[:=]` and only accept `status=` for the status field.
- The old bad pattern `status\s*[:=]` was removed from `AtualizarStatus`.
- No `BooleanPrebuiltEntity` in checked package scope.
- No references to old bot `pmo_AssistentePMO_Clean`.
- No references to deleted duplicate flow IDs:
  - `d2645ec7-c84c-f111-bec7-000d3abc5cc6`
  - `e4c43bb3-c84c-f111-bec7-7ced8d955c6c`
  - `f9c43bb3-c84c-f111-bec7-7ced8d955c6c`
  - `81917ec0-c84c-f111-bec7-000d3abc5cc6`
  - `68917ec0-c84c-f111-bec7-000d3abc5cc6`
  - `e14ca9b9-c84c-f111-bec7-7ced8d955c6c`

The exact 1.8 `parse_rag` expression is:

```yaml
value: =If(IsMatch(Topic.RawInput, "rag\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "rag\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.RawInput, "status\s*=\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "status\s*=\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank()))
```

This is intentionally conservative: no lookbehind, no lookahead, no unsupported regex constructs.

### Runtime Evidence Already Captured Before 1.8

These tests were run on V2 before the 1.8 RAG parser fix:

- `CriarTarefa`: PASS
  - Test command:
    `criar tarefa: titulo=Teste Smoke Final V5, responsavel=Manoel Benicio, prazo=2026/05/31, horas=1, prioridade=Alta`
  - SharePoint `Projetos` item created:
    - ID `18`
    - ProjectID `PRJ-5E7C4110`
    - NomeProjeto `Teste Smoke Final V5`
    - StatusRAG `Verde`
    - Prioridade `Alta`
    - Ativo `True`
    - Deleted `False`

- `ConsultarProjeto`: PASS
  - Returned real SharePoint data for `Teste Smoke Final V5`.

- `ConsultarPortfolio`: PASS
  - Returned real aggregate:
    `Portfolio PMO: 10 projetos ativos. Verde: 3 | Amarelo: 2 | Vermelho: 1. Projetos sem update (>24h): 0.`

- `AtualizarStatus`: WRITE SUCCEEDED, but parser defect found
  - User command used `status=Amarelo`.
  - Confirmation showed incorrect `RAG: projeto=Teste Smoke Final V5`.
  - Flow wrote a `Status Diario` row, but RAG stayed/fell back to `Verde`.
  - Root cause: `status\s*[:=]` matched the command prefix `atualizar status:`.
  - 1.8 fixes this by requiring `rag[:=]` or `status=`.

### Required Next Actions

1. Import `Solution\PMO_v11_Tarefas_1_8_ATUALIZAR_STATUS_RAG_FIX.zip` over the existing unmanaged solution.
2. Publish all customizations.
3. Open Copilot Studio for `Assistente PMO V2`, not Clean.
4. Confirm Topic Checker is green for all custom topics.
5. Start a fresh test conversation/session.
6. Run the mandatory runtime matrix below.
7. For every write test, verify the SharePoint row directly after the bot response.
8. Update evidence files:
   - `.planning\stop_ship\MASTER_CHECKLIST.md`
   - `.planning\stop_ship\TEST_STRATEGY.md`
   - `.planning\stop_ship\EVIDENCE_LOG.md`
   - `.planning\stop_ship\ISSUE_RCA_PACK.md` if a new defect is found

### Mandatory Runtime Test Matrix

Use project `Teste Smoke Final V5` for tests that need an existing project.

1. Cold-start / Greeting
   - Start a new session.
   - Expected first bot message: greeting/warmup.
   - First real command should not fall into generic fallback.

2. ConsultarPortfolio
   - Command:
     `consultar portfolio`
   - Expected:
     real SharePoint aggregate counts, not template text.

3. ConsultarProjeto
   - Command:
     `consultar projeto: projeto=Teste Smoke Final V5`
   - Expected:
     returns ProjectID, NomeProjeto, PM, StatusRAG, Percentual, DataAlvo, UltimaAtualizacao, and open risks count.

4. AtualizarStatus RAG parser regression
   - Command:
     `atualizar status: projeto=Teste Smoke Final V5, rag=Amarelo, resumo=Smoke test de atualizacao de status fix RAG, percentual=35, risco=Nenhum, bloqueio=Nenhum, proxima acao=Validar RAG`
   - Confirm with:
     `sim`
   - Expected confirmation:
     `RAG: Amarelo`, not `RAG: projeto=...`
   - Expected SharePoint:
     latest `Status Diario` item has `RAG=Amarelo`, `Percentual=35`, `Deleted=false`, `OrigemEntrada=CopilotStudio`.
     project `Teste Smoke Final V5` has `StatusRAG=Amarelo`, `Percentual=35`.

5. RegistrarRisco
   - Command:
     `registrar risco: projeto=Teste Smoke Final V5, descricao=Risco smoke test 1, severidade=Alta, impacto=Alto`
   - Confirm with:
     `sim`
   - Expected SharePoint:
     list `Riscos e Bloqueios`, new item with `Tipo=Risco`, `Severidade=Alta`, `Impacto=Alto`, `StatusRisco=Aberto`, `Deleted=false`.

6. RegistrarBloqueio
   - Command:
     `registrar bloqueio: projeto=Teste Smoke Final V5, descricao=Bloqueio smoke test 1, impacto=Alto`
   - Confirm with:
     `sim`
   - Expected SharePoint:
     list `Riscos e Bloqueios`, new item with `Tipo=Bloqueio`, `Impacto=Alto`, `StatusRisco=Aberto`, `Deleted=false`.

7. PedirDecisao
   - Command:
     `solicitar decisao: projeto=Teste Smoke Final V5, descricao=Decidir prioridade do smoke test, impacto=Alto, prazo=31/05/2026, aprovador=mbenicios@minsait.com`
   - Confirm with:
     `sim`
   - Expected SharePoint:
     list `Decisoes do Board`, new item with `StatusDecisao=Pendente`, `Impacto=Alto`, `Deleted=false`, and approved user/UPN handling according to the actual flow definition.

8. CriarTarefa regression
   - Command:
     `criar tarefa: titulo=Teste Smoke Final V6, responsavel=Manoel Benicio, prazo=2026/05/31, horas=1, prioridade=Alta`
   - Confirm with:
     `sim`
   - Expected SharePoint:
     list `Projetos`, new item with `NomeProjeto=Teste Smoke Final V6`, `Prioridade=Alta`, `Ativo=true`, `Deleted=false`.

### Direct SharePoint Verification

Use a read-only verification method. If using PnP PowerShell, only query rows. Do not delete or mutate test data during validation.

Evidence required per test:

- Bot transcript screenshot.
- Flow run URL and status.
- Flow input/output payload where visible.
- SharePoint list row proof.
- Timestamp in BRT.

### Stop Conditions

Stop and return NO-SHIP if any of these occur:

- Topic Checker shows any error.
- The imported package targets `Assistente PMO Clean` instead of `Assistente PMO V2`.
- Any topic uses `BooleanPrebuiltEntity`.
- Any topic references a deleted flow ID.
- Any write topic skips confirmation.
- Any SharePoint write omits `Deleted=false`.
- `AtualizarStatus` confirmation shows `RAG: projeto=...`.
- Any runtime test returns template text instead of SharePoint-backed data.
- Any flow run fails.

### Final Output Required From Opus

Return:

1. Release decision: `SHIP` or `NO-SHIP`.
2. Exact package imported and SHA256.
3. Topic Checker status.
4. Runtime test table with PASS/FAIL for each test.
5. SharePoint evidence summary with list name, item ID, and relevant fields.
6. Remaining blockers, if any.
7. Files updated in the repo.

Do not generalize. Do not infer success without direct evidence.
