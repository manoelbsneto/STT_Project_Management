# PMO 3.21 — Resource Allocation Plan (Maximum Efficiency)

| Field | Value |
|---|---|
| Document type | Master orchestration plan + resource allocation |
| Created | 2026-05-24 13:14 BRT |
| Author | Opus 4.7 (Kiro) — Orchestrator |
| Mission | PM0-3_21-CONSOLIDATION |
| Constraint | No tenant write/import/publish/deploy/commit unless Owner approves the exact action |

## 0. MANDATORY INHERITANCE — All Existing Rules Carry Forward

This plan **inherits and enforces** every rule already established in the project. Nothing previously mandatory becomes optional in 3.21. Below is the explicit inheritance contract — each agent in this mission acknowledges and complies with all of them BEFORE starting any WP.

### 0.1 — Mandatory Reading (every agent, every session, before claiming any WP)

| # | Document | Reading mode | Purpose |
|---|---|---|---|
| R1 | `.planning/GOLDEN_RULES.md` | Linear, complete | Project-wide non-negotiables |
| R2 | `.planning/TENANT_COMMAND_RUNBOOK.md` | Linear, complete | Tenant IDs, exact tool versions, "do not declare blocker before exhausting alternatives" |
| R3 | `.planning/SHAREPOINT_ACCESS_RUNBOOK.md` | Linear, complete | PowerShell 5.1 + PnP 3.29.2101.0 + UseWebLogin pattern |
| R4 | `.planning/power-platform-tooling-guide.md` | Linear, complete (~1000 lines) | PAC ecosystem, MCP servers, alternative paths |
| R5 | `.planning/CURRENT_BASELINE.md` | Linear | Current tenant state of truth |
| R6 | `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md` | Linear | Stop-ship quality gates |
| R7 | `.planning/comms/codex_pm0_remediation_20260522/T0_PROGRESS_BOARD.md` | Linear | Current mission board (live) |
| R8 | `.planning/AGENT_CHECKIN_REGISTRY.md` | Linear | Agent activity log (append-only) |
| R9 | This file (RESOURCE_ALLOCATION_PLAN_3_21.md) | Linear, complete | 3.21 mission rules |
| R10 | `TASK_FORCE_OPERATING_MODEL_3_21.md` | Linear, complete | Roles + work packages |

Reading proof requirement: each agent produces `READING_LOG.md` in their WP directory with line count + SHA256 + reading time per document. **No WP work begins without this file.**

### 0.1.1 — REMOTE CONNECTION + AUTH BIBLE (Mandatory CORE — read line-by-line, no exceptions)

This is the most important section. Owner invested **6 months** of real project experience compiling these documents. They contain every workaround, every version pin, every alternative path that has been proven to work in this corporate tenant. **Skipping any of these or reading via grep/keyword is FAIL_DISCIPLINE FD-02.**

| # | Document | Lines (approx) | What it covers |
|---|---|---:|---|
| **C1** | `.planning/power-platform-tooling-guide.md` | **~1000** | Master doc. PAC CLI ecosystem complete reference: VSIX extension, PAC MCP server (official + community), GitHub Actions for ALM, full PAC command reference, decision matrix for which tool to use when, installation checklist, references and links. **6 months of compiled real-world experience in this exact tenant.** |
| **C2** | `.planning/TENANT_COMMAND_RUNBOOK.md` | ~330 | Exact tenant IDs, exact tool versions confirmed working (Windows PowerShell 5.1.26100.8115, PowerShell Core 7.6.1, PAC CLI 2.6.4, SharePointPnPPowerShellOnline 3.29.2101.0, Microsoft.PowerApps.PowerShell 1.0.45, Microsoft.PowerApps.Administration.PowerShell 2.0.217). Rules that cannot be broken. |
| **C3** | `.planning/SHAREPOINT_ACCESS_RUNBOOK.md` | ~80 | The authoritative SharePoint provisioning path. Hard rules: do NOT use `pwsh`/PS7 for tenant provisioning, do NOT use modern PnP.PowerShell with `-Interactive`, do NOT use device code, do NOT use ClientId/Entra app registration/certificate/service principal/Graph direct/premium HTTP. |
| **C4** | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/AUTH_RESOLUTION_TRAIL.md` | live | Documented working auth path from 2026-05-24 mission — what worked when AADSTS70043 expired |
| **C5** | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/00_auth_verify_20260523_000318.md` | live | Past auth resolution case 1 |
| **C6** | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/00_auth_verify_20260523_020002.md` | live | Past auth resolution case 2 |
| **C7** | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/00_auth_verify_20260523_020132.md` | live | Past auth resolution case 3 |
| **C8** | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/T0_PREFLIGHT_RERUN_MANIFEST.md` | live | Sub 2A's PAC FetchXML fallback that resolved 403 error |

**Reading discipline for C1 (the ~1000-line master)**:
- Read sequentially from line 1 to last line — no skipping, no grep
- For each numbered section (1 through 9), produce a paragraph in your own words in `READING_SUMMARY_C1.md`
- Cite at least 30 individual rules / commands / workarounds with `path:line` format in your `RULES_INTERNALIZED.md`
- If you encounter a command pattern unfamiliar to your default behavior, default to the doc's pattern, not yours

**Why this matters for 3.21 mission specifically**:
- Different commands need different client versions. Example: SharePoint legacy needs Windows PS 5.1 + SharePointPnPPowerShellOnline 3.29.2101.0 + `Connect-PnPOnline -UseWebLogin` (per C2 + C3). PAC CLI 2.6.4 sometimes needs different auth flow than az CLI (per C1). PowerShell 7 is FORBIDDEN for SharePoint legacy operations.
- Corporate tenant blocks: no Azure AD principal direct, no app registration, no service principal, no certificate auth, no Graph direct, no premium HTTP. Only documented workarounds work.
- Personal Azure account `manoel.benicio@icloud.com` has historically been used as an auth-inversion vector when corporate tenant blocks something. Pattern: authenticate first in personal Azure, then switch context to operate in tenant. Look for this pattern in C1 sections relevant to your task.
- Existing `AUTH_RESOLUTION_TRAIL.md` (C4) and PREFLIGHT auth_verify files (C5–C7) document EXACTLY which auth paths worked in this exact tenant in the last 48 hours. **REPLICATE that pattern. Do not invent new ones until those are exhausted.**

**FAIL_DISCIPLINE for this section**:
- FD-02-EXTENDED: Declaring "X auth method does not work" without evidence of having tried every documented path in C1 + C2 + C4 = FAIL_DISCIPLINE
- FD-11 (NEW): Skipping linear reading of C1 ~1000 lines and using grep/keyword as substitute = FAIL_DISCIPLINE
- FD-12 (NEW): Inventing a new auth approach when documented working paths exist in C4/C5/C6/C7/C8 without first replicating those = FAIL_DISCIPLINE

### 0.2 — Check-in / Check-out Protocol (PUBLIC + MANDATORY)

Single source of truth: `.planning/comms/codex_pm0_remediation_20260522/T0_PROGRESS_BOARD.md`. Owner reads this. Every agent writes to it in real time.

**Three-Element Check-in Rule** (no exceptions, applies to every entry):

| # | Element | Format | Example |
|---|---|---|---|
| 1 | Agent name (full label) | Lead/Sub identifier exactly as in board | `Codex #2 Sub 2A`, `Codex #3 Lead`, `Opus 4.6` |
| 2 | Full timestamp BRT | `YYYY-MM-DD HH:MM:SS BRT` | `2026-05-24 13:30:00 BRT` |
| 3 | Screenshot path | Full repo-relative `.png` path under track's evidence root | `.planning/.../screenshots/<UTC>_<AgentLabel>_<artifact>.png` |

A check-in missing any of the three is **invalid** — Opus 4.7 reverts on sight + posts correction notice in Recent events feed; agent must re-post before continuing.

**Cadence:**
- Every **5 minutes** while actively executing a task (current-state screenshot, even mid-work)
- On every **state transition**: claim, complete, raise blocker, clear blocker
- Phase entry: lead posts CLAIMED in `T0_PROGRESS_BOARD.md`
- Phase exit: lead posts COMPLETE + verdict file path

**Per check-in, update ALL of:**
1. Your row in "All actors" section of `T0_PROGRESS_BOARD.md`
2. Append one line to "Recent events feed" (trim to latest 10)
3. Update `Last refreshed` header at top of board
4. Append entry to `Agent Activity Log` of `AGENT_CHECKIN_REGISTRY.md`

**Forbidden modifications** (Opus 4.7-only):
- Other agents' DONE rows
- Status legend
- Mission phase progression rows (T0→T1→...)
- T0 success criteria item descriptions
- Active blockers table (unless raising/clearing your own)

### 0.3 — Evidence Triplet Rule (every artifact, every WP)

For each artifact produced, three files MUST exist under the agent's evidence root:

```
<UTC>_<AgentLabel>_<artifact_name>.txt   — log
<UTC>_<AgentLabel>_<artifact_name>.json  — structured
<UTC>_<AgentLabel>_<artifact_name>.png   — screenshot (referenced in check-in)
```

The `.png` is what satisfies the mandatory check-in screenshot element. No triplet = invalid evidence.

### 0.4 — Quality Gates (SEV-0 stop-ship; non-negotiable)

| Gate | Type | Inherited from | When enforced |
|---|---|---|---|
| 1. `Test-SolutionXmlSchemaValidity.ps1` | Static | 3.19/3.20 BUILD_REPORT | WP4 + WP5 |
| 2. PM0 placeholder scan | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 3. `Test-Pm0WorkflowResponseSemantics.ps1` | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 4. `Test-Pm0TopicActionFlowContract.ps1` | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 5. `Test-PMOFlowStopShipAudit.ps1` | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 6. `Test-SolutionZipP0Contracts.ps1` | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 7. `Test-SolutionZipP24Contracts.ps1 -ExpectedVersion 3.21.0.0` | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 8. `Test-CopilotRoutingInstructions.ps1` | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 9. `Test-CopilotPowerFxRegexSafety.ps1` | Static | 3.19 BUILD_REPORT | WP4 + WP5 |
| 10. Status Diario required-field gap check | Static | 3.20 BUILD_REPORT | WP4 + WP5 |
| 11. AQ-08 post-remediation reverify | Tenant | AQ-08 ADR | WP6 post-import |
| 12. AQ-09 Section A smoke (A1–A5) | Runtime | AQ-09 runbook | WP6 post-publish |
| 13. Copilot Studio Topic Checker (zero validation errors) | Runtime UI | Inherited from 3.20 publish failure | WP6 post-publish all customizations |
| 14. Bot publish must show "Publish successful" + zero topic errors | Runtime UI | Inherited from 3× publish failures | WP6 |

ALL 14 gates must PASS for SHIP. If any fails: stop-ship, root-cause, remediate, re-run.

### 0.5 — Golden Rules (carry forward verbatim from `.planning/GOLDEN_RULES.md` + project history)

| GR | Rule | Source |
|---|---|---|
| GR-01 | Default release state is NO-SHIP until current static + runtime evidence proves otherwise | `SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL` |
| GR-02 | CI may be ignored only when explicitly Owner-excluded; every other quality gate is mandatory | idem |
| GR-03 | No tenant import/publish/deploy/commit/delete/portal-modify/production-write without explicit Owner approval in current thread | `GOLDEN_RULES.md` |
| GR-04 | Use Windows PowerShell 5.1 for legacy PnP SharePoint; do NOT use PowerShell 7 | `SHAREPOINT_ACCESS_RUNBOOK.md` |
| GR-05 | Use SharePointPnPPowerShellOnline 3.29.2101.0 with `-UseWebLogin` for SharePoint operations | idem |
| GR-06 | NEVER use Microsoft 365 CLI (`m365`) — explicitly prohibited in this project | `GOLDEN_RULES.md` |
| GR-07 | All shipped app-facing text must be ASCII-only (no accents, cedilla, emojis, smart punctuation, mojibake) | `GOLDEN_RULES.md` + `CURRENT_BASELINE.md` |
| GR-08 | Use Portuguese only when ASCII-safe (`Concluida`, `Critica`, `Media`, `Proxima acao`) | idem |
| GR-09 | Always use `ColOfertasBrasilPro` environment, never Default | `STATE.md` Decision 9 |
| GR-10 | "Não declarar bloqueio antes de testar Windows PowerShell 5.1 com import absoluto dos módulos" | `TENANT_COMMAND_RUNBOOK.md:30` |
| GR-11 | For PAC auth issues, exhaust all 11 documented paths before declaring HOLD | inherited from `AUTH_RESOLUTION_TRAIL.md` precedent |
| GR-12 | Each Codex (1, 2, 3) may use up to 3 subagents in parallel — disjoint write scope only | Owner directive 2026-05-24 |
| GR-13 | Subagent overlap = process violation. Lead-only merge of subagent outputs | inherited from operating model |
| GR-14 | Test flows one by one (no shotgun runtime testing) | `CURRENT_BASELINE.md` |
| GR-15 | Read mandatory docs LINEARLY, line by line — no grep / keyword search as substitute | inherited from R&D Disciplina v2 prompt |
| GR-16 | Local file edits, local package preparation, and local tests are allowed; tenant write is Owner-controlled | `CURRENT_BASELINE.md` |

### 0.6 — FAIL_DISCIPLINE Clauses (active in this mission)

| ID | Trigger | Consequence |
|---|---|---|
| FD-01 | Agent declares "X doesn't work / doesn't exist" without exhausting all documented alternatives, and Owner/another agent proves X works | Mission marked FAIL_DISCIPLINE; agent removed from project; financial penalty per contract |
| FD-02 | Agent skips linear reading of mandatory docs (R1–R10) and uses grep/keyword as substitute | FAIL_DISCIPLINE |
| FD-03 | Agent writes to another agent's evidence directory or modifies another agent's DONE row | FAIL_DISCIPLINE |
| FD-04 | Agent claims COMPLETE without producing required triplet (txt+json+png) | check-in invalidated; if repeated, FAIL_DISCIPLINE |
| FD-05 | Agent introduces non-ASCII text in app-facing artifacts | stop-ship; remediate before continuing |
| FD-06 | Agent performs tenant write without explicit Owner approval recorded in T0_PROGRESS_BOARD | mission immediately HALT; investigation required |
| FD-07 | Agent skips a quality gate or fakes its result | FAIL_DISCIPLINE |
| FD-08 | Subagent overlap (two subs writing same scope) | rejected output; lead must redispatch with disjoint scopes |
| FD-09 | Agent uses M365 CLI (`m365`) | FAIL_DISCIPLINE |
| FD-10 | Agent skips a convergence point (CONVERGENCE A/B/C) and dispatches next phase without Opus 4.7 verdict | reverted; Opus 4.7 issues correction notice |

### 0.7 — Agent Acknowledgement Template (every WP claim must include)

When an agent claims a WP, the check-in MUST include this acknowledgement line:

> "Acknowledged: R1–R10 read linearly with READING_LOG produced. Will comply with GR-01 to GR-16, all 14 quality gates relevant to my WP, triplet rule, 5min cadence, FD-01 to FD-12. Disjoint write scope confirmed. Acknowledged execution-velocity rules in section 0.8."

This is non-decorative. If the line is missing, Opus 4.7 reverts the claim.

### 0.8 — EXECUTION VELOCITY (Owner directive 2026-05-24 13:28 BRT)

This mission prioritizes **action over validation**. Validation rounds beyond what's required by the 14 quality gates are forbidden waste. Owner will recover from any breakage manually if it occurs.

**Hard rules:**

| EV | Rule | Rationale |
|---|---|---|
| EV-01 | **Connection references are NOT blockers.** If a conn ref is missing, broken, points to deleted accelerator, or has auth issue: log it, move on, Owner creates a new one manually in tenant if needed | Owner directive: "eu vou la manualmente e crio uma nova se necessario" |
| EV-02 | **Single verification round per artifact.** Each gate runs ONCE. No "let me double-check by running it again." Trust your own evidence triplet | No double/triple check imbecis |
| EV-03 | **Lead-only merge of subagent outputs is the verification.** Do NOT add a separate Lead self-review pass on top | Reduces redundancy |
| EV-04 | **Peer review is ONE pass.** Codex #1 reviews once. Opus 4.6 reviews once. No back-and-forth iterations unless concrete defect found | Avoid review death-spiral |
| EV-05 | **Fail forward.** If Phase D breaks something at runtime: capture exact failure, root-cause, fix at source, rebuild, re-import. Do NOT add pre-flight checks that would have caught it. The 14 quality gates are sufficient. | Action > paranoid pre-checks |
| EV-06 | **No "exploratory" cross-validation between agents on same scope.** Each agent has their scope. Other agents do not re-verify it unless they own a downstream gate. | Disjoint scopes are enforcement, not double-coverage |
| EV-07 | **Owner-domain decisions stay with Owner.** Don't analyze whether Owner should create conn ref X. Just flag what's needed and continue | Time discipline |
| EV-08 | **No speculative remediation.** If WP1A forensics finds 40 errors, fix exactly those 40. Do not add "while we're here, let's also fix Y" unless Y is in DO_NOT_REGRESS_LIST | Scope discipline |
| EV-09 | **No retro-validation of completed WPs.** Once a WP is signed off and dispatched downstream, it is closed. Reopen only on concrete failure evidence | Forward momentum |
| EV-10 | **Time budget per WP is enforced.** If a WP exceeds 1.5× its ETA, lead reports HALT to Opus 4.7 with concrete blocker — Opus 4.7 either grants extension or splits/repaths | Failsafe against rabbit holes |

**Execution mode**: ship fast, fail fast, recover fast. The 14 quality gates + RCA + peer review are the safety net. Anything beyond that is bureaucracy.

## 1. Capacity Inventory (17 workers + 1 orchestrator)

| Slot | Agent | Capacity | Location |
|---|---|---|---|
| 1 | Opus 4.7 (Kiro) | Orchestrator | Owner's right-IDE |
| 2 | Opus 4.6 | Senior R&D reviewer | Owner side, right |
| 3 | Codex #1 Lead | Independent peer reviewer | Owner side, left |
| 4–6 | Codex #1 Sub 1A, 1B, 1C | Parallel verification slices | Same session |
| 7 | Codex #2 Lead | Build owner | Other IDE, left |
| 8–10 | Codex #2 Sub 2A, 2B, 2C | Parallel build/graph/diff | Same session |
| 11 | Codex #3 Lead | Forensics + special projects | TBD on demand |
| 12–14 | Codex #3 Sub 3A, 3B, 3C | Parallel forensic slices | Same session |
| 15 | Gemini Lead | Fast verification | Other IDE, central |
| 16–17 | Gemini Sub G1, G2 | Targeted slice checks | Same session |

Total active workforce when fully deployed: **17 parallel workers** under Opus 4.7 coordination.

## 2. Phase / WP Map (with parallelism)

```
PHASE A — DISCOVERY (≈45 min, full parallelism)
├── WP0  Freeze + Baseline                    [Codex #2 Lead]               5  min
├── WP1  Dependency Graph                     [Codex #2 Lead + 3 subs]      30 min  ╮
├── WP1A Publish Error Forensics              [Codex #3 Lead + 3 subs]      30 min  ├─ parallel
├── WP1B Historical Baseline Review           [Codex #1 Lead + 3 subs]      30 min  │
└── WP1C Architecture Challenge Review        [Opus 4.6]                    30 min  ╯

CONVERGENCE A — Opus 4.7 consolidates (5 min)

PHASE B — CONVERGENCE + CLEANUP (≈30 min, partial parallelism)
├── WP2  Connection Ref Consolidation         [Codex #2 + Gemini Sub G1]    15 min  ╮
└── WP3  Dead Component Cleanup               [Codex #2 + Gemini Sub G2]    15 min  ╯

CONVERGENCE B — Opus 4.7 reviews + Codex #1 quick check (5 min)

PHASE C — BUILD + REVIEW (≈45 min)
├── WP4  Package Build 3.21                   [Codex #2 + 3 subs]           20 min  ╮
└── WP5  Peer Review Gate                     [Codex #1 + 3 subs + Opus 4.6] 25 min ╯ partial parallel

CONVERGENCE C — Opus 4.7 consolidates verdict (5 min)

PHASE D — OWNER EXECUTION (≈30 min)
└── WP6  Owner Tenant Execution               [Owner + Codex #2 + 3 subs]   30 min

TOTAL CRITICAL PATH: ~2h 30min wall-clock
TOTAL WORK if sequential: ~4h 45min
EFFICIENCY GAIN: ~47% (parallelism)
```

## 3. Detailed Work Package Allocation

### WP0 — Freeze And Baseline

| Item | Value |
|---|---|
| Owner | Codex #2 Lead |
| Subs | None (lead-only) |
| Inputs | `PMO_v11_Tarefas_3_20_0_1.zip`, `CURRENT_SOLUTION_3_20_0_1_REVIEW.json` |
| Outputs | `BASELINE_FREEZE.md`, `DECISION_LOG_3_21.md` (initialized) |
| ETA | 5 min |
| Stop condition | SHA mismatch with declared baseline |

### WP1 — Dependency Graph

| Item | Value |
|---|---|
| Owner | Codex #2 Lead |
| Subs | Codex #2 Sub 2A, 2B, 2C (disjoint scope) |
| Sub 2A | Topic graph (parse 18 topic YAMLs → action refs) |
| Sub 2B | Action graph (parse action data files → workflow refs) |
| Sub 2C | Workflow + connection ref graph (parse workflow JSONs → triggers/actions/connRefs) |
| Lead consolidation | Merge 3 partial graphs + classify components |
| Outputs | `DEPENDENCY_GRAPH_3_21.json`, `DEPENDENCY_GRAPH_3_21.md` |
| ETA | 30 min |
| Anti-overlap | Each sub writes only to its own `subagent_outputs/sub<N>_*.json`. Lead-only merge. |

### WP1A — Publish Error Forensics 🔥 (CRITICAL — never done)

| Item | Value |
|---|---|
| Owner | **Codex #3 Lead** |
| Subs | Codex #3 Sub 3A, 3B, 3C |
| Mission | Reverse-engineer the 40 publish errors that have appeared 3× |
| Sub 3A | Extract raw "Mostrar bruto(a)" content from each of 5 topics via Copilot Studio API or browser automation (with Owner consent for browser session if needed) |
| Sub 3B | Decode and classify each error into categories: binding mismatch / variable ref / schema / connection ref / other |
| Sub 3C | Map each error → specific fix required in 3.21 source |
| Outputs | `PUBLISH_ERROR_FORENSICS.md`, `ERROR_TO_FIX_MATRIX.json` |
| ETA | 30 min |
| Why critical | The 40 errors persist across `_3_18.zip` import, canonical `_3_20.zip` import, and "Publicar todas as personalizações" — root cause is at topic-checker level, not workflow level. WP1A finds the missing piece that WP1 + AQ-08 reverify cannot detect. |

### WP1B — Historical Baseline Review

| Item | Value |
|---|---|
| Owner | Codex #1 Lead |
| Subs | Codex #1 Sub 1A, 1B, 1C |
| Mission | Ensure 3.21 doesn't regress any prior fix |
| Sub 1A | Diff 3.20.0.1 vs 3.19 (last known state pre-StatusID) — extract every fix that 3.19 had |
| Sub 1B | Diff 3.20.0.1 vs canonical 3.20.0.0 — confirm 3.20.0.1 contains everything from 3.20.0.0 |
| Sub 1C | List all fixes from 3.10 → 3.20 (StatusID, OrigemEntrada/Value, coalesce numeric, action bindings, content-safe outputs, BR date parser, etc) — produce **DO_NOT_REGRESS_LIST.md** |
| Outputs | `HISTORICAL_FIX_INVENTORY.md`, `DO_NOT_REGRESS_LIST.md` |
| ETA | 30 min |

### WP1C — Architecture Challenge Review

| Item | Value |
|---|---|
| Owner | Opus 4.6 |
| Subs | None (senior independent) |
| Mission | Challenge consolidation correctness from architecture POV |
| Concerns | Removing `CopilotStudioAccelerator` dependency without breaking runtime; replacing connection refs without breaking auth flows; topic-checker validation rules that we may not understand |
| Outputs | `ARCHITECTURE_CHALLENGE_3_21.md` with risks + recommendations |
| ETA | 30 min |

### CONVERGENCE A — Opus 4.7 Consolidation (5 min)

Opus 4.7 (me) reads outputs from WP1, WP1A, WP1B, WP1C and produces:
- `CONVERGENCE_A_VERDICT.md`: integrated decision matrix combining graph + forensics + history + architecture
- Updated `DECISION_LOG_3_21.md` with all KEEP / DELETE_CANDIDATE / MIGRATE / INVESTIGATE_FIRST + INCLUDE_FIX_FROM_FORENSICS rows
- Dispatch prompts for Phase B

### WP2 — Connection Reference Cleanup (simplified per EV-01)

| Item | Value |
|---|---|
| Owner | Codex #2 Lead |
| Subs | None (lead-only — single pass per EV-02) |
| Reviewer | None (no cross-validation per EV-06; EV-01 says conn refs are not blockers) |
| Tasks | (1) Remove `cat_DataverseIndexerSharePoint` reference from `solution.xml` MissingDependencies + workflow JSONs that import it. (2) Same for `cat_sharedteams_1ef7e`. (3) Same for `gstf_sharepoint` if zero inbound. (4) Produce `WP2_CONNECTION_REFS_DELTA.md` listing what was removed + what conn refs Owner may need to create manually in tenant post-import (if any). |
| What is NOT in scope | Programmatically creating new conn refs. Trying to "fix" auth flows. Replacing one accelerator dep with another. |
| Outputs | Updated source files, `WP2_CONNECTION_REFS_DELTA.md` (with section "Owner manual action needed: <list>") |
| ETA | **5 min** (down from 15 — EV-01 simplification) |
| Stop condition | Any conn ref removal breaks an inbound dep that wasn't in graph → log to INVESTIGATE_FIRST + revert that single removal, continue with others |

### WP3 — Dead Component Cleanup

| Item | Value |
|---|---|
| Owner | Codex #2 Lead |
| Subs | Codex #2 Sub 2B (apply deletes), Sub 2C (verify zero inbound deps post-delete) |
| Reviewer | Gemini Sub G2 (root component / workflowset cross-check) |
| Tasks | Remove `PM0_PA_OpsFailureHandling` if dead; remove `PMO_PA_AtualizarStatus` (legacy) if no inbound; remove `PMO_PA_ConsultarPortfolio` (legacy) if no inbound; evaluate other legacy bindings |
| Outputs | Updated source files, `WP3_CLEANUP_DELTA.md` |
| ETA | 15 min |
| Stop condition | Any deletion that breaks an inbound dep that wasn't visible in WP1 graph → revert + INVESTIGATE_FIRST |

### CONVERGENCE B — Opus 4.7 + Codex #1 Quick Check (5 min)

Opus 4.7 consolidates WP2 + WP3 deltas. Codex #1 Lead does a fast inbound-dep recompute on the post-cleanup state to catch anything WP1 graph missed.

### WP4 — Package Build 3.21

| Item | Value |
|---|---|
| Owner | Codex #2 Lead |
| Subs | Sub 2A (apply approved deletes/migrates from DECISION_LOG), Sub 2B (re-run 10 static gates), Sub 2C (generate diff 3.20.0.1 → 3.21) |
| Outputs | `PMO_v11_Tarefas_3_21_0_0.zip`, `BUILD_REPORT_3_21.md`, `PACKAGE_DIFF_3_20_0_1_TO_3_21.md`, 10/10 gates exit 0 |
| ETA | 20 min |
| Stop condition | Any of 10 static gates fails → HALT, root-cause, fix, re-run |

### WP5 — Peer Review Gate (parallel with WP4 review windows)

| Item | Value |
|---|---|
| Owner | Codex #1 Lead |
| Subs | Sub 1A (SHA recompute + 10 gates rerun), Sub 1B (per-defect verification using DO_NOT_REGRESS_LIST), Sub 1C (anti-drift diff: only authorized changes vs 3.20.0.1) |
| Senior review | Opus 4.6 — final architecture sign-off |
| Outputs | `PEER_REVIEW_CODEX1_3_21.md` (PASS / PASS_WITH_NOTES / FAIL), `PEER_REVIEW_OPUS46_3_21.md` |
| ETA | 25 min |
| Gate to Phase D | BOTH must be PASS or PASS_WITH_NOTES (not FAIL) |

### CONVERGENCE C — Opus 4.7 Final Verdict (5 min)

Opus 4.7 reads both peer reviews + builds `FINAL_VERDICT_3_21.md` with PROCEED to WP6 or RECYCLE to WP4.

### WP6 — Owner Tenant Execution

| Item | Value |
|---|---|
| Owner | Owner (only one with tenant write rights) |
| Standby support | Codex #2 Lead + Sub 2A/2B/2C for read-only validation |
| Sequence | (a) Owner imports 3.21 zip → Sub 2A confirms `pac solution list` shows 3.21.0.0 → (b) Owner clicks "Publicar todas as personalizações" → Sub 2A re-checks workflow inventory all `Activado/Activado` → (c) Sub 2B runs AQ-08 reverify → (d) Sub 2C verifies `pac copilot list` Published/Active/Provisioned → (e) Owner clicks Publish in Copilot Studio → (f) Codex #2 Lead checks Copilot Studio for any topic validation errors (this is what we missed before — must be ZERO before declaring success) |
| Outputs | `WP6_TENANT_EXECUTION_LOG.md`, AQ-09 smoke evidence |
| ETA | 30 min |
| Stop condition | Any check fails → halt, dump state, root-cause |

## 4. Anti-Waste Rules (Reinforced)

| Rule | Enforcement Mechanism |
|---|---|
| One source of truth | Baseline ZIP declared in `BASELINE_FREEZE.md` only |
| No repeated broad analysis | Existing `CURRENT_SOLUTION_3_20_0_1_REVIEW.json` consumed before any new query |
| No blind cleanup | Every delete cites graph evidence + forensics fix-needed |
| No duplicate reports | Each agent writes one verdict file; subagents write `subagent_outputs/sub<N>_*` only |
| No speculative blockers | Blockers require exact component ID, file path, failing evidence |
| No scope creep | 3.21 is consolidation + publish unblock only |
| No manual-only fixes | Tenant UI fix must round-trip back into reproducible package |
| No subagent overlap | Each sub has disjoint write scope; lead-only merges |
| No phase skipping | Convergence points must produce verdict file before next phase dispatches |

## 5. Communication Model

| Cadence | Action |
|---|---|
| Every 5 min during active work | Each lead/sub posts triplet check-in |
| Phase entry | Lead posts CLAIMED in `T0_PROGRESS_BOARD.md` |
| Phase exit | Lead posts COMPLETE + verdict path |
| Conflict detected | Lead posts DEGRADED + escalates to Opus 4.7 via `ORCHESTRATION_STATUS_3_21.md` |
| Convergence | Opus 4.7 posts CONVERGENCE_X_VERDICT.md and dispatches next phase prompts |

## 6. Risk Register (3.21 specific)

| Risk ID | Description | Mitigation | Owner |
|---|---|---|---|
| R-3_21-01 | Topic-checker errors in WP6 even after WP1A forensics | WP1A produces `ERROR_TO_FIX_MATRIX.json`; WP4 applies all fixes; WP5 verifies match | Codex #3 Lead → Codex #2 → Codex #1 |
| R-3_21-02 | Removing accelerator dep breaks runtime auth | WP1C Opus 4.6 architectural challenge; WP2 keeps necessary refs | Opus 4.6 |
| R-3_21-03 | Subagent overlap produces inconsistent outputs | Lead-only merge; disjoint write scopes; pre-dispatch scope review | All leads |
| R-3_21-04 | New regression introduced by cleanup | DO_NOT_REGRESS_LIST from WP1B; Codex #1 Sub 1B verification | Codex #1 Sub 1B |
| R-3_21-05 | PAC auth expires mid-mission | AUTH_RESOLUTION_TRAIL pattern reused; Codex agents follow runbook | Each Codex Lead |
| R-3_21-06 | Owner unavailable for tenant write | Phase D blocks gracefully; remain in PROCEED state until Owner returns | Opus 4.7 |

## 7. Decision Authority Matrix

| Decision | Authority |
|---|---|
| Component KEEP / DELETE / MIGRATE | Codex #2 Lead (with WP1 graph + WP1A forensics evidence) |
| Architecture coherence | Opus 4.6 (WP1C) — can BLOCK |
| No-regress fidelity | Codex #1 Lead (WP1B + WP5) — can BLOCK |
| Static gate pass | Codex #2 Lead (WP4) — must reach 10/10 |
| Topic-checker fitness | Codex #3 Lead (WP1A) — produces required fix list |
| Phase promotion | Opus 4.7 (after convergence verdict) |
| Tenant write | Owner only — Opus 4.7 cannot bypass |
| Final SHIP | Opus 4.6 senior sign-off + Owner GO |

## 8. Files To Be Produced (canonical paths)

Root: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/current_solution_review_3_20_0_1/`

| File | Owner | Phase |
|---|---|---|
| `BASELINE_FREEZE.md` | Codex #2 | WP0 |
| `DECISION_LOG_3_21.md` | Codex #2 (init), all (append) | WP0+ |
| `DEPENDENCY_GRAPH_3_21.json` + `.md` | Codex #2 | WP1 |
| `subagent_outputs/sub2A_topic_graph.json` | Codex #2 Sub 2A | WP1 |
| `subagent_outputs/sub2B_action_graph.json` | Codex #2 Sub 2B | WP1 |
| `subagent_outputs/sub2C_workflow_connection_graph.json` | Codex #2 Sub 2C | WP1 |
| `PUBLISH_ERROR_FORENSICS.md` + `ERROR_TO_FIX_MATRIX.json` | Codex #3 | WP1A |
| `HISTORICAL_FIX_INVENTORY.md` + `DO_NOT_REGRESS_LIST.md` | Codex #1 | WP1B |
| `ARCHITECTURE_CHALLENGE_3_21.md` | Opus 4.6 | WP1C |
| `CONVERGENCE_A_VERDICT.md` | Opus 4.7 | Conv A |
| `WP2_CONNECTION_REFS_DELTA.md` | Codex #2 | WP2 |
| `WP3_CLEANUP_DELTA.md` | Codex #2 | WP3 |
| `CONVERGENCE_B_VERDICT.md` | Opus 4.7 | Conv B |
| `PMO_v11_Tarefas_3_21_0_0.zip` | Codex #2 | WP4 |
| `BUILD_REPORT_3_21.md` | Codex #2 | WP4 |
| `PACKAGE_DIFF_3_20_0_1_TO_3_21.md` | Codex #2 | WP4 |
| `PEER_REVIEW_CODEX1_3_21.md` | Codex #1 | WP5 |
| `PEER_REVIEW_OPUS46_3_21.md` | Opus 4.6 | WP5 |
| `FINAL_VERDICT_3_21.md` | Opus 4.7 | Conv C |
| `WP6_TENANT_EXECUTION_LOG.md` | Codex #2 + Owner | WP6 |
| `ORCHESTRATION_STATUS_3_21.md` | Opus 4.7 (live) | All |

## 9. Dispatch Sequence (executable)

| Step | Trigger | Action | Dispatch target |
|---|---|---|---|
| S1 | NOW | Dispatch WP0 + WP1 | Codex #2 Lead |
| S2 | Same time as S1 | Dispatch WP1A | Codex #3 Lead |
| S3 | Same time as S1 | Dispatch WP1B | Codex #1 Lead |
| S4 | Same time as S1 | Dispatch WP1C | Opus 4.6 |
| S5 | All of WP1/A/B/C COMPLETE | Build CONVERGENCE_A_VERDICT.md | Opus 4.7 (me) |
| S6 | After S5 | Dispatch WP2 + WP3 | Codex #2 Lead + Gemini A/B |
| S7 | After WP2 + WP3 COMPLETE | CONVERGENCE_B_VERDICT.md | Opus 4.7 |
| S8 | After S7 | Dispatch WP4 | Codex #2 Lead |
| S9 | After S7 | Dispatch WP5 | Codex #1 Lead + Opus 4.6 |
| S10 | After WP4 + WP5 COMPLETE | FINAL_VERDICT_3_21.md | Opus 4.7 |
| S11 | After S10 (PROCEED) | Owner imports + publishes | Owner + Codex #2 standby |

## 10. Success Criteria

The mission succeeds when ALL of:

1. ✅ One reproducible local package `PMO_v11_Tarefas_3_21_0_0.zip` exists
2. ✅ 10/10 static gates exit 0
3. ✅ Codex #1 verdict PASS or PASS_WITH_NOTES
4. ✅ Opus 4.6 verdict PASS
5. ✅ Owner imports + publishes all customizations + bot publish all green
6. ✅ Copilot Studio shows ZERO topic validation errors (this is what failed all 3× before)
7. ✅ AQ-09 Section A smoke A1–A5 all PASS
8. ✅ A4 (AtualizarStatus) writes row with non-empty `StatusID` to SharePoint

Failure modes and recovery paths are documented in section 6.
