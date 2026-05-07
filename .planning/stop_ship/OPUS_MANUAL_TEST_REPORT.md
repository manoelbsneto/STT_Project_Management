# OPUS MANUAL TEST REPORT

Status: IMPORTED, but still NO-SHIP until this runbook passes live in `ColOfertasBrasilPro`.

Latest prepared/imported package:
`.planning/canonical/PMO_v11_Tarefas_T004_DECIMAL_FIX_20260506_1115.zip`

Package SHA256:
`84BB2A57A784DF16C1887FEA982490BCC6EE5C341C5EFCA759BD45B928573EA8`

Validated unpacked package:
`.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120`

Target solution:
`PMO_v11_Tarefas`

Target bot:
`Assistente PMO Clean`

Target environment:
`ColOfertasBrasilPro`

Environment id:
`e2d10003-4d8e-e007-9d63-76d5fe89ef56`

Current concrete QA values:

| Item | Value |
|---|---|
| Positive test `ProjectID` | `PRJ-2127A0E4` |
| Positive `Tarefas` row IDs | `1` and `2` |
| Negative `Tarefas` row ID | `3` |
| Negative `ProjectID` | `PRJ-NO-MATCH` |

Import status:
Imported by Codex into `ColOfertasBrasilPro` on 2026-05-06.

Latest post-import export:
`.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120.zip`

Latest rollback export taken before import:
`.planning/canonical/PMO_v11_Tarefas_PRE_T004_DECIMAL_FIX_IMPORT_20260506_1115.zip`

ASCII text rule:

- All shipped solution text must be ASCII-only: no accents, cedilla, emoji, em dash, arrow symbols, or mojibake. Post-import export `.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120` passed `Solution text is ASCII-only` and `Solution text has no mojibake`.
- T-004 check-in percent must remain decimal-safe. Post-import export `.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120` passed `CheckIn percent does not force integer`.

## 1. Executive Decision

Do not release yet.

The fixed ZIP is imported and structurally validated after re-export from `ColOfertasBrasilPro`, but the release is blocked until every cloud flow is executed directly in Power Automate and then through the Copilot test chat. The bot must not be considered ready because Power Automate runtime, SharePoint schema, Teams permissions, Outlook permissions, and connection references can only be fully proven by live runs.

Operating rule:

- Test and approve one flow at a time. A fix or approval for one flow does not approve the next flow; each flow needs its own live run evidence, captured issue/fix notes when it fails, and explicit approval before moving on.

## 2. Local Evidence Already Green

| Check | Result | Evidence |
|---|---|---|
| All workflow JSON parse | PASS | Six `PMO_PA_*.json` files parsed with `ConvertFrom-Json`. |
| SharePoint provisioning script syntax | PASS | `deploy/SP_Provisioning.ps1` parsed with `[scriptblock]::Create(...)`. |
| Stop-ship flow audit on source | PASS | `tests/Test-PMOFlowStopShipAudit.ps1`, 22 checks, 0 failures. |
| Stop-ship flow audit on unpacked ZIP | PASS | Same test on `_unpacked`, 22 checks, 0 failures. |
| CriarTarefa definition audit on source | PASS | `tests/Test-CriarTarefaFlowDefinition.ps1`, 9 checks, 0 failures. |
| CriarTarefa definition audit on unpacked ZIP | PASS | Same test on `_unpacked`, 9 checks, 0 failures. |
| ZIP pack | PASS | `pac solution pack`, unmanaged pack complete. |
| ZIP unpack | PASS | `pac solution unpack`, unmanaged extract complete. |
| Import to `ColOfertasBrasilPro` | PASS | `pac solution import --publish-changes --async false`, solution imported and customizations published. |
| Post-import export | PASS | `PMO_v11_Tarefas_POST_STOPSHIP_IMPORT_20260506_080900.zip`, exported from `ColOfertasBrasilPro`. |
| Post-import structural audit | PASS | `tests/Test-PMOFlowStopShipAudit.ps1`, 22 checks, 0 failures on post-import export. |
| Post-import CriarTarefa audit | PASS | `tests/Test-CriarTarefaFlowDefinition.ps1`, 9 checks, 0 failures on post-import export. |
| Flow activation state | PASS | All six PMO cloud flows returned `statecode=Activado`, `statuscode=Activado`. |

## 3. Fixes Included In The ZIP

| Flow | Fixes |
|---|---|
| `PMO_PA_CriarTarefa` | Removed unsupported `padLeft`; fixed `DataAlvo` duplicate lookup with UTC day range; added required `Projetos.PM` person-claim mapping. |
| `PMO_PA_ListarTarefas` | Uses `Tarefas` list and corrected `Concluida` completed-status literal. |
| `PMO_PA_AtualizarTarefa` | Updates SharePoint choice fields using `/Value`; adds guard for missing project lookup; normalizes overdue date comparison. |
| `PMO_PA_CheckInOnDemand` | Adds guard for missing project lookup; handles comma decimal percent values. |
| `PMO_PA_EscalarRiscoCritico` | Accepts `Critica` and `Critica` severity values. |
| `PMO_PA_RegistrarDecisaoBoard` | Stores decision status in `Resposta` instead of the justification text. |
| `deploy/SP_Provisioning.ps1` | Adds `Tarefas` list provisioning and pilot `PM` values. |

## 4. Import Already Completed

Completed actions:

1. Confirmed active PAC environment is exactly `ColOfertasBrasilPro`.
2. Exported rollback ZIP before import:
   `.planning/canonical/PMO_v11_Tarefas_PRE_STOPSHIP_IMPORT_20260506_080600.zip`
3. Imported fixed ZIP:
   `.planning/canonical/PMO_v11_Tarefas_STOPSHIP_FIX_ALL_20260506.zip`
4. Published all customizations.
5. Exported the solution again after import:
   `.planning/canonical/PMO_v11_Tarefas_POST_STOPSHIP_IMPORT_20260506_080900.zip`
6. Unpacked and tested the post-import export.
7. Confirmed all six PMO cloud flows are active.

Manual tester next action:

1. Open Power Automate in `ColOfertasBrasilPro`.
2. Open each flow and run Power Automate checker.
3. Execute the flow tests below one by one.
4. Do not test the bot until all six flow-level tests below have passed.

## 5. SharePoint Preconditions

Site:
`https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`

Required lists:

| List | Required For |
|---|---|
| `Projetos` | Create/list/update/check-in/risk/decision flows. |
| `Tarefas` | List and update task flows. |
| `Status Diario` | Check-in flow. |
| `Riscos e Bloqueios` | Critical risk escalation flow. |
| `Decisoes do Board` | Decision-board flow. |

Critical schema points:

| List | Column | Expected Type / Behavior |
|---|---|---|
| `Projetos` | `ProjectID` | Text, unique project code. |
| `Projetos` | `DataAlvo` | Date/date-time field used by duplicate lookup. |
| `Projetos` | `PM` | Required Person field; fixed flow sends a claims value. |
| `Projetos` | `Prioridade` | Choice accepting `Baixa`, `Media`, `Alta`, `Critica`. |
| `Projetos` | `StatusRAG` | Choice field updated using `/Value`. |
| `Tarefas` | `ProjectID` | Text, links task to project. |
| `Tarefas` | `Status` | Choice accepting `Pendente`, `Em Andamento`, `Concluida`, `Cancelada`. |
| `Tarefas` | `Prioridade` | Choice accepting `Baixa`, `Media`, `Alta`, `Critica`. |
| `Tarefas` | `DataFim` | Date field. |
| `Tarefas` | `HorasEstimadas` | Number. |
| `Tarefas` | `HorasRealizadas` | Number. |

If `Tarefas` is missing, run or manually apply the updated `deploy/SP_Provisioning.ps1` before testing flow 2 and flow 3.

## 6. Manual Test Matrix

Mark each row PASS only when the run history is green and the expected SharePoint/Teams/Outlook side effect exists.

| ID | Flow | Direct Flow Run | Data Side Effect | Negative Test | Status |
|---|---|---|---|---|---|
| T-001 | `PMO_PA_CriarTarefa` | Required | Project created or duplicate detected | Duplicate and invalid date | PARTIAL - positive create PASS 2026-05-06 08:54; duplicate branch not evidenced |
| T-002 | `PMO_PA_ListarTarefas` | Required | Correct task summary returned | Unknown ProjectID | PASS - positive and empty/no-task branches confirmed 2026-05-06 |
| T-003 | `PMO_PA_AtualizarTarefa` | Required | Task and project counters updated | Missing linked project | PASS - positive update and controlled missing-project path confirmed 2026-05-06 |
| T-004 | `PMO_PA_CheckInOnDemand` | Required | Status Diario row and project progress update | Unknown ProjectID | PASS - positive and negative confirmed 2026-05-06 11:32 |
| T-005 | `PMO_PA_EscalarRiscoCritico` | Required via SharePoint trigger | Teams/email escalation sent | Non-critical risk | PASS - positive and negative confirmed 2026-05-06 12:29 |
| T-006 | `PMO_PA_RegistrarDecisaoBoard` | Required via SharePoint trigger | Decision status/response updated | Reject/justify path | PASS - approval and rejection confirmed 2026-05-06 12:47 |
| T-007 | Copilot `CriarTarefa` topic | Required after T-001 | Flow invoked by bot without FlowNotFound | Cancel path | FAIL - `FlowNotFound` observed 2026-05-06 14:48; bot republished, retest required |

## 7. Flow T-001: PMO_PA_CriarTarefa

Purpose:
Create a project/task request from Copilot inputs and write to SharePoint `Projetos`.

Trigger schema:

| Input | Type | Required | Test Value |
|---|---|---|---|
| `nomeProjeto` | string | optional | `Agente Qualificacao de Ofertas` |
| `titulo` | string | required | `Agente Qualificacao de Ofertas` |
| `responsavel` | string | required | `mbenicios@minsait.com` |
| `prazo` | string | required | `30/06/2026` |
| `horas` | integer | required | `336` |
| `prioridade` | string | required | `Alta` |

Run steps:

1. Open `PMO_PA_CriarTarefa` in Power Automate.
2. Select Test, then manual execution.
3. Enter the values above.
4. Run the flow.
5. Open run details.

Expected green actions:

| Action | Expected |
|---|---|
| `Compose_NomeProjeto` | Returns `Agente Qualificacao de Ofertas`. |
| `Compose_DataAlvo` | Returns `2026-06-30`. |
| `Map_Prioridade` | Returns `Alta`. |
| `Get_Duplicate_Projects` | Succeeds. No DateTime parsing error. |
| `Condition_Duplicate_Projeto` | Routes based on whether duplicate exists. |
| `Create_Projeto_SharePoint` | Succeeds when no duplicate exists. |
| `Response_Success` | Returns success JSON/text to caller. |

Expected SharePoint result:

- One `Projetos` item exists for `Agente Qualificacao de Ofertas`.
- `ProjectID` starts with `PRJ-`.
- `DataAlvo` is `2026-06-30`.
- `PM` is populated.
- `Prioridade` is `Alta`.

Negative test:

1. Run the same input a second time.
2. Expected result: duplicate branch returns an already-existing project response.
3. Confirm no second duplicate project row is created.

Fail criteria:

- Any `padLeft` error.
- Any `Get_Duplicate_Projects` DateTime/OData error.
- SharePoint rejects required `PM`.
- Flow succeeds but no SharePoint row exists.

Evidence to capture:

- Run URL.
- Screenshot of green run.
- Screenshot of created SharePoint item.
- Response body.

## 8. Flow T-002: PMO_PA_ListarTarefas

Purpose:
Return the task breakdown for a project from SharePoint `Tarefas`.

Precondition:

Use the `ProjectID` created by T-001, for example `PRJ-0001`.

Create these two rows manually in SharePoint `Tarefas` if the flow cannot create them yet:

| Column | Row 1 | Row 2 |
|---|---|---|
| `Title` | `Preparar proposta` | `Revisao tecnica` |
| `ProjectID` | `<ProjectID from T-001>` | `<ProjectID from T-001>` |
| `Status` | `Pendente` | `Concluida` |
| `Prioridade` | `Alta` | `Media` |
| `Responsavel` | `mbenicios@minsait.com` | `mbenicios@minsait.com` |
| `DataFim` | `2026-06-30` | `2026-06-29` |
| `HorasEstimadas` | `8` | `4` |
| `HorasRealizadas` | `0` | `4` |

Trigger schema:

| Input | Type | Required | Test Value |
|---|---|---|---|
| `text` | string | required | `<ProjectID from T-001>` |

Run steps:

1. Open `PMO_PA_ListarTarefas`.
2. Select Test, then manual execution.
3. Enter `text=<ProjectID from T-001>`.
4. Run the flow.

Expected green actions:

| Action | Expected |
|---|---|
| `Get_Tarefas_Projeto` | Succeeds and returns the rows created for the project. |
| `Filter_Concluidas` | Counts completed rows using `Concluida`. |
| `Compose_Lista` | Returns a readable task breakdown. |
| Response action | Returns task summary to caller. |

Expected response:

- Mentions the project id.
- Mentions 2 total tasks.
- Mentions 1 completed task.
- Lists the task titles or key fields.

Negative test:

Run with:
`text=PRJ-DOES-NOT-EXIST`

Expected:
Controlled response saying no tasks were found, not a failed run.

Fail criteria:

- Flow queries `Projetos` instead of `Tarefas`.
- Completed count is wrong because `Concluida` choice does not match.
- Unknown project returns an unhandled failure.

Evidence to capture:

- Run URL.
- Response body.
- SharePoint rows used as fixture.

## 9. Flow T-003: PMO_PA_AtualizarTarefa

Purpose:
Update a task in SharePoint `Tarefas` and recalculate project counters in `Projetos`.

Precondition:

Use the SharePoint item ID of Row 1 created for T-002.

Trigger schema:

| Input | Title | Type | Required | Test Value |
|---|---|---|---|---|
| `number` | `TaskID` | number | required | `<SharePoint item ID from Tarefas>` |
| `text` | `Status` | string | optional | `Concluida` |
| `number_1` | `HorasRealizadas` | number | optional | `8` |
| `text_1` | `Responsavel` | string | optional | `mbenicios@minsait.com` |
| `text_2` | `DataFim` | string | optional | `2026-06-30` |
| `text_3` | `Prioridade` | string | optional | `Alta` |
| `number_2` | `HorasEstimadas` | number | optional | `8` |

Run steps:

1. Open `PMO_PA_AtualizarTarefa`.
2. Select Test, then manual execution.
3. Enter the values above.
4. Run the flow.

Warning:

- If the Power Automate manual run side panel shows only "Falha ao executar o fluxo. Tente novamente." and no useful run appears in run history, do not count it as runtime evidence for T-003. Treat it as pre-run validation or connection blocking until the tester confirms that `TaskID` is an existing SharePoint `Tarefas` item ID, choice values match the list options exactly, the `Responsavel` email resolves in the tenant, and the SharePoint connection is healthy.

Expected green actions:

| Action | Expected |
|---|---|
| `Get_Tarefa_Atual` | Finds the task row. |
| `Update_Tarefa` | Updates `Status/Value` and `Prioridade/Value` correctly. |
| `Get_All_Tarefas_Projeto` | Finds all tasks for the linked project. |
| `Filter_Concluidas` | Counts completed tasks. |
| `Filter_Atrasadas` | Uses normalized date-only comparison. |
| `Get_Projeto_Item` | Finds the linked project. |
| `Condition_Projeto_Encontrado` | True branch for valid project. |
| `Update_Projeto_Counters` | Updates project counters without choice-object errors. |
| `Respond_Success` | Returns success. |

Expected SharePoint result:

- The selected task has `Status=Concluida`.
- `HorasRealizadas=8`.
- `Prioridade=Alta`.
- Linked project counters are updated.
- `StatusRAG` update does not fail.

Negative test:

1. Create a temporary `Tarefas` row with `ProjectID=PRJ-NO-MATCH`.
2. Run the flow against that item ID.
3. Expected response: controlled 409-style message that the linked `ProjectID` was not found.
4. Expected failure mode: no unhandled `first()` empty-array crash.

Fail criteria:

- Choice field object error on `Status` or `Prioridade`.
- `first()` error when project is missing.
- Date comparison fails on `DataFim`.

Evidence to capture:

- Run URL.
- Before/after SharePoint task row.
- Before/after project counters.
- Negative-test run URL.

## 10. Flow T-004: PMO_PA_CheckInOnDemand

Purpose:
Send a Teams check-in card, receive the response, create a `Status Diario` row, and update project progress.

Trigger schema:

| Input | Type | Required | Test Value |
|---|---|---|---|
| `ProjectID` | string | required | `PRJ-2127A0E4` |

Run steps:

1. Open `PMO_PA_CheckInOnDemand`.
2. Select Test, then manual execution.
3. Enter `ProjectID=PRJ-2127A0E4`.
4. Run the flow.
5. Wait for the Teams adaptive card.
6. Submit the card.

Recommended card response:

| Field | Value |
|---|---|
| Percentual | `10.5` |
| Status | `Verde` or available status choice |
| Comentario | `Teste Opus check-in` |
| Bloqueios | `Nenhum` |

If the card allows comma decimal, also test `10,5`.

Expected green actions:

| Action | Expected |
|---|---|
| `Get_Projeto` | Finds exactly the requested project. |
| `Condition_Projeto_Encontrado` | True branch for valid project. |
| Teams adaptive-card action | Sends and waits for response. |
| `Create_Status_Diario` | Creates the status row. |
| `Update_Projeto` | Updates project progress and RAG fields. |
| `Response_OK` | Returns success. |

Negative test:

Run with:
`ProjectID=PRJ-DOES-NOT-EXIST`

Expected:

- Controlled 404 response.
- No Teams card sent.
- No `Status Diario` row created.

Observed negative result on 2026-05-06 11:32:

- Manual test with `ProjectID=PRJ-DOES-NOT-EXIST` returned `ProjectID nao encontrado na lista Projetos`.
- Downstream Teams, normalize, create status, and update project actions were not executed.
- This is the expected controlled not-found behavior.

Fail criteria:

- Empty project lookup crashes.
- Percent conversion fails on comma decimal.
- Teams connector cannot post or wait for response.

Evidence to capture:

- Run URL.
- Teams card screenshot.
- Submitted card screenshot or response details.
- Created `Status Diario` item.
- Updated project row.

Observed partial result on 2026-05-06 11:08:

- New Teams card rendered with clean ASCII labels and no mojibake.
- Card submission returned `Resposta registrada. Obrigado.`
- Teams showed `Sua resposta foi enviada ao aplicativo`.
- Backend failed in `Create_Status_Diario` because the previous expression used `int(float(...))` and could not process decimal value `10.5`.
- Fix imported on 2026-05-06 11:20. Live post-import export shows both `Status Diario.Percentual` and `Projetos.Percentual` now use decimal-safe `float(replace(...))`.
- Fresh rerun confirmed green on 2026-05-06 11:30: `Create_Status_Diario`, `Update_Projeto`, and `Response_OK` all succeeded.
- Warning: old Teams cards posted before the 2026-05-06 10:40 ASCII import can still show legacy broken button text. Those old messages must not be used as evidence for the current fixed package.

## 11. Flow T-005: PMO_PA_EscalarRiscoCritico

Purpose:
Escalate critical risks from SharePoint `Riscos e Bloqueios` through Teams/email.

Trigger:
SharePoint new item trigger, not a manual Power Automate trigger.

Run steps:

1. Open SharePoint list `Riscos e Bloqueios`.
2. Create a new item with the values below.
3. Wait for the flow trigger interval.
4. Open run history for `PMO_PA_EscalarRiscoCritico`.

Test item:

| Column | Value |
|---|---|
| `Title` | `Teste Opus risco critico` |
| `RiskID` | `RISK-OPUS-001` |
| `ProjectID` | `<ProjectID from T-001>` |
| `Tipo` | `Risco` |
| `Severidade` | `Critica` |
| `Descricao` | `Teste Opus risco critico` |
| `Impacto` | `Alto` |
| `StatusRisco` | `Aberto` |
| `PlanoMitigacao` | `Mitigar imediatamente` |

If SharePoint choice values only allow ASCII, use `Critica`.

Programmatic setup executed on 2026-05-06:

| Column | Value |
|---|---|
| SharePoint item ID | `2` |
| `Title` | `Teste Opus risco critico 20260506 1138` |
| `RiskID` | `RISK-OPUS-20260506-1138` |
| `ProjectID` | `PRJ-2127A0E4` |
| `Tipo` | `Risco` |
| `Severidade` | `Critica` |
| `Impacto` | `Alto` |
| `StatusRisco` | `Aberto` |
| `PlanoMitigacao` | `Mitigar imediatamente` |

Expected green actions:

| Action | Expected |
|---|---|
| SharePoint trigger | Fires for the new item. |
| `Get_Risco_Detalhes` | Reads created item. |
| `Condition_Risco_Critico` | True branch for `Critica` or `Critica`. |
| `Get_Projeto` | Finds linked project. |
| Teams post action | Sends escalation message. |
| Outlook/email action | Sends escalation email if configured. |

Negative test:

Create another risk item with `Severidade=Alta`.

Expected:

- Flow does not escalate as critical.
- Run terminates cleanly or takes non-critical branch.

Fail criteria:

- `Critica` is not recognized.
- Project lookup fails for a valid `ProjectID`.
- Teams/email connector permissions fail.

Evidence to capture:

- Risk item screenshot.
- Flow run URL.
- Teams message screenshot.
- Email screenshot or send action output.

## 12. Flow T-006: PMO_PA_RegistrarDecisaoBoard

Purpose:
Post a board decision adaptive card and write the selected decision back to SharePoint `Decisoes do Board`.

Trigger:
SharePoint new item trigger, not a manual Power Automate trigger.

Run steps:

1. Open SharePoint list `Decisoes do Board`.
2. Create a new decision item with the values below.
3. Wait for the flow trigger interval.
4. Open the Teams adaptive card.
5. Approve the decision.
6. Open the SharePoint item and verify fields.

Test item:

| Column | Value |
|---|---|
| `Title` | `Teste Opus decisao` |
| `DecisionID` | `DEC-OPUS-001` |
| `ProjectID` | `<ProjectID from T-001>` |
| `Descricao` | `Teste Opus decisao` |
| `Solicitante` | `mbenicios@minsait.com` |
| `Aprovador` | `mbenicios@minsait.com` |
| `Prazo` | `2026-06-30` |
| `StatusDecisao` | `Pendente` |
| `Impacto` | `Medio` |

Expected green actions:

| Action | Expected |
|---|---|
| SharePoint trigger | Fires for the new item. |
| `Get_Decisao_Detalhes` | Reads the item. |
| Teams adaptive-card action | Posts card and waits for response. |
| Normalize decision actions | Produce approved/rejected/deferred status. |
| SharePoint update action | Writes decision result to the item. |

Expected SharePoint result after approval:

| Column | Expected Value |
|---|---|
| `StatusDecisao` | `Aprovada` or configured approved value |
| `Resposta` | `Aprovada` |
| `DataResposta` | Populated |
| `ResponseSource` | `AdaptiveCard` |
| `CardVersion` | `1.0` |

Negative/regression test:

1. Create a second decision.
2. Reject it with justification `Teste Opus rejeicao`.
3. Expected: `Resposta` stores the rejected status, not the justification text.
4. Expected: justification remains available in its intended field if the flow stores it.

Fail criteria:

- Teams card does not post.
- Flow writes justification into `Resposta`.
- SharePoint update fails due to choice values.

Evidence to capture:

- Decision item screenshot before and after.
- Flow run URL.
- Teams card screenshot.

## 13. Bot Test T-007: CriarTarefa Topic

Run this only after T-001 through T-006 are green.

Bot:
`Assistente PMO Clean`

Channel:
Copilot Studio test chat first. Do not use Teams until Studio test chat passes.

Test message:

```text
Criar tarefa: Titulo=Agente Qualificacao de Ofertas Bot Test,
Responsavel=mbenicios@minsait.com,
Prazo=30/06/2026,
Horas=336,
Prioridade=Alta
```

Expected bot behavior:

1. Bot recognizes `CriarTarefa`.
2. Bot parses title, responsible person, date, hours, and priority.
3. Bot asks for confirmation.
4. User replies `sim`.
5. Bot calls `PMO_PA_CriarTarefa`.
6. No `FlowNotFound` error.
7. No `FlowActionBadRequest` error.
8. Bot returns the flow response or a clear success message.

Cancel-path test:

```text
Criar tarefa: Titulo=Teste Cancelar, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=1, Prioridade=Baixa
```

Reply:

```text
nao
```

Expected:

- Bot cancels.
- Flow is not called.
- No SharePoint item is created.

Fail criteria:

- Bot does not trigger the topic.
- Bot asks again for values already provided.
- Bot invokes an old/missing flow id.
- Bot returns success without a green Power Automate run.

Evidence to capture:

- Full Copilot Studio test conversation screenshot.
- Flow run URL generated by the bot action.
- SharePoint created item screenshot.

## 14. Post-Test Cleanup

Do not delete failed evidence. Failed runs are part of the RCA record.

Optional cleanup after all screenshots are captured:

| Object | Cleanup Action |
|---|---|
| Test projects | Mark inactive or delete only after evidence is saved. |
| Test tasks | Mark inactive or delete only after evidence is saved. |
| Test risks | Close or delete only after evidence is saved. |
| Test decisions | Keep if needed for audit; otherwise delete after evidence is saved. |

## 15. Final SHIP Criteria

Change release decision from NO-SHIP to SHIP only when all are true:

- T-001 through T-006 have green Power Automate run URLs.
- T-007 passes in Copilot Studio test chat.
- No flow returns `FlowNotFound`.
- No flow returns `FlowActionBadRequest`.
- No SharePoint connector action fails on schema/type errors.
- No Teams or Outlook connector action fails on permissions.
- The bot is added to the `PMO_v11_Tarefas` solution.
- All final components are in `ColOfertasBrasilPro`.
- No required component lives only in Default.

## 16. Manual Evidence Table To Fill

| Test ID | PASS/FAIL | Flow Run URL | Screenshot Path | SharePoint Evidence | Notes |
|---|---|---|---|---|---|
| T-001 | PASS | ProcessSimple API run `08584235384084827126403549386CU23`, 2026-05-06 08:54:37 local | No local screenshot found; API evidence only | Trigger body `Teste Opus T001 20260506`; actions green through `Create_Projeto_SharePoint` and `Response_Success` | Positive create path passed. |
| T-001 duplicate | NOT EVIDENCED | No clean duplicate-branch run found | No screenshot found | None | Needs explicit duplicate rerun if required for ship. |
| T-002 | PASS | ProcessSimple API run `08584235366361473356193312412CU07`, 2026-05-06 09:24:09 local | No local screenshot found; API evidence only | Trigger `text=PRJ-2127A0E4`; fixture rows from E-026 | Positive list path passed; `Respond_Lista` succeeded. |
| T-002 negative | PASS | ProcessSimple API runs `08584235373297069823216697416CU00` and `08584235386337980996267736116CU02` | No local screenshot found; API evidence only | Empty/no-task branch `Respond_Empty` succeeded | Controlled empty response path passed. |
| T-003 | PASS | ProcessSimple API run `08584235365054585349888166089CU15`, 2026-05-06 09:26:20 local | No local screenshot found; API evidence only | Trigger `TaskID=1`; actions green through `Update_Tarefa`, `Update_Projeto_Counters`, `Respond_Success` | Positive task update path passed. |
| T-003 negative | PASS - CONTROLLED TERMINATE | ProcessSimple API run `08584235344991803047647694049CU31`, 2026-05-06 09:59:46 local | No local screenshot found; API evidence only | Trigger `TaskID=3`; fixture E-027 `ProjectID=PRJ-NO-MATCH`; `Response_Project_Not_Found` and `Terminate_Project_Not_Found` succeeded | Controlled missing-project path passed; run status is `Failed` because flow terminates after conflict response. |
| T-004 | PASS | User Power Automate screenshot 2026-05-06 11:30 | User Teams and Power Automate screenshots 2026-05-06 11:28-11:30 | `Create_Status_Diario` and `Update_Projeto` succeeded | Decimal fix validated in fresh run; `Response_OK` succeeded |
| T-004 negative | PASS | User Power Automate side-panel screenshot 2026-05-06 11:32 | User screenshot 2026-05-06 11:32 | No Teams card and no `Status Diario` row expected | Controlled not-found response: `ProjectID nao encontrado na lista Projetos` |
| T-005 | PASS | User Power Automate screenshot 2026-05-06 12:26 | User Teams screenshot 2026-05-06 11:39 | `Riscos e Bloqueios` item ID `2`, `RiskID=RISK-OPUS-20260506-1138`, `ProjectID=PRJ-2127A0E4`, `Severidade=Critica` | Positive path approved: Teams card and Outlook email action both green. |
| T-005 negative | PASS | ProcessSimple API run `08584235255461664150933958163CU19`, 2026-05-06 12:28:59 local | API evidence captured by Codex | `Riscos e Bloqueios` item ID `3`, `RiskID=RISK-OPUS-NEG-20260506`, `ProjectID=PRJ-2127A0E4`, `Severidade=Alta` | Run succeeded with `Terminate_Nao_Critico`; Teams and email actions skipped. |
| T-006 approval | PASS | ProcessSimple API run `08584235250828761703799075484CU24`, user Power Automate screenshot 2026-05-06 12:40 | User Teams screenshots 2026-05-06 12:38-12:39 | `Decisoes do Board` item ID `1`, `DecisionID=DEC-OPUS-APPROVE-20260506`, `StatusDecisao=Aprovada`, `Resposta=Aprovada` | Approval path passed. `Resposta` correctly stores `Aprovada`; `Justificativa` stores `Aprovado`. |
| T-006 rejection | PASS | ProcessSimple API run `08584235246295304668464023051CU06`, user Power Automate screenshot 2026-05-06 12:46 | User Teams screenshots 2026-05-06 12:44-12:47 | `Decisoes do Board` item ID `2`, `DecisionID=DEC-OPUS-REJECT-20260506`, `StatusDecisao=Rejeitada`, `Resposta=Rejeitada`, `Justificativa=Teste Opus rejeicao` | Rejection path passed. `Resposta` correctly stores `Rejeitada`; justification remains in `Justificativa`. |
| T-007 bot create | FAIL - RETEST REQUIRED | User Copilot Studio test conversation 2026-05-06 14:48; no Power Automate run created | User screenshot in Codex conversation 2026-05-06 14:48 | Bot returned `FlowNotFound` for active flow `71f62da4-9748-f111-bec7-6045bdf42cae`. Live Dataverse check confirmed action component and `botcomponent_workflow` binding exist. `pac copilot publish` succeeded for bot `77cfb838-6ed1-4488-9e57-ab98751081d3` at 2026-05-06 14:45:48 local / 17:45:48 UTC. | Fresh create retest required after publish. |
| T-007 bot cancel |  |  |  |  |  |
