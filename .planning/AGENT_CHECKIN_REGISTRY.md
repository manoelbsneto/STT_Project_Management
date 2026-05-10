# AGENT CHECK-IN REGISTRY — Central Coordination Hub
# =====================================================
# POLLING INTERVAL: Every 60 seconds
# BOTH Opus 4.6 AND Codex 5.5 MUST read this file before starting ANY task.
# A task can only start when ALL its dependencies show status = DONE.
# =====================================================

> **Created:** 2026-05-10T10:32:00-03:00
> **Created by:** Opus 4.6
> **Purpose:** Single source of truth for multi-agent task coordination
> **Rule:** NO agent modifies another agent's DONE entries. Each agent only updates its OWN tasks.

---

## How to Use This File

1. **Before starting work:** Read this file. Find your next assigned task.
2. **Check dependencies:** If `Depends On` column lists task IDs, ALL must be `DONE`.
3. **Claim task:** Change status from `READY` to `IN_PROGRESS | <Agent> | <timestamp>`.
4. **Complete task:** Change status to `DONE | <Agent> | <timestamp> | <evidence_path>`.
5. **If blocked:** Change status to `BLOCKED | <Agent> | <timestamp> | <reason>`.
6. **Re-read every 60s** while waiting for dependencies.

---

## Task Registry

| Task ID | Wave | GAP | Activity | Owner | Depends On | Status | Agent | Started At | Completed At | Evidence Path | Est. Time |
|---------|------|-----|----------|-------|------------|--------|-------|------------|--------------|---------------|-----------|
| PRE-01 | 0 | — | Add Deleted/DeletedAt/DeletedReason/DeletedByUPN fields to SharePoint lists (Projetos, Tarefas, Status Diario, Riscos e Bloqueios, Decisoes do Board) | Codex 5.5 | NONE | DONE | Codex 5.5 | 2026-05-10T10:43:10-03:00 | 2026-05-10T10:46:38-03:00 | `.planning/cleanup/logical_delete_fields_20260510_104442.md` | 45min |
| PRE-02 | 0 | — | Verify logical delete fields exist via browser/SharePoint UI | Opus 4.6 | PRE-01 | WAITING | — | — | — | — | 20min |
| CLN-01 | 0 | — | Freeze test data creation — record timestamp | Opus 4.6 | NONE | DONE | Opus 4.6 | 2026-05-10T10:38:00-03:00 | 2026-05-10T10:39:00-03:00 | `.planning/stop_ship/TEST_DATA_FREEZE_RECORD_20260510.md` | 5min |
| CLN-02 | 0 | — | Run SharePoint test/trash data discovery script | Codex 5.5 | CLN-01 | WAITING | — | — | — | — | 15min |
| CLN-03 | 0 | — | Mark test/trash candidates as Deleted=Yes with metadata | Opus 4.6 | PRE-02, CLN-02 | WAITING | — | — | — | — | 30min |
| CLN-04 | 0 | — | Validate deleted records hidden from default views/queries | Opus 4.6 | CLN-03 | WAITING | — | — | — | — | 20min |
| W1-01 | 1 | A1 | Verify/rebuild PMO_PA_CriarTarefa_V3 with real SP write logic | Codex 5.5 | CLN-04 | WAITING | — | — | — | — | 60min |
| W1-02 | 1 | A1 | Verify V3 flow writes real SP items + new records have Deleted=false | Opus 4.6 | W1-01 | WAITING | — | — | — | — | 30min |
| W1-03 | 1 | A2 | Bind CriarTarefa topic to V3 flow in Copilot Studio UI | Opus 4.6 | W1-02 | WAITING | — | — | — | — | 20min |
| W1-04 | 1 | A2 | Publish bot from Copilot Studio UI | Opus 4.6 | W1-03 | WAITING | — | — | — | — | 15min |
| W1-05 | 1 | — | Test T-007 create path with real runtime evidence | Opus 4.6 | W1-04 | WAITING | — | — | — | — | 20min |
| W1-06 | 1 | — | Test T-007 cancel path | Opus 4.6 | W1-04 | WAITING | — | — | — | — | 15min |
| W1-07 | 1 | A1 | Codex re-audit after Opus T-007 evidence | Codex 5.5 | W1-05, W1-06 | WAITING | — | — | — | — | 15min |
| W2-01 | 2 | B1 | Build/deploy ConsultarPortfolio flow (exclude Deleted=1) | Codex 5.5 | W1-07 | WAITING | — | — | — | — | 45min |
| W2-02 | 2 | B2 | Build/deploy ConsultarProjeto flow (exclude Deleted=1) | Codex 5.5 | W1-07 | WAITING | — | — | — | — | 45min |
| W2-03 | 2 | B1 | Bind/test ConsultarPortfolio topic in Copilot Studio | Opus 4.6 | W2-01 | WAITING | — | — | — | — | 25min |
| W2-04 | 2 | B2 | Bind/test ConsultarProjeto topic in Copilot Studio | Opus 4.6 | W2-02 | WAITING | — | — | — | — | 25min |
| W3-01 | 3 | B3 | Build/deploy RegistrarRisco flow | Codex 5.5 | W2-03, W2-04 | WAITING | — | — | — | — | 40min |
| W3-02 | 3 | B4 | Build/deploy RegistrarBloqueio flow | Codex 5.5 | W2-03, W2-04 | WAITING | — | — | — | — | 40min |
| W3-03 | 3 | B5 | Build/deploy PedirDecisao flow | Codex 5.5 | W2-03, W2-04 | WAITING | — | — | — | — | 40min |
| W3-04 | 3 | B3 | Bind/test RegistrarRisco in Copilot Studio | Opus 4.6 | W3-01 | WAITING | — | — | — | — | 25min |
| W3-05 | 3 | B4 | Bind/test RegistrarBloqueio in Copilot Studio | Opus 4.6 | W3-02 | WAITING | — | — | — | — | 25min |
| W3-06 | 3 | B5 | Bind/test PedirDecisao in Copilot Studio | Opus 4.6 | W3-03 | WAITING | — | — | — | — | 25min |
| W4-01 | 4 | B6 | Apply AtualizarStatus STT redesign in Copilot Studio | Opus 4.6 | W3-04, W3-05, W3-06 | WAITING | — | — | — | — | 30min |
| W4-02 | 4 | B7 | Publish and test String confirmation (sim/s/yes/confirmo) | Opus 4.6 | W4-01 | WAITING | — | — | — | — | 20min |
| W5-01 | 5 | C1 | Discover ghost orphan botcomponents | Codex 5.5 | W4-02 | WAITING | — | — | — | — | 20min |
| W5-02 | 5 | C1 | Get Human/Admin approval for ghost deletion | Opus 4.6 | W5-01 | WAITING | — | — | — | — | 15min |
| W5-03 | 5 | C1 | Delete approved ghost components (Human/Admin) | Human/Admin | W5-02 | WAITING | — | — | — | — | 30min |
| W5-04 | 5 | C2 | Capture recurrence flow runtime evidence | Opus 4.6 | W4-02 | WAITING | — | — | — | — | 30min |
| W5-05 | 5 | C3 | Test SyncPlannerStats with real data | Opus 4.6 | W4-02 | WAITING | — | — | — | — | 30min |
| W5-06 | 5 | C4 | Test AlertaProjetoVermelho E2E | Opus 4.6 | W4-02 | WAITING | — | — | — | — | 30min |
| RPT-01 | 5 | — | Validate daily portfolio report (Deleted=1 excluded) | Opus 4.6 | CLN-04, W4-02 | WAITING | — | — | — | — | 20min |
| RPT-02 | 5 | — | Validate weekly portfolio report | Opus 4.6 | RPT-01 | WAITING | — | — | — | — | 20min |
| RPT-03 | 5 | — | Validate red project alert | Opus 4.6 | RPT-01 | WAITING | — | — | — | — | 15min |
| RPT-04 | 5 | — | Validate critical risk escalation card | Opus 4.6 | RPT-01 | WAITING | — | — | — | — | 15min |
| RPT-05 | 5 | — | Validate pending decision card (approve/reject paths) | Opus 4.6 | RPT-01 | WAITING | — | — | — | — | 25min |
| EXP-01 | 6 | — | Export final cleaned solution | Opus 4.6 | W5-03, RPT-05 | WAITING | — | — | — | — | 15min |
| EXP-02 | 6 | — | Run post-cleanup static audits on exported solution | Codex 5.5 | EXP-01 | WAITING | — | — | — | — | 20min |
| GATE-01 | 6 | — | Final SHIP/NO-SHIP gate decision | Human/Admin | EXP-02 | WAITING | — | — | — | — | 10min |

---

## Conflict Lock Table

| Resource | Current Lock | Locked By | Since |
|----------|-------------|-----------|-------|
| `deploy/` scripts and JSON | UNLOCKED | — | — |
| `tests/` scripts | UNLOCKED | — | — |
| `.planning/stop_ship/` | UNLOCKED | — | — |
| `deploy/copilot/*.yaml` | UNLOCKED | — | — |
| Copilot Studio UI | UNLOCKED | — | — |
| Power Automate UI | UNLOCKED | — | — |
| SharePoint lists (write) | UNLOCKED | — | — |

---

## Agent Activity Log (append-only)

| Timestamp | Agent | Action | Task ID | Details |
|-----------|-------|--------|---------|---------|
| 2026-05-10T10:32:00-03:00 | Opus 4.6 | CREATED | — | Registry created. All tasks initialized as READY/WAITING. |
| 2026-05-10T10:38:00-03:00 | Opus 4.6 | CLAIMED | CLN-01 | Freeze test data creation. |
| 2026-05-10T10:39:00-03:00 | Opus 4.6 | COMPLETED | CLN-01 | Freeze record at `.planning/stop_ship/TEST_DATA_FREEZE_RECORD_20260510.md`. CLN-02 now unblocked for Codex. |
| 2026-05-10T10:43:10-03:00 | Codex 5.5 | CLAIMED | PRE-01 | Started logical delete field script implementation. |
| 2026-05-10T10:46:38-03:00 | Codex 5.5 | COMPLETED | PRE-01 | Added logical delete fields to all five SharePoint lists. Evidence: `.planning/cleanup/logical_delete_fields_20260510_104442.md`. |
