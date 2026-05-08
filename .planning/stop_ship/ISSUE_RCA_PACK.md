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
