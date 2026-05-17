# ISSUE RCA PACK

## ISSUE-001 - PMO_PA_CriarTarefa invalid date padding expression

Severity: SEV-0

Impact: `PMO_PA_CriarTarefa` failed before SharePoint lookup/write. Bot cannot create a task/project.

Timeline:
- Detected in manual Power Automate run screenshot: `Compose_DataAlvo` failed.
- Error: `The template function 'padLeft' is not defined or not valid.`
- Fix implemented and imported before Stop-Ship reset: replaced `padLeft()` with supported `if/length/concat` expression.
- Verification: exported solution after import no longer contains `padLeft`.

Root cause:
- Flow used an unsupported Power Automate template function in `Compose_DataAlvo`.

Contributing factors:
- No direct flow regression test existed.
- Bot testing was attempted before proving the Power Automate flow independently.

Corrective action:
- Code fix: `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_src/Workflows/PMO_PA_CriarTarefa-71F62DA4-9748-F111-BEC7-6045BDF42CAE.json`
- Imported package: `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_20260506.zip`

Prevention:
- Add direct manual/automated flow test for `prazo=30/06/2026` and `prazo=2026-06-30`.

## ISSUE-002 - PMO_PA_CriarTarefa invalid SharePoint DateTime OData filter

Severity: SEV-0

Impact: `Get_Duplicate_Projects` fails with SharePoint BadRequest: string not recognized as valid DateTime.

Timeline:
- Detected in manual Power Automate run screenshot after ISSUE-001 fix.
- Failed action: `Get_Duplicate_Projects`.
- Current exported evidence before fix: `.planning/canonical/PMO_v11_Tarefas_VERIFY_FLOW_FIX_20260506_072447/Workflows/PMO_PA_CriarTarefa-71F62DA4-9748-F111-BEC7-6045BDF42CAE.json:101`
- Draft local fix prepared but not imported under Stop-Ship rule.

Root cause:
- OData filter compares SharePoint DateTime column `DataAlvo` using `DataAlvo eq 'yyyy-MM-dd'`, causing SharePoint to reject the date.

Proposed corrective action:
- Use a one-day DateTime range:
  `DataAlvo ge datetime'yyyy-MM-ddT00:00:00Z' and DataAlvo lt datetime'next-dayT00:00:00Z'`

Prevention:
- Regression test duplicate lookup path with `prazo=30/06/2026`.

## ISSUE-003 - PMO_PA_AtualizarTarefa unsafe project lookup

Severity: HIGH

Impact: Task update can succeed but project counter update can fail if `Get_Projeto_Item` returns zero rows.

Evidence:
- `.planning/canonical/PMO_v11_Tarefas_VERIFY_FLOW_FIX_20260506_072447/Workflows/PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json:276`
- Uses `first(body('Get_Projeto_Item')?['value'])` without a prior length guard.

Status: not reproduced manually yet.

## ISSUE-004 - PMO_PA_CheckInOnDemand unsafe project lookup / Teams dependency

Severity: HIGH

Impact: Flow may post a check-in card for a missing project or fail on Teams channel permissions.

Evidence:
- `.planning/canonical/PMO_v11_Tarefas_VERIFY_FLOW_FIX_20260506_072447/Workflows/PMO_PA_CheckInOnDemand-F5AAB85E-FF46-F111-BEC7-7CED8D955C6C.json:94`
- Uses `first(body('Get_Projeto')?['value'])` inside Teams card composition.

Status: not reproduced manually yet.

## MAY7-GAP-RCA-SUMMARY - Active 16-GAP stop-ship registry

Severity: SEV-0/P0/P1

Status: NO-SHIP.

## MAY7-PROGRAMMATIC-CLOSURE - Codex local preparation pass

Severity: SEV-0/P0

Status: Programmatic preparation complete; runtime still NO-SHIP.

Evidence:
- Flow scripts created for GAP-B1 through GAP-B5 under `deploy/PA_*_Flow.ps1`.
- Shared flow helpers created in `deploy/PMO_FlowScript.Common.ps1` and `deploy/PA_BotTopicFlows.Factory.ps1`.
- Local Copilot template updated in `deploy/copilot/AssistentePMO.template.yaml`.
- `Test-CopilotStopShipGaps.ps1` passes against local template.
- New flow definition tests pass for ConsultarPortfolio, ConsultarProjeto, RegistrarRiscoBot, RegistrarBloqueioBot, and PedirDecisaoBot.
- Ghost discovery and operations manual tests pass.
- Programmatic deployment attempt timed out; see `.planning/comms/CODEX_PROGRAMMATIC_DEPLOY_ATTEMPT_20260507.md`.

Root cause still active for runtime:
- Copilot Studio flow tool registration and publish state cannot be proven by local files.
- New flow IDs were not produced because Power Platform API/auth calls timed out.

Corrective action now required:
- Opus executes `.planning/comms/CODEX_BROWSER_REQUESTS_20260507.md` in a consolidated browser session.
- Human/Admin reviews ghost discovery output before any deletion.

Prevention:
- Keep static tests green before browser edits.
- After Opus publishes, export/fetch fresh bot artifacts and rerun `Test-CopilotStopShipGaps.ps1` and `Test-PMOFlowStopShipAudit.ps1`.

This section supersedes the older May 6 issue-only framing for release readiness. The current source of truth is `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md`.

### GAP-A1 - V3 Flow has no real SharePoint logic

Evidence:
- `deploy/PA_CriarTarefa_Flow.ps1` statically passes `tests/Test-CriarTarefaFlowDefinition.ps1`.
- RCA evidence says V3 was callable but stubbed and did not write to SharePoint: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md`.

Current RCA conclusion:
- Programmatic blueprint is ready.
- Runtime state is unverified until Opus rebuilds V3 in the Power Automate UI and captures run evidence.

Corrective action:
- Execute Wave 1 Task 1.1 in UI.
- Attach success run URL, duplicate run URL, and SharePoint item evidence.

### GAP-A2 - CriarTarefa binding targets old/dead flow IDs

Evidence:
- `tests/Test-CopilotStopShipGaps.ps1` fails against `deploy/copilot/AssistentePMO.template.yaml` because `71f62da4` remains and V3 `3104124d` is absent.
- The same test fails against `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml` because `42d9abd1` remains and V3 `3104124d` is absent.

Current RCA conclusion:
- Static/package checks cannot prove Copilot runtime tool registration.
- UI binding and publish evidence are mandatory.

Corrective action:
- Opus binds `CriarTarefa` to V3 in Copilot Studio UI, publishes, and captures T-007 evidence.

### GAP-B1 through GAP-B5 - Read/write topics are stubs or confirm-only

Evidence:
- `tests/Test-CopilotStopShipGaps.ps1` detects `portfolio_stub`, `project_stub`, `risk_confirmed_msg`, `block_confirmed_msg`, and `decision_confirmed_msg`.
- Forensics audit: `.planning/comms/CODEX_FORENSICS_AUDIT.md`.

Current RCA conclusion:
- The bot has conversational shells but lacks real SharePoint-backed flow calls for these topics.

Corrective action:
- Wave 2 and Wave 3 flow/topic creation in UI after Wave 1 approval.

### GAP-B6/GAP-B7 - STT/confirmation defects

Evidence:
- Local template still fails GAP-B6 raw input capture check.
- Live-after-FlowNotFound export fails GAP-B7 Boolean confirmation checks.

Current RCA conclusion:
- Local code has partial confirmation improvements, but live runtime is not proven and AtualizarStatus remains STT-incompatible.

Corrective action:
- Redesign AtualizarStatus for raw input parse.
- Publish and test String confirmations in browser.

### GAP-C1 - Ghost bot components

Evidence:
- Forensics audit confirms Clean and V2 bot/component coexistence from existing Dataverse/export artifacts.
- Cleanup remains Human/Admin-gated.

Current RCA conclusion:
- Discovery can be programmatic, but deletion must not proceed without explicit approval.

Corrective action:
- Produce fresh discovery output, backup references, request Human/Admin delete approval or risk acceptance.

## ISSUE-20260512-001 - Solution import rejected generated flow clientdata

Severity: SEV-0 / Stop-Ship.

Impact:
- Manual import of solution `PMO v1.1 - Task Management Topics` version `2.4` failed before runtime validation.
- No production import/publish/deploy was completed by Codex. No SharePoint schema change was made by this fix.

Timeline:
- 2026-05-12 02:17:50 UTC: owner import log started.
- 2026-05-12 02:18:38 UTC: import failed at 47.83 percent.
- Triage found `PMO_PA_CriarTarefa-0A5D2A41-24C0-4D5E-9F6D-000000000241.json` started with UTF-8 BOM bytes `EF BB BF`.
- Fix applied locally in `deploy/Build-Solution24LocalPackage.ps1`.
- Regression gate added in `tests/Test-SolutionZipP24Contracts.ps1`.
- Package rebuilt as `Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip`, SHA256 `0FACF178209722BAE98401418A46C5D36A36B62B57E95373EB8B242EE4D8BA38`.

Root cause:
- The package builder wrote newly generated workflow JSON with `Set-Content -Encoding UTF8`.
- On Windows PowerShell 5.1, this emits UTF-8 with BOM.
- Dataverse flow clientdata import parser expected JSON at byte zero and rejected the BOM before `{`.

Contributing factors:
- Existing tests verified JSON parse after extraction but did not inspect package bytes for BOM.
- Previous import failure focused on ZIP path separator normalization, so byte-level clientdata validation was missing.

Corrective actions:
- Code fix: `deploy/Build-Solution24LocalPackage.ps1` now writes generated text through `System.IO.File.WriteAllText` with UTF-8 no BOM.
- Regression test: `tests/Test-SolutionZipP24Contracts.ps1` now blocks BOM in `Workflows/*.json` and `botcomponents/*/data`.
- Evidence: `.planning/comms/solution_2_4_create_project_task_batch_20260511/LOCAL_GATES.md`.

Verification:
- `Test-SolutionZipP24Contracts.ps1`: PASS, including `No UTF-8 BOM in workflow/clientdata files`.
- `Test-SolutionZipP0Contracts.ps1`: PASS.
- `Test-ExcluirSoftDeleteCapability.ps1`: PASS.
- `Test-PMOFlowStopShipAudit.ps1`: PASS.
- Byte evidence: generated `PMO_PA_CriarTarefa` starts with `7B 0D 0A 20 20 20 20 22`, `HasBom=False`.

Prevent recurrence:
- P24 package gate is mandatory before any owner import attempt.
- ZIP path separator gate and manifest path gate remain mandatory.
- CI gate is explicitly excluded only when the owner authorizes local gates only; all other stop-ship gates remain required.

Release decision:
- Local package readiness: PASS.
- Production release readiness: NO-SHIP until owner manual import/publish and runtime validation pass.

## ISSUE-20260512-003 - CriarTarefa publish blocked by missing CloudFlow action reference

Severity: SEV-0 / Stop-Ship.

Impact:
- Owner manual import of version 2.7 succeeded, but Copilot Studio publish was blocked before runtime validation.
- `CriarTarefa` could not be published because the topic referenced a cloud flow ID that was not present as a bot action definition.

Timeline:
- 2026-05-12: owner provided Copilot Studio diagnostic for component `CriarTarefa`.
- Diagnostic: `InvalidReferenceError`, `referenceType=CloudFlow`, `referenceId=0a5d2a41-24c0-4d5e-9f6d-000000000241`, `errorCode=NotFound`.
- Local reproduction found direct `InvokeFlowAction` in `.planning/comms/solution_2_7_batch_topic_no_flow_preview_20260512/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa/data`.
- Local package lacked `botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`.
- Fix prepared locally in version 2.8 package.

Root cause:
- `CriarTarefa` topic invoked the cloud flow directly through `InvokeFlowAction`.
- The package registered the workflow, but did not include the corresponding Copilot Studio action botcomponent expected by the bot definition.
- This made the topic checker/publish step unable to resolve the `CloudFlow` reference.

Contributing factors:
- The existing local gates verified the workflow JSON and task-write contract, but did not verify Copilot Studio publish binding shape.
- A previous fix for `Gerar_Multiplos_Projetos` addressed no-flow preview behavior, but did not audit all direct `InvokeFlowAction` topic references for publish compatibility.

Corrective actions:
- Code fix: `deploy/Build-Solution24LocalPackage.ps1` now creates `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`.
- Code fix: `CriarTarefa` topic now stages slot values into globals and calls `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` through `BeginDialog`.
- Regression test: `tests/Test-CriarTarefaPublishBinding.ps1` blocks direct `InvokeFlowAction` in `CriarTarefa` and requires the action component.
- Package: `Solution/PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip`, SHA256 `4B0F2B5597BA1DFD18479A1D213A8DFC1D5D8BEB5B9060F933751CD2B69E90BC`.

Verification:
- `Test-CriarTarefaPublishBinding.ps1`: PASS.
- `Test-CriarTarefaCreatesTarefas.ps1`: PASS.
- `Test-GerarMultiplosProjetosDefinition.ps1`: PASS.
- `Test-SolutionZipP24Contracts.ps1`: PASS.
- `Test-SolutionZipP0Contracts.ps1`: PASS.
- `Test-ExcluirSoftDeleteCapability.ps1`: PASS.
- `Test-PMOFlowStopShipAudit.ps1`: PASS.

Prevent recurrence:
- P24 gate now runs the publish-binding regression test.
- Any future topic that invokes Power Automate should use an action component with `TaskDialog`/`InvokeFlowTaskAction`, and topic YAML should call that component through `BeginDialog`.

Release decision:
- Local package readiness: PASS.
- Production release readiness: NO-SHIP until owner manual import, Copilot Studio publish, and runtime smoke validation pass.

## ISSUE-001 - CriarProjeto ContentFiltered After Success

Severity: SEV-0 stop-ship.

Impact:
- User completed guided `novo projeto` flow in Copilot Studio.
- Bot displayed `Projeto criado com sucesso!` and then returned `Ocorreu um erro no Assistente PMO. Codigo: ContentFiltered.`
- Copilot Studio diagnostics showed `openAIIndirectAttack`.

Timeline:
- 2026-05-13: Owner imported package 3.1 successfully.
- 2026-05-13: Runtime guided test reproduced `ContentFiltered` after project creation success.
- 2026-05-13: Static evidence found 3.1 `CriarProjeto` sent `activity: "{Topic.Result}"`.
- 2026-05-13: Candidate 3.3 replaces raw action output echo with static mapped messages and passes local gates.

Root cause:
- The topic echoed the Power Automate action output directly into a bot `SendActivity`. Even controlled flow text was treated as bot-visible action output and triggered Responsible AI filtering.

Contributing factors:
- Existing publish-binding tests verified action binding but did not block raw `Topic.Result` echo.
- The import succeeded, so the failure was only visible at runtime after the user action.

Corrective actions:
- Code fix: `.planning/comms/solution_3_3_criarprojeto_content_route_safe_20260513/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.CriarProjeto/data`.
- Regression test: `tests/Test-CriarProjetoContentSafeOutput.ps1`.
- Aggregate gate: `tests/Test-SolutionZipP24Contracts.ps1` now runs the content-safe output subtest.

Prevent recurrence:
- Do not send raw Power Automate outputs directly from Copilot topics when the text can contain dynamic or user-controlled content.
- Map known action outcomes to static bot text; use generic static fallback for unexpected results.

Release decision:
- Local package readiness: PASS for 3.3.
- Production readiness: NO-SHIP until owner import/publish and Copilot runtime smoke test prove no `ContentFiltered`.

## ISSUE-002 - One-Shot Project Creation Routed To CriarTarefa

Severity: SEV-0 stop-ship.

Impact:
- User sent `criar projeto: NomeProjeto=...` and Copilot routed to `CriarTarefa`, asking `Qual o titulo da tarefa?`
- This can write or collect task data when the user intended to create a project.

Timeline:
- 2026-05-13: Runtime screenshot showed project one-shot routed to `CriarTarefa`.
- 2026-05-13: Static evidence found GPT default instruction: `criar tarefa ou projeto` -> `CriarTarefa`.
- 2026-05-13: Static evidence found LowConfidence `detect_criar_tarefa` also matched `criar projeto`, `novo projeto`, `abrir projeto`, and `registrar projeto`.
- 2026-05-13: Candidate 3.3 separates project and task routing in both layers.

Root cause:
- Project-creation phrases were grouped with task-creation phrases and redirected to `CriarTarefa`.

Corrective actions:
- Code fix: `.planning/comms/solution_3_3_criarprojeto_content_route_safe_20260513/unpacked/botcomponents/pmo_AssistentePMO_V2.gpt.default/data`.
- Code fix: `.planning/comms/solution_3_3_criarprojeto_content_route_safe_20260513/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.LowConfidence/data`.
- Regression test: `tests/Test-CopilotRoutingInstructions.ps1`.

Prevent recurrence:
- Project and task route rules must remain separate in GPT/default instructions, fallback routing, and trigger phrases.
- Package gate must fail if any fallback task route captures project phrases.

Release decision:
- Local package readiness: PASS for 3.3.
- Production readiness: NO-SHIP until runtime confirms one-shot project phrases route to `CriarProjeto`.
