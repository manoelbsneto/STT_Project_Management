# CODEX #1 (LEAD) — PM0 FIX-AND-SHIP REMEDIATION
## Mission: implement, test, and ship the 5 PM0 card-first flows under mandatory quality gates
## SEV-0 | Run in parallel with Codex #2 | 5 flows, 1 release

**Date:** 2026-05-22 16:02 BRT
**Owner decision:** FIX-AND-SHIP (option a). Containment during fix: leave broken state in tenant (option a). Release scope: all 5 flows in 1 release (option a). Functional DoD approved with mandatory Evidence Triplet.
**Owner:** Manoel Benicio. Sole approver. **Codex (#1 and #2) is the ONLY agent authorized to perform tenant writes.** Kiro is read-only.
**Source of truth:** official Microsoft Learn (`learn.microsoft.com`) only. Memory, blogs, third-party rejected.
**Continuation:** This mission continues from Codex #1's prior audit completed at 2026-05-22 15:41 BRT. RCA, Remediation Plan, Mitigation Plan, Executive Summary already exist at `.planning/comms/codex_pm0_audit_20260522/`. You implement the Remediation Plan now.

---

## 0. NEW MANDATORY RULES (read these first — added today after audit)

`.planning/GOLDEN_RULES.md` was updated at 2026-05-22 15:58 BRT with three rules that govern this mission:

### Continuous Documentation Update Rule
After every action (file read, command, evidence captured, decision, gate transition), update the relevant project doc immediately. Do not batch.

### Evidence Triplet Rule (MANDATORY for every test, deploy, gate, claim of DONE)
Every test, deploy, audit, gate, smoke, and DONE claim MUST include all three:

1. **Screenshot (printscreen)** — visual proof, PNG/JPG saved under evidence folder. Required for Copilot Studio test panel, Teams chat, SharePoint UI, Power Automate run history. CLI cases: terminal screenshot or rendered output, not just text logs.
2. **Timestamp BRT** — exact `YYYY-MM-DD HH:mm:ss BRT` at moment of action.
3. **Agent name** — named agent (Codex Lead, Codex sub-A1, etc.). No anonymous evidence.

Storage: `.planning/comms/codex_pm0_remediation_20260522/<flow>/evidence/<YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}` indexed in per-flow `EVIDENCE_LOG.md`.

If any of the three is missing, the entry is `INCOMPLETE` and cannot be cited as DONE/PASS/PUBLISH.

### Functional Definition of Done Rule
A flow is DONE only when:
1. Real runtime call returns real backend data (not hardcoded placeholder).
2. Runtime evidence captured per Evidence Triplet.
3. Bot end-to-end test reproduces successful outcome with real data in bot reply.
4. Action `.mcs.yml` declares `inputs:` matching workflow trigger schema.
5. Topic `.mcs.yml` `BeginDialog input:` Power Fx mapping passes all required workflow trigger fields.
6. No agent writes DONE/PASS/PUBLISH_GO without conditions 1-5 evidenced.

---

## 1. CONTEXT (continuity from audit)

Read your prior outputs first (already produced by you, Codex #1):

- `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md`
- `.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md`
- `.planning/comms/codex_pm0_audit_20260522/MITIGATION_PLAN.md`
- `.planning/comms/codex_pm0_audit_20260522/EXECUTIVE_SUMMARY.md`
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/AUDIT_TABLE.md`
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A2_actions/AUDIT_TABLE.md`
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A3_topics/AUDIT_TABLE.md`
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md`
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md`

Plus the 20 mandatory project docs you read at audit time. Confirm you re-read updated `.planning/GOLDEN_RULES.md` (note new rules in §0 above).

---

## 2. MISSION SCOPE — FIX-AND-SHIP

Implement the per-defect fixes from your own `REMEDIATION_PLAN.md` for all 5 PM0 flows in parallel, package as a single release, import/publish to `ColOfertasBrasilPro` env, run full AQ-09 runtime smoke (12 scenarios), and ship 3.16 only when all functional gates PASS with full Evidence Triplet on each.

**5 in-scope flows (from prior audit):**

| Topic | Action | Workflow ID |
|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

---

## 3. EXECUTION MODEL — Team Alpha (you) + Team Bravo (Codex #2)

### Team Alpha — Codex #1 Lead
**Three subagents, parallel:**

- **Subagent A1 — Workflow Body Fixer**
  Per workflow: replace hardcoded `result` with dynamic body referencing actual SP/Planner action outputs. Add Adaptive Card post for write-paths where applicable (per `deploy/cards/*.json`). Validate against MS Learn `kind: Skills` Response action shape.

- **Subagent A2 — Action Contract Fixer**
  Per `Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_*.mcs.yml`: add `inputs:` block matching workflow trigger schema (per Codex #2 Bravo B2 MS Learn citations on `kind: TaskDialog`).

- **Subagent A3 — Topic Contract Fixer**
  Per `Local_Repo/Assistente PMO V2/topics/{topic}.mcs.yml`: replace `input: {}` with explicit Power Fx mapping passing all required workflow trigger fields. Where ProjectID resolution is needed (`ListarTarefas` is a known case), add upstream `Get items` lookup that converts project name → ProjectID before flow call.

### Team Bravo — Codex #2 (parallel, separate prompt)
- B1: SP test data prep + AQ-09 runtime smoke executor
- B2: Functional verifier implementation (replaces structural-only verifier)
- B3: Solution package builder + import/publish operator (with owner-approved tenant writes)

Both teams sync via `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md`. No team waits to start.

---

## 4. PER-FLOW DELIVERABLES (Codex #1 Lead must own end-to-end fix)

For each of the 5 flows, produce under `.planning/comms/codex_pm0_remediation_20260522/<flow>/`:

```
<flow>/
├── DEFECT_FIX_REPORT.md          (per defect from REMEDIATION_PLAN: what fixed, file diff, MS Learn cite)
├── workflow_patch.diff            (unified diff of workflow.json changes)
├── action_patch.diff              (unified diff of action.mcs.yml changes)
├── topic_patch.diff               (unified diff of topic.mcs.yml changes)
├── unit_test/                     (local tests proving the patch in isolation)
│   ├── test_workflow_response.ps1   (validates Response body references SP/Planner outputs, not hardcoded)
│   ├── test_action_inputs.ps1       (validates action declares all required inputs)
│   ├── test_topic_input_mapping.ps1 (validates topic BeginDialog input maps all required fields)
│   └── results/
└── evidence/                      (every action triplet-evidenced)
    └── <YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}
```

---

## 5. RELEASE PIPELINE (gates in order, no skips)

### Gate 1 — Local fixes complete
- All 5 `<flow>/DEFECT_FIX_REPORT.md` written, each defect from REMEDIATION_PLAN closed
- All 5 unit tests PASS
- Each PASS evidenced with triplet

### Gate 2 — Functional verifier (Codex #2 owns build, you run)
- Run new `tests/Test-Pm0FunctionalContract.ps1` (Codex #2 builds it under §3.B2)
- Must check: workflow Response body references SP/Planner outputs (not hardcoded), action declares inputs, topic input mapping covers required fields
- All 5 flows must PASS the functional verifier
- Triplet evidence for each PASS

### Gate 3 — Solution package build
- Codex #2 builds package: `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip`
- Local static gates (existing): P0/P24 contracts, stop-ship audit, content-safe, routing
- Must NOT contain string `"successfully\."` or hardcoded result placeholders in any PM0 workflow JSON (automated grep)
- Triplet evidence for each gate

### Gate 4 — Owner approval for tenant write
- Codex Lead writes a single explicit ASK to owner in active thread:
  > "Codex requesting tenant write authorization to import `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` into `ColOfertasBrasilPro` and republish `Assistente PMO V2`. SHA256: <hash>. Local gates 1-3 PASS. Awaiting owner OK."
- Wait for explicit owner "approved" / "OK" / "vai" / equivalent in thread
- Without explicit owner approval, do NOT proceed to Gate 5

### Gate 5 — Tenant import + publish (Codex executes, owner-approved)
- `pac solution import` per Microsoft Learn syntax
- `pac copilot publish` per Microsoft Learn syntax
- Capture: full command output, run IDs, screenshots of Copilot Studio publish status, full timestamps BRT, agent name (Codex Lead or which subagent)
- Triplet evidence: screenshot of Copilot Studio "Published" panel + timestamp + agent name

### Gate 6 — Drift monitor structural pass
- Run existing AQ-08 reverify post-publish at T+5min and T+1h
- Must remain PASS (we are not regressing routing)
- Triplet evidence

### Gate 7 — AQ-09 runtime smoke (12 scenarios) — Codex #2 owns execution
- 5 Section A scenarios + 7 Section B scenarios per `aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`
- Each scenario: chat input → bot reply → SP read verification
- Each scenario triplet-evidenced (screenshot of Teams/Copilot test panel + timestamp BRT + agent name)
- Section A all 5: ZERO ContentFiltered/openAIIndirectAttack, real data in bot reply
- Section B: ContentFiltered allowed (legacy debt accepted by ADR_AQ08)
- All 5 Section A PASS = Gate 7 PASS

### Gate 8 — Functional DoD attestation
- For each of the 5 flows, write a `DOD_ATTESTATION.md` confirming all 5 functional DoD criteria from §0 are met
- Each criterion linked to triplet evidence file
- Codex Lead signs the attestation

### Gate 9 — Owner final SHIP decision
- Codex Lead consolidates Gates 1-8 evidence into `SHIP_REVIEW_3_16.md`
- Owner reviews and approves SHIP / NO-SHIP / Rollback in thread
- Codex does not auto-advance

---

## 6. EVIDENCE FOLDER (mandatory structure)

```
.planning/comms/codex_pm0_remediation_20260522/
├── INVESTIGATION_LOG.md                  (append-only, both teams)
├── DOC_UPDATES_LOG.md                    (every project doc update with diff link)
├── EVIDENCE_LOG.md                       (master index of all triplet evidence files)
├── ALPHA/                                (Codex #1 owns)
│   ├── AtualizarStatus/{DEFECT_FIX_REPORT.md, *.diff, unit_test/, evidence/}
│   ├── AtualizarTarefa/...
│   ├── ConsultarPortfolio/...
│   ├── CriarTarefa/...
│   └── ListarTarefas/...
├── BRAVO/                                (Codex #2 owns — read for sync)
├── package/
│   └── PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip
├── ship_review/
│   └── SHIP_REVIEW_3_16.md
└── DOD_ATTESTATIONS/
    ├── AtualizarStatus_DOD.md
    ├── AtualizarTarefa_DOD.md
    ├── ConsultarPortfolio_DOD.md
    ├── CriarTarefa_DOD.md
    └── ListarTarefas_DOD.md
```

---

## 7. CONTINUOUS DOC UPDATES

After every gate transition, update:
- `.planning/STATE.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/START_HERE_CURRENT_STATUS.md`
- `.planning/stop_ship/MASTER_CHECKLIST.md`
- `.planning/stop_ship/RISK_REGISTER.md`
- `.planning/milestones/M2_card_first_revision_v2/STATE.md`
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_EXECUTIVE_20260522.md`
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_TASKS_PLANNER.csv`
- `.planning/comms/STATUS_REPORT_20260522/UNBLOCK_PATH_VISUAL.md`
- `.planning/comms/STATUS_REPORT_20260522/IMMEDIATE_ACTION.md`

Each edit: `Last updated: <YYYY-MM-DD HH:mm:ss BRT> | Codex #1 | <one-line reason>` and logged in `DOC_UPDATES_LOG.md`.

---

## 8. FORBIDDEN

- Tenant writes without explicit owner approval (Gate 4 of §5)
- Marking ANY step DONE without all 3 elements of Evidence Triplet (screenshot + timestamp BRT + agent name)
- Marking ANY flow DONE without all 5 conditions of Functional DoD
- Citing memory or third-party for Microsoft behavior (MS Learn only)
- Auto-advancing past Gate 9 without owner SHIP/NO-SHIP decision
- Inventing MS Learn URLs
- Workflow Response action containing hardcoded `"successfully\."` or equivalent placeholder strings (automated grep blocks Gate 3)

---

## 9. ACCEPTANCE GATES (mission accepted only when all true)

1. All 5 flows pass Functional DoD (5 DOD_ATTESTATION files signed)
2. All 9 release pipeline gates PASS with triplet evidence each
3. AQ-09 Section A: 5/5 PASS with real backend data in bot reply, zero ContentFiltered
4. New functional verifier `Test-Pm0FunctionalContract.ps1` exists, runs, PASSes
5. Solution 3.16 imported and bot republished with full triplet evidence
6. All 11+ project docs continuously updated, last-updated within 10min of last action
7. EVIDENCE_LOG.md has entries for every PASS in pipeline
8. Owner SHIP/NO-SHIP recorded in thread

---

## 10. FINAL DELIVERY (your message in active thread)

1. Confirmation of new Golden Rule (§0) absorbed
2. Per-flow fix summary (5 lines, one per flow, with triplet path)
3. Pipeline gate status table (Gate 1-9, PASS/FAIL/SKIPPED, triplet path)
4. AQ-09 Section A 5-row table with bot reply + SP verification + triplet path
5. Path to SHIP_REVIEW_3_16.md
6. Path to all 5 DOD_ATTESTATION files
7. List of every project doc updated with timestamp
8. Owner approvals recorded (write authorizations, SHIP decisions)
9. Confirmation that no tenant write was performed without explicit thread approval
10. Time stamps for Alpha dispatch / completion / merge

---

## 11. WHAT MUST NOT HAPPEN AGAIN

The defect that triggered this mission was a hardcoded placeholder Response in published PM0 flows. Five agents marked work DONE because structural verification passed and no one ran a real call. The Evidence Triplet Rule and Functional DoD Rule exist now to prevent this. If your remediation does not enforce both rules end-to-end, the mission has not been completed.

---

## END OF PROMPT — Codex #1 Lead, begin remediation
