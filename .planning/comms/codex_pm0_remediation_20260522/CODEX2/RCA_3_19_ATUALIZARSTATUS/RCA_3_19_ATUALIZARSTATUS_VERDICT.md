# RCA_3_19_ATUALIZARSTATUS_VERDICT

Agent name: Codex #2 Lead
Timestamp BRT: 2026-05-24 02:55:01 BRT
Screenshot path: .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/screenshots/20260524_055351_Codex2Lead_rca_verdict_complete.png

## Executive Verdict

H1 = CONFIRMED. The 3.19 activation failure is caused by missing item/StatusID in Create_StatusDiario for SharePoint PostItem.

## Hypothesis Table

| Hypothesis | Status | Evidence |
|---|---|---|
| H1: missing item/StatusID is exact cause | CONFIRMED | Import log states PostItem missing required property item/StatusID; 3.19 source lacks it; PnP schema requires it; gap table shows it is the only missing required field. Evidence: .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054119_Codex2Lead_create_statusdiario_source_3_19.{txt,json,png}, .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054740_Codex2Lead_status_diario_field_schema.{txt,json,png}, .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054819_Codex2Lead_status_diario_required_gap_table.{txt,json,png}. |
| H2: other required Status Diario properties are missing | REFUTED | PnP required fields are Title, StatusID, ProjectID, DataRegistro, RAG, Resumo, OrigemEntrada; all except StatusID are sent by workflow. Evidence: SP_LIST_GAP_TABLE.md. |
| H3: tenant list evolved after last write | REFUTED | Current PnP schema matches documented custom required fields in docs/SCHEMA_SHAREPOINT_PMO.md; StatusID was already documented required before 3.19. Evidence: schema triplet plus mandatory reading hash log. |
| H4: connectionName/OpenAPI metadata corruption is root cause | REFUTED | Dataverse export normalization stripped some embedded connectionName values and added templateName: null, but the nested activation error names the missing item/StatusID; other PM0 flows activated. Evidence: prior 3.19 import deep dive and source-vs-tenant diff, plus Learn citations. |
| H5: defect also existed in 3.18 | CONFIRMED | 3.18 Create_StatusDiario exists and also lacks item/StatusID; 3.18 first failed earlier on OrigemEntrada string-vs-object, so missing StatusID was latent until 3.19 fixed OrigemEntrada/Value. Evidence: CHRONOLOGICAL_DIFF.md and prior 3.18 import log. |

## Root Cause Statement

PM0_PA_Card_AtualizarStatus 3.19 defines SharePoint Create_StatusDiario as operation PostItem against list Status Diario, but its inputs.parameters omit item/StatusID. The live SharePoint list requires StatusID. Power Automate rejects the OpenAPI action at save/activation time with InvalidOpenApiFlow / OpenApiOperationParameterValidationFailed, leaving the flow in draft state and surfacing Dataverse/import error 0x80040216.

## Required Property Gap Table

See SP_LIST_GAP_TABLE.md. Missing required count is 1: StatusID.

## Chronological Diff Summary

See CHRONOLOGICAL_DIFF.md. Versions 3.10, 3.15.1, and live 3.17 do not contain Create_StatusDiario. Versions 3.18 and 3.19 contain it and both omit item/StatusID.

## Microsoft Learn Citations

- https://learn.microsoft.com/en-us/project-for-the-web/deploy-project-for-web-accelerator-power-bi-template - documents solution deployment failure where component activation fails because flow save failed with OpenApiOperationParameterValidationFailed and a missing required property.
- https://learn.microsoft.com/en-us/connectors/sharepointonline/ - SharePoint connector reference lists Create item, operation ID PostItem, with required dataset, table, and dynamic item parameter.
- https://learn.microsoft.com/en-us/power-automate/error-reference - Power Automate reference says missing required fields in request body are a BadRequest connector/API validation cause, and FlowCheckerError includes required fields empty.
- https://learn.microsoft.com/en-us/power-apps/maker/data-platform/create-edit-virtual-entities - confirms 0x80040216 can appear as an activation-time Dataverse wrapper code; in this RCA, the nested InvalidOpenApiFlow message provides the precise cause.

## Local Reproduction Result

pac solution unpack succeeded locally with PAC 2.6.4. PAC 2.6.4 has no flow command, so no offline pac flow validate runner is available. No sandbox runner was found and no import or tenant write was attempted. Evidence: .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055110_Codex2Lead_local_validation_attempt_pac_explicit_corrected.{txt,json,png}.

## Proposed 3.20 Fix Scope

Proceed with a minimal workflow patch adding item/StatusID; no other SharePoint required fields need to be added. See REMEDIATION.md.

## Risk For Gate 4B

BLOCK current 3.19. Proceed only after 3.20 candidate is built, statically validated, Owner-authorized for import, and post-import evidence shows AtualizarStatus activated with zero 0x80040216 rows.

## Evidence Index

| Artifact | TXT | JSON | PNG |
|---|---|---|---|
| 20260524_053819_Codex2Lead_mandatory_reading_initial | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_053819_Codex2Lead_mandatory_reading_initial.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_053819_Codex2Lead_mandatory_reading_initial.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_053819_Codex2Lead_mandatory_reading_initial.png |
| 20260524_054119_Codex2Lead_create_statusdiario_source_3_19 | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054119_Codex2Lead_create_statusdiario_source_3_19.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054119_Codex2Lead_create_statusdiario_source_3_19.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054119_Codex2Lead_create_statusdiario_source_3_19.png |
| 20260524_054222_Codex2Lead_create_statusdiario_chronological_diff | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054222_Codex2Lead_create_statusdiario_chronological_diff.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054222_Codex2Lead_create_statusdiario_chronological_diff.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054222_Codex2Lead_create_statusdiario_chronological_diff.png |
| 20260524_054255_Codex2Lead_status_diario_field_schema | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054255_Codex2Lead_status_diario_field_schema.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054255_Codex2Lead_status_diario_field_schema.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054255_Codex2Lead_status_diario_field_schema.png |
| 20260524_054455_Codex2Lead_status_diario_field_schema_complete | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054455_Codex2Lead_status_diario_field_schema_complete.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054455_Codex2Lead_status_diario_field_schema_complete.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054455_Codex2Lead_status_diario_field_schema_complete.png |
| 20260524_054740_Codex2Lead_status_diario_field_schema | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054740_Codex2Lead_status_diario_field_schema.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054740_Codex2Lead_status_diario_field_schema.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054740_Codex2Lead_status_diario_field_schema.png |
| 20260524_054819_Codex2Lead_status_diario_required_gap_table | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054819_Codex2Lead_status_diario_required_gap_table.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054819_Codex2Lead_status_diario_required_gap_table.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_054819_Codex2Lead_status_diario_required_gap_table.png |
| 20260524_055007_Codex2Lead_local_validation_attempt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055007_Codex2Lead_local_validation_attempt.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055007_Codex2Lead_local_validation_attempt.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055007_Codex2Lead_local_validation_attempt.png |
| 20260524_055031_Codex2Lead_local_validation_attempt_pac_explicit | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055031_Codex2Lead_local_validation_attempt_pac_explicit.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055031_Codex2Lead_local_validation_attempt_pac_explicit.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055031_Codex2Lead_local_validation_attempt_pac_explicit.png |
| 20260524_055110_Codex2Lead_local_validation_attempt_pac_explicit_corrected | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055110_Codex2Lead_local_validation_attempt_pac_explicit_corrected.txt | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055110_Codex2Lead_local_validation_attempt_pac_explicit_corrected.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/evidence/20260524_055110_Codex2Lead_local_validation_attempt_pac_explicit_corrected.png |

## Learn Snapshot Index

See CITATION_INDEX.md and learn_citations/.
