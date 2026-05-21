# M2 Roadmap — Hybrid Card-First Revision

**Milestone:** M2
**Date:** 2026-05-20
**Owner:** Manoel Benicio
**Architect:** Opus 4.7
**Total estimated effort:** 42-67h bruto / 4 dias úteis com paralelização máxima
**Target ship:** sexta 22/05/2026 ou segunda 25/05/2026

---

## Phase Sequence Overview

```
Phase 1: Discovery (read-only)        [4-6h] — parallel agents
   ↓
Phase 2: Architecture Spec            [6-10h] — Opus + Opus#2
   ↓
Phase 3: Card Design                  [4-6h] — Gemini + Gemini sub
   ↓
Phase 4: Flow Build                   [10-15h] — Codex + 3 sub-agents
   ↓
Phase 5: Topic Update                 [2-4h] — Codex + Owner UI
   ↓
Phase 6: Schema Update                [2-4h] — Codex + Owner PnP
   ↓
Phase 7: Smoke E2E                    [8-12h] — Owner chat + AI validators
   ↓
Phase 8: Documentation                [4-6h] — Gemini Flash + Opus#2
   ↓
Phase 9: Cutover                      [2-4h] — Owner + standby AI support
```

**Auto-advance enabled:** phases progress automatically once gates PASS, no manual approval between phases except at Phase 7 (smoke results) and Phase 9 (final ship decision).

---

## Phase 1 — Discovery

**Goal:** Lock complete inventory of current state. Zero assumption, 100% read-only evidence.

**Effort:** 4-6h
**Calendar:** 4h with parallel execution
**Owner gate:** None (read-only, fully agent-driven)

### Inputs

- `.planning/milestones/M2_card_first_revision_v2/PROJECT.md`
- `.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md`
- Existing M1 evidence packs in `.planning/comms/`

### Tasks

| Task | Owner | Output |
|---|---|---|
| 1.1 — PAC FetchXML inventory complete (all topics, flows, action components, connection refs) | Codex | `discovery/01_dataverse_inventory.md` + raw .txt files |
| 1.2 — SharePoint schema inventory (all 5 lists, all fields, all views) | Codex sub | `discovery/02_sharepoint_schema_inventory.md` |
| 1.3 — Adaptive Cards JSON catalog (`deploy/cards/`, `deploy/UI_UX/`, `frontend/`) | Gemini Flash | `discovery/03_adaptive_cards_catalog.md` |
| 1.4 — Connection references audit (SharePoint, Teams, Planner Standard, Power Virtual Agents) | Codex sub | `discovery/04_connection_refs.md` |
| 1.5 — Power Automate flow definitions extract for all PMO_PA_* and PM0_PA_* | Codex sub | `discovery/05_flow_definitions/*.json` |
| 1.6 — Channel and routing inventory (Teams Group/Channel IDs, current routes) | Opus #2 | `discovery/06_routing_inventory.md` |
| 1.7 — Existing topic YAMLs (12 user + 4 system) | Opus #2 | `discovery/07_topics_yaml/*.yml` |
| 1.8 — Identify Copilot Studio errors (each topic's "1 error" — root cause analysis) | Codex | `discovery/08_copilot_topic_errors_rca.md` |
| 1.9 — Test data residual inventory (post-2026-05-10 test artifacts) | Codex sub | `discovery/09_test_data_residual.md` |

### Gates

- ✅ All 9 inventories complete
- ✅ Zero unanswered questions about current state
- ✅ Gap list (current → target M2) lockada e revisada

### Exit criteria

`phases/01_discovery/HANDOFF.md` produced, listing:
- Confirmed inventory (matches reality 100%)
- Gap list (what M2 must add/change)
- Risks discovered (e.g., Copilot Studio errors that block publish)

---

## Phase 2 — Architecture Specification

**Goal:** Lock the COMPLETE design before any build. No build starts until spec is signed off.

**Effort:** 6-10h
**Calendar:** 6h
**Owner gate:** Single approval at end of phase

### Inputs

- Phase 1 handoff
- M2 PROJECT.md + REQUIREMENTS.md

### Tasks

| Task | Owner | Output |
|---|---|---|
| 2.1 — Master architecture document (component model, sequence diagrams, dual-entry pattern) | Opus 4.7 (lead) | `phases/02_architecture_spec/ARCHITECTURE.md` |
| 2.2 — ADR-001: routing matrix DM + Canal | Opus 4.7 | `decisions/ADR-001-routing-matrix.md` |
| 2.3 — ADR-002: legacy decommission timeline | Opus 4.7 | `decisions/ADR-002-legacy-decommission.md` |
| 2.4 — ADR-003: dual-entry flow pattern + idempotency | Opus 4.7 | `decisions/ADR-003-dual-entry-pattern.md` |
| 2.5 — ADR-004: card design system (visual language, components, states) | Opus #2 | `decisions/ADR-004-card-design-system.md` |
| 2.6 — Flow contract specs for 13 flows (input schema, output schema, routes per action) | Opus #2 | `phases/02_architecture_spec/FLOW_CONTRACTS.md` |
| 2.7 — Topic update contracts for 12 topics (current → target diff per topic) | Opus 4.7 | `phases/02_architecture_spec/TOPIC_CONTRACTS.md` |
| 2.8 — SharePoint schema delta script (PnP) for new fields | Codex | `phases/02_architecture_spec/SCHEMA_DELTA.md` + `Apply-SchemaDelta.ps1` |
| 2.9 — Error handling matrix (every error type → user message + log + escalation) | Opus #2 | `phases/02_architecture_spec/ERROR_MATRIX.md` |
| 2.10 — Test plan complete (per-flow integration + cross-flow + smoke) | Codex sub | `phases/02_architecture_spec/TEST_PLAN.md` |

### Gates

- ✅ Architecture doc reviewed by 2 Opus instances (cross-check)
- ✅ All 4 ADRs published
- ✅ Owner reads ARCHITECTURE.md and approves (single decision point)

### Exit criteria

`phases/02_architecture_spec/HANDOFF.md` listing all artifacts, owner sign-off recorded.

---

## Phase 3 — Card Design

**Goal:** All 13 Adaptive Cards designed, JSON ready, schema validated.

**Effort:** 4-6h
**Calendar:** 4h
**Owner gate:** Visual mockup review (single batch)

### Inputs

- Phase 2 ARCHITECTURE.md + ADR-004 (design system)

### Tasks

| Task | Owner | Output |
|---|---|---|
| 3.1 — Design system tokens (colors, typography, spacing, icons) | Gemini Flash | `phases/03_card_design/DESIGN_TOKENS.md` |
| 3.2 — 9 confirmation cards JSON | Gemini Flash + sub | `deploy/cards/*ConfirmCard.json` |
| 3.3 — 4 result cards JSON | Gemini Flash sub | `deploy/cards/*Card.json` (Consultar, Listar, Resumo) |
| 3.4 — 1 ops failure card JSON | Gemini Flash sub | `deploy/cards/OpsFailureCard.json` |
| 3.5 — Card schema validator script | Codex | `tests/Test-AdaptiveCardSchemaCompliance.ps1` |
| 3.6 — Visual mockup compilation (renders all 13 cards) | Gemini Flash | `phases/03_card_design/MOCKUPS.md` (links to Adaptive Card Designer URLs) |
| 3.7 — Owner visual review batch | Owner | `phases/03_card_design/OWNER_REVIEW.md` |

### Gates

- ✅ All 13 cards <27KB
- ✅ All 13 schema-valid (Adaptive Cards 1.4+)
- ✅ Owner approval (visual)

### Exit criteria

`phases/03_card_design/HANDOFF.md` with cards locked.

---

## Phase 4 — Flow Build

**Goal:** All 13 PM0_PA_Card_* flows built, imported, active.

**Effort:** 10-15h
**Calendar:** 8h with 4 parallel agents
**Owner gate:** Approve final solution package before import

### Inputs

- Phase 2 FLOW_CONTRACTS.md
- Phase 3 cards JSON

### Tasks

| Task | Owner | Output |
|---|---|---|
| 4.1 — Refactor 5 existing PM0_PA_Card_* flows for dual-entry hybrid pattern | Codex | Flow definition JSONs |
| 4.2 — Build 7 new PM0_PA_Card_* flows | Codex + 2 sub-agents | Flow definition JSONs |
| 4.3 — Validate PM0_PA_OpsFailureHandling | Codex sub | Flow definition JSON |
| 4.4 — BLK-AT-001 fix integrated in PM0_PA_Card_AtualizarTarefa | Codex | Flow + regression test |
| 4.5 — Solution package builder script | Codex sub | `scripts/Build-Solution316.ps1` |
| 4.6 — Local gates (P24, P0 contracts, stop-ship audit, content-safe, routing) | Codex | Test results |
| 4.7 — Solution import (owner-executed) | Owner | Import log |
| 4.8 — Post-import read-only verification | Codex | `phases/04_flow_build/POST_IMPORT_INVENTORY.md` |

### Gates

- ✅ 13 flows active in Dataverse
- ✅ All local tests PASS
- ✅ Owner-approved solution import successful

### Exit criteria

`phases/04_flow_build/HANDOFF.md` with flow inventory PASS.

---

## Phase 5 — Topic Update

**Goal:** 12 topics updated to call PM0_PA_Card_* exclusively.

**Effort:** 2-4h
**Calendar:** 3h
**Owner gate:** Manual paste of YAMLs into Copilot Studio UI

### Inputs

- Phase 1 current topic YAMLs
- Phase 2 TOPIC_CONTRACTS.md
- Phase 4 PM0 flow IDs

### Tasks

| Task | Owner | Output |
|---|---|---|
| 5.1 — Generate TO-BE YAML per topic (preserve current logic, swap final call) | Opus 4.7 + Codex | `phases/05_topic_update/to_be/*.yaml` |
| 5.2 — Diff documentation per topic | Opus 4.7 | `phases/05_topic_update/diffs/*.md` |
| 5.3 — Owner paste-and-save 12 topics | Owner | Save evidence in Copilot Studio |
| 5.4 — Codex Studio errors RCA + fix (the "1 error" per topic from current screenshot) | Codex | `phases/05_topic_update/COPILOT_ERRORS_RESOLUTION.md` |
| 5.5 — Re-run Test-Aq08PostRemediationReverify.ps1 — must PASS | Codex | Test output |

### Gates

- ✅ All 12 topics call PM0_PA_Card_*
- ✅ Zero "1 error" status in Copilot Studio
- ✅ Reverify script PASS (exit code 0)

### Exit criteria

`phases/05_topic_update/HANDOFF.md` with reverify PASS evidence.

---

## Phase 6 — Schema Update + Cleanup

**Goal:** SharePoint schema completed + test data cleaned.

**Effort:** 2-4h
**Calendar:** 2h
**Owner gate:** Approve PnP scripts before -Confirm execution

### Tasks

| Task | Owner | Output |
|---|---|---|
| 6.1 — Apply schema delta in `Tarefas` (+ other lists per discovery) | Owner running PnP | Field verification log |
| 6.2 — Cleanup test data 2026-05-10/13 | Owner running PnP | Cleanup log |
| 6.3 — Post-cleanup verification | Codex | `phases/06_schema_update/POST_CLEANUP.md` |

### Gates

- ✅ All new fields present
- ✅ 0 test data residuals (Deleted=No filter returns 0)

### Exit criteria

`phases/06_schema_update/HANDOFF.md`.

---

## Phase 7 — Smoke E2E

**Goal:** All 12 operations validated runtime + DM/Channel routing verified + zero XPIA.

**Effort:** 8-12h
**Calendar:** 6h with parallel evidence validation
**Owner gate:** Decision after smoke results

### Tasks

| Task | Owner | Output |
|---|---|---|
| 7.1 — Smoke runbook complete (12 ops × N steps each) | Codex | `phases/07_smoke_e2e/SMOKE_RUNBOOK.md` |
| 7.2 — Pre-publish rollback evidence captured | Codex | `phases/07_smoke_e2e/rollback_evidence/` |
| 7.3 — Owner imports + publishes 3.16 candidate | Owner | Import + publish logs |
| 7.4 — Owner executes 12 smoke scenarios in Copilot Studio chat + Teams | Owner | Screenshots + chat traces |
| 7.5 — Codex validates evidence | Codex | `phases/07_smoke_e2e/EVIDENCE_VALIDATION.md` |
| 7.6 — XPIA harness analyzes traces | Opus #2 | `phases/07_smoke_e2e/XPIA_VERIFICATION.md` |
| 7.7 — DM + Channel routing verification (each operation posts to correct destinations) | Codex sub + Owner | `phases/07_smoke_e2e/ROUTING_VERIFICATION.md` |
| 7.8 — Cross-flow scenarios (create project → create task → assign → update → close) | Owner | Multi-step traces |

### Gates

- ✅ 12/12 smoke operations PASS
- ✅ 0 XPIA recurrences
- ✅ DM + Channel routing per ADR-001 verified
- ✅ Cross-flow scenarios PASS

### Exit criteria

If all gates PASS → automatic advance to Phase 8.
If any P0 gate FAIL → Opus #2 fallback strategy activated; Phase 7 re-runs.

---

## Phase 8 — Documentation

**Goal:** All deliverable documentation complete.

**Effort:** 4-6h
**Calendar:** 3h with parallel writers
**Owner gate:** None (auto-advance after Phase 7)

### Tasks

| Task | Owner | Output |
|---|---|---|
| 8.1 — Manual Operacional v1.0 PT-BR (uses Phase 7 screenshots) | Gemini Flash | `docs/MANUAL_OPERACIONAL_PMO_v1_0.md` |
| 8.2 — Release Notes 3.16 PT-BR + EN | Gemini Flash sub | `RELEASE_NOTES_3_16.md` |
| 8.3 — Post-publish monitoring runbook (24h + 30 day) | Opus #2 | `phases/08_docs/MONITORING_RUNBOOK.md` |
| 8.4 — Updated PRD reflecting M2 final state | Opus 4.7 | `PRD/PRD_PMO_M365_v2.0_M2_FINAL.md` |
| 8.5 — Updated AGENT_CONTRACT for M2 phase agents | Opus 4.7 | `.planning/AGENT_CONTRACT.md` revision |

### Gates

- ✅ Manual readable end-to-end
- ✅ Release notes signed off

### Exit criteria

`phases/08_docs/HANDOFF.md`.

---

## Phase 9 — Cutover

**Goal:** Production deployment + 24h monitoring active.

**Effort:** 2-4h
**Calendar:** 2h + 24h sentinel
**Owner gate:** Final SHIP decision

### Tasks

| Task | Owner | Output |
|---|---|---|
| 9.1 — Final SHIP review with Opus 4.7 | Opus 4.7 + Owner | `phases/09_cutover/FINAL_SHIP_REVIEW.md` |
| 9.2 — Owner SHIP/NO-SHIP decision | Owner | Decision logged |
| 9.3 — Production publish (if SHIP) | Owner | Publish log |
| 9.4 — Communication to stakeholders | Owner | Email/Teams post |
| 9.5 — Activate 24h monitoring sentinel | Opus #2 standby | Monitoring active |
| 9.6 — Deactivate 12 PMO_PA_* legacy flows (T+0) | Owner | Deactivation log |
| 9.7 — Schedule 30-day decommission ticker | Codex | `phases/09_cutover/T_PLUS_30_CHECKLIST.md` |

### Gates

- ✅ Owner SHIP approval
- ✅ Production publish successful
- ✅ Monitoring active

### Exit criteria

M2 = COMPLETE. Project state transitions to "Production Sentinel — 30 days".

---

## Phase 10 — Decommission (T+30 days)

**Goal:** Remove legacy PMO_PA_* permanently after stability proven.

**Effort:** 1-2h
**Calendar:** scheduled for ~22/06/2026

### Tasks

| Task | Owner | Output |
|---|---|---|
| 10.1 — Stability review (P0 incident count = 0?) | Opus 4.7 | Review report |
| 10.2 — Backup legacy flows | Codex | `Solution/legacy_pmo_pa_backup_2026MMDD.zip` |
| 10.3 — Delete 12 PMO_PA_* | Owner | Deletion log |
| 10.4 — Verify no orphaned references | Codex | `phases/10_decommission/POST_DELETE_VERIFICATION.md` |

### Gates

- ✅ Zero P0 incidents in 30 days
- ✅ Backup created

### Exit criteria

M2 fully closed. Production state = "Steady State Card-First Hybrid".

---

## Critical Path

The critical path that determines ship date:

```
P1 → P2 → P4 → P5 → P6 → P7 → P9
4h   6h   8h   3h   2h   6h   2h   = 31h
```

(P3 runs parallel to P4, P8 runs parallel to P7→P9)

**Optimistic ship target: T+31h calendar = quinta-feira 22/05 ~17h se trabalho contínuo.**

**Realistic ship target: T+40h calendar with owner gates = sexta 23/05 evening.**

---

## Failure Modes & Rollback Triggers

| Failure point | Trigger | Mitigation |
|---|---|---|
| Phase 1 — Inventory incomplete | Missing data | Re-run with elevated PAC discovery |
| Phase 2 — Architecture review reject | Owner concern | Single iteration loop, max 1 day |
| Phase 4 — Flow import fail | Solution package error | Codex fixes + retry |
| Phase 5 — Reverify FAIL | Topic remediation incorrect | Codex generates corrected YAMLs |
| Phase 7 — XPIA recurs | ContentFiltered detected | Opus #2 fallback strategy α/β/γ activated |
| Phase 7 — Cross-flow scenario fails | Bug in flow | Targeted fix + re-smoke that scenario only |
| Phase 9 — Production publish fails | PAC error | Rollback to 3.10_POST_WFSET_CLEAN within 15 min |

---

*Last updated: 2026-05-20 17:46 BRT*
