# RELEASE READINESS CHECKLIST

Decision: IMPORTED, but NO-SHIP until the Opus manual runbook passes in `ColOfertasBrasilPro`.

| Gate | Status | Evidence |
|---|---|---|
| Critical issues reproduced | PARTIAL | ISSUE-001 and ISSUE-002 reproduced by screenshots; additional risks found by source audit. |
| Critical fixes complete locally | YES | `.planning/canonical/PMO_v11_Tarefas_STOPSHIP_FIX_ALL_20260506.zip`; `tests/Test-PMOFlowStopShipAudit.ps1` green. |
| Fixed ZIP pack/unpack validated | YES | `pac solution pack` and `pac solution unpack` completed successfully. |
| Fixed ZIP imported to target environment | YES | Latest import: `.planning/canonical/PMO_v11_Tarefas_STOPSHIP_FIX_ALL_20260506_0819.zip`; `Solution Imported successfully`; `Published All Customizations`. |
| Post-import export validated | YES | `.planning/canonical/PMO_v11_Tarefas_POST_STOPSHIP_0819_IMPORT_20260506_083136.zip`; 27-check expanded audit green. |
| Flow activation state validated | YES | `pac org fetch` returned all six PMO flows `Activado`. |
| All flows direct-tested live | NO | Must execute Opus runbook after importing the fixed ZIP. |
| Copilot tested end-to-end live | NO | Must test after all six flow runs are green. |
| CI parity / automated harness | PARTIAL | Local structural tests exist; Power Automate cloud runtime still requires manual execution evidence. |
| SharePoint schema validated live | NO | Must confirm lists/columns in target SharePoint site, especially `Tarefas` and required `Projetos.PM`. |
| Security/permissions validated | NO | Teams/SharePoint/Outlook connectors require manual validation. |
| Rollback plan documented | YES | See rollback plan below. |

## Rollback Plan

1. Before importing the fixed ZIP, export the current `PMO_v11_Tarefas` solution from `ColOfertasBrasilPro`.
2. Keep the new export under `.planning/canonical/` with timestamped name.
3. Import `.planning/canonical/PMO_v11_Tarefas_STOPSHIP_FIX_ALL_20260506.zip` as unmanaged.
4. If a fix regresses, reimport the previous export and publish all customizations.
5. Republish `Assistente PMO Clean`.
6. Retest the previously green flow before continuing.

## Manual Release Gate

Use `.planning/stop_ship/OPUS_MANUAL_TEST_REPORT.md`.

Release can move from NO-SHIP to SHIP only after every listed manual test has a green run URL or screenshot evidence.
