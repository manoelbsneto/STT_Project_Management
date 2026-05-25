# T0 Gate Transition Sanity Protocol — Opus 4.6 Architectural Review

| Field | Value |
|---|---|
| Author | Opus 4.6 (Track Γ — Architecture + Risk) |
| Role | Final SHIP/NO-SHIP arbiter after AQ-09 Section A passes |
| Created | 2026-05-23 16:35:00 BRT |
| Last updated | 2026-05-23 16:35:00 BRT |
| Controlling gate model | 3-gate: 4A (import) → 4B (publish) → 4C (AQ07 cleanup), with AQ-09 Section A mandatory between 4B and 4C |
| Decision authority | Owner approval per Decision Responses Section 9 |

---

## Gate 4A → 4B (Import → Publish)

### Minimum Evidence Opus 4.6 Must See Before Sign-Off

| # | Evidence Item | Source | Format | Mandatory? |
|---|---|---|---|---|
| 4A-1 | Package SHA256 matches `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` | `pac solution import` output or manual SHA-verify command | Screenshot + timestamp BRT + agent name | **YES** |
| 4A-2 | Target environment confirmed as `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) | `pac env who` or import command environment flag | Screenshot | **YES** |
| 4A-3 | Import command exit code = 0 | Terminal output | Screenshot | **YES** |
| 4A-4 | Post-import SHA read-back: `pac solution export` of `PMO_v11_Tarefas` from tenant, SHA256 computed and compared | Sub 2C `T0_SHA_COMPARE.ps1` output | PASS/FAIL + both SHAs | **YES** |
| 4A-5 | Post-import `pac solution list` showing `PMO_v11_Tarefas` version updated | Terminal output | Screenshot | **YES** |
| 4A-6 | Post-import spot-check: at least 1 PM0 workflow root component now appears in `PMO_v11_Tarefas` solutioncomponent table (if Dataverse read is available) | FetchXML query result | Structured evidence | Conditional (only if 403 resolved) |

### Red-Flag Conditions That Block Sign-Off

| # | Red Flag | Action |
|---|---|---|
| 4A-R1 | Post-import SHA diverges from pre-import package SHA by more than expected Dataverse re-serialization | HALT. Do NOT proceed to 4B. Investigate whether Dataverse modified the solution during import. |
| 4A-R2 | Import command returns non-zero exit code | HALT. Capture full error output. Determine if partial import occurred. |
| 4A-R3 | `pac solution list` shows PMOv11 version unchanged after import | HALT. Import may have failed silently or targeted wrong solution. |
| 4A-R4 | Any tenant-side MissingDependency error during import referencing `cat_DataverseIndexerSharePoint` or other connector | HALT. Dependency gap prevents PM0_PA_Card_ListarTarefas from functioning. Resolve before publish. |

---

## Gate 4B → AQ-09 Section A (Publish → Runtime Smoke)

### Minimum Evidence Opus 4.6 Must See Before Sign-Off

| # | Evidence Item | Source | Format | Mandatory? |
|---|---|---|---|---|
| 4B-1 | `pac copilot publish` for `Assistente PMO V2` exit code = 0 | Terminal output | Screenshot + timestamp BRT + agent name | **YES** |
| 4B-2 | `pac copilot list` shows `Assistente PMO V2` status = `Published / Active / Provisioned` | Terminal output | Screenshot | **YES** |
| 4B-3 | Publish UTC label captured | `pac copilot list` detailed output | Timestamp string | **YES** |
| 4B-4 | T+5min drift monitor shows no blocking regressions (structural routes intact) | AQ-08 reverifier output | PASS/FAIL + screenshot | **YES** |
| 4B-5 | Bot test panel accessible (Copilot Studio or Teams) | Visual confirmation | Screenshot | Encouraged |

### Red-Flag Conditions That Block Sign-Off

| # | Red Flag | Action |
|---|---|---|
| 4B-R1 | Publish command returns non-zero exit code | HALT. Bot may be in inconsistent state. Check `pac copilot list` for status. |
| 4B-R2 | `pac copilot list` shows status other than `Published / Active / Provisioned` | HALT. Bot may not be serving the new configuration. |
| 4B-R3 | T+5min drift shows any in-scope topic (5 PM0 topics) changed routing unexpectedly | HALT. Post-publish configuration may have regressed a PM0 route. |
| 4B-R4 | T+5min drift shows `blockingTopicCount > 0` | HALT. A topic that should route to PM0 is not routing. |

---

## AQ-09 Section A → Gate 4C (Runtime Smoke → AQ07 Cleanup)

### Minimum Evidence Opus 4.6 Must See Before Sign-Off

This is the **SHIP/NO-SHIP gate**. Opus 4.6 serves as the final arbiter.

| # | Evidence Item | Source | Format | Mandatory? |
|---|---|---|---|---|
| AQ09-1 | A1 (ListarTarefas/CMD-12-H) returns real task data, NOT static `"Tasks retrieved successfully."` | Copilot Studio test panel or Teams chat | Screenshot + timestamp BRT + agent name | **YES** — this is the exact test that failed on 2026-05-22 |
| AQ09-2 | A2 (CriarTarefa/CMD-15) creates a task and returns confirmation with real data | Test panel + SharePoint read-back | Screenshot + PnP read-back | **YES** |
| AQ09-3 | A3 (AtualizarStatus/CMD-11-P0) updates status and returns card with real data | Test panel + SharePoint read-back | Screenshot + PnP read-back | **YES** |
| AQ09-4 | A4 (AtualizarTarefa/CMD-13A) updates task fields and returns confirmation | Test panel + SharePoint read-back | Screenshot + PnP read-back | **YES** |
| AQ09-5 | A5 (ConsultarPortfolio/CMD-10) returns real portfolio summary | Test panel | Screenshot | **YES** |
| AQ09-6 | Zero `ContentFiltered` / `openAIIndirectAttack` recurrences on A1–A5 | Test panel response + flow run history | Screenshot per test | **YES** (per ADR §2.5 Section A) |
| AQ09-7 | Each test evidence has full triplet: screenshot + timestamp BRT + agent name | Per-test evidence files | File paths | **YES** |
| AQ09-8 | Flow run history for each test shows `Succeeded` with real backend calls | Power Automate run history or `pac flow` output | Screenshot | **YES** |

### Cross-Validation Against Merged RCA (Opus 4.6 Standby Task)

For each A1–A5 test result, Opus 4.6 will validate:

| Test | RCA Finding | Expected Behavior After Fix | Red Flag If... |
|---|---|---|---|
| A1 (ListarTarefas) | PM0-DEF-01/02: Static `"Tasks retrieved successfully."` returned instead of task data | Bot renders Adaptive Card with real SharePoint task items | Bot still returns static text or "Nao encontrei essa informacao" |
| A2 (CriarTarefa) | PM0-DEF-02/03/04: Workflow `PARTIAL`, action missing `inputs:`, topic `input: {}` | Bot confirms task creation with real task ID/title from SharePoint | Flow runs but returns static confirmation without real data |
| A3 (AtualizarStatus) | PM0-DEF-05: Only PM0 flow with NO backend action at all (`STUB`) | Bot confirms status update with real data from SharePoint | Flow has no SharePoint/Planner write action; returns generic success |
| A4 (AtualizarTarefa) | PM0-DEF-02/03/04: Workflow `PARTIAL`, action missing inputs | Bot confirms task update with real modified fields | Flow runs but doesn't actually write to SharePoint |
| A5 (ConsultarPortfolio) | PM0-DEF-02/03/04: Workflow `PARTIAL`, action missing inputs; topic `input: {}` (exception: ConsultarPortfolio has no required inputs) | Bot renders executive summary card with real portfolio data | Bot returns static summary text without real project data |

### Red-Flag Conditions That Block SHIP Sign-Off

| # | Red Flag | Action |
|---|---|---|
| AQ09-R1 | **Any** A1–A5 test returns static/placeholder text instead of real backend data | **NO-SHIP.** The core defect from RCA PM0-DEF-01/02 has not been fixed. |
| AQ09-R2 | **Any** A1–A5 test triggers `ContentFiltered` / `openAIIndirectAttack` | **NO-SHIP** per ADR §2.5 Section A: zero recurrences required for in-scope topics. |
| AQ09-R3 | Flow run history for any A1–A5 shows `Failed` or no backend connector calls | **NO-SHIP.** Functional DoD (GOLDEN_RULES) requires real flow call with real backend data. |
| AQ09-R4 | Any evidence item missing the mandatory triplet (screenshot + timestamp BRT + agent name) | **INCOMPLETE.** Cannot be cited as proof of PASS. Re-execute with full triplet. |
| AQ09-R5 | Post-AQ-09 T+5min drift monitor shows regression | **NO-SHIP.** Investigate whether AQ-09 tests caused side effects. |
| AQ09-R6 | SharePoint/Planner read-back for write tests (A2, A3, A4) does not confirm the written data | **NO-SHIP.** Flow may be returning success without actually writing. |

### SHIP Decision Protocol

```
IF all A1–A5 PASS with full triplets
   AND zero ContentFiltered on Section A
   AND flow run history shows Succeeded with real backend calls
   AND SharePoint read-back confirms write-side data
   AND T+5min drift PASS
   AND T+1h drift PASS
THEN → Opus 4.6 signs SHIP
        Gate 4C can be scoped and ASK drafted

ELSE → Opus 4.6 signs NO-SHIP
        Trigger recovery per Decision 2 (Owner manual backup)
        OR one bounded fix-repackage cycle if RCA is single-issue
```

---

## Gate 4C Cleanup — Post-SHIP Only

### Minimum Evidence Opus 4.6 Must See Before Sign-Off

| # | Evidence Item | Source | Format | Mandatory? |
|---|---|---|---|---|
| 4C-1 | AQ07 dependency tree audit complete (this mission's Deliverable 1) | `T0_AQ07_DEPENDENCY_TREE_AUDIT.md` | Document | **YES** — completed |
| 4C-2 | Post-import tenant solutioncomponent query confirms PMOv11 owns all 6 PM0 workflows | FetchXML query result | Structured evidence | **YES** |
| 4C-3 | AQ07 has zero unique live dependencies not covered by PMOv11 | Same FetchXML query | Analysis document | **YES** |
| 4C-4 | Explicit Owner per-step approval for AQ07 deletion | Chat thread | Written approval | **YES** (Decision 4 scope: 4C requires per-step) |
| 4C-5 | Pre-deletion snapshot of AQ07 solution state | `pac solution export` of AQ07 | ZIP file + SHA256 | **YES** — safety backup |
| 4C-6 | Post-deletion AQ-08 structural re-verify PASS | Reverifier output | PASS/FAIL + screenshot | **YES** |
| 4C-7 | Post-deletion AQ-09 A1 quick-check PASS | Bot test | Screenshot + triplet | Encouraged |

### Red-Flag Conditions That Block Sign-Off

| # | Red Flag | Action |
|---|---|---|
| 4C-R1 | Tenant solutioncomponent query shows AQ07 owns unique components not in PMOv11 | HALT. Do not delete AQ07. Investigate which unique components exist and why. |
| 4C-R2 | Owner does not provide explicit per-step approval (4C is not covered by standing auth) | HALT. Standing auth covers 4A+4B only. 4C requires separate approval. |
| 4C-R3 | Post-deletion AQ-08 reverifier shows any blocking topic | HALT. Deletion may have broken a route binding. Investigate immediately. |

---

## Timing Summary

```
4A (import) ──evidence──→ Opus 4.6 reviews 4A evidence
                         ├─ PASS → proceed to 4B
                         └─ FAIL → HALT, investigate

4B (publish) ──evidence──→ Opus 4.6 reviews 4B evidence
                          ├─ PASS → proceed to AQ-09
                          └─ FAIL → HALT, investigate

AQ-09 A1-A5 ──evidence──→ Opus 4.6 cross-validates against RCA
                          ├─ ALL PASS → sign SHIP, scope 4C
                          └─ ANY FAIL → sign NO-SHIP, trigger recovery or bounded fix

4C (cleanup) ──evidence──→ Opus 4.6 reviews 4C evidence
                          ├─ PASS → mission complete
                          └─ FAIL → HALT, do not delete AQ07
```

---

Last updated: 2026-05-23 16:37:00 BRT | Opus 4.6 | Initial protocol complete.
