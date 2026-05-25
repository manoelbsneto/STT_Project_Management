# T0 3.18 Strict Consistency Final

| Field | Value |
|---|---|
| Agent | Codex #2 Lead |
| Timestamp BRT | 2026-05-23 19:32:55 BRT |
| Subject | .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/package/PMO_v11_Tarefas_3_18_PM0_FUNCTIONAL_FIX.zip |
| SHA256 | 270F569A0D34CB596115B8776A8354F88F184F1D2F772755416175A80D0A12FD |
| Reference | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/unpacked/3_17_live_unpacked |
| Tenant write commands | None |
| Verdict | PASS |
| Screenshot path | .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/screenshots/20260523_20260523_223255_Codex2Lead_step08_strict_consistency_final.png |

## Checks

| # | Check | Result | Path | Finding |
|---:|---|---|---|---|
| 1 | Package SHA256 matches authorized 3.18 hash | PASS | .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/package/PMO_v11_Tarefas_3_18_PM0_FUNCTIONAL_FIX.zip | Expected 270F569A0D34CB596115B8776A8354F88F184F1D2F772755416175A80D0A12FD; actual 270F569A0D34CB596115B8776A8354F88F184F1D2F772755416175A80D0A12FD |
| 2 | 1. Five PM0 workflow entries present with expected names and GUIDs | PASS | Workflows/PM0_PA_Card_*.json | [{"flow":"AtualizarStatus","path":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/Workflows/PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json","exists":true},{"flow":"AtualizarTarefa","path":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/Workflows/PM0_PA_Card_AtualizarTarefa-7C6300C2-A250-F111-BEC7-000D3ABC5CC6.json","exists":true},{"flow":"ConsultarPortfolio","path":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/Workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333BD91-A250-F111-BEC7-000D3ABC5CC6.json","exists":true},{"flow":"CriarTarefa","path":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/Workflows/PM0_PA_Card_CriarTarefa-7F662DB7-A250-F111-BEC7-000D3ABC5CC6.json","exists":true},{"flow":"ListarTarefas","path":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/Workflows/PM0_PA_Card_ListarTarefas-E0E3C6B0-A250-F111-BEC7-000D3ABC5CC6.json","exists":true}] |
| 3 | 2. Five PM0 action components present with botcomponent.xml and data | PASS | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_* | [{"action":"PM0_PA_Card_AtualizarStatus","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus","xml":true,"data":true},{"action":"PM0_PA_Card_AtualizarTarefa","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa","xml":true,"data":true},{"action":"PM0_PA_Card_ResumoExecutivoPortfolio","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio","xml":true,"data":true},{"action":"PM0_PA_Card_CriarTarefa","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa","xml":true,"data":true},{"action":"PM0_PA_Card_ListarTarefas","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas","xml":true,"data":true}] |
| 4 | 3. Five PM0 topic components present with botcomponent.xml and data | PASS | botcomponents/pmo_AssistentePMO_V2.topic.* | [{"topic":"AtualizarStatus","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarStatus","xml":true,"data":true},{"topic":"AtualizarTarefa","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa","xml":true,"data":true},{"topic":"ConsultarPortfolio","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.ConsultarPortfolio","xml":true,"data":true},{"topic":"CriarTarefa","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa","xml":true,"data":true},{"topic":"ListarTarefas","dir":".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/work/step08_strict_consistency/package_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.ListarTarefas","xml":true,"data":true}] |
| 5 | 4. Zero internal duplicate PM0 botcomponents | PASS | botcomponents/ | No duplicate PM0 botcomponent directory names. |
| 6 | 5. Zero unexplained canonical leaf diffs vs prescribed recipe | PASS | package tree vs forensic_diff/unpacked/3_17_live_unpacked | Total diffs=24; unexplained=0 |
| 7 | 6. solution.xml RootComponents includes five PM0 card workflow entries | PASS | solution.xml | [{"guid":"1721E0A3-A250-F111-BEC7-000D3ABC5CC6","present":true},{"guid":"7C6300C2-A250-F111-BEC7-000D3ABC5CC6","present":true},{"guid":"8333BD91-A250-F111-BEC7-000D3ABC5CC6","present":true},{"guid":"7F662DB7-A250-F111-BEC7-000D3ABC5CC6","present":true},{"guid":"E0E3C6B0-A250-F111-BEC7-000D3ABC5CC6","present":true}] |
| 8 | 7. customizations.xml has five PM0 card Workflow definitions | PASS | customizations.xml | [{"action":"PM0_PA_Card_AtualizarStatus","guid":"1721E0A3-A250-F111-BEC7-000D3ABC5CC6","present":true},{"action":"PM0_PA_Card_AtualizarTarefa","guid":"7C6300C2-A250-F111-BEC7-000D3ABC5CC6","present":true},{"action":"PM0_PA_Card_ResumoExecutivoPortfolio","guid":"8333BD91-A250-F111-BEC7-000D3ABC5CC6","present":true},{"action":"PM0_PA_Card_CriarTarefa","guid":"7F662DB7-A250-F111-BEC7-000D3ABC5CC6","present":true},{"action":"PM0_PA_Card_ListarTarefas","guid":"E0E3C6B0-A250-F111-BEC7-000D3ABC5CC6","present":true}] |
| 9 | 8. botcomponent_workflowset.xml has five PM0 card links plus all 3.17 baseline leaf entries | PASS | Assets/botcomponent_workflowset.xml | pm0Links=5; missingLiveLeafEntries=0 |
| 10 | 9. solution.xml Version equals 3.18.0.0 | PASS | solution.xml | Observed Version=3.18.0.0 |
| 11 | 10. solution.xml Managed equals 0 | PASS | solution.xml | Observed Managed=0 |

## Prescribed Diff Surface

- Total package-vs-3.17 leaf diffs: 24
- Unexplained leaf diffs: 0
- Allowed surfaces: root XML reconciliation, five PM0 workflow JSONs, PM0 card action/topic binding files, and PMO_PA_CriarProjeto Embedded-mode restore required by P24.

## Diff Inventory

| Status | Allowed | Path |
|---|---|---|
| MODIFIED | True | Assets/botcomponent_workflowset.xml |
| ADDED | True | Workflows/PM0_PA_Card_CriarTarefa-7F662DB7-A250-F111-BEC7-000D3ABC5CC6.json |
| ADDED | True | Workflows/PM0_PA_Card_AtualizarTarefa-7C6300C2-A250-F111-BEC7-000D3ABC5CC6.json |
| ADDED | True | Workflows/PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json |
| MODIFIED | True | solution.xml |
| MODIFIED | True | customizations.xml |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.topic.ListarTarefas/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.topic.ConsultarPortfolio/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.topic.AtualizarStatus/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio/botcomponent.xml |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas/botcomponent.xml |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa/botcomponent.xml |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa/botcomponent.xml |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus/data |
| MODIFIED | True | botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus/botcomponent.xml |
| ADDED | True | Workflows/PM0_PA_Card_ListarTarefas-E0E3C6B0-A250-F111-BEC7-000D3ABC5CC6.json |
| ADDED | True | Workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333BD91-A250-F111-BEC7-000D3ABC5CC6.json |
