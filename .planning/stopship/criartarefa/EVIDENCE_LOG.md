# Evidence Log

| Item | Evidence Type | Link / Path | Command | Output Snippet | Notes |
|---|---|---|---|---|---|
| E-001 | Known-bad reproduction | `.planning/stopship/criartarefa/test_known_bad_125833.json` | `tests/Test-CriarTarefaContract.ps1 ... -ExpectFailure` | `failedCheckCount: 7` | Reproduces original routing/contract defects. |
| E-002 | Live clean extract | `.planning/stopship/criartarefa/test_live_extract_192913.json` | `tests/Test-CriarTarefaContract.ps1 -TemplatePath ...192913.yaml` | `passed: true`, `failedCheckCount: 0` | Proves extracted live contract is clean. |
| E-003 | Repo template clean | `.planning/stopship/criartarefa/test_repo_template.json` | `tests/Test-CriarTarefaContract.ps1 -TemplatePath deploy/copilot/AssistentePMO.template.yaml` | `passed: true`, `failedCheckCount: 0` | Proves source template matches contract. |
| E-004 | Publish failure | `.planning/comms/pac_copilot_publish_criartarefa_contract_20260505_193448.txt` | `pac copilot publish ...` | `Failed to publish... [05/05/2026 15:58:57]` | Release blocker. |
| E-005 | Import success | `.planning/comms/pac_import_criartarefa_contract_20260505_193448.txt` | `pac solution import ... --publish-changes` | `Solution Imported successfully`; `Published All Customizations` | Dataverse customization import succeeded. |
| E-006 | Parser check | local command output | PowerShell parser on deploy/test scripts | `PS parser OK` | Syntax gate passed. |
| E-007 | Source lines | `deploy/copilot/AssistentePMO.template.yaml` | `rg -n "PMO_PA_CriarTarefa|CriarTarefa|result: Topic.message"` | action at line 86, topic at line 513, binding at line 619 | Current line evidence after edits. |
| E-008 | Runbook env proof | `.planning/stopship/criartarefa/pac_env_who_20260505_2003.txt` | `pac env who` | `Friendly Name: ColOfertasBrasilPro`; `Environment ID: e2d10003...` | Confirms correct environment. |
| E-009 | Runbook connection proof | `.planning/stopship/criartarefa/pac_connection_list_20260505_2003.txt` | `pac connection list --environment ...` | SharePoint, Teams, Office 365: `Connected` | Confirms required connectors. |
| E-010 | Published bot proof | `.planning/stopship/criartarefa/pac_copilot_list_20260505_2003.txt` | `pac copilot list --environment ...` | `Assistente PMO ... Published ... Active ... Provisioned` | Replaces stale `pac copilot publish` failure as release gate. |
| E-011 | Fresh live extract proof | `.planning/stopship/criartarefa/test_live_extract_194946.json` | `tests/Test-CriarTarefaContract.ps1 -TemplatePath live_extract_20260505_194946.yaml` | `passed: true`, `failedCheckCount: 0` | Latest live contract check. |
| E-012 | Raw Dataverse component proof | `.planning/stopship/criartarefa/fetch_criartarefa_components_20260505_2002.txt` | `pac org fetch --xmlFile fetch_criartarefa_components.xml` | `includeInOnSelectIntent: true`; `result: Topic.message`; action output `result` | Direct botcomponent data. |
| E-013 | Flow contract proof | `.planning/stopship/criartarefa/get_flow_criartarefa_summary_20260505_195945.json` | `powershell.exe ... GetFlowProbe.ps1` | `enabled: true`; `state: Started`; success/error body has `result` | Runbook-compliant Windows PowerShell 5.1 Get-Flow proof. |
