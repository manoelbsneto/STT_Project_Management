# CODEX IC / GATEKEEPER AUDIT

Date: 2026-05-07
Scope: Programmatic audit only. No browser-owned files or `deploy/copilot/AssistentePMO.template.yaml` were edited.

## Current Gate Status

Verdict: NO-SHIP.

The active stop-ship source of truth is `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md`. It defines 16 GAPs and requires NO-SHIP unless every quality gate is green. The current status still shows open SEV-0/P0 blockers: 5 stub topics, incomplete STT support, partial confirm-before-action runtime state, V3 flow stub behavior, dead CriarTarefa binding, missing ghost cleanup, and missing Operations Manual evidence. Evidence: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:129-142`, `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:252-265`, `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:294-308`.

The May 6 checklist/readiness files also say NO-SHIP, but for the older six-flow import/manual-test gate. They do not represent the full May 7 stop-ship scope.

## Stale Or Conflicting Claims

1. `.planning/stop_ship/MASTER_CHECKLIST.md` claims "Known stop-ship fixes implemented" and "Fixed ZIP imported to target" are PASS, with all six PMO flows activated. Evidence: `.planning/stop_ship/MASTER_CHECKLIST.md:11-16`. This conflicts with the May 7 plan, where GAP-A1 says V3 still lacks real SharePoint logic and GAP-A2 says CriarTarefa still binds to a dead flow. Evidence: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:129-130`, `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:301-302`.

2. `.planning/stop_ship/MASTER_CHECKLIST.md` tracks only WI-001 through WI-007 as complete/imported. Evidence: `.planning/stop_ship/MASTER_CHECKLIST.md:25-31`. It does not track the active 16 GAP IDs from the May 7 registry. Evidence: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:129-144`.

3. `.planning/stop_ship/RELEASE_READINESS_CHECKLIST.md` says critical fixes are complete locally, ZIP import succeeded, post-import export validated, and flow activation is YES. Evidence: `.planning/stop_ship/RELEASE_READINESS_CHECKLIST.md:8-12`. This is stale against the May 7 plan because PAC/solution import is explicitly not sufficient for Copilot runtime tool registration, and all flow/topic runtime work requires UI evidence. Evidence: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:28`, `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:83`.

4. `.planning/stop_ship/RELEASE_READINESS_CHECKLIST.md` allows SHIP after listed manual tests get green run URLs/screenshots. Evidence: `.planning/stop_ship/RELEASE_READINESS_CHECKLIST.md:29-33`. That is incomplete under the current quality gates, which additionally require all 8 PRD topics functional, STT/long-text handling, V3 write plus duplicate check, V3 binding, 10 PRD flow runtime evidence, ghost cleanup, automated tests, Operations Manual, and zero SEV-0/P0 open items. Evidence: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:252-265`.

5. `.planning/stop_ship/RISK_REGISTER.md` retains old risks RISK-001 through RISK-006 but does not include active May 7 risks for stub topics, dead Copilot binding, ghost bot components, missing recurrence/runtime evidence, SyncPlannerStats, AlertaProjetoVermelho, or Operations Manual. Evidence: `.planning/stop_ship/RISK_REGISTER.md:5-10`, `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:129-142`.

## Required Updates

### MASTER_CHECKLIST.md

Replace or supersede the May 6 WI-only table with the May 7 GAP registry. Required fields per GAP: GAP ID, severity, owner, wave, status, current evidence, next required evidence, and gate impact.

Mark these gates NO-SHIP/PENDING until browser/runtime evidence exists:
- GAP-A1: V3 SharePoint write and duplicate check.
- GAP-A2: CriarTarefa UI binding to V3 and published bot evidence.
- GAP-B1 through GAP-B6: functional topic/flow implementation and STT/long-text evidence.
- GAP-B7: template fix is not enough; require published runtime evidence.
- GAP-C1: ghost component cleanup requires discovery plus Human/Admin deletion approval.
- GAP-C2 through GAP-C4: recurrence and E2E runtime evidence.
- GAP-C5: Operations Manual delivered.

Retain May 6 imported-ZIP evidence only as historical evidence, not as a release gate PASS.

### RISK_REGISTER.md

Keep existing risks if still true, but remap them to GAP IDs and add missing active stop-ship risks:
- RISK: PAC/import success can mask Copilot runtime tool registration failure. Map: GAP-A2, GAP-B1 through GAP-B7.
- RISK: Read/write topics are stubs or confirm-only. Map: GAP-B1 through GAP-B5.
- RISK: STT/long-text remains runtime-unproven. Map: GAP-B6, GAP-B7.
- RISK: Dataverse ghost bot components can pollute runtime routing. Map: GAP-C1.
- RISK: Scheduled/recurrence flows lack green-run evidence. Map: GAP-C2, GAP-C3, GAP-C4.
- RISK: Release operations are undocumented. Map: GAP-C5.

Close or downgrade RISK-001/RISK-002 only after live V3 success, duplicate, and Copilot T-007 evidence are attached.

### RELEASE_READINESS_CHECKLIST.md

Replace "IMPORTED, but NO-SHIP until Opus manual runbook passes" with "NO-SHIP until May 7 quality gates are green." The readiness checklist must require:
- All GAP-A/B/C blockers closed with proof links.
- Browser evidence for Copilot binding, publish, and test chat.
- Power Automate green run URLs for all 10 PRD flows.
- SharePoint item screenshots or equivalent evidence for write flows.
- Ghost cleanup evidence or explicit Human/Admin risk acceptance.
- Operations Manual path and review status.
- Rollback plan updated to include previous bot version plus flow version/solution export, not only ZIP reimport.

## NO-SHIP Blockers By GAP ID

| GAP ID | Blocker | Required evidence to clear |
|---|---|---|
| GAP-A1 | V3 flow has no proven real SharePoint write logic. | Successful flow run URL, duplicate-test run URL, and SharePoint `Projetos` item evidence. |
| GAP-A2 | CriarTarefa binds to dead/non-target flow in Copilot runtime. | Browser evidence showing binding to V3 flow, published bot, and T-007 chat result. |
| GAP-B1 | ConsultarPortfolio is a stub. | Flow/topic implementation plus live response evidence from `Projetos`. |
| GAP-B2 | ConsultarProjeto is a stub. | Flow/topic implementation plus live lookup evidence including risks/bloqueios. |
| GAP-B3 | RegistrarRisco confirms but does not write. | Live SharePoint create evidence in `Riscos e Bloqueios` with `Tipo=Risco`. |
| GAP-B4 | RegistrarBloqueio confirms but does not write. | Live SharePoint create evidence in `Riscos e Bloqueios` with `Tipo=Bloqueio`. |
| GAP-B5 | PedirDecisao confirms but does not write. | Live SharePoint create evidence in `Decisoes do Board`. |
| GAP-B6 | AtualizarStatus is STT-incompatible. | Runtime evidence for long-text/STT-style input through parse, confirm, and write path. |
| GAP-B7 | Boolean confirmation fix is template-only until published/tested. | Published runtime evidence using String confirmation terms. |
| GAP-C1 | Ghost bot components remain pending cleanup. | Discovery output plus Human/Admin-approved deletion or explicit release risk acceptance. |
| GAP-C2 | Recurrence flows lack runtime evidence. | Green run evidence for each recurrence flow. |
| GAP-C3 | SyncPlannerStats lacks real-data test. | Green run against pilot project with PlannerPlanId. |
| GAP-C4 | AlertaProjetoVermelho E2E is unverified. | StatusRAG=Vermelho trigger evidence and resulting alert evidence. |
| GAP-C5 | Operations Manual is missing. | pt-BR Operations Manual artifact linked and reviewed. |

GAP-D1 and GAP-D2 remain post-ship only and are not release blockers unless Project Owner changes the gate.
