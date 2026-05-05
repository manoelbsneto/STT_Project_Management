# Issue RCA Pack

## ISSUE-001: CriarTarefa Routes To LowConfidence

Severity: P0

Impact: User messages like `Criar tarefa: ...` were not routed to the CriarTarefa topic and instead received the LowConfidence fallback.

Timeline:
- Detection: User reported bot response `"Não entendi bem..."`; documented in `.planning/CODEX_HOTFIX_CRIARTAREFA_ROUTING.md`.
- Triage: Extracted template showed `includeInOnSelectIntent: false`, only 4 trigger phrases, stale fallback, and ProjectID prompt in CriarTarefa.
- Fix verification: Fresh live extract `.planning/stopship/criartarefa/live_extract_20260505_194946.yaml` has clean routing state.
- Regression proof: `tests/Test-CriarTarefaContract.ps1` fails the known-bad extract and passes current live/repo templates.

Root causes:
- CriarTarefa was excluded from orchestrator selection.
- Trigger phrase coverage was too narrow.
- Fallback message did not advertise create task/project.
- Topic still contained stale ProjectID collection artifacts.

Contributing factors:
- No automated contract test existed for Copilot routing invariants.
- Evidence folder contained stale before/after files, making raw grep misleading.

Corrective actions:
- Code fix: `deploy/copilot/AssistentePMO.template.yaml`
- Deployment hardening: `deploy/CS_CriarTarefa_ContractFix.ps1`
- Regression test: `tests/Test-CriarTarefaContract.ps1`

Prevent recurrence:
- Run `tests/Test-CriarTarefaContract.ps1` against every fresh `pac copilot extract-template` output before release.

## ISSUE-002: CriarTarefa Action/Flow Contract Mismatch Risk

Severity: P0

Impact: Topic could route correctly but fail or return blank output if the action expected `result` while the flow returned old aliases such as `message`, `projectId`, `success`, or `errorcode`.

Evidence:
- Live extract uses `result: Topic.message` in `.planning/comms/codex_triplecheck_live_extract_20260505_192913.yaml`.
- Internal fetch after fix shows raw action/topic data with `result`.
- Older ProcessSimple request artifacts still show old response shape, so they must not be used as source of truth without package rewrite evidence.

Root cause:
- Flow response contract and Copilot output binding evolved independently.

Corrective actions:
- `deploy/CS_CriarTarefa_ContractFix.ps1` rewrites the workflow response body to `result`.
- Regression test checks action output and topic binding.

Closure evidence:
- `.planning/stopship/criartarefa/get_flow_criartarefa_summary_20260505_195945.json` proves the live flow is enabled/Started and both success/error response bodies return `result`.

## ISSUE-003: Publish State Ambiguity

Severity: P1

Impact: Clean component data may exist in Dataverse/extracts while the end-user published bot still serves older behavior.

Evidence:
- `.planning/comms/pac_copilot_publish_criartarefa_contract_20260505_193448.txt` reports `Failed to publish`.
- `pac copilot list` reports `Assistente PMO` as Published/Active/Provisioned.
- The 193448 deployment run timed out and wrote no final result JSON.

Root cause:
- PAC publish command reports stale/failed publish state from `2026-05-05 15:58:57` even after later solution import and active component verification. `pac copilot status` is also unusable in this environment due a Dataverse metadata error on `componentstate_Property`.

Closure evidence:
- `.planning/stopship/criartarefa/pac_copilot_list_20260505_2003.txt` reports `Assistente PMO` as Published/Active/Provisioned.
- `.planning/stopship/criartarefa/live_extract_20260505_194946.yaml` and `test_live_extract_194946.json` prove the extracted live bot contract is clean.
- `.planning/stopship/criartarefa/fetch_criartarefa_components_20260505_2002.txt` proves raw active Dataverse botcomponents contain the clean contract.

Prevent recurrence:
- Treat `pac copilot publish` failure as insufficient by itself. Use the runbook evidence bundle: solution import log, `pac copilot list`, fresh extract regression, and raw `pac org fetch`.

## ISSUE-004: Repo Template Drift

Severity: P1

Impact: Future deployments from repo template could reintroduce stale behavior.

Root cause:
- `deploy/copilot/AssistentePMO.template.yaml` did not contain the same action-calling CriarTarefa body as the live extract.

Corrective actions:
- Added `PMO_PA_CriarTarefa` action component to repo template.
- Replaced placeholder CriarTarefa confirmation with action-calling dialog.
- Regression now passes against repo template.
