# Issue RCA Pack

## ISSUE-001: CriarTarefa Routes To LowConfidence

Severity: P0

Impact: User messages like `Criar tarefa: ...` were not routed to the CriarTarefa topic and instead received the LowConfidence fallback.

Timeline:
- Detection: User reported bot response `"Não entendi bem..."`; documented in `.planning/CODEX_HOTFIX_CRIARTAREFA_ROUTING.md`.
- Triage: Extracted template showed `includeInOnSelectIntent: false`, only 4 trigger phrases, stale fallback, and ProjectID prompt in CriarTarefa.
- Fix verification: Fresh no-output live extract `.planning/comms/cs_criartarefa_no_output_verify_20260505_202323.yaml` has clean routing state and no fragile output binding.
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

## ISSUE-002: CriarTarefa Invalid Topic Output Binding

Severity: P0

Impact: Copilot Studio blocked publish/test readiness with `BindingKeyNotFoundError` / `InvalidBindingOutput` because `CriarTarefa` bound action output `result` to `Topic.message`, but the topic checker did not resolve that output binding.

Evidence:
- User screenshot and diagnostic JSON show `bindingKey: result`, `errorCode: InvalidBindingOutput`, `componentDisplayName: CriarTarefa`, and component ID `b7fbf995-ffd8-4657-ba76-d289f6a9d3a8`.
- Superseded extracts such as `.planning/stopship/criartarefa/live_extract_20260505_194946.yaml` still had `result: Topic.message`, proving why the earlier SHIP claim was premature.
- Live no-output hotfix result `.planning/comms/cs_criartarefa_no_output_result_20260505_202323.json` reports `status: PASS`, `noOutputBinding: true`, and `noTopicMessageReference: true`.
- Raw Dataverse fetch `.planning/stopship/criartarefa/fetch_criartarefa_components_after_no_output_20260505_202323.txt` shows `call_criar_tarefa` invokes `template-content.action.PMO_PA_CriarTarefa` with no `output:` block.

Root cause:
- The topic contained a fragile action-output binding that Copilot Studio's checker rejected even though the action schema exposed `outputs.result`.
- Earlier validation over-trusted extracted action schema shape and did not include a negative assertion against topic output bindings.

Corrective actions:
- Live hotfix: `deploy/CS_CriarTarefa_RemoveOutputBinding.ps1` removes the topic `output:` binding and replaces `{Topic.message}` with a deterministic acknowledgement.
- Repo fix: `deploy/copilot/AssistentePMO.template.yaml` preserves the same no-output-binding shape.
- Regression fix: `tests/Test-CriarTarefaContract.ps1` now fails if `call_criar_tarefa` contains `output:` or if the topic references `Topic.message`, `Topic.ProjectIDGerado`, `Topic.CriarSuccess`, or `Topic.CriarErrorCode`.

Closure evidence:
- `.planning/stopship/criartarefa/test_no_output_verify_20260505_202323.json` passes 9/9 checks.
- `.planning/stopship/criartarefa/fetch_criartarefa_components_after_no_output_20260505_202323.txt` proves the active Dataverse component has no invalid topic output binding.
- `.planning/stopship/criartarefa/pac_copilot_list_after_no_output_20260505_202323.txt` reports Assistente PMO as Published/Active/Provisioned.

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
- `.planning/comms/cs_criartarefa_no_output_verify_20260505_202323.yaml` and `test_no_output_verify_20260505_202323.json` prove the extracted live bot contract is clean after the no-output-binding hotfix.
- `.planning/stopship/criartarefa/fetch_criartarefa_components_after_no_output_20260505_202323.txt` proves raw active Dataverse botcomponents contain the clean contract.

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
