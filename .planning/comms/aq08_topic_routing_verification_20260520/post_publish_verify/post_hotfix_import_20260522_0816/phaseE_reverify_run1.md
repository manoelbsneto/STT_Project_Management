# AQ-08 Phase E Reverify Run 1

- generated_brt: `2026-05-22 08:20:21 -03:00`
- execution_shell: `Windows PowerShell 5.1`
- mode: `LivePacReadOnly`
- evidence_dir: `D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_publish_verify\post_hotfix_import_20260522_0816`
- report_json: `aq08_post_remediation_reverify_report.json`
- process_exit_code: `1`
- verifier_overall: `BLOCK`
- blocking_topic_count: `4`

## Per-topic result

| Topic | Found topic | Expected action reference in topic | Expected action workflow bound | Legacy hits | Status |
|---|---|---|---|---|---|
| AtualizarStatus | true | false | true | none | BLOCK |
| AtualizarTarefa | true | false | true | none | BLOCK |
| ConsultarPortfolio | true | false | true | none | BLOCK |
| CriarTarefa | true | true | true | none | PASS |
| ListarTarefas | true | false | true | none | BLOCK |

## Evidence files

- `pac_env_who_reverify.txt`
- `botcomponent_topics_inventory_reverify.txt`
- `botcomponent_workflow_inventory_reverify.txt`
- `aq08_post_remediation_reverify_report.json`

## Notes

- The verifier invoked only live PAC read-only operations implemented by `tests/Test-Aq08PostRemediationReverify.ps1`: `pac env who` and `pac org fetch` inventory reads.
- This markdown summary reflects the report fields emitted by the reverifier. The run did not meet the requested expected PASS state.
