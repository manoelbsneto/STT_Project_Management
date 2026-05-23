# CODEX MISSION — PM0 Card-First Flows: Full RCA, Remediation & Mitigation
## Escalation level: SEV-0 | Dual-team Codex parallel execution

**Date:** 2026-05-22 15:04 BRT
**Severity:** SEV-0
**Owner:** Manoel Benicio (sole approver, all tenant writes require explicit in-thread approval)
**Source of truth:** official Microsoft Learn (`learn.microsoft.com`) only. Memory, blogs, third-party rejected.
**Execution model:** **Two parallel Codex teams** (Codex Lead + Codex #2), **3 subagents each = 8 agents working concurrently**, owner-approved budget exception per Golden Rules §Agent Budget Gate.
**Read-only mode:** mandatory until written tenant-write approval in active thread.

---

## 0. WHY THIS IS BEING ESCALATED TO YOU (read first, no skipping)

This escalation is **not** a routine audit. It is a SEV-0 escalation triggered by a project-quality failure that should not have reached this stage. Owner is explicitly frustrated with the "junior, stupid, bizarre, mediocre" pattern that allowed this to happen at this stage of delivery. You are being engaged because:

1. **Five previous agents (Codex 5.5, Gemini-PA, Opus 4.7, CODEX-PA, CODEX-QA) marked work DONE that was not functionally validated.** Each one verified structure (manifest hash, ASCII, package contents, routing component names) and none ran a single end-to-end runtime call to prove the bot actually does anything useful.
2. **AQ-08 PASS was structural, not functional.** The verifier `tests/Test-Aq08PostRemediationReverify.ps1` checks that topics call `PM0_PA_Card_*` action components. It does not check that the action component is wired to a flow that returns real data.
3. **The first runtime test ever (AQ-09 A1, today 14:42 BRT) failed immediately** with `"Não encontrei essa informação nas listas do PMO."` — exposing that the entire AQ-07 → AQ-08 chain delivered shells, not features.
4. **Owner has lost confidence in the gate process.** Golden Rules now mandate functional verification (added today). You are the engagement that must restore the rigor and produce official, professionally documented evidence.

There is no acceptable path that involves another structural-only audit. Every claim must be runtime-evidenced or Microsoft-Learn-cited or both.

---

## 1. PROJECT CONTEXT — full timeline you must understand

### 1.1 Product
PMO Intelligent Hub on Microsoft 365 Standard-Only stack:
- Backend: Power Automate (Standard connectors only) + SharePoint Online (5 lists in `Grp_T_DN_Transformacao_Digital` site)
- Conversational layer: Copilot Studio bot `Assistente PMO V2`
- Visual layer: Adaptive Cards posted to Teams channel `Projetos_Tranformação_Digital`
- Optional: Planner Standard connector for task sync
- Hard constraints: no Microsoft Graph direct, no Premium connectors, no Dataverse, no Entra app registration, no service principal. All work in env `ColOfertasBrasilPro` (env id `e2d10003-4d8e-e007-9d63-76d5fe89ef56`), never Default

### 1.2 Milestone history

**M1 — PMO Hub MVP Chat-First (28/04/2026 → 20/05/2026)**
- 19 sessions, packages 1.0 → 3.15
- All 8 PRD topics implemented chat-first calling `PMO_PA_*` legacy flows with full SharePoint logic
- M1 reached `94% completion` per `.planning/START_HERE_CURRENT_STATUS.md` baseline
- **M1 was working in tenant** (validated runtime in sessions 17-19): CriarTarefa, AtualizarStatus, RegistrarRisco, RegistrarBloqueio, PedirDecisao all wrote real data to SP
- Last working baseline: `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` (SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`)
- M1 superseded — never shipped to production — to allow M2 hybrid card-first redesign

**M2 — Hybrid Card-First Revision (20/05/2026 → today)**
- ADR `ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` accepted: scope = 5 in-scope topics migrate to `PM0_PA_Card_*` actions; 7 legacy topics remain on `PMO_PA_*` (accepted backlog debt)
- AQ-07 (15/05): allegedly built 6 PM0_PA_Card_* flows — **bindable, but never functionally tested**
- AQ-08 (20-22/05): redirected 5 topics to PM0 actions in Copilot Studio UI — passed structural verifier
- 3.15.1 hotfix package built, audited "PUBLISH_GO" by Gemini-PA, imported and published to env on 2026-05-22 ~08:15 BRT
- Drift monitor T+5min and T+1h: PASS, blockingTopicCount=0
- AQ-09 first runtime test: **FAILED on the very first call** (A1, ListarTarefas)

### 1.3 The 5 in-scope flows (focus of this mission)

| Topic | Action | Workflow ID |
|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

### 1.4 The failure (verbatim)

**Test executed by Owner 2026-05-22 14:42 BRT:**

- Input 1: `Listar tarefas QA Robust 20260513 F`
- Bot reply 1: "What action would you like to perform?" (English fallback prompt)
- Owner manually filled `action = Listar tarefas`
- Flow ran 31.58s, Copilot Studio panel showed:
  - Input `projectId` = `QA Robust 20260513 F` (the project NAME, not the ProjectID `PRJ-274E5ACC`)
  - Input `action` = `Listar tarefas`
  - Output `result` = `Tasks retrieved successfully.`
- Bot final reply: `"Não encontrei essa informação nas listas do PMO."`

This single test is the entire evidence base for AQ-09 today. No other A or B test was executed. No XPIA verification ran.

### 1.5 Why owner is frustrated

Quote, today 14:51 BRT: *"nao da pra aceitar um erro tao junior desse nessa altura do campeonato"*. Translation: at this maturity stage, this class of defect should be impossible. The fact that 5 sequential agent audits did not catch a placeholder hardcoded `result` string is a **process failure**, not a one-off bug.

---

## 2. MANDATORY READING (before any action)

Per `.planning/GOLDEN_RULES.md` and the Continuous Documentation Update Rule added today:

1. `.planning/GOLDEN_RULES.md`
2. `.planning/CURRENT_BASELINE.md`
3. `.planning/AGENT_CHECKIN_REGISTRY.md`
4. `.planning/START_HERE_CURRENT_STATUS.md`
5. `.planning/stop_ship/MASTER_CHECKLIST.md`
6. `.planning/stop_ship/RISK_REGISTER.md`
7. `.planning/stop_ship/A1_FAIL_RCA_20260522.md` (initial RCA — verify or refute its claims; do not adopt)
8. `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`
9. `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`
10. `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`
11. `.planning/TENANT_COMMAND_RUNBOOK.md`
12. `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
13. `docs/MANUAL_OPERACIONAL_PMO.md`
14. `.planning/milestones/M2_card_first_revision_v2/STATE.md`
15. `.planning/milestones/M2_card_first_revision_v2/ROADMAP.md`
16. `.planning/comms/aq07_power_automate_build_20260515/` (the alleged build evidence)
17. `.planning/comms/aq08_topic_routing_verification_20260520/` (full folder)
18. `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`
19. `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_EXECUTIVE_20260522.md`
20. `.planning/comms/CODEX_P0_CLOSEOUT_HANDOFF_20260520.md`

Confirm completion of mandatory reading by listing all 20 paths in your first response with one-line summary each. Do not start technical work until this is done.

---

## 3. MISSION SCOPE

End-to-end investigation of why the 5 in-scope PM0 card-first flows do not deliver runtime functionality despite passing all structural gates, followed by a complete RCA, a remediation plan, a mitigation plan, and continuous synchronization of every project document affected.

You are not asked to choose between rollback or fix. You are asked to **investigate, evidence, and recommend** based exclusively on Microsoft Learn citations and tenant evidence. Owner makes the final call.

---

## 4. EXECUTION MODEL — DUAL-TEAM PARALLEL

**Owner-approved exception to the 3-subagent budget rule.** Total agents: 8.

### Team Alpha — Codex Lead (you)
- **Subagent A1 — Workflow Body Auditor**
  Reads all 5 `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_*-<id>/workflow.json` and produces per-flow report: trigger schema, action chain, SP/Planner operations, Response body, dynamic vs static output classification, full Microsoft Learn citation for `kind: Skills` Request triggers and Skill Response shape.
- **Subagent A2 — Action Contract Auditor**
  Reads all 5 `Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_*.mcs.yml` and validates against official Copilot Studio `kind: TaskDialog` schema. Documents missing `inputs:` declarations and required mapping per workflow trigger schema.
- **Subagent A3 — Topic Contract Auditor**
  Reads all 5 `Local_Repo/Assistente PMO V2/topics/{topic}.mcs.yml` and audits the `BeginDialog` block calling each PM0 action: variable preparation, `input:` mapping, expected vs actual data flow.

### Team Bravo — Codex #2 (parallel, runs immediately, no waiting)
- **Subagent B1 — Tenant Drift & Live Evidence**
  Uses `pac` read-only commands (`pac org fetch`, `pac copilot list`, `pac connection list`) to capture live tenant state of the 5 workflows (clientdata, status, last modified, last run). Compares with `Local_Repo` to detect drift. Captures full publish history of `Assistente PMO V2`.
- **Subagent B2 — Microsoft Learn Citation Officer**
  Builds the canonical Microsoft Learn citation index for: Copilot Studio Skills protocol; `kind: TaskDialog` actions and `InvokeFlowTaskAction`; `BeginDialog input` Power Fx mapping; Power Automate `kind: Skills` Request triggers and Response actions; SharePoint Standard connector `GetItems`/`PostItem`/`PatchItem` operations; Teams `PostCardToConversation`; Planner Standard connector `CreateTask_V3`/`UpdateTask_V2`/`ListTasks_V3`; Adaptive Cards 1.5 size limits and rendering rules; ContentFiltered/openAIIndirectAttack mitigations. Every URL with accessed timestamp.
- **Subagent B3 — Process Failure & Audit-Gap Analyst**
  Reads all prior audit reports (AQ-07 build evidence, AQ-08 verifier source code, Gemini-PA pre-publish audit, Track H cross-validation, AQ-09 prep) and identifies the exact moment each gate could have caught the defect and did not. Produces named-ownership process failure analysis.

### Coordination
- **Codex Lead** owns merge of Team Alpha + Team Bravo outputs into the final RCA, Remediation Plan, Mitigation Plan, Executive Summary.
- **Both teams work concurrently from minute zero.** No Bravo subagent waits for Alpha.
- All 8 subagents post progress updates every 10 minutes to `.planning/comms/codex_pm0_audit_20260522/INVESTIGATION_LOG.md` (append-only, timestamped).

---

## 5. EVIDENCE FOLDER STRUCTURE (mandatory)

```
.planning/comms/codex_pm0_audit_20260522/
├── INVESTIGATION_LOG.md                          (append-only, every action timestamped)
├── ALPHA/
│   ├── A1_workflows/<flowname>.md
│   ├── A1_workflows/AUDIT_TABLE.md
│   ├── A2_actions/<actionname>.md
│   ├── A2_actions/AUDIT_TABLE.md
│   ├── A3_topics/<topicname>.md
│   └── A3_topics/AUDIT_TABLE.md
├── BRAVO/
│   ├── B1_tenant_drift/<flowname>_live_vs_local.md
│   ├── B1_tenant_drift/PAC_OUTPUTS/{*.txt,*.json}
│   ├── B2_ms_learn_citations/CITATION_INDEX.md
│   ├── B2_ms_learn_citations/raw/<topic>_<accessed_ts>.html
│   └── B3_process_failure/PROCESS_FAILURE_ANALYSIS.md
├── RCA_PM0_FLOWS_20260522.md
├── REMEDIATION_PLAN.md
├── MITIGATION_PLAN.md
├── EXECUTIVE_SUMMARY.md
├── DOC_UPDATES_LOG.md
└── ESCALATION_REQUEST.md                          (only if needed beyond 8 agents)
```

---

## 6. RCA DOCUMENT REQUIREMENTS

`RCA_PM0_FLOWS_20260522.md` follows professional incident-RCA structure:

1. **Incident Summary** — what happened, when, who detected, severity, business impact, current containment
2. **Detection Timeline** — chronological from AQ-07 build alleged completion (15/05) → AQ-08 PASS (22/05 ~08:15) → drift monitor PASS (T+5min, T+1h) → AQ-09 A1 FAIL (14:42) → escalation (15:04)
3. **Affected Components** — full inventory with versions, hashes, IDs
4. **Investigation Methodology** — every command, every file read, every URL fetched, fully reproducible
5. **Findings** — defect register: each defect with ID, severity, file/line evidence, MS Learn citation defining correct behavior, why current diverges
6. **Root Cause(s)** — 5-Whys ending at systemic cause; distinguish direct, contributing, systemic
7. **Process Failure Analysis** — which gates failed, which agents owned them, why detection did not occur (use Bravo B3 output)
8. **Why Previous Audits Did Not Catch It** — explicit gap between structural and functional verification, with examples
9. **Blast Radius** — production impact, data integrity, user trust, M1 status, M2 status, downstream Phases 7-10
10. **Containment Actions Taken** — during this engagement, with timestamps
11. **Lessons Learned** — specific, testable, mapped to new gates / DoD / verifier requirements
12. **Action Items** — owner, due date, link to Remediation/Mitigation, acceptance criteria
13. **References** — full citation index, all evidence paths, all source code references

Executive Summary section must be readable by a non-technical executive in under 3 minutes.

---

## 7. REMEDIATION PLAN REQUIREMENTS

`REMEDIATION_PLAN.md`:
- Per defect: proposed fix, exact file diff, automated test that proves the fix, rollback plan if fix fails, owner approval gate
- Updated **Functional Definition of Done** for any future PM0 flow: no flow is DONE until a real call returns real data, end-to-end, evidenced by `pac flow run` plus runtime bot test
- Updated AQ-08-style verifier requirements: must include functional checks, not only structural
- Updated build/release gates so a stub flow cannot pass CI/audit
- New automated test suite specification: file paths, commands, expected outputs, sample evidence
- Microsoft Learn citation per architectural choice

---

## 8. MITIGATION PLAN REQUIREMENTS

`MITIGATION_PLAN.md`:
- Containment options for live tenant (rollback path, feature flag, topic disable, owner-controlled emergency switches)
- Communication plan for active users
- Monitoring controls (drift, runtime, error rates) until full remediation lands
- Rollback procedure with exact commands, prerequisites, dry-run output, expected post-rollback evidence
- Decision matrix for owner: per option (e.g., ROLLBACK / FIX-AND-SHIP / HYBRID), exact tradeoffs, time, risk, reversibility, dependencies
- Codex's recommended path with justification grounded in citations and evidence

---

## 9. EXECUTIVE SUMMARY REQUIREMENTS

`EXECUTIVE_SUMMARY.md` — exactly one page:
- Incident in 2 sentences
- Root cause in 1 sentence
- Defect count by severity
- Recommended path with 2-line justification
- Time estimate to remediation
- Owner decisions required (numbered)
- Risks if no decision is taken

---

## 10. CONTINUOUS DOCUMENTATION UPDATE (mandatory, real-time)

After every action — file read, command run, evidence captured, hypothesis verified or rejected, decision rendered — update the relevant project doc immediately. Do not batch. Do not defer to "end of phase".

Documents that must be in continuous sync:

- `.planning/STATE.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/START_HERE_CURRENT_STATUS.md`
- `.planning/stop_ship/MASTER_CHECKLIST.md`
- `.planning/stop_ship/RISK_REGISTER.md`
- `.planning/milestones/M2_card_first_revision_v2/STATE.md`
- Active status reports under `.planning/comms/STATUS_REPORT_20260522/`

Every doc edit must carry a `Last updated: <timestamp BRT> | <agent> | <one-line reason>` line.

Every doc edit must be logged in `DOC_UPDATES_LOG.md` with diff link.

---

## 11. FORBIDDEN

- Tenant writes (no `pac solution import`, no `pac flow create/update`, no Copilot Studio UI edits, no SharePoint writes) without explicit written owner approval in the active thread
- Citing memory or third-party sources for Microsoft product behavior
- Marking a flow as functionally correct without proving real data flows from SP/Planner action to bot-rendered response
- Auto-advancing between phases without delivering the prior-phase artifact
- Adopting prior hypotheses (including the initial A1_FAIL_RCA_20260522.md) without independent verification
- Inventing Microsoft Learn URLs

---

## 12. ACCEPTANCE GATES

Mission is accepted only when all are true:

1. RCA document complete, professional, fully cited, owner-readable
2. Remediation Plan with per-defect fixes and updated functional DoD
3. Mitigation Plan with rollback procedure and decision matrix
4. All project status docs updated to reflect findings (continuous, real-time)
5. Microsoft Learn citation index complete; no claim left as `UNVERIFIED`
6. Executive Summary one-pager
7. Every claim runtime-evidenced or Microsoft-Learn-cited
8. Owner approval recorded in `AGENT_CHECKIN_REGISTRY.md` for any tenant-write actions the plans require
9. Process-failure analysis names which gate failed, which agent owned it, what specific check would have caught the defect

---

## 13. FINAL DELIVERY

Codex Lead's final response in the active thread must contain:

1. List of all 20 mandatory docs read with one-line summary each (proof of compliance)
2. Paths to RCA, Remediation Plan, Mitigation Plan, Executive Summary
3. List of every project doc updated with timestamp and reason
4. Defect register summary: count by severity, with severity breakdown
5. Recommended path with 1-paragraph justification grounded in evidence + citations
6. Owner decisions explicitly required, numbered, with options and tradeoffs
7. Confirmation that no tenant write was performed without explicit owner approval
8. Time stamps for Team Alpha and Team Bravo dispatch, completion, and merge
9. Any escalation request if 8 agents proved insufficient (with concrete blockers)

---

## 14. WHAT MUST NOT HAPPEN AGAIN

The defect found today is a placeholder hardcoded `"result": "Tasks retrieved successfully."` in a published production-candidate flow. Five agents marked work DONE before any human or any automation ever called the flow end-to-end. This is the systemic failure to fix.

Your remediation must include the verifier and DoD changes that make this class of defect impossible to slip past gates again. If your remediation does not, the mission has not been completed.

---

## END OF PROMPT — Codex Lead, begin mission
