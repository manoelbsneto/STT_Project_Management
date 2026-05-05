# CriarTarefa Stop-Ship Master Checklist

Status: SHIP GO/GREEN after no-output-binding hotfix
Date: 2026-05-05
Scope: Assistente PMO CriarTarefa routing/action contract.

| Gate | Status | Evidence |
|---|---:|---|
| Repo inventory completed | Done | `rg --files` counted 104 files. |
| Critical issues enumerated | Done | `ISSUE_RCA_PACK.md` |
| Known-bad reproduction captured | Done | `tests/Test-CriarTarefaContract.ps1 -TemplatePath .planning/comms/cs_assistente_pmo_post_criartarefa_20260505_125833.yaml -ExpectFailure` fails 8 checks as expected. |
| Current live extract contract passes regression | Done | `test_no_output_verify_20260505_202323.json` passes 9/9 checks against `.planning/comms/cs_criartarefa_no_output_verify_20260505_202323.yaml`. |
| Repo template contract passes regression | Done | `tests/Test-CriarTarefaContract.ps1 -TemplatePath deploy/copilot/AssistentePMO.template.yaml` passes 9/9 checks. |
| PowerShell parser clean | Done | Parser check passed for `deploy/CS_CriarTarefa_RemoveOutputBinding.ps1`, `deploy/CS_CriarTarefa_ContractFix.ps1`, and `tests/Test-CriarTarefaContract.ps1`. |
| Copilot published state | Done | `pac_copilot_list_after_no_output_20260505_202323.txt` reports Assistente PMO Published/Active/Provisioned. |
| Raw Dataverse component proof | Done | `fetch_criartarefa_components_after_no_output_20260505_202323.txt` shows CriarTarefa action call with no `output:` binding and no `Topic.message`. |
| Flow runtime contract proof | Done | `get_flow_criartarefa_summary_20260505_195945.json` confirms Enabled/Started and `result` responses. |
| CI parity | Not applicable | No CI configuration exists in this repo; local deterministic harness is the release gate. |
| Rollback plan documented | Done | `RELEASE_READINESS_CHECKLIST.md` |
