# CODEX #1 (LEAD) — Team Alpha + Final Merge
## PM0 Card-First Flows: RCA, Remediation & Mitigation
## SEV-0 | Run in parallel with Codex #2

**Date:** 2026-05-22
**Your role:** Codex Lead. You execute Team Alpha (3 subagents) AND own the final merge of all outputs into RCA, Remediation Plan, Mitigation Plan, Executive Summary.
**Codex #2** runs Team Bravo concurrently in a separate instance. You do not wait for #2 to start; you sync via shared filesystem `.planning/comms/codex_pm0_audit_20260522/`.
**Owner:** Manoel Benicio. Sole approver. Tenant writes require explicit in-thread approval.
**Source of truth:** official Microsoft Learn (`learn.microsoft.com`) only. Memory, blogs, third-party rejected.
**Read-only:** mandatory until written tenant-write approval.

---

## 0. WHY THIS IS BEING ESCALATED TO YOU

This is a SEV-0 escalation. Owner has lost confidence in the gate process because:

1. Five previous agents (Codex 5.5, Gemini-PA, Opus 4.7, CODEX-PA, CODEX-QA) marked work DONE based on **structural verification** (manifest hash, ASCII, package, routing component names) without ever running an end-to-end runtime call.
2. AQ-08 PASS confirmed topics call `PM0_PA_Card_*` actions, but did not confirm the actions return real data.
3. AQ-09 A1 (today 14:42 BRT, first runtime call ever) failed: bot replied `"Não encontrei essa informação nas listas do PMO."` because flow returned hardcoded `"Tasks retrieved successfully."`.
4. Owner quote (14:51 BRT): *"nao da pra aceitar um erro tao junior desse nessa altura do campeonato"*.

You must restore rigor. Every claim must be runtime-evidenced or Microsoft-Learn-cited.

---

## 1. PROJECT CONTEXT

**Product:** PMO Intelligent Hub on M365 Standard-Only stack. Power Automate Standard + SharePoint Online (5 lists) + Copilot Studio bot `Assistente PMO V2` + Adaptive Cards in Teams + optional Planner Standard. Env `ColOfertasBrasilPro` (id `e2d10003-4d8e-e007-9d63-76d5fe89ef56`).

**M1 (28/04→20/05):** chat-first with `PMO_PA_*` legacy flows. Working in tenant. Last good baseline `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` (SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`). Never shipped to production.

**M2 (20/05→today):** hybrid card-first per `ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`. 5 in-scope topics migrated to `PM0_PA_Card_*` actions. Active package `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`, published 2026-05-22T11:15:52 UTC. AQ-08 structural PASS (T+5min, T+1h). AQ-09 functional A1 FAIL.

**The 5 in-scope flows:**

| Topic | Action | Workflow ID |
|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

**Failure verbatim:** Owner typed `Listar tarefas QA Robust 20260513 F`. Bot prompted "What action would you like to perform?" (English fallback). Owner manually filled `action`. Flow ran 31.58s, output `result = "Tasks retrieved successfully."`. Bot final reply `"Não encontrei essa informação nas listas do PMO."`.

---

## 2. MANDATORY READING BEFORE WORK

Per `.planning/GOLDEN_RULES.md` (Continuous Documentation Update Rule added today):

1. `.planning/GOLDEN_RULES.md`
2. `.planning/CURRENT_BASELINE.md`
3. `.planning/AGENT_CHECKIN_REGISTRY.md`
4. `.planning/START_HERE_CURRENT_STATUS.md`
5. `.planning/stop_ship/MASTER_CHECKLIST.md`
6. `.planning/stop_ship/RISK_REGISTER.md`
7. `.planning/stop_ship/A1_FAIL_RCA_20260522.md` (verify or refute, do not adopt)
8. `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`
9. `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`
10. `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`
11. `.planning/TENANT_COMMAND_RUNBOOK.md`
12. `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
13. `docs/MANUAL_OPERACIONAL_PMO.md`
14. `.planning/milestones/M2_card_first_revision_v2/STATE.md`
15. `.planning/milestones/M2_card_first_revision_v2/ROADMAP.md`
16. `.planning/comms/aq07_power_automate_build_20260515/`
17. `.planning/comms/aq08_topic_routing_verification_20260520/`
18. `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`
19. `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_EXECUTIVE_20260522.md`
20. `.planning/comms/CODEX_P0_CLOSEOUT_HANDOFF_20260520.md`

Confirm completion by listing all 20 paths in your first response with one-line summary each. Do not start technical work until done.

---

## 3. YOUR DELIVERABLES (Codex #1)

### 3.1 Team Alpha — 3 subagents in parallel

#### Subagent A1 — Workflow Body Auditor
For each of the 5 workflows at `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_*-<id>/workflow.json`, produce per-flow report including:

1. Trigger inputs schema (name, type, required) with verbatim JSON path
2. Action chain in execution order (`type`, `connectionName`, `operationId`)
3. SP/Planner action filter/parameter expressions verbatim
4. Response action body verbatim with line number
5. Whether SP/Planner data flows into Response body (true/false with line evidence)
6. Adaptive Card posting analysis (dynamic vs static content)
7. Microsoft Learn citation defining correct Response shape for `kind: Skills` Request triggers (cite URL and accessed timestamp)
8. Classification: STUB / PARTIAL / REAL with explicit per-criterion justification
   - STUB = no SP/Planner action at all
   - PARTIAL = SP/Planner actions exist but Response body does not reflect their output
   - REAL = full pipeline including dynamic Response body

Output:
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/<flowname>.md` (one per flow)
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/AUDIT_TABLE.md` (consolidated)

#### Subagent A2 — Action Contract Auditor
For each of the 5 `Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_*.mcs.yml`:

1. Capture verbatim YAML
2. Validate against official Microsoft schema for Copilot Studio `kind: TaskDialog` actions. Cite Microsoft Learn page defining `inputs:`, `outputs:`, `action.kind: InvokeFlowTaskAction`, required mapping fields
3. List missing `inputs:` block per file
4. Cross-reference with workflow trigger schema from A1: which trigger fields are required by workflow but not declared in action

Output:
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A2_actions/<actionname>.md`
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A2_actions/AUDIT_TABLE.md`

#### Subagent A3 — Topic Contract Auditor
For each of the 5 `Local_Repo/Assistente PMO V2/topics/{topic}.mcs.yml`:

1. Capture all `Topic.*` and `Global.*` variables set before action call
2. Capture verbatim `BeginDialog` block calling `pmo_AssistentePMO_V2.action.PM0_PA_Card_*`
3. Report exact `input:` content
4. Identify correct Power Fx mapping that should be in `input:` based on workflow trigger schema (cross-reference A1)
5. Microsoft Learn citation for `BeginDialog input` syntax

Output:
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A3_topics/<topicname>.md`
- `.planning/comms/codex_pm0_audit_20260522/ALPHA/A3_topics/AUDIT_TABLE.md`

### 3.2 Final Merge — Codex Lead (you)

After Team Alpha (yours) and Team Bravo (Codex #2's, deposited in `.planning/comms/codex_pm0_audit_20260522/BRAVO/`) both complete, merge into:

#### `RCA_PM0_FLOWS_20260522.md` (professional incident RCA)
1. Incident Summary
2. Detection Timeline (AQ-07 alleged completion → AQ-08 PASS → drift PASS → AQ-09 FAIL → escalation)
3. Affected Components (full inventory with versions, hashes, IDs)
4. Investigation Methodology (every command, file, URL — fully reproducible)
5. Findings (defect register: ID, severity, file/line evidence, MS Learn citation, divergence)
6. Root Cause(s) (5-Whys, distinguish direct/contributing/systemic)
7. Process Failure Analysis (use Bravo B3 output)
8. Why Previous Audits Did Not Catch It (structural vs functional gap with examples)
9. Blast Radius (production, data, trust, M1, M2, downstream phases)
10. Containment Actions Taken (with timestamps)
11. Lessons Learned (specific, testable, mapped to gates/DoD/verifier)
12. Action Items (owner, due, link, acceptance)
13. References

#### `REMEDIATION_PLAN.md`
- Per defect: proposed fix, exact file diff, automated test proving fix, rollback if fix fails, owner approval gate
- Updated **Functional Definition of Done**: no flow is DONE until real call returns real data, evidenced by `pac flow run` plus runtime bot test
- Updated AQ-08-style verifier requirements with functional checks
- Updated build/release gates so stub flows cannot pass
- Automated test suite spec (paths, commands, expected outputs, sample evidence)
- MS Learn citation per architectural choice

#### `MITIGATION_PLAN.md`
- Containment options for live tenant (rollback, feature flag, topic disable, emergency switches)
- Communication plan for active users
- Monitoring controls (drift, runtime, error rates) until full remediation
- Rollback procedure with exact commands, prerequisites, dry-run output, expected post-rollback evidence
- Decision matrix for owner: per option (ROLLBACK / FIX-AND-SHIP / HYBRID), tradeoffs, time, risk, reversibility, dependencies
- Codex Lead's recommended path with citation- and evidence-grounded justification

#### `EXECUTIVE_SUMMARY.md` — exactly one page
- Incident in 2 sentences
- Root cause in 1 sentence
- Defect count by severity
- Recommended path with 2-line justification
- Time estimate
- Owner decisions required (numbered)
- Risks if no decision

---

## 4. EVIDENCE FOLDER STRUCTURE

```
.planning/comms/codex_pm0_audit_20260522/
├── INVESTIGATION_LOG.md                   (append-only, every action timestamped — both teams write)
├── ALPHA/                                 (you own this)
│   ├── A1_workflows/{<flowname>.md, AUDIT_TABLE.md}
│   ├── A2_actions/{<actionname>.md, AUDIT_TABLE.md}
│   └── A3_topics/{<topicname>.md, AUDIT_TABLE.md}
├── BRAVO/                                 (Codex #2 owns this — read for merge)
├── RCA_PM0_FLOWS_20260522.md              (you own)
├── REMEDIATION_PLAN.md                    (you own)
├── MITIGATION_PLAN.md                     (you own)
├── EXECUTIVE_SUMMARY.md                   (you own)
└── DOC_UPDATES_LOG.md                     (you own — log every project doc update)
```

---

## 5. SYNC WITH CODEX #2

- Both teams start at minute zero, no waiting
- Both teams append progress to `INVESTIGATION_LOG.md` every 10 minutes
- Codex #2 deposits Bravo outputs in `BRAVO/` folder
- You watch for `BRAVO/B1_tenant_drift/`, `BRAVO/B2_ms_learn_citations/CITATION_INDEX.md`, `BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md` to be complete before final merge
- If Bravo blocks beyond 60min, escalate to owner via `ESCALATION_REQUEST.md`

---

## 6. CONTINUOUS DOCUMENTATION UPDATE (mandatory, real-time)

After every action, update relevant project doc immediately. Do not batch.

Documents to keep in continuous sync:

- `.planning/STATE.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/START_HERE_CURRENT_STATUS.md`
- `.planning/stop_ship/MASTER_CHECKLIST.md`
- `.planning/stop_ship/RISK_REGISTER.md`
- `.planning/milestones/M2_card_first_revision_v2/STATE.md`
- Active status reports under `.planning/comms/STATUS_REPORT_20260522/`

Every doc edit carries `Last updated: <timestamp BRT> | Codex #1 | <one-line reason>`.
Every doc edit logged in `DOC_UPDATES_LOG.md` with diff link.

---

## 7. FORBIDDEN

- Tenant writes (no `pac solution import`, `pac flow create/update`, Copilot Studio UI edits, SharePoint writes) without explicit written owner approval in active thread
- Citing memory or third-party sources for Microsoft product behavior
- Marking a flow as functionally correct without proving real data flows from SP/Planner action to bot-rendered response
- Adopting prior hypotheses (including A1_FAIL_RCA_20260522.md) without independent verification
- Inventing Microsoft Learn URLs

---

## 8. ACCEPTANCE GATES

Mission accepted only when all true:

1. RCA complete, professional, fully cited, owner-readable
2. Remediation Plan with per-defect fixes and updated functional DoD
3. Mitigation Plan with rollback procedure and decision matrix
4. All project status docs updated (continuous, real-time)
5. MS Learn citation index complete; no `UNVERIFIED` claim left
6. Executive Summary one-pager
7. Every claim runtime-evidenced or MS-Learn-cited
8. Owner approval recorded in `AGENT_CHECKIN_REGISTRY.md` for any tenant-write actions plans require
9. Process-failure analysis names which gate failed, which agent owned, what specific check would have caught the defect

---

## 9. FINAL DELIVERY (your message in active thread)

1. List of all 20 mandatory docs read with one-line summary each
2. Paths to RCA, Remediation Plan, Mitigation Plan, Executive Summary
3. List of every project doc updated with timestamp and reason
4. Defect register summary (count by severity)
5. Recommended path with 1-paragraph justification grounded in evidence + citations
6. Owner decisions explicitly required, numbered, with options and tradeoffs
7. Confirmation no tenant write was performed without explicit owner approval
8. Time stamps for Team Alpha dispatch/completion and merge with Bravo
9. Any escalation if 8 agents (Alpha+Bravo) proved insufficient

---

## 10. WHAT MUST NOT HAPPEN AGAIN

The defect found today is a placeholder hardcoded `"result": "Tasks retrieved successfully."` in a published production-candidate flow. Five agents marked work DONE before any human or any automation ever called the flow end-to-end. This is the systemic failure to fix.

Your remediation must include verifier and DoD changes that make this class of defect impossible to slip past gates again. If your remediation does not, the mission has not been completed.

---

## END OF PROMPT — Codex #1 Lead, begin Team Alpha and prepare for merge
