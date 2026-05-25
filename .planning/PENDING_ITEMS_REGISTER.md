# PMO Project — Pending Items Register

> **Canonical consolidated view of all open items across this project.** This file replaces ad-hoc tracking in fragmented documents. Every open item — SEV-0, P0/P1/P2/P3, accepted backlog, process debt, forensic gaps — is listed here with ID, severity, owner, status, and resolution path. Update this file every time an item is opened, changed, or closed.

| Field | Value |
|---|---|
| Created | 2026-05-23 18:52 BRT |
| Version | V1 — Kiro initial consolidation |
| Authoritative | YES — supersedes fragmented tracking |
| Next sweep | Codex #1 to backfill V2 (full planning-file sweep while Codex #2 builds 3.18) |
| Last updated | 2026-05-24 03:16:05 BRT \| Codex #2 Lead via Kiro \| MISSION evolved 3.16→3.17→3.18→3.19→3.20; RCA-3_19-ATUALIZARSTATUS DONE H1 CONFIRMED; 3.20 BUILD COMPLETE awaiting peer review + Owner Gate 4A. |

---

## 1. Executive Summary

| Severity | Open | In-flight | Resolved (recent) | Accepted backlog |
|---|---:|---:|---:|---:|
| SEV-0 | 0 | 1 (3.18 rebuild → BLK-LIVE-317) | 4 (BLK-403, BLK-DELTA-NOSHOW, BLK-ALPHA-DEGRADED, BLK-BACKUP) | — |
| P0 | 1 | 1 (5 PM0 topics card-first migration via 3.18) | — | — |
| P1 | 7 | 0 | — | — |
| P2 | 5 | 0 | — | — |
| P3 | 1 | 0 | — | — |
| Accepted legacy | 7 | 0 | — | 7 (legacy topics on PMO_PA_*) |
| Process / forensic | 5 | 0 | — | — |
| **TOTAL OPEN** | **26** | **2** | **4** | **7** |

---

## 2. SEV-0 / Active Mission

| ID | Item | Status | Owner | ETA | Notes |
|---|---|---|---|---|---|
| MISSION-3.20 | Ship PMO_v11_Tarefas 3.20 PM0 StatusID Fix → Codex #1 peer review → Owner Gate 4A import → post-import verification → Gate 4B publish → AQ-09 PASS → AQ07 cleanup → SHIP | 🟡 BUILD COMPLETE 2026-05-24 03:16:05 BRT (SHA `ADE54BF23F60F7A9EA5AB054680640F00F4971BC201C82E130640AC1F3B28DAC`); peer review pending | Codex #2 + Codex #1 + Owner | Variable (peer review ~30-45min, then sequential gates) | Resolves PM0 functional defects + dual-ownership; supersedes failed 3.18/3.19 attempts. Mission evolved: 3.16 (initial) → 3.17 (Owner export drift) → 3.18 (rebuild, OrigemEntrada FAIL) → 3.19 (OrigemEntrada/coalesce fixed, AtualizarStatus StatusID FAIL) → 3.20 (StatusID fix, BUILT). |

---

## 3. P0 — Card-first In-scope (resolves on 3.18 ship)

| ID | Item | Status | Resolution |
|---|---|---|---|
| P0-CARD-FIRST | 5 in-scope topics migrated to PM0_PA_Card_* with functional bindings: AtualizarStatus, AtualizarTarefa, ConsultarPortfolio, CriarTarefa, ListarTarefas | 🟡 In flight via 3.18 | Resolved on Gate 4C COMPLETE + Opus 4.6 SHIP sign-off |

---

## 4. Accepted Legacy Debt (intentional, requires future migration sprint)

These 7 topics remain on legacy `PMO_PA_*` actions per the AQ-08 ADR. Tracked as RISK-012. Need a future "full card-first migration" sprint — explicitly OUT OF SCOPE for 3.18.

| ID | Topic | Severity rationale |
|---|---|---|
| LEGACY-01 | `ConsultarProjeto` | P3 — read-only, no XPIA exposure |
| LEGACY-02 | `CriarProjeto` | P3 — write path, needs replan |
| LEGACY-03 | `ExcluirProjeto` | P3 — write path, needs replan |
| LEGACY-04 | `ExcluirTarefa` | P2 — task-write impact |
| LEGACY-05 | `PedirDecisao` | P2 — decision-write impact |
| LEGACY-06 | `RegistrarBloqueio` | P2 — risk/blocker-write impact |
| LEGACY-07 | `RegistrarRisco` | P2 — risk/blocker-write impact |

**Resolution path:** dedicated sprint after 3.18 SHIP. Estimated ~2–3 weeks for full card-first redesign + migration of all 7 topics.

---

## 5. P1 Open Items

| ID | Item | Owner | Status | Effort | Resolution path |
|---|---|---|---|---|---|
| P1-DOC-MANUAL | `docs/MANUAL_OPERACIONAL_PMO.md` v1.0 with real production screenshots (currently draft v0.9) | Owner / Gemini Flash #1 | OPEN | ~1 day | Update post-3.18-SHIP with real screenshots from live runtime |
| P1-PLAN-CONSOLIDATION | Fragmented planning files (Registry, Status, Board) — consolidation in progress | Kiro / Codex #1 | IN PROGRESS | ~2h | Continue migration to canonical files; this register is part of that |
| P1-GAP-C2 | Recurrence flow evidence (PMO_PA_Recurring_*) | Codex #2 | OPEN | ~2h | Capture run history, recurrence interval, success rate over 24h window |
| P1-GAP-C3 | SyncPlannerStats pilot E2E evidence | Codex #2 | OPEN | ~3h | Run pilot from Teams card → flow → Planner row → SP stats update; capture full chain |
| P1-GAP-C4 | AlertaProjetoVermelho E2E | Codex #2 | OPEN | ~2h | Trigger red-status threshold; verify card posted to Teams channel; SP stats update |
| P1-GAP-C1 | Ghost Copilot bot components in solution | Owner / Admin | PENDING ADMIN | ~1h | Discovery script ready (`Discover-GhostBotComponents.ps1`); deletion needs Human/Admin approval |
| P1-LIVE-NON-ASCII | Live bot text violates ASCII-only operational rule (RISK-009 in risk register) | Codex #2 | OPEN | ~2h | Remove/replace non-ASCII GPT instructions; republish |

---

## 6. P2 Open Items

| ID | Item | Owner | Status | Effort | Resolution path |
|---|---|---|---|---|---|
| P2-CLEANUP-TEST-DATA | Logical delete of all 2026-05-10/13 test data rows from SP lists | Codex #2 | OPEN | ~1h | Run `Set-SharePointTestDataDeletedFlag.ps1` against test data set |
| P2-BATCH-WRITE | `Gerar_Multiplos_Projetos` full write path (currently preview-only) | Codex #2 | OPEN | ~1 day | Implement batch SP write with rollback; integrate with existing topic |
| P2-AT-DISPLAY-PATCH | BLK-AT-001 display patch — `AtualizarTarefa` skip preserves data but displays raw `nao` instead of `(mantido)` | Codex #2 | OPEN | ~1h | Topic response template fix |
| P2-AQ07-1001-MISSING | AQ07 1.0.0.1 local baseline missing on disk (forensic gap from 3.17 diff) | Codex #2 | OPEN | ~30min | Either retrieve from environment history OR document as accepted gap |
| P2-CARD-RUNTIME-QA | Copilot Runtime Conversation QA — full Teams runtime validation: greeting, consultar portfolio, consultar projeto, confirmar ação de escrita, acionar fluxo | Owner | OPEN | ~2h | Phase 6 priority post-3.18 |

---

## 7. P3 / Future

| ID | Item | Owner | Status | Effort | Resolution path |
|---|---|---|---|---|---|
| P3-VERTEX-AI | Vertex AI / advanced LLM scripts integration (tests added May 17) | Codex #2 / Gemini | DEFERRED | TBD | Backlog; plan when STT/voice fallback becomes priority |

---

## 8. Process / Forensic Debt (introduced by recent missions)

| ID | Item | Status | Resolution path |
|---|---|---|---|
| PROC-01 | Codex #1 sub-agent spawn failed (platform token-refresh error) during T0 fan-out | OPEN | Investigate token-refresh limit; document workaround for future 15-actor deploys |
| PROC-02 | Gemini Flash #1 never started despite Owner "all were started" — dispatch reliability | OPEN | Investigate why prompt didn't reach the agent; verify session lifecycle |
| PROC-03 | Multiple agent compliance violations: future timestamps (Gemini Flash #2 ×2), `.md` instead of `.png` screenshot (Opus 4.6), unresolved `$pngRel` placeholder (Codex #2) | OPEN | Reinforce 3-element check-in rule; consider automated validator that rejects malformed entries |
| PROC-04 | BLK-BACKUP cleared on Owner trust without SHA/schema validation | ACCEPTED RISK | Document recovery contingency; if 3.18 import fails, validation happens under stress |
| PROC-05 | STT fallback (long voice/text-to-intent) deferred indefinitely | ACCEPTED BACKLOG | Schedule when business priority demands; tracked under P2 originally |

---

## 9. Resolution Roadmap

### Sprint 0 — Current mission (3.18 SHIP)
**Closes:** SEV-0 active item, P0-CARD-FIRST  
**ETA:** ~3 hours wall-clock from now

### Sprint 1 — Post-ship cleanup (within 1 week of 3.18 SHIP)
**Closes:** P1-LIVE-NON-ASCII, P2-CLEANUP-TEST-DATA, P2-AT-DISPLAY-PATCH, P2-AQ07-1001-MISSING, PROC-01, PROC-02, PROC-03  
**Estimated effort:** ~1.5 days  
**Owner:** Codex #2 + Kiro  
**Why batch these together:** all are local/static fixes with no tenant write outside the AT display patch. Can be bundled into a single 3.19 patch ZIP.

### Sprint 2 — Manual + Documentation polish (within 2 weeks of SHIP)
**Closes:** P1-DOC-MANUAL, P1-PLAN-CONSOLIDATION (finish)  
**Estimated effort:** ~2 days  
**Owner:** Owner + Gemini Flash #1 (or whoever replaces them)  
**Dependencies:** real production screenshots from post-ship runtime

### Sprint 3 — Recurrence + Sync evidence (within 3 weeks of SHIP)
**Closes:** P1-GAP-C2, P1-GAP-C3, P1-GAP-C4  
**Estimated effort:** ~1 week  
**Owner:** Codex #2  
**Why grouped:** all three need live recurrence/sync runs over 24h+ windows; can run in parallel.

### Sprint 4 — Ghost components admin cleanup (whenever admin available)
**Closes:** P1-GAP-C1  
**Estimated effort:** ~1h after admin approval  
**Owner:** Owner / Admin  
**Blocker:** human admin approval gate

### Sprint 5 — Card-first full migration (4–6 weeks effort)
**Closes:** LEGACY-01 through LEGACY-07  
**Estimated effort:** ~3 weeks design + dev + test  
**Owner:** Codex #2 + Owner  
**Why deferred:** 7 topics × full topic+action+workflow rebuild + AQ-08 reverify + AQ-09 retest. Substantial project on its own.

### Sprint 6 — Batch write + STT/Vertex AI (when business priority)
**Closes:** P2-BATCH-WRITE, P2-CARD-RUNTIME-QA, P3-VERTEX-AI, PROC-05  
**Estimated effort:** ~2 weeks  
**Owner:** Codex #2  
**Trigger:** product owner decision on STT/voice priority

---

## 10. Sources Consolidated

This register supersedes scattered tracking in:
- `.planning/comms/PENDING_TESTS_FEATURES_PRIORITY_20260513.md` (May 13 view; some items closed since)
- `.planning/comms/planner_tasks_pending_20260513.csv` (May 13 CSV; items folded in)
- `.planning/STATE.md` "Backlog" + "Risk Register" sections
- `.planning/START_HERE_CURRENT_STATUS.md` "Pending Project Features" + "Backlog / Post-Launch"
- `.planning/stop_ship/MASTER_CHECKLIST.md` "GAP Checklist"
- `.planning/stop_ship/RISK_REGISTER.md`
- `.planning/comms/codex_pm0_remediation_20260522/T0_PROGRESS_BOARD.md` "Active blockers"

Those source files remain for historical traceability but should NOT be edited going forward — update this register instead, then sync state changes back to STATE.md / START_HERE / MASTER_CHECKLIST headers as needed.

---

## 11. Update protocol

Any agent or owner that opens, changes, or closes an item MUST:

1. Update the item row in this register with: status, owner, last update timestamp BRT, evidence path (if applicable).
2. Update Section 1 Executive Summary counts.
3. If the item closes, move it to "Resolved" line in Section 1 and add resolution date.
4. If the item changes severity, also update STATE.md and START_HERE_CURRENT_STATUS.md headers if it's SEV-0 or P0.
5. If a new item is identified (e.g. during peer review or post-mortem), add it with a new ID using the next sequential number in its category.
6. Append entry to "Recent register events" feed below.

---

## 12. Recent register events (latest 10)

| Timestamp BRT | Actor | Event |
|---|---|---|
| 2026-05-23 18:52:00 BRT | Kiro | Initial register creation; consolidates 26 open items across all severities; 4 SEV-0 closed today; mission 3.18 in flight |
