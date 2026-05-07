# MASTER CHECKLIST

Status: READY FOR MANUAL TESTING; NO-SHIP UNTIL MANUAL EVIDENCE IS GREEN

Scope: PMO_v11_Tarefas solution in ColOfertasBrasilPro, with Assistente PMO Clean and six PMO_PA_* flows.

## Gates

| Gate | Status | Evidence |
|---|---|---|
| Known stop-ship fixes implemented | PASS | Latest fixed ZIP: `.planning/canonical/PMO_v11_Tarefas_STOPSHIP_FIX_ALL_20260506_0819.zip`. |
| Fixed ZIP imported to target | PASS | Import log: `.planning/canonical/import_stopship_fix_all_0819_20260506_082924.txt`; connected to `ColOfertasBrasilPro`, imported successfully, published customizations. |
| Post-import export structurally verified | PASS | `.planning/canonical/PMO_v11_Tarefas_POST_STOPSHIP_0819_IMPORT_20260506_083136`; `tests/Test-PMOFlowStopShipAudit.ps1` passed 27 checks with 0 failures. |
| CriarTarefa definition verified | PASS | `tests/Test-CriarTarefaFlowDefinition.ps1` passed 9 checks with 0 failures against the post-import export. |
| SharePoint provisioning script parses | PASS | `deploy/SP_Provisioning.ps1` parsed successfully as PowerShell. |
| Flow activation state validated live | PASS | `pac org fetch` in `ColOfertasBrasilPro` returned all six PMO flows `Activado`. |
| All flows manually verified | PENDING | Execute T-001 through T-006 in `.planning/stop_ship/OPUS_MANUAL_TEST_REPORT.md`. |
| Copilot tested end-to-end live | PENDING | Execute T-007 only after all six direct flow tests are green. |
| Release readiness | NO-SHIP | Manual runtime evidence is still required before SHIP. |

## Current Work Items

| ID | Item | Status |
|---|---|---|
| WI-001 | Reproduce and document PMO_PA_CriarTarefa expression failures | COMPLETE |
| WI-002 | Harden PMO_PA_CriarTarefa duplicate lookup filter | COMPLETE, IMPORTED |
| WI-003 | Review and harden PMO_PA_ListarTarefas | COMPLETE, IMPORTED |
| WI-004 | Review and harden PMO_PA_AtualizarTarefa | COMPLETE, IMPORTED |
| WI-005 | Review and harden PMO_PA_CheckInOnDemand | COMPLETE, IMPORTED |
| WI-006 | Review and harden PMO_PA_RegistrarDecisaoBoard | COMPLETE, IMPORTED |
| WI-007 | Review and harden PMO_PA_EscalarRiscoCritico | COMPLETE, IMPORTED |
