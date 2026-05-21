# M2 State — Hybrid Card-First Revision

**Milestone:** M2
**Active phase:** 1 (Discovery)
**Phase status:** READY TO DISPATCH
**Started:** 2026-05-20 17:46 BRT
**Last updated:** 2026-05-20 17:46 BRT

---

## Project Reference

See: `.planning/milestones/M2_card_first_revision_v2/PROJECT.md` (updated 2026-05-20 17:46 BRT)

**Core value:** Toda operação PMO crítica gera evidência visual auditável (card no Teams) sem forçar o usuário a abandonar o chat.

**Current focus:** Discovery — read-only inventory complete antes de qualquer build.

---

## Phase Status Tracker

| Phase | Name | Status | Started | Completed | Output ref |
|---:|---|---|---|---|---|
| 1 | Discovery | READY | — | — | — |
| 2 | Architecture Spec | WAITING | — | — | — |
| 3 | Card Design | WAITING | — | — | — |
| 4 | Flow Build | WAITING | — | — | — |
| 5 | Topic Update | WAITING | — | — | — |
| 6 | Schema Update + Cleanup | WAITING | — | — | — |
| 7 | Smoke E2E | WAITING | — | — | — |
| 8 | Documentation | WAITING | — | — | — |
| 9 | Cutover | WAITING | — | — | — |
| 10 | Decommission (T+30) | SCHEDULED | scheduled ~2026-06-22 | — | — |

---

## Active Decisions Locked

- Hybrid card-first sobre pure card-first ✓
- Versão alvo: 3.16 ✓
- 4 routes mantidos (DM + Canal por audiência) ✓
- Legacy PMO_PA_* deactivate at M2 publish, delete at T+30 days ✓
- Vertex AI fora de scope ✓
- Owner sole approver ✓
- Continuous parallel execution ✓
- Auto-advance entre fases (sem manual gates exceto P7 + P9) ✓
- Standard granularity (8 phases ativas + decommission ticker) ✓
- Plan check + Verifier ON, automated ✓

---

## Agent Roster

| Agent | Role | Current scope |
|---|---|---|
| Opus 4.7 (lead, this chat) | Principal Architect | Documents M2 setup + Phase 2 architecture spec lead + Phase 5 topic YAMLs + Phase 9 SHIP review |
| Opus 4.7 #2 (parallel IDE) | Architect support | Phase 2 ADR-004 design system + Phase 7 XPIA harness + Phase 8 monitoring runbook |
| Codex 5.5 (lead) | Senior Integration + Deploy + QA | Phase 1 dataverse inventory + Phase 4 flow build lead + Phase 5 reverify + Phase 7 evidence + Phase 9 backup |
| Codex sub-1 | SharePoint specialist | Phase 1 SP schema + Phase 6 PnP scripts |
| Codex sub-2 | Power Automate specialist | Phase 1 flow definitions + Phase 4 7 new flows |
| Codex sub-3 | QA + tests | Phase 1 connection refs + Phase 4 local gates + Phase 7 smoke validator |
| Gemini Flash 3.5 (lead) | Card designer + docs writer | Phase 1 cards catalog + Phase 3 design lead + Phase 8 manual |
| Gemini Flash sub-1 | Card sub-designer | Phase 3 confirmation cards |
| Gemini Flash sub-2 | Documentation sub-writer | Phase 3 result cards + Phase 8 release notes |
| Owner (Manoel) | Sole approver + tenant write executor + chat smoke runner | Every gate approval + Copilot Studio UI edits + tenant imports + chat smoke |

---

## Open Risks (M2 register — supplemental to RISK_REGISTER.md)

| ID | Risk | Severity | Mitigation |
|---|---|---|---|
| RISK-M2-01 | XPIA recurrence in any of 12 PM0 operations during smoke | SEV-0 | Opus #2 prepares fallback strategies α/β/γ in Phase 2 |
| RISK-M2-02 | Owner availability for tenant writes (manual gates) | P1 | Schedule continuous window or batch tenant writes |
| RISK-M2-03 | Copilot Studio "1 error per topic" — root cause unknown | P1 | Phase 1.8 RCA dedicated; if it's a SP connection ref orphan, fix in Phase 6 |
| RISK-M2-04 | Card schemas exceed 27KB | P2 | Phase 3 schema validator catches before build |
| RISK-M2-05 | Planner Standard connector quotas during smoke | P2 | Smoke uses test bucket data only; production usage stays under quota |
| RISK-M2-06 | Test data residuals interfere with smoke evidence | P2 | Phase 6 cleanup before Phase 7 |
| RISK-M2-07 | Cross-flow scenario reveals state-management bug (e.g., card submit retried) | P1 | Idempotency via operationId in Phase 4; cross-flow tests in Phase 7 |

---

## Blockers (current)

None. Phase 1 is dispatchable now.

---

## Next Action

**Owner action required:** dispatch Phase 1 prompt to Codex + Codex sub-1 + Codex sub-2 + Codex sub-3 + Opus #2 + Gemini Flash + Gemini Flash sub-1 + Gemini Flash sub-2 (8 agents in parallel).

Phase 1 prompt is ready in `phases/01_discovery/SPEC.md`.

---

*Updated automatically by phase transitions.*
