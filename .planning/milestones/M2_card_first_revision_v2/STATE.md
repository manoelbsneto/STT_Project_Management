# M2 State — Hybrid Card-First Revision

**Milestone:** M2
**Active phase:** 7 (Smoke E2E)
**Phase status:** 🔴 **NO-SHIP** — local 3.16 PM0 source/package static gates pass; runtime proof still missing
**Started:** 2026-05-20 17:46 BRT
**Last updated:** 2026-05-22 17:13:10 BRT | Codex | Reflected local package static-gate pass and remaining release gates.

---

## 🚨 Phase 7 FAILED 2026-05-22 14:42 BRT

A1 (ListarTarefas) exposed non-dynamic PM0 caller output. The merged audit narrows the five PM0 workflow bodies to one `STUB`, four `PARTIAL`, and zero `REAL`.

RCA: `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md`

Owner selected fix-and-ship. Local 3.16 source guards and scoped package static gates pass, but this is not a ship decision.

Codex #1 completed the local Alpha + Bravo merge lane in `.planning/comms/codex_pm0_audit_20260522/`; this does not authorize tenant writes.

---

## Project Reference

See: `.planning/milestones/M2_card_first_revision_v2/PROJECT.md` (updated 2026-05-20 17:46 BRT)

**Core value:** Toda operação PMO crítica gera evidência visual auditável (card no Teams) sem forçar o usuário a abandonar o chat.

**Current focus:** Use the rebuilt scoped 3.16 package status to request explicit Gate 4 owner approval before any tenant import/publish.

---

## Phase Status Tracker

| Phase | Name | Status | Started | Completed | Output ref |
|---:|---|---|---|---|---|
| 1 | Discovery | DONE | 2026-05-20 | 2026-05-20 | Inventories complete in `phases/01_discovery/` |
| 2 | Architecture Spec | DONE | 2026-05-20 | 2026-05-20 | ADR_AQ08 accepted |
| 3 | Card Design | DONE | 2026-05-15 | 2026-05-15 | 12 Adaptive Cards JSON |
| 4 | Flow Build | 🟡 **LOCAL STATIC PASS** | 2026-05-15 | (runtime pending) | Local 3.16 PM0 source guards and scoped package gates PASS |
| 5 | Topic Update | 🟡 **LOCAL STATIC PASS** | 2026-05-22 | (runtime pending) | Local topic/action/workflow contract guard PASS |
| 6 | Schema Update + Cleanup | DONE | 2026-05-10 | 2026-05-10 | Logical delete fields |
| 7 | Smoke E2E | 🔴 **FAILED at A1** | 2026-05-22 13:30 | 2026-05-22 14:42 | A1_FAIL_RCA_20260522.md |
| 8 | Documentation | BLOCKED | — | — | Awaits decision |
| 9 | Cutover | BLOCKED | — | — | Awaits decision |
| 10 | Decommission (T+30) | SCHEDULED | scheduled ~2026-06-22 | — | — |

---

## Required Re-work for Phase 4

For each of the 5 PM0_PA_Card_* flows, the Workflow JSON must be rebuilt to include:
1. SharePoint Get/Create/Update items action(s)
2. Adaptive Card post action (Teams/DM/Channel)
3. Real serialized response in `result` (not hardcoded)

For each Action `.mcs.yml`, an `inputs:` block must be declared.

For each Topic `.mcs.yml`, the `BeginDialog input` must map topic variables to flow inputs.

---

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

AQ-08 structural routing is not the blocker. Local 3.16 source and scoped package static gates pass, but owner approval is still required before any tenant write and AQ-09 runtime evidence is still missing.

---

## Next Action

**Engineering action required:** Request explicit Gate 4 tenant-write approval for the rebuilt scoped 3.16 ZIP, then import/publish only after approval.

After AQ-09 evidence captured:
1. Opus #2 / CODEX-PA runs XPIA harness (Section A in-scope) — 30min auto.
2. Owner reviews aggregated evidence and renders SHIP / NO-SHIP decision — 30min.
3. If SHIP, production publish (if env != prod). Otherwise execute rollback to 3.10_POST_WFSET_CLEAN.

---

*Updated automatically by phase transitions.*
