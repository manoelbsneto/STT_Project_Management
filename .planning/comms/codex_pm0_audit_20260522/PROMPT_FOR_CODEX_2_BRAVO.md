# CODEX #2 — Team Bravo
## PM0 Card-First Flows: Tenant Drift, MS Learn Citations, Process Failure Analysis
## SEV-0 | Run in parallel with Codex #1

**Date:** 2026-05-22
**Your role:** Codex #2. You execute Team Bravo (3 subagents). You do NOT own RCA or final merge — Codex #1 (Lead) does that. Your job is to deposit high-quality Bravo evidence in `.planning/comms/codex_pm0_audit_20260522/BRAVO/` so Codex #1 can merge.
**Codex #1** runs Team Alpha concurrently in a separate instance. You do not wait for #1 to start; you sync via shared filesystem.
**Owner:** Manoel Benicio. Sole approver. Tenant writes require explicit in-thread approval.
**Source of truth:** official Microsoft Learn (`learn.microsoft.com`) only. Memory, blogs, third-party rejected.
**Read-only:** mandatory. You will run `pac` read-only commands but no writes.

---

## 0. WHY THIS IS BEING ESCALATED TO YOU

This is a SEV-0 escalation. Owner has lost confidence in the gate process because:

1. Five previous agents (Codex 5.5, Gemini-PA, Opus 4.7, CODEX-PA, CODEX-QA) marked work DONE based on **structural verification** without ever running an end-to-end runtime call.
2. AQ-08 PASS confirmed routing structure but did not confirm functional behavior.
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

## 3. YOUR DELIVERABLES (Codex #2 — Team Bravo)

### 3.1 Subagent B1 — Tenant Drift & Live Evidence

Use `pac` read-only commands per `.planning/TENANT_COMMAND_RUNBOOK.md`. Capture for each of the 5 workflows:

1. Live tenant `clientdata` JSON via `pac org fetch` of the workflow row (Dataverse `workflow` entity, by ID)
2. Workflow status (Draft/Published), last modified timestamp, last successful run, last failed run
3. Connection reference status (which connection, owner, status)
4. Adaptive Card binding status (if applicable)
5. Bot publish history of `Assistente PMO V2` (full timeline since 2026-05-15)

For each workflow, compare live tenant JSON vs `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_*-<id>/workflow.json`:
- Compute SHA256 of both
- Field-level diff (use `Compare-Object` or equivalent)
- Drift report with concrete differences

Output:
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B1_tenant_drift/<flowname>_live_vs_local.md` (one per flow)
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B1_tenant_drift/PAC_OUTPUTS/{*.txt,*.json}` (raw evidence)
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B1_tenant_drift/DRIFT_TABLE.md` (consolidated)

### 3.2 Subagent B2 — Microsoft Learn Citation Officer

Build the canonical Microsoft Learn citation index for every claim about Microsoft product behavior the audit will need. Each citation must include full URL, accessed timestamp BRT, brief excerpt of the relevant section.

Required citations (minimum):

1. **Copilot Studio Skills protocol** — what `kind: Skills` means in Power Automate trigger, what shape the Response action must have, how Skill outputs map to caller variables
2. **Copilot Studio `kind: TaskDialog` actions** — schema of `inputs:`, `outputs:`, `action.kind: InvokeFlowTaskAction`, `flowId`, `connectionProperties`
3. **`BeginDialog input:` Power Fx mapping** — exact syntax for passing topic variables to action
4. **Power Automate `kind: Skills` Request triggers** — required vs optional inputs, schema validation rules
5. **Power Automate Response action** — body schema, how response fields surface in Copilot Studio Skill outputs
6. **SharePoint Standard connector** — `GetItems`, `PostItem`, `PatchItem` operationIds, parameter shape, `dataset` and `table` semantics
7. **Teams Standard connector** — `PostCardToConversation` operationId, recipient/channel parameters, dynamic content rules
8. **Planner Standard connector** — `CreateTask_V3`, `UpdateTask_V2`, `ListTasks_V3` operationIds, group/plan/bucket relationship
9. **Adaptive Cards 1.5** — size limits (note prior 27KB ceiling per `.planning/STATE.md`), rendering rules in Teams
10. **ContentFiltered / openAIIndirectAttack** — Microsoft Responsible AI guidance, mitigation patterns, official troubleshooting docs
11. **`pac solution import`** — flags, prerequisites, rollback semantics, force-overwrite rules
12. **Functional verification practices** — Microsoft official guidance on testing Power Automate flows end-to-end (`pac flow run`, run history, monitoring)

For each citation, store the raw HTML in `BRAVO/B2_ms_learn_citations/raw/<topic>_<accessed_ts>.html` if technically possible; otherwise capture full quoted excerpt in the index.

If a Microsoft Learn page is unreachable, log it as `CITATION_PENDING` with attempt timestamp and continue. Do not invent URLs.

Output:
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md` (master index)
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/raw/` (raw fetched content)

### 3.3 Subagent B3 — Process Failure & Audit-Gap Analyst

Read all prior audit reports and identify the exact moment each gate could have caught the defect and did not. Be specific and name names.

Required reading:

1. `.planning/comms/aq07_power_automate_build_20260515/` (full folder) — what was alleged DONE
2. `tests/Test-Aq08PostRemediationReverify.ps1` — exact verifier source code
3. `.planning/comms/gemini_pa_audit_3_15_1_hotfix_topics_20260521/AUDIT_REPORT.md` — Gemini-PA pre-publish audit
4. `.planning/comms/track_h_cross_validation_20260521/CROSS_VALIDATION.md` — Track H cross-validation
5. `.planning/comms/aq09_smoke_runbook_20260520/PREP_REPORT_V2.md` — AQ-09 prep
6. `.planning/comms/independent_review_3_15_1_20260521/` (if exists) — independent review evidence
7. `.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/drift_monitoring_20260522_0816/` — drift evidence

Per gate, document:
- Gate name and owning agent
- What it verified
- What it did not verify
- Exact moment and exact check that would have caught the AQ-09 A1 failure (e.g., "if AQ-08 verifier had asserted that workflow Response action body referenced `Get_SharePoint_Item` output, this defect would have been blocked at 2026-05-22 11:28 BRT instead of 14:42 BRT")
- Why the omission happened (scope of gate, definition of DONE, specification ambiguity)

Output:
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md`
- One section per gate, with timestamps and verbatim quotes from the prior reports

---

## 4. EVIDENCE FOLDER STRUCTURE

```
.planning/comms/codex_pm0_audit_20260522/
├── INVESTIGATION_LOG.md                   (append-only — write here every 10min)
├── ALPHA/                                 (Codex #1 owns — do not write)
└── BRAVO/                                 (you own all of this)
    ├── B1_tenant_drift/{<flowname>_live_vs_local.md, DRIFT_TABLE.md, PAC_OUTPUTS/}
    ├── B2_ms_learn_citations/{CITATION_INDEX.md, raw/}
    └── B3_process_failure/PROCESS_FAILURE_ANALYSIS.md
```

---

## 5. SYNC WITH CODEX #1

- Both teams start at minute zero, no waiting
- Append progress to `INVESTIGATION_LOG.md` every 10 minutes with timestamp and brief description
- Codex #1 will pick up your Bravo outputs for final merge into RCA, Remediation, Mitigation, Executive Summary
- When all 3 Bravo deliverables are complete, append `[BRAVO COMPLETE]` line to `INVESTIGATION_LOG.md`
- If you block beyond 60min (PAC auth, MS Learn unreachable, etc.), write `BRAVO/ESCALATION_REQUEST.md` with concrete blocker

---

## 6. CONTINUOUS DOCUMENTATION UPDATE (mandatory, real-time)

After every action, update relevant project doc immediately. Do not batch.

Documents to keep in continuous sync (Codex #1 owns merge but you may write your evidence-related updates):

- `.planning/AGENT_CHECKIN_REGISTRY.md` — log every Bravo subagent claim/complete with timestamp
- `.planning/stop_ship/RISK_REGISTER.md` — if you discover new risks, add them
- `.planning/comms/STATUS_REPORT_20260522/` — if drift evidence changes status, reflect

Every doc edit carries `Last updated: <timestamp BRT> | Codex #2 | <one-line reason>`.

---

## 7. FORBIDDEN

- **Tenant writes** — read-only `pac` only. No `pac solution import`, no `pac flow create/update`, no Copilot Studio UI edits, no SharePoint writes
- Citing memory or third-party sources for Microsoft product behavior
- Inventing Microsoft Learn URLs
- Adopting prior hypotheses (including A1_FAIL_RCA_20260522.md) without independent verification
- Marking any Bravo output complete without supporting evidence (file paths, command outputs, MS Learn URLs)

---

## 8. ACCEPTANCE GATES (your portion)

Bravo accepted only when all true:

1. B1 produces drift report for all 5 flows with concrete diffs (or zero-diff confirmed)
2. B1 captures full publish history of bot
3. B2 CITATION_INDEX.md contains the 12 minimum citations from §3.2 with valid URLs and timestamps
4. B3 PROCESS_FAILURE_ANALYSIS.md names every gate, agent, omission, and exact check that would have caught the defect
5. All raw evidence (PAC outputs, MS Learn raw content) preserved in `BRAVO/`
6. `INVESTIGATION_LOG.md` shows your activity timeline with 10-min granularity
7. `[BRAVO COMPLETE]` marker written when done

---

## 9. FINAL DELIVERY (your message in active thread or in INVESTIGATION_LOG.md)

1. List of all 20 mandatory docs read with one-line summary each
2. Paths to B1 drift table, B2 citation index, B3 process failure analysis
3. Number of citations in B2 (must be at least 12)
4. Number of drift differences detected in B1 (per flow)
5. Number of gate failures named in B3
6. Any tenant access issues encountered
7. Confirmation no tenant write was performed
8. Time stamps for Bravo dispatch and completion
9. `[BRAVO COMPLETE]` marker written

Codex #1 (Lead) will pick up your outputs and merge.

---

## 10. WHAT MUST NOT HAPPEN AGAIN

The defect found today is a placeholder hardcoded `"result": "Tasks retrieved successfully."` in a published production-candidate flow. Five agents marked work DONE before any human or any automation ever called the flow end-to-end. This is the systemic failure to fix.

Your B3 analysis must name exactly which check at which gate would have caught this. Codex #1's remediation will use your B3 to update the verifiers and DoD.

---

## END OF PROMPT — Codex #2, begin Team Bravo
