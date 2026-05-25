# SP_LIST_GAP_TABLE

Agent name: Codex #2 Lead
Timestamp BRT: 2026-05-24 02:48:19 BRT
Screenshot path: .planning\comms\codex_pm0_remediation_20260522\CODEX2\RCA_3_19_ATUALIZARSTATUS\evidence\20260524_054819_Codex2Lead_status_diario_required_gap_table.png

Source evidence: 
.planning\comms\codex_pm0_remediation_20260522\CODEX2\RCA_3_19_ATUALIZARSTATUS\evidence\20260524_054119_Codex2Lead_create_statusdiario_source_3_19.json
Schema evidence: 
.planning\comms\codex_pm0_remediation_20260522\CODEX2\RCA_3_19_ATUALIZARSTATUS\evidence\20260524_054740_Codex2Lead_status_diario_field_schema.json

| Required field | Type | Sent by 3.19 workflow? | Sent key(s) | Gap |
|---|---|---:|---|---:|
| Title | Text | True | item/Title | False |
| StatusID | Text | False |  | True |
| ProjectID | Text | True | item/ProjectID | False |
| DataRegistro | DateTime | True | item/DataRegistro | False |
| RAG | Choice | True | item/RAG/Value | False |
| Resumo | Note | True | item/Resumo | False |
| OrigemEntrada | Choice | True | item/OrigemEntrada/Value | False |

Conclusion: only `StatusID` is required by SharePoint and missing from `Create_StatusDiario` in 3.19. The SharePoint system `Title` field is required and is sent as `item/Title`.

Evidence triplet:
- 
.planning\comms\codex_pm0_remediation_20260522\CODEX2\RCA_3_19_ATUALIZARSTATUS\evidence\20260524_054819_Codex2Lead_status_diario_required_gap_table.txt
- 
.planning\comms\codex_pm0_remediation_20260522\CODEX2\RCA_3_19_ATUALIZARSTATUS\evidence\20260524_054819_Codex2Lead_status_diario_required_gap_table.json
- 
.planning\comms\codex_pm0_remediation_20260522\CODEX2\RCA_3_19_ATUALIZARSTATUS\evidence\20260524_054819_Codex2Lead_status_diario_required_gap_table.png
