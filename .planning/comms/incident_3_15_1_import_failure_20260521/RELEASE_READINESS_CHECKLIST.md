# RELEASE_READINESS_CHECKLIST — 3.15.1 Hotfix (v3 — Replan Approved)

## Decision: **NO-SHIP** (replan path approved; awaiting Owner UI execution to produce new ZIP)

> v3 update: Topology Cenário 1 confirmed. D-1=Option A. D-2 accepted (workflow re-import per Microsoft docs).

| # | Gate | Status | Evidence | Owner |
|---|---|---|---|---|
| G-01 | RCA + recurrence guard complete | ✅ PASS | `ISSUE_RCA_PACK.md` + `CODEX_PHD_ANALYSIS.md`; guard `Test-SolutionXmlSchemaValidity.ps1` self-tests PASS | Kiro/Codex |
| G-02 | All tests green in CI | ⚠️ N/A | Owner-excluded per CURRENT_BASELINE | — |
| G-03 | Zero high/critical security findings | ✅ PASS | No security findings | — |
| G-04 | Performance not regressed | ⚠️ N/A | No perf change in scope | — |
| G-05 | Backward compatibility validated | ✅ PASS | Tenant forensic confirms 12 workflows active + 5 topics intact | Codex |
| G-06 | Rollback plan documented and tested | ⚠️ NOT NEEDED current | Tenant auto-rolled-back. `rollback_ready.ps1` staged for future attempt | — |
| G-07 | RCA package complete | ✅ PASS | `ISSUE_RCA_PACK.md` + `CODEX_PHD_ANALYSIS.md` + `TOPOLOGY_MAP.md` | Kiro/Codex |
| G-08 | Tenant runtime evidence current | ✅ PASS | Codex `FORENSIC_TENANT_STATE.md` (PAC FetchXML 2026-05-21) | Codex |
| G-09 | Replan path = official Microsoft tooling | ✅ PASS | Option A approved; method documented at https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export | Owner |
| G-10 | Schema-validity audit gate added | ✅ PASS | `tests/Test-SolutionXmlSchemaValidity.ps1` + fixtures + base/hotfix verification | Codex |
| G-11 | Workflow scope acceptance for replan | ✅ PASS | Owner accepted Microsoft-documented re-import behavior; mitigations: schema guard, `pac solution check`, drift monitor T+5/+1h/+6h | Owner |
| G-12 | Failed ZIP quarantined | ✅ PASS | `PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` flagged DO NOT IMPORT | Kiro |
| G-13 (NEW) | Topology mapped | ✅ PASS | `TOPOLOGY_MAP.md` Cenário 1 confirmed | Codex |
| G-14 (NEW) | New ZIP from Copilot Studio export | ⏳ PENDING | Owner steps 1–2 | Owner |
| G-15 (NEW) | New ZIP passes schema guard + `pac solution check` | ⏳ PENDING | Codex step 3 (depends on G-14) | Codex |
| G-16 (NEW) | New ZIP byte-diff confirms surgical scope | ⏳ PENDING | Codex step 3 (depends on G-14) | Codex |
| G-17 (NEW) | Post-import drift monitor T+5/+1h/+6h all PASS | ⏳ PENDING | Codex step 5 (depends on Owner step 4) | Codex |
| G-18 (NEW) | AQ-09 smoke + evidence validator clean | ⏳ PENDING | Owner+Codex step 6 (depends on G-17) | Owner+Codex |

## Blocking items (NO-SHIP)
- **G-14 PENDING** → Owner edits 5 topics in Copilot Studio + exports new ZIP
- **G-15, G-16, G-17, G-18** all chain off G-14

## Rollback plan (refresher)
- `rollback_ready.ps1` staged at `.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/rollback_ready.ps1`
- Rollback ZIP SHA256 verified
- Recovery time estimate: <5 min start, 15 min full
- **Trigger conditions:** any FAIL on G-15, G-16, G-17, or G-18 → consider rollback per Owner decision

## Quarantine
- ❌ `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` — DO NOT RE-IMPORT EVER. Hand-crafted schema violation. Evidence E-002.
- ✅ `tests/Test-SolutionXmlSchemaValidity.ps1` will block any future hand-crafted ZIP at audit phase.

## Authorization status
- ✅ Phase A approval (4 leads + 10 subagents): SPENT
- ✅ Codex forensic + topology missions: COMPLETE
- ✅ D-1 (replan path) decided: Option A
- ✅ D-2 (workflow re-import) accepted: per Microsoft docs
- ⏳ Owner steps 1–2 (Copilot Studio UI work): PENDING
- ⏳ Owner step 4 (PAC import): PENDING explicit approval at that time
- ⏳ Codex steps 3, 5, 6: PENDING dispatch (prepared)

## Sign-off
- **Status reviewed by:** Kiro / Opus 4.7 (Incident Commander)
- **UTC v3:** 2026-05-21T20:25:00Z
- **Decision:** NO-SHIP. Path: Owner step 1 → Owner step 2 → Codex step 3 → Owner step 4 → Codex step 5 → Owner+Codex step 6 → Final SHIP/NO-SHIP at G-18.
