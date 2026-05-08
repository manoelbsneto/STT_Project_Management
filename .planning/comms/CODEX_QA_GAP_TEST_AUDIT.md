# CODEX QA GAP TEST AUDIT

Date: 2026-05-07
Owner: Agent D QA
Scope: Programmatic audit only. Existing files in `tests/` and browser-owned artifacts were not edited.

## Inputs Inspected

- Existing tests:
  - `tests/Test-PMOFlowStopShipAudit.ps1`
  - `tests/Test-CriarTarefaFlowDefinition.ps1`
  - `tests/Test-CriarTarefaContract.ps1`
  - `tests/Test-CriarTarefaRawDataverse.ps1`
- Power Automate / deployment scripts:
  - `deploy/PA_CriarTarefa_Flow.ps1`
  - `deploy/PA_Provisioning_P0.ps1`
  - `deploy/PA_Phase3_P1P2.ps1`
  - `deploy/PA_Redesign_G2_PostCardWait.ps1`
  - `deploy/PA_Patch_G2_Wiring.ps1`
  - `deploy/QA_Phase6_Automated.ps1`
  - `deploy/SP_Provisioning.ps1`
  - `deploy/CS_G4_*.ps1`
  - `deploy/Teams_Phase5_*.ps1`
- Stop-ship planning evidence:
  - `.planning/stop_ship/TEST_STRATEGY.md`
  - `.planning/stop_ship/RELEASE_READINESS_CHECKLIST.md`
  - `.planning/stop_ship/QA_EVIDENCE_MATRIX_20260506.md`
  - `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md`
  - `.planning/comms/GATE_STATUS.md`

## Current Automated Coverage

| Test | Coverage | Fully programmatic? | Runtime dependency |
|---|---|---:|---|
| `Test-PMOFlowStopShipAudit.ps1` | Static solution export audit for workflow JSON parse, ASCII/mojibake, old bot schema refs, six flow structural regressions, provisioning text, bot workflow binding XML. | Yes | No, if run against unpacked solution source. |
| `Test-CriarTarefaFlowDefinition.ps1` | Static CriarTarefa flow definition audit: GUID ProjectID, no sequential latest-item logic, date normalization, duplicate branch, auth parameter shape. | Yes | No, if run against exported flow JSON. |
| `Test-CriarTarefaContract.ps1` | Static Copilot template topic/action contract for `CriarTarefa` and `PMO_PA_CriarTarefa`. | Yes | No, if run against template YAML. |
| `Test-CriarTarefaRawDataverse.ps1` | Static raw Dataverse fetch-log audit for imported `CriarTarefa` topic text and action reference. | Yes | Requires prior `pac org fetch` or equivalent log, but the assertion itself is offline. |
| `deploy/QA_Phase6_Automated.ps1` | Wave 1 live inventory: SharePoint evidence mode or optional PnP writes, ProcessSimple flow inventory/run history, card JSON parse, Copilot published/security/language evidence, action bindings. | Partial | Yes for live ProcessSimple/PnP/PAC checks; C2/C3 partly rely on prior evidence. |

## GAP-To-Test Matrix

| Gap ID | Stop-ship gap | Existing automated coverage | Missing automated test | Suggested test name | Programmatic classification |
|---|---|---|---|---|---|
| GAP-001 | `PMO_PA_CriarTarefa_V3` is callable but still a stub and does not write to SharePoint `Tarefas`. | None. Existing CriarTarefa tests target old/static `PMO_PA_CriarTarefa` package shape, not V3 write behavior. | Verify V3 definition contains real SharePoint `PostItem`/`PatchItem` to the decided target list and returns a created item identifier. After runtime run, query SharePoint for a unique marker in `Tarefas`. | `Test-CriarTarefaV3FlowDefinition.ps1`; `Test-CriarTarefaV3SharePointWrite.ps1` | Definition test: fully programmatic. SharePoint write proof: programmatic runtime with authenticated connectors; bot invocation remains runtime-only. |
| GAP-002 | Business contract remains ambiguous: `CriarTarefa` name implies `Tarefas`, old flow writes `Projetos`, RCA recommends deciding `Tarefas` vs `Projetos` vs both. | `Test-PMOFlowStopShipAudit.ps1` proves old `CriarTarefa` maps required `Projetos.PM`; provisioning creates `Tarefas`. It does not assert the final business target for V3. | Add a contract test that fails unless the agreed target list and required fields are explicit in the flow definition and topic response text. | `Test-CriarTarefaTargetListContract.ps1` | Fully programmatic once architect decision is recorded. |
| GAP-003 | `FlowNotFound` root cause is Copilot Studio runtime tool registration, not just Dataverse binding. | Static tests detect old schema refs and some binding XML issues. `QA_Phase6_Automated.ps1` checks action bindings via FetchXML for selected actions. | Programmatic inventory should flag Dataverse bindings that exist while Copilot tool picker/runtime registration is absent. True runtime resolution still needs a Copilot Studio conversation/tool-picker check. | `Test-CopilotToolRuntimeRegistration.ps1` | Partial. Dataverse/PAC inventory is programmatic; actual tool picker and conversation resolution are browser/runtime-only. |
| GAP-004 | V2 topic rebinding to V3, `sim` confirmation, and `EndDialog` success/cancel behavior must be verified after publish. | `Test-CriarTarefaContract.ps1` checks old Clean action call and trigger contract. It does not assert V2/V3 action names, `StringPrebuiltEntity`, explicit `sim`, or `EndDialog`. | Export/fetch V2 topic and assert V3 dialog reference, no old `42d9...` flow reference, explicit `sim` condition, success `EndDialog`, cancel `EndDialog`, and no follow-up title prompt after success. | `Test-CriarTarefaV2TopicContract.ps1` | Static topic assertions are fully programmatic from exported YAML/fetch logs. Final "no continued prompt" behavior is browser/runtime-only. |
| GAP-005 | GPT-4.1 is a production constraint; GPT-5 Chat was observed to weaken routing. | `QA_Phase6_Automated.ps1` checks Copilot language/security from gate/export evidence, not model selection. | Add inventory evidence for model configuration if available from Dataverse/PAC export. If not exposed, mark model check as browser-admin gate. | `Test-CopilotModelPolicy.ps1` | Partial. Programmatic only if model metadata is exportable; otherwise browser/runtime-only. |
| GAP-006 | Ghost/duplicate bot risk: `Assistente PMO Clean` and `Assistente PMO V2` coexist; agents can patch/test the wrong bot. | `Test-PMOFlowStopShipAudit.ps1` detects old `pmo_AssistentePMO.` references inside a solution source. | Live Dataverse inventory should assert one intended active bot, no active ghost bot components in the target solution, and action/topic parentbot IDs point to V2. | `Test-CopilotGhostBotInventory.ps1` | Fully programmatic against Dataverse/PAC fetch output. |
| GAP-007 | Six direct flow runtime paths T-001 through T-006 are evidenced manually/API-by-run, but not replayed by a repeatable harness. | Static audits cover common regressions. `QA_Phase6_Automated.ps1` inventories live flows and run histories, but does not invoke all six scenarios. | Build a scenario harness that seeds SharePoint fixtures, triggers each flow through supported APIs or source-list events, polls run history/actions, and cleans up markers. | `Invoke-PMOFlowScenarioTests.ps1`; `Test-PMOFlowRunActions.ps1` | Programmatic runtime. Requires authenticated Power Platform, SharePoint, Teams, and Outlook connectors. Not browser-owned, but not offline. |
| GAP-008 | T-001 duplicate branch lacks clean evidence in the evidence matrix. | Static duplicate branch exists in `Test-CriarTarefaFlowDefinition.ps1`; no live duplicate replay. | Run same marker twice, assert second run reaches `Response_Duplicate` and SharePoint item count remains one. | `Test-CriarTarefaDuplicateRuntime.ps1` | Programmatic runtime with SharePoint/ProcessSimple auth. |
| GAP-009 | T-007 cancel path is pending: user says no/nao and no flow/item should be created. | No existing automated coverage for V2/V3 cancel runtime. Static topic contract can be added for cancel branch. | Static: assert cancel branch and `EndDialog`. Runtime: run Copilot conversation and then query SharePoint/run history for absence of marker. | `Test-CriarTarefaCancelTopicContract.ps1`; `Test-CriarTarefaCancelRuntime.ps1` | Static contract: fully programmatic. Conversation/no-call proof: browser/runtime-only unless a supported bot conversation API is available. |
| GAP-010 | SharePoint schema live validation is still marked NO in release readiness, especially `Tarefas` and required `Projetos.PM`. | `Test-PMOFlowStopShipAudit.ps1` checks provisioning script text. `QA_Phase6_Automated.ps1 -RunSharePointPnP` can live-check main lists but its default evidence mode does not validate live schema. | Add read-only live schema test covering five lists, required fields, choice values, indexes, views, and required/person field types. Keep optional write smoke separate. | `Test-SharePointLiveSchema.ps1` | Programmatic runtime with interactive PnP login. |
| GAP-011 | Teams and Outlook connector permissions/channel access remain manual security gates. | `QA_Phase6_Automated.ps1` inventories Standard connectors and recurrence runs; static card JSON validation exists. | Poll run actions for Teams/email actions after seeded trigger events; require action statuses and returned message IDs where available. | `Test-TeamsOutlookActionRuntime.ps1` | Programmatic runtime if connector auth is cached; rendered card inspection and user interaction are browser/runtime-only. |
| GAP-012 | Adaptive Card rendering in Teams is evidenced by screenshots, but card JSON tests only parse version/size. | `QA_Phase6_Automated.ps1` validates six JSON files parse, version 1.4, and size under 27 KB. | Add schema validation against Adaptive Card schema and action/input IDs expected by flows; optionally render in Teams manually. | `Test-AdaptiveCardContracts.ps1` | Schema/contract: fully programmatic. Teams render and submit: browser/runtime-only. |
| GAP-013 | Flow activation state is checked, but trigger schemas and response contracts for all live flows are not version-pinned in one local regression suite. | `Test-PMOFlowStopShipAudit.ps1` covers some action-specific source invariants. `QA_Phase6_Automated.ps1` checks trigger types loosely. | Generate a flow manifest from exported/live definitions and assert expected trigger kind, response action names, connector set, target lists, required fields, and no unexpected premium connectors. | `Test-PMOFlowManifestContract.ps1` | Fully programmatic for exported definitions; live inventory variant is programmatic runtime. |

## Missing Automated Tests By Priority

| Priority | Suggested file | Purpose | Why now |
|---|---|---|---|
| P0 | `tests/Test-CriarTarefaV3FlowDefinition.ps1` | Fail if V3 remains a stub or writes to the wrong list after the target-list decision. | RCA final status says V3 is callable but not production ready. |
| P0 | `tests/Test-CriarTarefaV2TopicContract.ps1` | Assert V2 topic calls V3, accepts `sim`, exits after success/cancel, and has no old flow ID/schema refs. | T-007 is the active stop-ship path. |
| P0 | `tests/Test-CopilotGhostBotInventory.ps1` | Detect active ghost bot/components and wrong parentbot/action bindings. | Reduces risk of patching/testing the wrong bot. |
| P0 | `tests/Test-SharePointLiveSchema.ps1` | Read-only live schema proof for five lists, required fields, choices, indexes, and views. | Release readiness still marks live schema validation as NO. |
| P1 | `tests/Invoke-PMOFlowScenarioTests.ps1` | Repeat T-001 through T-006 with fixture setup, run polling, action-status checks, and cleanup. | Converts manual evidence into repeatable release evidence. |
| P1 | `tests/Test-CriarTarefaDuplicateRuntime.ps1` | Prove duplicate branch creates no second item. | Evidence matrix marks duplicate branch as not evidenced. |
| P1 | `tests/Test-AdaptiveCardContracts.ps1` | Validate Adaptive Card schema and action/input contracts used by flows. | Current card checks are parse/size only. |
| P2 | `tests/Test-CopilotModelPolicy.ps1` | Record model policy from exported metadata or flag browser-admin verification. | GPT-4.1 is an operating constraint but not currently test-gated. |
| P2 | `tests/Test-TeamsOutlookActionRuntime.ps1` | Verify Teams/email action success after seeded risk/decision/check-in scenarios. | Connector/channel permissions remain a runtime release gate. |

## Commands To Run

Run from repo root:

```powershell
Set-Location "d:\VMs\Projetos\STT_Project_Management"
```

Static/package tests against the latest available unpacked solution export:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath ".planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked"
```

Static CriarTarefa flow definition test:

```powershell
$flow = Get-ChildItem ".planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked\Workflows" -Filter "*CriarTarefa*.json" | Select-Object -First 1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaFlowDefinition.ps1 -Path $flow.FullName -AllowRuntimeRawAuthentication
```

Static Copilot template contract test:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaContract.ps1 -TemplatePath ".\deploy\copilot\AssistentePMO.template.yaml"
```

Raw Dataverse topic fetch audit, if a fresh fetch log exists:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaRawDataverse.ps1 -FetchLogPath ".planning\stop_ship\v2_criartarefa_components_after_fix_20260507_1335.txt" -BotSchema "pmo_AssistentePMO_V2"
```

Phase 6 evidence-mode QA:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy\QA_Phase6_Automated.ps1
```

Phase 6 live SharePoint write/read QA, only when interactive PnP auth is acceptable:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy\QA_Phase6_Automated.ps1 -RunSharePointPnP
```

PowerShell syntax parse smoke for existing tests and deploy scripts:

```powershell
Get-ChildItem .\tests,.\deploy -Filter *.ps1 -File | ForEach-Object {
  [scriptblock]::Create((Get-Content -LiteralPath $_.FullName -Raw)) | Out-Null
  "PARSE PASS: $($_.FullName)"
}
```

## Fully Programmatic Vs Browser/Runtime-Only

Fully programmatic and offline:

- Static solution export audits over unpacked `Workflows`, `Assets`, `botcomponents`, and provisioning script text.
- Copilot topic/action contract assertions over exported YAML or raw Dataverse fetch logs.
- Adaptive Card JSON parse/schema/action-contract tests.
- Flow manifest tests over exported definitions.

Programmatic but live/runtime-dependent:

- `deploy/QA_Phase6_Automated.ps1` ProcessSimple/PAC/PnP checks.
- SharePoint live schema and write/read smoke tests.
- T-001 through T-006 scenario replay with fixture setup, run polling, and cleanup.
- Teams/Outlook action status polling from Power Automate run history.
- Dataverse/PAC inventory for active bots, bot components, workflow bindings, and publish state.

Browser/runtime-only unless a supported bot conversation API is introduced:

- Copilot Studio tool picker proving a flow is not shown as deleted/inaccessible.
- T-007 conversational proof that `criar tarefa...` routes, accepts `sim`, invokes V3, returns the result, and ends cleanly.
- T-007 cancel proof that the bot exits and does not call the flow.
- GPT model selection verification if the model field is not exported by PAC/Dataverse.
- Teams rendered card inspection and interactive Adaptive Card submit behavior.

## QA Recommendation

No-ship remains correct until P0 gaps are closed. The minimum new automated gate should combine:

1. `Test-CriarTarefaV3FlowDefinition.ps1`
2. `Test-CriarTarefaV2TopicContract.ps1`
3. `Test-CopilotGhostBotInventory.ps1`
4. `Test-SharePointLiveSchema.ps1`
5. Existing `Test-PMOFlowStopShipAudit.ps1`

That still will not replace T-007 browser/runtime evidence, because the root `FlowNotFound` class is explicitly a Copilot runtime registry failure that static Dataverse/package checks did not catch.
