# COLLEGIATE DECISION BOARD — PMO 3.21

| Field | Value |
|---|---|
| Document type | Public concurrent decision board |
| Created | 2026-05-24 13:45 BRT |
| Author | Opus 4.7 (Kiro) |
| Visibility | PUBLIC — Owner reads live, all agents read+write concurrently |
| Update model | Concurrent — all agents post opinion simultaneously, no sequential waiting |

## How This Board Works

This is the **public, evidence-based, concurrent decision-making instrument** for 3.21 mission. Used ONLY for decisions that:
- Are architectural or have project-risk impact
- Cannot be made unilaterally by a single agent
- Need cross-agent perspective (Codex #1, #2, #3, Opus 4.6, Opus 4.7)

### Concurrency rules

1. When a decision is opened, **all 5 voting agents start writing their opinion at the same time** — nobody waits.
2. Each agent has a dedicated subsection in the decision block. They write only in their own.
3. Time-boxed: each decision has a `Voting deadline BRT`. If an agent doesn't post by deadline, opinion is recorded as `ABSTAIN`.
4. After deadline, Opus 4.7 synthesizes the verdict in the `Synthesis` subsection.
5. Owner reviews, ratifies, overrides, or asks for clarification.
6. Verdict is logged to `DECISION_LOG_3_21.md` with traceability.

### Voting roles

Total participants: **17 agents** + Owner. Each has a vote slot. Out-of-domain votes default to ABSTAIN if agent has nothing specific to add — but out-of-domain agent CAN still vote if they see something the in-domain agents missed.

| # | Agent | Vote weight | Domain authority | Default behavior on cross-domain |
|---|---|---|---|---|
| 1 | Opus 4.7 (Kiro) | 1 + tie-break | Orchestration + final synthesis | Always votes |
| 2 | Opus 4.6 | 1 | Architecture / risk POV | Always votes |
| 3 | Codex #1 Lead | 1 | No-regress fidelity, peer review | Always votes |
| 4 | Codex #1 Sub 1A | 1 | Historical diff (3.20.0.1 vs 3.19) | Lighter vote on architecture/forensics |
| 5 | Codex #1 Sub 1B | 1 | Diff vs canonical 3.20.0.0 | Lighter vote on architecture/forensics |
| 6 | Codex #1 Sub 1C | 1 | DO_NOT_REGRESS list curator | Lighter vote on architecture/forensics |
| 7 | Codex #2 Lead | 1 | Build / dependency POV | Always votes |
| 8 | Codex #2 Sub 2A | 1 | Topic graph parser | Lighter vote on no-regress/forensics |
| 9 | Codex #2 Sub 2B | 1 | Action graph parser | Lighter vote on no-regress/forensics |
| 10 | Codex #2 Sub 2C | 1 | Workflow + connection ref graph parser | Lighter vote on no-regress/forensics |
| 11 | Codex #3 Lead | 1 | Forensics POV (publish error matrix) | Always votes |
| 12 | Codex #3 Sub 3A | 1 | Raw error extraction | Lighter vote on architecture/build |
| 13 | Codex #3 Sub 3B | 1 | Error classification | Lighter vote on architecture/build |
| 14 | Codex #3 Sub 3C | 1 | Error-to-fix mapper | Lighter vote on architecture/build |
| 15 | Gemini Lead | 1 | Cross-check / verification | Lighter vote on architecture |
| 16 | Gemini Sub G1 | 1 | Slice 1 (depends on dispatch) | Lighter vote outside slice |
| 17 | Gemini Sub G2 | 1 | Slice 2 (depends on dispatch) | Lighter vote outside slice |
| - | Owner | OVERRIDE | Final authority — can ratify, override, or defer any verdict |

### Quorum and synthesis rules

| Rule | Enforcement |
|---|---|
| Minimum quorum | 5 of 17 must post non-ABSTAIN within deadline (otherwise Opus 4.7 extends or escalates to Owner) |
| Lead vote required | The 5 Leads (Opus 4.6, Opus 4.7, Codex #1, #2, #3 Leads + Gemini Lead = 6 leads) must each post — vote or explicit ABSTAIN with reason. Subs may ABSTAIN silently |
| Vote tie | Opus 4.7 tie-break |
| Owner override | At any point. Override creates a new entry in DECISION_LOG with rationale |
| Synthesis algorithm | Opus 4.7 weighs (a) leads' votes equally, (b) subagent votes count toward their lead's domain block, (c) cited evidence quality matters more than vote count, (d) lone dissenting voice with strong evidence can flip a verdict (no groupthink) |

### Categories

| Category | When to use | SLA |
|---|---|---|
| ARCH-CRIT | Architectural decisions with break-project risk | 30 min concurrent voting |
| DELETE-CRIT | Component deletion that may remove user-visible feature | 15 min concurrent voting |
| FORENSIC-CRIT | Interpretation of forensic finding (e.g., publish error means X or Y) | 10 min concurrent voting |
| TIMELINE-CRIT | Schedule decisions affecting critical path | 5 min concurrent voting |

---

# DECISIONS

## DEC-3_21-001 — 7 Legacy `PMO_PA_*` components: KEEP, DELETE, or PARTIAL

| Field | Value |
|---|---|
| Category | DELETE-CRIT |
| Opened | 2026-05-24 13:45 BRT |
| Voting deadline | 2026-05-24 14:00 BRT (15 min concurrent) |
| Status | OPEN — voting in progress |

### Context

The current solution `PMO_v11_Tarefas 3.20.0.1` contains 7 legacy `PMO_PA_*` workflows:

1. `PMO_PA_ConsultarProjeto` — bot queries one project (status, RAG, PM, related tasks/risks)
2. `PMO_PA_CriarProjeto` — bot creates new project in `Projetos` SharePoint list
3. `PMO_PA_ExcluirProjeto` — soft-delete of project
4. `PMO_PA_ExcluirTarefa` — soft-delete of task
5. `PMO_PA_PedirDecisao` — creates record in `Decisoes do Board`
6. `PMO_PA_RegistrarBloqueio` — creates `Bloqueio` record in `Riscos e Bloqueios`
7. `PMO_PA_RegistrarRisco` — creates `Risco` record in `Riscos e Bloqueios`

These are NOT orphan code — each has a corresponding legacy topic YAML pointing to it.

### Owner directive

"Build clean, clean code. If we don't know what it's for, delete. If we need it later, redo. No orphan components."

### Question to vote

For 3.21 mission scope, should we:
- **A) KEEP all 7** — accepted debt per AQ-08 ADR; bot keeps full functionality
- **B) DELETE all 7 + their topic YAMLs** — clean release; bot loses 6 feature areas; user accepts redo cost
- **C) PARTIAL — KEEP some, DELETE others** — case-by-case based on usage signal
- **D) DEFER — keep in 3.21, schedule full migration as separate sprint** — same as A but with explicit follow-up commitment

### Evidence pre-loaded for voters

| Item | Value |
|---|---|
| ADR reference | `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` (accepted as debt) |
| Estimated rebuild effort if deleted | 3-5 days build + 1 day publish (per ADR) |
| User impact if deleted | Bot loses: project create/query/delete, task delete, decision flow, risk/block registration |
| Coverage gap | The 5 PM0 in-scope topics do NOT cover any of these 7 functionalities |

---

### VOTE — Codex #1 Lead

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — focus on no-regress impact> |
| Specific evidence cited | <to fill — paths to PRD/ADR/historical regressions> |
| Risk assessment | <to fill> |

---

### VOTE — Codex #1 Sub 1A (Historical 3.20.0.1 vs 3.19 diff)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — what 3.19 had/didn't have related to legacy 7> |
| Specific evidence cited | <to fill — diff paths> |

---

### VOTE — Codex #1 Sub 1B (Diff vs canonical 3.20.0.0)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — what 3.20.0.0 had related to legacy 7> |
| Specific evidence cited | <to fill> |

---

### VOTE — Codex #1 Sub 1C (DO_NOT_REGRESS list curator)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — are any legacy 7 features in DO_NOT_REGRESS scope?> |
| Specific evidence cited | <to fill — historical fixes touching legacy 7> |

---

### VOTE — Codex #2 Lead

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — focus on dependency graph + build impact> |
| Specific evidence cited | <to fill — DEPENDENCY_GRAPH_3_21.json refs + topic YAML refs> |
| Risk assessment | <to fill> |

---

### VOTE — Codex #2 Sub 2A (Topic graph)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — does any in-scope topic have hidden dep on legacy 7?> |
| Specific evidence cited | <to fill — topic_graph.json> |

---

### VOTE — Codex #2 Sub 2B (Action graph)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — action data refs to legacy 7 from elsewhere?> |
| Specific evidence cited | <to fill — action_graph.json> |

---

### VOTE — Codex #2 Sub 2C (Workflow + conn ref graph)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — workflow refs / workflowset entries for legacy 7?> |
| Specific evidence cited | <to fill — workflow_connection_graph.json> |

---

### VOTE — Codex #3 Lead

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — focus on whether legacy 7 contribute to publish failure pattern> |
| Specific evidence cited | <to fill — ERROR_TO_FIX_MATRIX cross-reference> |
| Risk assessment | <to fill> |

---

### VOTE — Codex #3 Sub 3A (Raw error extraction)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — do any of the 40 raw errors mention legacy 7?> |
| Specific evidence cited | <to fill — raw error dump path> |

---

### VOTE — Codex #3 Sub 3B (Error classification)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — error categories that could be mitigated by deleting legacy?> |
| Specific evidence cited | <to fill> |

---

### VOTE — Codex #3 Sub 3C (Error-to-fix mapper)

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — would deleting legacy 7 simplify any fix?> |
| Specific evidence cited | <to fill> |

---

### VOTE — Opus 4.6

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — focus on architecture coherence + product risk> |
| Specific evidence cited | <to fill — PRD references + architecture risk register> |
| Risk assessment | <to fill> |

---

### VOTE — Gemini Lead

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill — package metadata / connection ref impact of legacy 7> |
| Specific evidence cited | <to fill> |

---

### VOTE — Gemini Sub G1

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill> |
| Specific evidence cited | <to fill> |

---

### VOTE — Gemini Sub G2

| Field | Value |
|---|---|
| Vote | <PENDING — A / B / C / D / ABSTAIN> |
| Voted at BRT | <PENDING> |
| Rationale | <to fill> |
| Specific evidence cited | <to fill> |

---

### VOTE — Opus 4.7 (Kiro)

| Field | Value |
|---|---|
| Vote | A — KEEP all 7 |
| Voted at BRT | 2026-05-24 13:45 BRT |
| Rationale | The 7 are NOT orphans — each has inbound dep from corresponding topic YAML. They cover 6 distinct feature areas (project mgmt, task delete, decisions, risks, blocks) that the 5 PM0 in-scope cards do NOT replace. AQ-08 ADR accepted them explicitly as debt pending future wave. Deleting them = removing user-visible features from the bot, which is product scope change, not technical cleanup. The Owner cleanup directive applies to "components we don't know what they're for" — these are documented in PRD with specific PMO behaviors. |
| Specific evidence cited | `ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` accepts as debt; `PRD_PMO_M365_v2_0_M2_FINAL.md` lists all 6 feature areas as in-scope for product; `EVIDENCE_LOG.md` E-026 to E-037 show legacy flows with active tenant data. |
| Risk assessment | KEEP risk: zero — already in production, no regression. DELETE risk: high — 6 feature areas vanish from bot; users can't manage projects/decisions/risks via chat; rebuild = 3-5 days; user-visible breakage. |

---

### Synthesis

| Field | Value |
|---|---|
| Status | <PENDING — until 14:00 BRT deadline> |
| Verdict | <PENDING> |
| Vote tally | <PENDING — A:n, B:n, C:n, D:n, ABSTAIN:n> |
| Owner ratification | <PENDING> |
| Recorded in | `DECISION_LOG_3_21.md` after Owner ratifies |

---

# Future decisions queued (open as needed)

| ID | Topic | Category | Will open when |
|---|---|---|---|
| DEC-3_21-002 | `gstf_sharepoint` if orphan: KEEP or DELETE | DELETE-CRIT | After WP1 graph confirms inbound count |
| DEC-3_21-003 | `PM0_PA_OpsFailureHandling` if orphan: KEEP or DELETE | DELETE-CRIT | After WP1 graph confirms (Owner pre-decided DELETE 2026-05-24 13:29 BRT) |
| DEC-3_21-004 | Forensic interpretation of 40 publish errors → are they topic-level or workflow-level? | FORENSIC-CRIT | After Codex #3 Sub 3A extracts raw errors |
| DEC-3_21-005 | If WP4 build SHA differs from expected, is this acceptable drift or rebuild trigger? | ARCH-CRIT | After WP4 if applicable |
| DEC-3_21-006 | Schedule for 7 legacy migration future sprint (assuming KEEP) | TIMELINE-CRIT | After 3.21 SHIP |

---

# Update protocol

When a new decision opens:

1. Opus 4.7 (Kiro) appends a new `DEC-3_21-NNN` block to this board
2. Posts notification in `T0_PROGRESS_BOARD.md` Recent events feed: `| <BRT> | Opus 4.7 | DEC-3_21-NNN OPENED — voting deadline <BRT> — see <board path> |`
3. All 5 voting agents see the update on next 5min check-in cycle
4. Each writes their vote in their own subsection (concurrent, no waiting)
5. Owner reads board live during voting window
6. After deadline, Opus 4.7 synthesizes + Owner ratifies
7. Verdict locked into `DECISION_LOG_3_21.md`

# Anti-pattern alerts (do not repeat)

| Anti-pattern | Why it's wrong |
|---|---|
| Sequential voting (A votes, then B reads A's vote, then B votes) | Causes bottleneck + groupthink. Concurrent rule prevents this. |
| Re-opening a decision already ratified by Owner | Closed = closed unless concrete new evidence emerges |
| Voting without citing specific evidence path | Opus 4.7 invalidates such votes |
| Owner deferring all decisions to agents | Some decisions (product scope, deletes that affect features) need Owner's call |
