# T0 Live Tenant 3.17 Forensic Diff

| Field | Value |
|---|---|
| Agent | Codex #2 Lead |
| Timestamp | 2026-05-23 18:14:29 BRT |
| Source mode | Owner admin-center exports, validation bypass per Kiro redirect |
| Tenant write commands | None |
| PMO live Managed flag | 0 |
| Verdict | VERDICT_SUBSTANTIVE |

## Executive Summary

VERDICT_SUBSTANTIVE: Live tenant 3.17 contains substantive content deltas versus 3.15.1 in files touched by the 3.16 fix. The 3.18 package must reconcile those files before Gate 4A. PMO live Managed flag is 0.

## Input SHA256 Record
| Artifact | Path | SHA256 | Bytes |
|---|---|---|---:|
| owner_pmo_source | C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_3_17.zip | 648B8484ADC3E3A690A3FBC4D51B0E6854E5341BDB75E62E0DA4FC3B5F2ED253 | 71807 |
| owner_aq07_source | C:\Users\dataops-lab\Downloads\PMO_AQ07_CopilotBinding_1_0_0_2.zip | 118DFCAA4BBE78D190D3314D7789B699090B31D8634105BDE527C9E7158ECA37 | 76817 |
| working_pmo_live | .planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\forensic_diff\live_3_17_export.zip | 648B8484ADC3E3A690A3FBC4D51B0E6854E5341BDB75E62E0DA4FC3B5F2ED253 | 71807 |
| working_aq07_live | .planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\forensic_diff\live_aq07_1_0_0_2_export.zip | 118DFCAA4BBE78D190D3314D7789B699090B31D8634105BDE527C9E7158ECA37 | 76817 |
| pmo_3_15_1_baseline | Solution\PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip | 661606EDB9E92A2D0B9606A91831D0F93079D6F76BC5368DF1C342FB595E7403 | 65951 |
| pmo_3_16_fix | .planning\comms\codex_pm0_remediation_20260522\CODEX2\PACKAGE\package\PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip | 3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB | 81627 |

## Quantitative Summary - PMO 3.17 vs 3.15.1
| Category | Added | Removed | Modified | Unchanged |
|---|---:|---:|---:|---:|
| Assets | 0 | 0 | 1 | 0 |
| botcomponents | 12 | 0 | 10 | 32 |
| bots | 0 | 0 | 1 | 1 |
| root | 0 | 0 | 3 | 0 |
| Workflows | 0 | 0 | 2 | 10 |

## File-Level Conflict Findings
| File | Classification | Live delta | Fix delta |
|---|---|---|---|
| Assets/botcomponent_workflowset.xml | SUBSTANTIVE | MODIFIED | MODIFIED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus/botcomponent.xml | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus/data | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa/botcomponent.xml | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa/data | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa/botcomponent.xml | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa/data | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas/botcomponent.xml | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas/data | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio/botcomponent.xml | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio/data | SUBSTANTIVE | ADDED | ADDED |
| botcomponents/pmo_AssistentePMO_V2.topic.AtualizarStatus/data | SUBSTANTIVE | MODIFIED | MODIFIED |
| botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data | SUBSTANTIVE | MODIFIED | MODIFIED |
| botcomponents/pmo_AssistentePMO_V2.topic.ConsultarPortfolio/data | SUBSTANTIVE | MODIFIED | MODIFIED |
| botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa/data | SUBSTANTIVE | MODIFIED | MODIFIED |
| botcomponents/pmo_AssistentePMO_V2.topic.ListarTarefas/data | SUBSTANTIVE | MODIFIED | MODIFIED |
| customizations.xml | SUBSTANTIVE | MODIFIED | MODIFIED |
| solution.xml | SUBSTANTIVE | MODIFIED | MODIFIED |
| Workflows/PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json | SUBSTANTIVE | MISSING_IN_DIFF | ADDED |
| Workflows/PM0_PA_Card_AtualizarTarefa-7C6300C2-A250-F111-BEC7-000D3ABC5CC6.json | SUBSTANTIVE | MISSING_IN_DIFF | ADDED |
| Workflows/PM0_PA_Card_CriarTarefa-7F662DB7-A250-F111-BEC7-000D3ABC5CC6.json | SUBSTANTIVE | MISSING_IN_DIFF | ADDED |
| Workflows/PM0_PA_Card_ListarTarefas-E0E3C6B0-A250-F111-BEC7-000D3ABC5CC6.json | SUBSTANTIVE | MISSING_IN_DIFF | ADDED |
| Workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333BD91-A250-F111-BEC7-000D3ABC5CC6.json | SUBSTANTIVE | MISSING_IN_DIFF | ADDED |

## AQ07 Forensics
AQ07 1.0.0.1 local baseline not found on disk; gap logged as non-blocking per redirect. Owner AQ07 1.0.0.2 file was copied and hashed.

## Recommended Next Action

Rebuild 3.18 must reconcile live 3.17 content deltas before import.

Managed=false note: live Owner PMO snapshot is unmanaged-compatible for the expected 3.18 re-version path.

## Evidence Index
| Artifact | Path |
|---|---|
| diff_3_17_vs_3_15_1.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/diff_3_17_vs_3_15_1.json |
| diff_3_17_vs_3_15_1.md | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/diff_3_17_vs_3_15_1.md |
| conflict_analysis_3_16_fix_vs_3_17.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/conflict_analysis_3_16_fix_vs_3_17.json |
| conflict_analysis_3_16_fix_vs_3_17.md | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/conflict_analysis_3_16_fix_vs_3_17.md |
| diff_aq07_1_0_0_2_vs_1_0_0_1.json | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/diff_aq07_1_0_0_2_vs_1_0_0_1.json |
| diff_aq07_1_0_0_2_vs_1_0_0_1.md | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/diff_aq07_1_0_0_2_vs_1_0_0_1.md |
