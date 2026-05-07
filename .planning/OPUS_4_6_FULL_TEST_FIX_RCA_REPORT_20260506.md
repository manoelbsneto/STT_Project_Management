# Opus 4.6 Handoff - PMO Bot / Flow Test, Fix, and RCA Report

Date: 2026-05-06

Audience: Opus 4.6 review

Environment: `ColOfertasBrasilPro`

Target solution: `PMO_v11_Tarefas`

Target bot: `Assistente PMO Clean`

Current release decision: **NO-SHIP until T-007 bot retest passes**

## 1. Executive Summary

The previously released PMO bot and Power Automate flow package had multiple stop-ship defects. The core direct Power Automate flows were structurally repaired, imported into `ColOfertasBrasilPro`, re-exported, audited, and live-tested. The major direct-flow paths are now working.

The remaining release blocker is the Copilot bot invocation of `PMO_PA_CriarTarefa`. In direct Power Automate testing, `PMO_PA_CriarTarefa` can create a project successfully. However, the Copilot Studio topic test returned `FlowNotFound` after confirmation. Live Dataverse checks showed the action component and botcomponent-workflow binding exist and point to the active flow, so the current working theory is stale bot runtime/publish state or Copilot runtime binding cache, not a missing flow definition.

The bot was republished after the `FlowNotFound` failure. A fresh T-007 create-path and cancel-path retest is still pending.

## 2. Current Baseline

Active baseline file:

- `.planning/CURRENT_BASELINE.md`

Active evidence folder:

- `.planning/stop_ship`

Do not use old `.planning/comms` packages or the older `.planning/stopship` folder as the active baseline. Those artifacts are useful as historical evidence only.

Latest imported package from the current baseline:

- `.planning/canonical/PMO_v11_Tarefas_T004_DECIMAL_FIX_20260506_1115.zip`
- SHA256: `84BB2A57A784DF16C1887FEA982490BCC6EE5C341C5EFCA759BD45B928573EA8`

Latest post-import export:

- `.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120.zip`
- SHA256: `1543027EE27248293C9C03014317667E2E36098A050BBE53DA3B2E6D90A725AC`

Post-import unpacked export:

- `.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120`

Rollback backup:

- `.planning/canonical/PMO_v11_Tarefas_PRE_T004_DECIMAL_FIX_IMPORT_20260506_1115.zip`

Important repository note:

- The May 6 `.planning/stop_ship` and `.planning/canonical` evidence is currently untracked in the local worktree.
- Several old `.planning/comms` and `.planning/stopship` artifacts show as deleted in `git status`.
- This report intentionally uses the latest local evidence rather than the older committed stop-ship closure only.

## 3. What Was Fixed

### Fix 1 - CriarTarefa ProjectID generation and unsupported `padLeft`

Affected flow:

- `PMO_PA_CriarTarefa`

Symptom:

- Direct Power Automate run failed in `Compose_DataAlvo`.
- Error: `The template function 'padLeft' is not defined or not valid.`

RCA:

- The flow used `padLeft()`, which is not supported by the Power Automate template language in this tenant/runtime.
- The release relied on generated expressions that were not validated by a live direct flow run before bot testing.

Fix:

- Replaced the fragile sequential ProjectID logic with GUID-based ProjectID generation:
  - `PRJ-` + uppercase GUID substring.
- Removed the dependency on reading the latest SharePoint project.
- Removed the race-prone `Compose_New_ProjectID` sequence increment path.

Verification:

- `tests/Test-CriarTarefaFlowDefinition.ps1` checks:
  - GUID-based `Compose_ProjectID` exists.
  - no `Get_Existing_Projects`.
  - no `Compose_New_ProjectID`.
  - no unsupported raw-auth package pattern unless explicitly allowed.
- Live T-001 positive create passed.

Evidence:

- E-003, E-004, E-011, E-049 in `.planning/stop_ship/EVIDENCE_LOG.md`

### Fix 2 - CriarTarefa SharePoint DateTime duplicate lookup

Affected flow:

- `PMO_PA_CriarTarefa`

Symptom:

- After the first expression fix, `Get_Duplicate_Projects` failed with SharePoint BadRequest.
- Error pattern: string not recognized as a valid DateTime.

RCA:

- The duplicate lookup compared a SharePoint DateTime column with a plain date string:
  - `DataAlvo eq 'yyyy-MM-dd'`
- SharePoint OData rejected the string comparison against a DateTime column.

Fix:

- Replaced equality string comparison with a UTC day range:
  - `DataAlvo ge datetime'yyyy-MM-ddT00:00:00Z'`
  - `DataAlvo lt datetime'next-dayT00:00:00Z'`

Verification:

- T-001 positive create reached `Get_Duplicate_Projects`, then `Create_Projeto_SharePoint`, then `Response_Success`.
- Structural audit checks for DateTime day range.

Evidence:

- E-005, E-006, E-024, E-049

Remaining gap:

- The explicit duplicate branch is not yet evidenced. We have positive create proof, but no clean second-run proof that `Response_Duplicate` is taken and no second row is created.

### Fix 3 - CriarTarefa required `PM` person field

Affected flow:

- `PMO_PA_CriarTarefa`

Symptom:

- The SharePoint `Projetos.PM` field is required by provisioning/schema expectations, but the initial create flow did not reliably populate it.

RCA:

- The flow treated `responsavel` as text in the summary, while the SharePoint list expects a Person field.
- The provisioning assumptions and flow write contract were not aligned.

Fix:

- Added `PM/Claims` mapping:
  - `i:0#.f|membership|<responsavel>`
- Updated provisioning/pilot data to include default PM values.

Verification:

- T-001 positive create passed.
- `tests/Test-PMOFlowStopShipAudit.ps1` checks `CriarTarefa maps required PM person field`.
- `deploy/SP_Provisioning.ps1` now provisions pilot project PM values.

Evidence:

- E-012, E-024, E-049

### Fix 4 - CriarTarefa Copilot topic routing and action contract

Affected bot topic/action:

- `pmo_AssistentePMO.topic.CriarTarefa`
- `pmo_AssistentePMO.action.PMO_PA_CriarTarefa`

Symptoms:

- The bot did not reliably select the `CriarTarefa` topic.
- The topic used template export aliases or stale references in some iterations.
- Earlier contract versions exposed fragile action output bindings that caused checker/runtime problems.

RCA:

- Copilot Studio exported templates used `template-content.action...` aliases that are not always the runtime internal schema name after import.
- Topic trigger phrases and LowConfidence behavior were incomplete for the target test utterances.
- The action output contract changed across iterations, leaving stale output aliases such as `Topic.message` or action output bindings under `call_criar_tarefa`.

Fix:

- Added/validated trigger queries:
  - `criar tarefa`
  - `nova tarefa`
  - `adicionar tarefa`
  - `cadastrar tarefa`
  - `criar projeto`
  - `novo projeto`
  - `abrir projeto`
  - `registrar projeto`
  - `criar tarefa:`
  - `abrir tarefa`
- Set `includeInOnSelectIntent: true` for the `CriarTarefa` topic.
- Added direct parsing from `System.Activity.Text` for title, responsible person, date, hours, and priority.
- Ensured the confirmed branch calls `PMO_PA_CriarTarefa`.
- Removed fragile output bindings from the topic call step.

Verification:

- `tests/Test-CriarTarefaContract.ps1` checks:
  - topic selectable by orchestrator.
  - exact trigger contract.
  - LowConfidence advertises criar tarefa/projeto.
  - no stale ProjectID questions/globals.
  - action input contract includes `nomeProjeto`, `titulo`, `responsavel`, `prazo`, `horas`, `prioridade`.
  - action exposes `result`.
  - no fragile topic output binding.
- `tests/Test-CriarTarefaRawDataverse.ps1` checks live/raw data for internal action schema and absence of template alias/output binding.

Evidence:

- Historical commits: `838f04b`, `1bdd732`, `aadb799`, `c92b16a`
- E-053, E-054, E-055 for current T-007 state

Current status:

- Partially fixed, but not release-approved.
- T-007 create path failed with `FlowNotFound`.
- Live Dataverse binding check showed the action and workflow binding exist.
- Bot republish completed.
- Fresh retest is pending.

### Fix 5 - Removed CriarTarefa topic action output binding causing `BindingKeyNotFoundError`

Affected bot topic:

- `CriarTarefa`

Symptom:

- Bot/topic checker/runtime path failed with binding errors when the topic tried to bind action outputs that were no longer available under the expected keys.

RCA:

- Copilot Studio topic YAML retained stale output aliases from an earlier action contract.
- The action response contract was simplified, but the topic still expected old output binding names.

Fix:

- Removed the `output:` block under `call_criar_tarefa`.
- Topic now calls the action and returns a generic submission confirmation without relying on stale output aliases.

Verification:

- `tests/Test-CriarTarefaContract.ps1` checks `CriarTarefa avoids fragile output binding`.
- `tests/Test-CriarTarefaRawDataverse.ps1` checks raw imported topic data has no output block under `call_criar_tarefa`.

Evidence:

- Commit `c92b16a`
- E-054 confirms live botcomponent/action/workflow binding exists.

### Fix 6 - Tarefas list provisioning gap

Affected component:

- `deploy/SP_Provisioning.ps1`
- flows `PMO_PA_ListarTarefas`, `PMO_PA_AtualizarTarefa`

Symptom:

- Task list and update flows assume a `Tarefas` list, but provisioning did not include it in the original script.

RCA:

- Flow implementation and SharePoint provisioning drifted.
- The release package included flows that depended on a list not created by the canonical provisioning script.

Fix:

- Added `Tarefas` list provisioning with fields:
  - `TaskID`
  - `ProjectID`
  - `Status`
  - `HorasRealizadas`
  - `Responsavel`
  - `DataInicio`
  - `DataFim`
  - `Prioridade`
  - `HorasEstimadas`
  - `Ativo`
- Added indexes and `Por Projeto` view.

Verification:

- `tests/Test-PMOFlowStopShipAudit.ps1` checks provisioning creates `Tarefas`.
- T-002 positive list passed.
- T-003 positive update passed.

Evidence:

- E-012, E-026, E-050, E-051

### Fix 7 - AtualizarTarefa SharePoint choice field writes

Affected flow:

- `PMO_PA_AtualizarTarefa`

Symptom:

- SharePoint task/project updates were at risk of failing because choice fields were patched with raw field names instead of the connector choice-value paths.

RCA:

- SharePoint connector requires choice updates through `/Value` paths.
- The generated flow did not consistently use `item/Status/Value` and `item/Prioridade/Value`.

Fix:

- Updated task status and priority writes to use:
  - `item/Status/Value`
  - `item/Prioridade/Value`
- Preserved required PM as claims when updating related project counters.

Verification:

- T-003 positive update passed through `Update_Tarefa`, `Update_Projeto_Counters`, and `Respond_Success`.
- Structural audit checks choice paths.

Evidence:

- E-024, E-051

### Fix 8 - AtualizarTarefa missing project guard

Affected flow:

- `PMO_PA_AtualizarTarefa`

Symptom:

- A task could exist with a `ProjectID` that does not match any `Projetos` item.
- The flow previously used `first(body('Get_Projeto_Item')?['value'])` without checking length.

RCA:

- Missing empty-array guard around project lookup.
- The flow assumed referential integrity between `Tarefas.ProjectID` and `Projetos.ProjectID`.

Fix:

- Added `Condition_Projeto_Encontrado`.
- Added controlled `PROJECT_NOT_FOUND` response/terminate path.
- Avoided unhandled `first()` crash.

Verification:

- T-003 negative created a task with `ProjectID=PRJ-NO-MATCH`.
- Run returned controlled not-found path.
- Run status is `Failed` by design because the flow terminates after the conflict response, but the failure is controlled and not an unhandled crash.

Evidence:

- E-027, E-052

Opus review ask:

- Confirm whether this controlled terminate should remain as a `Failed` run in Power Automate history, or whether we should change the negative branch to return a 200/404 response without a terminating failed status to keep operational dashboards cleaner.

### Fix 9 - AtualizarTarefa overdue date comparison

Affected flow:

- `PMO_PA_AtualizarTarefa`

Symptom:

- Overdue task counts could be wrong if comparing full DateTime values rather than normalized dates.

RCA:

- Date comparisons could treat today's due date as overdue depending on UTC/time component behavior.

Fix:

- Normalized `DataFim` using `formatDateTime(..., 'yyyy-MM-dd')`.

Verification:

- Structural audit checks date-normalized overdue comparison.
- T-003 positive update path passed.

Evidence:

- E-024, E-051

### Fix 10 - CheckInOnDemand missing project guard

Affected flow:

- `PMO_PA_CheckInOnDemand`

Symptom:

- Unknown `ProjectID` could previously proceed into Teams card composition or fail through unguarded lookup use.

RCA:

- The flow assumed `Get_Projeto` always returned at least one row.
- Teams card composition referenced project data before validating lookup results.

Fix:

- Added `Condition_Projeto_Encontrado`.
- Added controlled not-found response.
- Downstream Teams/card/status actions are skipped when the project does not exist.

Verification:

- T-004 negative with `ProjectID=PRJ-DOES-NOT-EXIST` returned:
  - `ProjectID nao encontrado na lista Projetos`
- No Teams card/status row expected.

Evidence:

- E-036

### Fix 11 - CheckInOnDemand decimal percent handling

Affected flow:

- `PMO_PA_CheckInOnDemand`

Symptom:

- Teams card submission succeeded, but backend failed in `Create_Status_Diario`.
- Decimal input `10.5` failed because the flow forced `int(float(...))`.

RCA:

- SharePoint Number fields can store decimal values, but the flow coerced percent to integer.
- Adaptive Card numeric values can arrive as decimal strings using either dot or comma notation.

Fix:

- Replaced integer coercion with decimal-safe parsing:
  - `float(replace(string(outputs('Normalize_Percentual')), ',', '.'))`
- Applied to both `Status Diario.Percentual` and `Projetos.Percentual`.

Verification:

- Post-import audit passed `CheckIn percent does not force integer`.
- Fresh T-004 positive run after import succeeded:
  - `Create_Status_Diario`
  - `Update_Projeto`
  - `Response_OK`

Evidence:

- E-032, E-033, E-034, E-035

### Fix 12 - ASCII-only text and mojibake cleanup

Affected areas:

- Flow messages
- Adaptive card text
- Copilot topic text
- Deploy scripts

Symptoms:

- Older messages/cards had broken Portuguese characters or unsafe non-ASCII content.
- Old Teams cards posted before the fix can still display legacy broken text.

RCA:

- Mixed encoding/export/import paths corrupted accented Portuguese characters.
- The safest release rule for this environment is ASCII-only shipped text.

Fix:

- Replaced accents, cedilla, emoji, smart punctuation, arrows, and mojibake-prone characters with ASCII-safe text.
- Examples:
  - `Nao`, `Voce`, `portfolio`, `decisao`, `Critica`, `Concluida`, `Media`

Verification:

- `tests/Test-PMOFlowStopShipAudit.ps1` checks:
  - all workflow JSON parses.
  - no user-visible mojibake.
  - ASCII-only workflow text.
  - ASCII-only solution text.
- Current baseline notes `rg -n "[^\x00-\x7F]"` returned no matches in the post-import export, deploy cards, copilot template, or current tests.

Evidence:

- E-028, E-029, E-030, E-031

### Fix 13 - ListarTarefas list target and completed status literal

Affected flow:

- `PMO_PA_ListarTarefas`

Symptoms:

- Flow needed to query `Tarefas`, not `Projetos`.
- Completed task counting depended on the exact SharePoint choice literal.

RCA:

- The flow/list contract was incomplete and choice values were not normalized to the ASCII-safe provisioned values.

Fix:

- Ensured `ListarTarefas` targets the `Tarefas` list.
- Standardized completed status to `Concluida`.

Verification:

- T-002 positive run returned task summary.
- T-002 negative/empty branch returned controlled empty response.

Evidence:

- E-026, E-050

### Fix 14 - EscalarRiscoCritico critical/non-critical handling

Affected flow:

- `PMO_PA_EscalarRiscoCritico`

Symptoms:

- Critical severity matching could fail due to accented vs ASCII value mismatch.
- Risk escalation paths could be brittle if project lookup returned no data.

RCA:

- SharePoint choice values and flow text were not consistently ASCII-safe.
- Previous logic had unsafe lookup assumptions.

Fix:

- Standardized critical severity to `Critica`.
- Added safer project lookup behavior.
- Ensured non-critical risk takes the non-escalation path.

Verification:

- T-005 positive:
  - SharePoint risk item created with `Severidade=Critica`.
  - Teams escalation card posted.
  - Outlook/email action green.
- T-005 negative:
  - SharePoint risk item created with `Severidade=Alta`.
  - Flow terminated non-critical branch.
  - Teams/email actions skipped.

Evidence:

- E-037, E-038, E-039, E-040, E-041

### Fix 15 - RegistrarDecisaoBoard response mapping

Affected flow:

- `PMO_PA_RegistrarDecisaoBoard`

Symptom:

- `Resposta` could store the justification text instead of the decision status.

RCA:

- Adaptive card response fields were mapped incorrectly.
- The flow did not clearly separate decision status from justification.

Fix:

- `Resposta` now stores normalized decision status:
  - `Aprovada`
  - `Rejeitada`
- `Justificativa` stores the free-text justification.

Verification:

- T-006 approval:
  - `Resposta=Aprovada`
  - `Justificativa=Aprovado`
- T-006 rejection:
  - `Resposta=Rejeitada`
  - `Justificativa=Teste Opus rejeicao`

Evidence:

- E-042, E-043, E-044, E-045, E-046, E-047

## 4. Test Coverage Summary

| Test ID | Scenario | Status | Evidence |
|---|---|---|---|
| T-001 | `PMO_PA_CriarTarefa` positive create | PASS | ProcessSimple run `08584235384084827126403549386CU23`; E-049 |
| T-001 duplicate | Duplicate create branch | NOT EVIDENCED | No clean duplicate-branch run found |
| T-002 | `PMO_PA_ListarTarefas` positive list | PASS | ProcessSimple run `08584235366361473356193312412CU07`; E-050 |
| T-002 negative | Unknown/no-task project | PASS | ProcessSimple runs `08584235373297069823216697416CU00`, `08584235386337980996267736116CU02`; E-050 |
| T-003 | `PMO_PA_AtualizarTarefa` positive update | PASS | ProcessSimple run `08584235365054585349888166089CU15`; E-051 |
| T-003 negative | Missing linked project | PASS - CONTROLLED TERMINATE | ProcessSimple run `08584235344991803047647694049CU31`; E-052 |
| T-004 | `PMO_PA_CheckInOnDemand` positive decimal check-in | PASS | User Power Automate screenshots around 2026-05-06 11:30; E-035 |
| T-004 negative | Unknown project | PASS | User screenshot around 2026-05-06 11:32; E-036 |
| T-005 | `PMO_PA_EscalarRiscoCritico` critical risk | PASS | User Teams/Power Automate screenshots; E-037 to E-039 |
| T-005 negative | Non-critical risk | PASS | ProcessSimple run `08584235255461664150933958163CU19`; E-041 |
| T-006 approval | Board decision approved | PASS | ProcessSimple run `08584235250828761703799075484CU24`; E-044 |
| T-006 rejection | Board decision rejected | PASS | ProcessSimple run `08584235246295304668464023051CU06`; E-047 |
| T-007 create | Copilot `CriarTarefa` create path | FAIL - RETEST REQUIRED | User Copilot Studio screenshot; E-053 |
| T-007 cancel | Copilot `CriarTarefa` cancel path | PENDING | No evidence yet |

## 5. Automated Regression Tests Added / Used

### `tests/Test-PMOFlowStopShipAudit.ps1`

Purpose:

- Audits the full solution source/export for stop-ship flow regressions.

Key checks:

- All workflow JSON files parse.
- No workflow text contains mojibake.
- Solution text is ASCII-only.
- `CriarTarefa` has no `padLeft`.
- `CriarTarefa` duplicate lookup uses DateTime day range.
- `CriarTarefa` maps required PM person field.
- `CriarTarefa` supports critical priority choice.
- `ListarTarefas` targets `Tarefas`.
- `ListarTarefas` uses `Concluida`.
- `AtualizarTarefa` uses `/Value` for SharePoint choices.
- `AtualizarTarefa` preserves PM as claims.
- `AtualizarTarefa` has project lookup guard.
- `AtualizarTarefa` overdue comparison is date-normalized.
- `CheckInOnDemand` has project lookup guard.
- `CheckInOnDemand` accepts comma decimal and does not force integer percent.
- `EscalarRiscoCritico` accepts ASCII critical value.
- `EscalarRiscoCritico` avoids unsafe first project lookup.
- `RegistrarDecisaoBoard` stores response status in `Resposta`.
- Provisioning creates `Tarefas`.
- Provisioning pilot projects include PM.

Latest known result:

- Passed against post-import export.
- Expanded audit: 27 checks, 0 failures.

### `tests/Test-CriarTarefaFlowDefinition.ps1`

Purpose:

- Focused audit of `PMO_PA_CriarTarefa` workflow definition.

Key checks:

- GUID-based ProjectID composer.
- No latest-project read.
- No sequential increment composer.
- No priority mojibake.
- ASCII-only flow text.
- `horas` required in trigger contract.
- Date normalization compose exists.
- Priority normalization is ASCII safe.
- Duplicate project check exists.
- Duplicate response branch exists.
- Package uses parameter authentication rather than raw APIM tokens unless runtime raw auth is explicitly allowed.

Latest known result:

- Passed on source and unpacked fixed package.

### `tests/Test-CriarTarefaContract.ps1`

Purpose:

- Validates the Copilot Studio topic/action contract for `CriarTarefa`.

Key checks:

- Topic is selectable by orchestrator.
- Exact trigger phrase contract.
- LowConfidence advertises criar tarefa/projeto.
- Topic does not ask for `ProjectID`.
- Topic does not set stale global ProjectID.
- Topic calls `PMO_PA_CriarTarefa`.
- Topic avoids fragile output binding.
- Action exposes expected input contract.
- Action exposes `result` output.

Latest status:

- Used as a contract guard for the bot package. The live T-007 failure still requires runtime retest because static contract checks cannot prove Copilot runtime cache/binding refresh.

### `tests/Test-CriarTarefaRawDataverse.ps1`

Purpose:

- Validates raw imported Dataverse bot component data.

Key checks:

- Raw topic uses internal action schema.
- Raw topic does not use template export alias.
- Raw topic has no fragile action output binding.
- Raw topic has no stale `Topic.message`.
- Raw topic reads original user message from `System.Activity.Text`.
- Regex parsers are ASCII safe for title/responsavel labels.

Latest status:

- Live Dataverse evidence shows topic, action, and `botcomponent_workflow` binding exist. Runtime T-007 retest is still required.

## 6. Remaining Release Blockers

### Blocker 1 - T-007 Copilot create path returned `FlowNotFound`

Observed failure:

- User tested Copilot Studio chat on 2026-05-06 around 14:48 local.
- Test message:
  - `Criar tarefa: Titulo=Teste Opus Bot T007 20260506 143104, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=336, Prioridade=Alta`
- User replied `sim`.
- Bot returned `FlowNotFound` for flow:
  - `71f62da4-9748-f111-bec7-6045bdf42cae`
- Conversation ID:
  - `7e998ef1-7db8-48bd-afd9-90b57cee0151`
- UTC error time:
  - `2026-05-06 17:48:40 UTC`

Why this is strange:

- Live Dataverse check confirmed:
  - topic exists: `pmo_AssistentePMO_Clean.topic.CriarTarefa`
  - action exists: `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa`
  - action flowId is `71f62da4-9748-f111-bec7-6045bdf42cae`
  - `botcomponent_workflowid=04b1acfe-fc48-f111-bec7-000d3abc5cc6`
  - bound workflow is active: `PMO_PA_CriarTarefa`

Working theory:

- Copilot runtime had a stale published snapshot or stale action binding cache.
- The flow/action binding exists in Dataverse, but the bot runtime did not have the refreshed binding at the moment of the test.

Action already taken:

- Bot republished:
  - bot ID `77cfb838-6ed1-4488-9e57-ab98751081d3`
  - publish succeeded at `2026-05-06 17:45:48 UTC`

Pending:

- Fresh T-007 create retest after publish.
- Confirm a new Power Automate run is created by the bot.
- Confirm no `FlowNotFound`.
- Confirm no `FlowActionBadRequest`.
- Confirm SharePoint project item is created.

### Blocker 2 - T-007 Copilot cancel path not tested

Expected behavior:

- Bot recognizes `CriarTarefa`.
- Bot parses or asks for missing fields.
- User responds `nao` at confirmation.
- Bot cancels.
- Flow is not called.
- No SharePoint project/task item is created.

Pending:

- Execute cancel-path test and capture evidence.

### Blocker 3 - T-001 duplicate branch not evidenced

Expected behavior:

- Run `PMO_PA_CriarTarefa` twice with the same `NomeProjeto`/`DataAlvo`.
- Second run should take duplicate branch.
- No second duplicate SharePoint project row should be created.

Current state:

- Positive create path is green.
- Explicit duplicate branch evidence was not found.

Release impact:

- This is lower than T-007 but still a meaningful data-quality gap.

### Blocker 4 - Bot must be in final solution and not only Default

Release rule:

- No required component should exist only in Default.
- The bot, action components, workflow bindings, and flows must be in the intended solution/environment.

Current state:

- Live Dataverse checks show the action and binding exist in the target environment.
- We still need final confirmation that the bot and all required components are packaged in the final release solution after T-007 is fixed.

## 7. Questions For Opus 4.6

1. Given live Dataverse confirms the Copilot action and `botcomponent_workflow` binding exist, what is the most likely cause of `FlowNotFound` in Copilot Studio runtime: stale publish snapshot, action cache, wrong bot runtime version, solution layering, or flow permission/connection reference issue?

2. What exact Dataverse tables/columns should we inspect next to prove Copilot runtime uses the intended published bot version and action binding?

3. Is `pac copilot publish` enough after direct Dataverse/package fixes, or should we force a no-op edit/publish in Copilot Studio UI to refresh the runtime action binding?

4. Should the `CriarTarefa` topic call `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa` instead of `pmo_AssistentePMO.action.PMO_PA_CriarTarefa` if the active bot schema is `pmo_AssistentePMO_Clean`?

5. For T-003 negative missing-project behavior, should the controlled not-found branch terminate with a failed run status, or should we avoid `Terminate` failure semantics and return a clean response for operational monitoring?

6. Should the T-001 duplicate rule key on `NomeProjeto + DataAlvo`, `Title + DataAlvo`, `responsavel + prazo + titulo`, or another idempotency key to avoid false duplicates?

7. Does Opus recommend keeping the strict ASCII-only policy for this tenant, or is there a safer export/import encoding workflow that would allow Portuguese accents without mojibake risk?

8. Are there additional Copilot Studio action-binding regression tests we can automate beyond static YAML/raw Dataverse checks?

## 8. Recommended Next Steps

1. Retest T-007 create path in Copilot Studio test chat after the publish refresh.

2. During the T-007 create retest, verify all of the following:
   - Bot selects the `CriarTarefa` topic.
   - Bot asks confirmation only after all values are parsed.
   - User replies `sim`.
   - Bot does not return `FlowNotFound`.
   - A new Power Automate run appears for `PMO_PA_CriarTarefa`.
   - Flow run is green.
   - SharePoint `Projetos` item is created.
   - Bot gives a clear success response.

3. Retest T-007 cancel path:
   - Use a unique title.
   - Reply `nao`.
   - Confirm no Power Automate run is created.
   - Confirm no SharePoint row is created.

4. Run T-001 duplicate branch:
   - Reuse an already-created `NomeProjeto` and `DataAlvo`.
   - Confirm duplicate response branch.
   - Confirm no duplicate row.

5. If T-007 still returns `FlowNotFound`, inspect:
   - bot schema used in topic dialog reference.
   - `botcomponent_workflow` binding row.
   - action component `flowId`.
   - flow `workflowid`.
   - solution layering for bot/action.
   - Copilot published version/runtime snapshot.
   - connection references and action permissions.

6. After T-007 passes, produce final release package/export and rerun:
   - `tests/Test-PMOFlowStopShipAudit.ps1`
   - `tests/Test-CriarTarefaFlowDefinition.ps1`
   - `tests/Test-CriarTarefaContract.ps1`
   - `tests/Test-CriarTarefaRawDataverse.ps1`

7. Only change release decision to SHIP when:
   - T-001 duplicate branch is evidenced or explicitly waived.
   - T-002 through T-006 remain green.
   - T-007 create and cancel paths pass.
   - No `FlowNotFound`.
   - No `FlowActionBadRequest`.
   - Final solution export contains all required bot, action, workflow binding, and flow components.

## 9. Bottom Line

The direct Power Automate flow layer is now largely recovered and validated. The biggest remaining concern is not the flow logic itself; it is the Copilot runtime-to-flow binding for `CriarTarefa`.

Opus should focus review on the Copilot Studio binding/runtime layer, especially why the bot runtime reported `FlowNotFound` even though Dataverse shows the action component and workflow binding exist and the target flow is active.
