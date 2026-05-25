# REMEDIATION

Agent name: Codex #2 Lead
Timestamp BRT: 2026-05-24 02:55:01 BRT
Screenshot path: .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/screenshots/20260524_055351_Codex2Lead_rca_verdict_complete.png

## Minimal 3.20 Patch Scope

Add only item/StatusID to Create_StatusDiario.inputs.parameters in PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json.

The proposed value is deterministic enough for a status-history row and does not require a tenant read:

~~~diff
--- a/Workflows/PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json
+++ b/Workflows/PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json
@@ -156,6 +156,7 @@
               "dataset": "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
               "table": "Status Diario",
               "item/Title": "@concat('Status ', triggerBody()?['projectId'], ' ', utcNow())",
+              "item/StatusID": "@concat('STATUS-', triggerBody()?['projectId'], '-', formatDateTime(utcNow(), 'yyyyMMddHHmmssfff'))",
               "item/ProjectID": "@triggerBody()?['projectId']",
               "item/DataRegistro": "@utcNow()",
               "item/RAG/Value": "@triggerBody()?['rag']",
~~~

## Other Required Fields

No other required SharePoint fields are missing in 3.19. Required fields from PnP are Title, StatusID, ProjectID, DataRegistro, RAG, Resumo, and OrigemEntrada. The workflow sends all except StatusID; see SP_LIST_GAP_TABLE.md.

## Regression Tests Before 3.20 Candidate

- Parse all workflow JSON files.
- Re-run PM0 contract verifier for topic/action/workflow bindings.
- Re-run PM0 response semantics verifier.
- Re-run stop-ship workflow audit.
- Re-run package P24 contract verifier with expected version 3.20.0.0.
- Re-run the Status Diario required-field gap check against the 3.20 source.
- Re-run source-vs-package and package-vs-previous diff, with the only intended AtualizarStatus action delta being item/StatusID.
- After Owner-authorized import only: verify import log has zero 0x80040216 rows and PM0_PA_Card_AtualizarStatus is Activated/Started.

## Effort Estimate

Expected effort is small: one workflow JSON line, package version bump, rebuild, and the existing static-gate suite. Comparable package cycle: 3.19 package SHA 43A33783ABC30E7A3DC74EAED162558FBA0781AC163804F85FDC559023D514BF, completed 2026-05-23 21:34:51 BRT and peer-reviewed 2026-05-23 21:46:03 BRT.

Do not build or import 3.20 under this RCA mission.
