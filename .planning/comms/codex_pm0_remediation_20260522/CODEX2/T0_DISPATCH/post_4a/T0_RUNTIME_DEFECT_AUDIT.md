# T0 Runtime Defect Audit

- Agent: Codex #2 Lead
- Timestamp: 2026-05-23 21:34:51 BRT
- Screenshot: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/screenshots/20260524_003451_Codex2Lead_3_19_runtime_fix_complete.png
- Scope: 5 PM0_PA_Card workflow JSON files from 3.18 package source
- Tenant writes: none

## Executive Summary

DEFECTS_FOUND. The 3.18 package passed static gates but contained runtime defects in PM0 SharePoint binding and expression semantics. I found and fixed four source defects for 3.19: one Choice field path defect, two numeric empty() defects in AtualizarStatus, and one numeric empty() defect in AtualizarTarefa. Follow-up runtime audit scan on the 3.19 work tree is clean for those defect classes.

## Per-Workflow Verdicts

| Workflow | Verdict | Defect count | Notes |
|---|---|---:|---|
| PM0_PA_Card_AtualizarStatus | DEFECTS_FOUND | 3 | Choice binding plus two numeric empty() expressions |
| PM0_PA_Card_AtualizarTarefa | DEFECTS_FOUND | 1 | Numeric empty() on horasRealizadas |
| PM0_PA_Card_CriarTarefa | CLEAN | 0 | Numeric horas uses coalesce; Choice paths correct |
| PM0_PA_Card_ListarTarefas | CLEAN | 0 | Read-only flow; compose refs valid |
| PM0_PA_Card_ResumoExecutivoPortfolio | CLEAN | 0 | Read-only flow; no write bindings |

## Defect Table

| Workflow | Location | Class | Severity | Current | Fix |
|---|---|---|---|---|---|
| PM0_PA_Card_AtualizarStatus | Create_StatusDiario item/OrigemEntrada | A schema-binding | BLOCKING_ACTIVATION | item/OrigemEntrada = Copilot Studio PM0 card | item/OrigemEntrada/Value = CopilotStudio |
| PM0_PA_Card_AtualizarStatus | Update_SharePoint_Project item/Percentual | B expression type safety | RUNTIME_FAIL | if(empty(triggerBody()?['percentual']), existing, trigger) | coalesce(triggerBody()?['percentual'], existing, 0) |
| PM0_PA_Card_AtualizarStatus | Create_StatusDiario item/Percentual | B expression type safety | RUNTIME_FAIL | if(empty(triggerBody()?['percentual']), 0, trigger) | coalesce(triggerBody()?['percentual'], 0) |
| PM0_PA_Card_AtualizarTarefa | Update_SharePoint_Item item/HorasRealizadas | B expression type safety | RUNTIME_FAIL | if(empty(triggerBody()?['horasRealizadas']), existing, trigger) | coalesce(triggerBody()?['horasRealizadas'], existing, 0) |

## Checks A-E

| Check | Result |
|---|---|
| A SharePoint schema-binding correctness | FAIL in 3.18, PASS after 3.19 patch. Choice fields use /Value; person field uses /Claims; numeric fields are bare. |
| B Expression type safety | FAIL in 3.18, PASS after 3.19 patch. No empty()/length() remains on numeric trigger fields in PM0 card workflows. |
| C Null-safety on optional inputs | PASS after patch for audited writes. Optional numeric writes use coalesce; optional text/choice fields either coalesce or preserve existing value. |
| D GUID/dynamic ID generation | PASS for audited scope. Status write uses dynamic Title with utcNow(); existing PM0 package did not introduce static StatusID/RiskID writes. |
| E Compose action references | PASS. All outputs(...) references resolve to an action/compose in the same workflow. |

## Cross-Workflow Patterns

- Static gates were blind to Power Automate runtime type rules for numeric inputs and SharePoint Choice object paths.
- The repeated pattern is empty(triggerBody()?[numeric]) against trigger schema fields typed as number/integer.
- Choice fields must be bound through item/<ChoiceField>/Value; raw item/<ChoiceField> can import but fail activation/runtime.

## Fix Complexity Estimate

Low. Four deterministic JSON edits plus solution version bump and package rebuild. No tenant write was performed.

## 3.19 Build Result

| Item | Value |
|---|---|
| Package | .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/package/PMO_v11_Tarefas_3_19_PM0_RUNTIME_FIX.zip |
| SHA256 | 43A33783ABC30E7A3DC74EAED162558FBA0781AC163804F85FDC559023D514BF |
| Version | 3.19.0.0 |
| Static gates | 9/9 PASS |
| Runtime audit after patch | PASS |

## Recommendation

Proceed with Codex #1 peer review of 3.19. Keep T2 blocked and do not proceed to Gate 4B until 3.19 is Owner-imported and post-import verification confirms a clean activation/import log and tenant state.

## Evidence Index

- Raw 3.18 runtime audit: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/evidence/runtime_audit_raw.json
- Post-patch runtime audit: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/evidence/runtime_audit_after_patch_raw.json
- Static gate log: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/evidence/static_gates_3_19.log
- Static gate JSON: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/evidence/static_gates_3_19.json
- Package inventory: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/reports/package_inventory.md
- Diff summary: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/reports/diff_3_19_vs_3_18.md
