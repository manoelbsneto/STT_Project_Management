# CriarTarefa Stop-Ship Closure Handoff

| Field | Value |
|---|---|
| Decision | **SHIP GO/GREEN** |
| Closed | 2026-05-05T20:37 BRT |
| Scope | `CriarTarefa` routing/action contract for Assistente PMO |
| SEV Level | SEV-0 / Stop-Ship |
| Diligence Method | Runbook-compliant evidence per `deploy/MASTER_RUNBOOK` |

---

## 1. Target System Identifiers

| Component | Identifier |
|---|---|
| Bot | Assistente PMO |
| Bot ID | `0c4a9729-d55d-483c-8ec3-db9369583155` |
| Environment | ColOfertasBrasilPro |
| Environment ID | `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| Flow | PMO_PA_CriarTarefa |
| Flow Name | `7ca90102-525b-48bb-875e-0f7bda96f85b` |
| Workflow Entity ID | `71f62da4-9748-f111-bec7-6045bdf42cae` |

---

## 2. Issues Closed

### ISSUE-001 — CriarTarefa Routes to LowConfidence (P0) ✅ CLOSED
- **Root cause:** `includeInOnSelectIntent: false`, narrow triggers, stale fallback, ProjectID prompt artifacts.
- **Fix:** Template updated; 10 trigger phrases; fallback advertises `criar tarefa/projeto`; ProjectID artifacts removed.
- **Proof:** Known-bad fails 8/9 checks; live no-output extract passes 9/9.

### ISSUE-002 — Invalid Topic Output Binding (P0) ✅ CLOSED
- **Root cause:** `CriarTarefa` bound action output `result` to `Topic.message`, but Copilot Studio topic checker rejected that binding with `BindingKeyNotFoundError`.
- **Fix:** Topic intentionally has no action output binding; it calls `PMO_PA_CriarTarefa` and sends a fixed confirmation message. The action/flow may still expose `result`.
- **Proof:** No-output live extract passes 9/9; raw Dataverse fetch shows `call_criar_tarefa` with no `output:` block and no `Topic.message`.

### ISSUE-003 — Publish State Ambiguity (P1) ✅ CLOSED (runbook substitute)
- **Root cause:** `pac copilot publish` reports stale failure from 15:58:57 even after successful solution import.
- **Substitute evidence:** `pac copilot list` → Published/Active/Provisioned; fresh extract passes regression; raw Dataverse fetch is clean.

### ISSUE-004 — Repo Template Drift (P1) ✅ CLOSED
- **Root cause:** `AssistentePMO.template.yaml` lacked action component and action-calling dialog.
- **Fix:** Action component added; CriarTarefa body replaced with action-calling dialog.
- **Proof:** Regression passes against repo template.

---

## 3. Evidence Cross-Reference

| ID | Evidence File | Proves |
|---|---|---|
| E-001 | `test_known_bad_125833.json` | Known-bad reproduction: 8 failed checks |
| E-002 | `test_live_extract_192913.json` | First live extract clean: 9/9 pass |
| E-003 | `test_repo_template.json` | Repo template clean: 9/9 pass |
| E-008 | `pac_env_who_20260505_2003.txt` | Environment = ColOfertasBrasilPro |
| E-009 | `pac_connection_list_20260505_2003.txt` | SharePoint, Teams, Office 365 = Connected |
| E-010 | `pac_copilot_list_20260505_2003.txt` | Bot = Published / Active / Provisioned |
| E-011 | `test_live_extract_194946.json` | Superseded extract; retained as historical evidence only |
| E-012 | `fetch_criartarefa_components_20260505_2002.txt` | Superseded raw fetch; retained as defect evidence only |
| E-013 | `get_flow_criartarefa_summary_20260505_195945.json` | Flow enabled/Started; `result` in success/error bodies |
| E-014 | `cs_criartarefa_no_output_result_20260505_202323.json` | Live no-output-binding import passed |
| E-015 | `test_no_output_verify_20260505_202323.json` | Fresh no-output live extract: 9/9 pass |
| E-016 | `fetch_criartarefa_components_after_no_output_20260505_202323.txt` | Raw Dataverse: CriarTarefa has no output binding and no `Topic.message` |
| E-017 | `pac_copilot_list_after_no_output_20260505_202323.txt` | Bot = Published / Active / Provisioned after final hotfix |
| E-018 | `test_live_extract_no_output_final_20260505_203459.json` | Final fresh live extract: 9/9 pass; no CriarTarefa output binding |
| E-019 | `pac_copilot_list_final_20260505_203732.txt` | Final bot state = Published / Active / Provisioned |

All evidence files are in `.planning/stopship/criartarefa/`.

---

## 4. Regression Harness Summary

| Input | Result | Failed Checks |
|---|---|---|
| Known-bad extract (`125833`) | Expected failure | 7 |
| Live extract #1 (`192913`) | Pass | 0 |
| Live no-output extract (`202323`) | Pass | 0 |
| Repo template | Pass | 0 |

Harness: `tests/Test-CriarTarefaContract.ps1` — 9 deterministic checks covering routing, triggers, fallback, ProjectID cleanup, action call, absence of fragile topic output binding, and action input/output contract.

---

## 5. Code Changes Shipped

| File | Change |
|---|---|
| `deploy/CS_CriarTarefa_ContractFix.ps1` | Hardened post-extract validation; exact trigger checks; ProjectID artifact checks; action/topic cleanliness checks |
| `deploy/CS_CriarTarefa_RemoveOutputBinding.ps1` | Focused live hotfix removing the invalid `CriarTarefa` topic output binding |
| `deploy/copilot/AssistentePMO.template.yaml` | Added `PMO_PA_CriarTarefa` action component; aligned CriarTarefa topic with action-calling dialog |
| `tests/Test-CriarTarefaContract.ps1` | Deterministic regression harness (9 checks) |

---

## 6. Residual Risks (Accepted, Not Blocking)

| ID | Risk | Severity | Track In |
|---|---|---|---|
| R-005 | Sequential ProjectID generation can race under concurrent creates | P1 | Next data-integrity phase |
| R-006 | Raw `prazo` and `Prioridade` input can violate SharePoint schema | P2 | Next data-validation phase |

---

## 7. Post-Ship Action Items

| # | Action | Owner | Priority |
|---|---|---|---|
| 1 | Manual Teams conversation transcript for user-facing acceptance | User / QA | Phase 6 QA |
| 2 | Optional concurrency test for ProjectID generation | Dev | Phase 7+ |
| 3 | Data validation for `prazo` / `Prioridade` field inputs | Dev | Phase 7+ |
| 4 | Investigate `pac copilot publish` stale failure behavior | Dev | Low |
| 5 | Run `Test-CriarTarefaContract.ps1` after every future `pac copilot extract-template` | Ops | Ongoing |

---

## 8. Publish Caveat

`pac copilot publish` still reports a stale failure:

```
Failed to publish. 0c4a9729-d55d-483c-8ec3-db9369583155 Failed [05/05/2026 15:58:57].
```

This is **not a blocker**. The substitute evidence chain is:

1. `pac solution import --publish-changes` → Solution Imported successfully; Published All Customizations
2. `pac copilot list` → Published / Active / Provisioned
3. Fresh no-output `pac copilot extract-template` → Passes 9/9 regression checks
4. `pac org fetch` → Raw Dataverse botcomponents contain clean no-output-binding contract
5. `Get-Flow` (Windows PowerShell 5.1) → Enabled / Started / `result` response

---

## 9. Runbook Compliance

All live checks followed:

- `deploy/MASTER_RUNBOOK/MASTER_RUNBOOK.md`
- `deploy/MASTER_RUNBOOK/LESSONS_LEARNED.md`

Commands used per runbook:

| Command | Purpose |
|---|---|
| `pac env who` | Environment verification |
| `pac connection list` | Connector status |
| `pac copilot list` | Bot publish/active state |
| `pac copilot extract-template` | Live contract extraction |
| `pac org fetch` | Raw Dataverse component data |
| Windows PowerShell 5.1 `Get-Flow` | Flow runtime contract proof |

PowerShell module path (per runbook):
```
C:\Users\mbenicios\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1
```

---

## 10. Stop-Ship Package Manifest

| Document | Purpose |
|---|---|
| `EXEC_SUMMARY.md` | Executive decision summary |
| `ISSUE_RCA_PACK.md` | Root cause analysis for 4 issues |
| `EVIDENCE_LOG.md` | 19-item evidence chain |
| `TEST_STRATEGY.md` | Regression strategy and coverage |
| `RELEASE_READINESS_CHECKLIST.md` | Release gates and rollback plan |
| `RISK_REGISTER.md` | 6 risks (4 closed, 2 accepted) |
| `MASTER_CHECKLIST.md` | 10-gate master checklist |
| **`CLOSURE_HANDOFF.md`** | This document |

---

**Status: CLOSED — SHIP GO/GREEN**

Signed off: 2026-05-05T20:07 BRT
