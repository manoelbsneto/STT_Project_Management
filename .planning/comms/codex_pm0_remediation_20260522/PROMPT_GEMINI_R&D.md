# GEMINI LEAD + 2 SUBAGENTS — PM0 RELEASE 3.16 PARALLEL DOCUMENTATION & DESIGN MISSION

| Field | Value |
|---|---|
| Mission ID | `PM0-DOCS-DESIGN-20260522-GEMINI` |
| Severity | `P0` (release-blocking documentation + design assets) |
| Date issued | `2026-05-22 16:54 BRT` |
| Owner | Manoel Benicio (sole approver) |
| Owner directive | Run all 6 parallel workstreams concurrently. Do not wait for Codex #2 smoke before drafting docs. Use placeholder backfill mechanism per new Golden Rule. |
| Source of truth | `learn.microsoft.com` only — every Microsoft product behavior must be cited from official Learn docs with full URL and accessed timestamp BRT |
| Tenant write authorization | NOT granted to Gemini. Gemini is read-only for tenant. Codex (#1 and #2) owns all tenant writes. |
| Kiro role | Read-only. Kiro does not edit tenant. |
| Sync channel | `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` (append-only, 10-minute cadence) |
| Subagent budget | Owner-approved exception: Gemini Lead + Gemini sub-1 (Card Designer / Monitoring Runbook) + Gemini sub-2 (Docs Writer / Comms) |

---

## 0. MANDATORY GOLDEN RULES (read updated `.planning/GOLDEN_RULES.md` first)

Four rules govern this mission:

### 0.1 Continuous Documentation Update Rule
After every action, update relevant project docs immediately. No batching. Header on every edit:
```
Last updated: <YYYY-MM-DD HH:mm:ss BRT> | <agent_name> | <one-line reason>
```
Logged in `DOC_UPDATES_LOG.md` with diff link.

### 0.2 Evidence Triplet Rule (MANDATORY)
Every test, deploy, audit, gate, smoke, DONE/PASS/PUBLISH claim MUST include all three:
1. Screenshot (PNG/JPG saved under evidence folder)
2. Timestamp BRT exact
3. Agent name (Gemini Lead, Gemini sub-1, Gemini sub-2 — no anonymous)

Storage:
```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/<workstream>/evidence/<YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}
```

### 0.3 Placeholder Backfill Rule (MANDATORY)
Documents written ahead of upstream data MUST use exact token `<<TODO_BACKFILL: <reason> (depends on: <path>)>>`. Each section with placeholders includes a `## Backfill Manifest` at the bottom listing each placeholder, upstream evidence path, responsible agent, trigger condition. Document with open placeholders is `INCOMPLETE` and cannot ship. Backfill within 10 min of data arriving.

### 0.4 Functional Definition of Done Rule
A flow is DONE only when real runtime call returns real backend data, evidence captured, bot end-to-end test reproduces successful outcome, action+topic contracts honored, all 5 conditions evidenced.

---

## 1. CONTEXT — current project state

### 1.1 Active workstreams (parallel)

| Team | Mission | Status |
|---|---|---|
| **Codex #1 Lead** | Team Alpha — patches to 5 PM0 flows (workflows, actions, topics) | ✅ DONE 2026-05-22 16:33 BRT (per handoff) |
| **Codex #2** | Package build 3.16, tenant import/publish, AQ-09 12-scenario smoke, post-publish verifiers | ⏳ IN PROGRESS — running PROMPT_CODEX_2_FIXES_R&D.md |
| **Gemini (you)** | THIS MISSION — 6 parallel documentation + design workstreams | 🔴 STARTING |

### 1.2 The 5 in-scope PM0 flows

| Topic | Action | Workflow ID |
|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

### 1.3 Mandatory reading

| File | Purpose |
|---|---|
| `.planning/GOLDEN_RULES.md` | All 4 mandatory rules |
| `.planning/CURRENT_BASELINE.md` | Active 3.15.1 artifact, rollback target |
| `.planning/STATE.md` | Project state |
| `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` | M2 architecture decision |
| `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md` | Root cause analysis |
| `.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md` | Remediation directives |
| `.planning/comms/codex_pm0_audit_20260522/EXECUTIVE_SUMMARY.md` | Owner-facing summary |
| `.planning/comms/codex_pm0_remediation_20260522/PROMPT_CODEX_1_LEAD_R&D.md` | Codex #1 mission spec |
| `.planning/comms/codex_pm0_remediation_20260522/PROMPT_CODEX_2_FIXES_R&D.md` | Codex #2 mission spec |
| `.planning/comms/codex_pm0_remediation_20260522/ALPHA/AtualizarStatus/DEFECT_FIX_REPORT.md` | Codex #1 patch detail (5 reports total) |
| `.planning/comms/codex_pm0_remediation_20260522/ALPHA/AtualizarTarefa/DEFECT_FIX_REPORT.md` | (read all 5) |
| `.planning/comms/codex_pm0_remediation_20260522/ALPHA/CriarTarefa/DEFECT_FIX_REPORT.md` | |
| `.planning/comms/codex_pm0_remediation_20260522/ALPHA/ListarTarefas/DEFECT_FIX_REPORT.md` | |
| `.planning/comms/codex_pm0_remediation_20260522/ALPHA/ConsultarPortfolio/DEFECT_FIX_REPORT.md` | |
| `docs/MANUAL_OPERACIONAL_PMO.md` | Current PMO operational manual (you will produce v1.0 update) |
| `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md` | Current PRD baseline (you will produce v2.0 M2 final) |
| `deploy/cards/AtualizarStatusCard.json`, `AtualizarTarefaCard.json`, `CriarTarefaCard.json`, `ListarTarefasProjetoCard.json` | Existing Adaptive Cards |

Confirm reading by listing each path with one-line summary in your first response.

---

## 2. SIX PARALLEL WORKSTREAMS

| # | Workstream | Owner | Phase | Depends on Codex #2? |
|---|---|---|---|---|
| 1 | Adaptive Card design + render testing (5 cards) | Gemini sub-1 | START NOW | No |
| 2 | Manual Operacional v1.0 PT-BR with placeholders | Gemini sub-2 | START NOW (structure), backfill after smoke | Partial — needs smoke screenshots |
| 3 | Release Notes 3.16 PT-BR + EN with placeholders | Gemini sub-2 | START NOW (structure), backfill after smoke | Partial — needs final defect counts and ship date |
| 4 | Post-publish Monitoring Runbook (24h + 30 day) | Gemini sub-1 | START NOW | No |
| 5 | Owner Communication Plan with placeholders | Gemini sub-2 | START NOW (structure), backfill after smoke | Partial — needs final ship status + sample card screenshots |
| 6 | Updated PRD v2.0 reflecting M2 final state | Gemini Lead | START NOW | No |

All 6 start at minute zero. Items 2, 3, 5 use `<<TODO_BACKFILL:>>` tokens for data not yet available. Backfill triggered automatically when Codex #2 emits `[CODEX2 SMOKE COMPLETE]` to `INVESTIGATION_LOG.md`.

---

## 3. SUBAGENT ALLOCATION

### 3.1 Gemini Lead (you)
- Workstream 6: Updated PRD v2.0 (M2 final state)
- Final consolidation: `GEMINI_FINAL_REPORT.md` referencing all sub-deliverables
- Coordinate sub-1 and sub-2 via `INVESTIGATION_LOG.md`
- Monitor `INVESTIGATION_LOG.md` for `[CODEX2 SMOKE COMPLETE]` marker; trigger backfill phase

### 3.2 Gemini sub-1 — Card Designer + Monitoring Runbook
- Workstream 1: Adaptive Card design + render testing (5 cards)
- Workstream 4: Post-publish Monitoring Runbook

### 3.3 Gemini sub-2 — Docs Writer + Comms
- Workstream 2: Manual Operacional v1.0 PT-BR
- Workstream 3: Release Notes 3.16 PT-BR + EN
- Workstream 5: Owner Communication Plan

---

## 4. WORKSTREAM 1 — Adaptive Card Design + Render Testing (Gemini sub-1)

### 4.1 Scope

Five Adaptive Cards for PM0 release 3.16:

1. `AtualizarStatusCard_v316.json` (NEW — replaces static text card from prior release)
2. `AtualizarTarefaCard.json` (UPDATE — bind dynamic data)
3. `CriarTarefaCard.json` (UPDATE — bind dynamic data)
4. `ListarTarefasCard_v316.json` (NEW — FactSet of tasks)
5. `ResumoExecutivoPortfolioCard_v316.json` (NEW — FactSet with portfolio totals)

### 4.2 Per-card requirements

| Item | Specification |
|---|---|
| Schema version | Adaptive Cards 1.5 (cite Microsoft Learn URL with timestamp) |
| Size | < 27KB after dynamic data binding |
| Encoding | ASCII-only for app-facing strings (per `CURRENT_BASELINE.md`) |
| Structure | TextBlock title + FactSet for dynamic data + small TextBlock for IDs |
| Validation | Test in Adaptive Cards Designer (https://adaptivecards.io/designer/) with sample data |
| Render evidence | Screenshot of rendered card with sample data |

### 4.3 Per-card deliverables

```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/CARDS/
├── AtualizarStatusCard_v316/
│   ├── card.json
│   ├── sample_data.json
│   ├── designer_render.png
│   ├── size_measurement.txt
│   ├── ms_learn_citations.md
│   └── evidence/<ts>_gemini_sub1_step.{png,md}
├── AtualizarTarefaCard_v316/...
├── CriarTarefaCard_v316/...
├── ListarTarefasCard_v316/...
├── ResumoExecutivoPortfolioCard_v316/...
└── CARDS_AUDIT_TABLE.md (5-row consolidated)
```

Replicate JSON to `deploy/cards/` for Codex #2 to pick up in package build.

---

## 5. WORKSTREAM 4 — Post-Publish Monitoring Runbook (Gemini sub-1)

### 5.1 Scope

Operational runbook for monitoring 3.16 in production for 30 days.

### 5.2 Required sections

1. **24-hour sentinel** — what to watch in first 24h after publish: PA flow run success rates, Copilot Studio chat errors, SP write failures, Teams card render failures, ContentFiltered occurrences. Cite Microsoft Learn for Power Automate monitoring (run history, alerts).

2. **Daily checks (T+1d to T+30d)** — daily flow run inventory, drift monitor execution, AQ-08 verifier run, card render sample, escalation thresholds.

3. **Weekly checks** — full AQ-09 sub-smoke (3 in-scope scenarios), evidence archive, status report update.

4. **Escalation paths** — who to contact for: tenant outage, ContentFiltered storm, SP throttling, Planner quota exceeded, bot publish stuck. Reference `AGENT_ACCESS_PROTOCOL_P0_20260514.md`.

5. **Rollback triggers and procedure** — exact criteria that trigger rollback to `3.10_POST_WFSET_CLEAN.zip` (mirror `MITIGATION_PLAN.md` rollback steps with `pac` commands).

6. **T+30 decommission checklist** — when to delete legacy `PMO_PA_*` flows; reference ADR_AQ08 backlog item.

### 5.3 Deliverable

```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/MONITORING_RUNBOOK/
├── MONITORING_RUNBOOK_3_16.md
├── escalation_matrix.md
├── ms_learn_citations.md
├── evidence/<ts>_gemini_sub1_step.{png,md}
└── BACKFILL_MANIFEST.md (none expected — fully self-contained)
```

---

## 6. WORKSTREAM 6 — Updated PRD v2.0 M2 Final (Gemini Lead)

### 6.1 Scope

Update `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md` to v2.0 reflecting:

- M2 hybrid card-first architecture
- 5 in-scope topics on PM0_PA_Card_*
- 7 legacy topics accepted as backlog debt per ADR_AQ08
- New Adaptive Cards 1.5 design system
- Functional DoD as architectural principle
- Evidence Triplet as quality gate
- 3.16 release scope and out-of-scope
- BACKLOG-PM0-LEGACY-MIGRATION-WAVE2 as future work

### 6.2 Required sections

1. Executive Summary (M1 → M2 evolution)
2. Architectural Decisions (reference ADR_AQ08, ADR-001..004 from M2 milestone)
3. In-Scope Topics + Their Workflows + SP Lists
4. Out-of-Scope (Backlog Wave 2)
5. Functional DoD (mandatory criteria for any future flow)
6. Quality Gates (Evidence Triplet + Functional Verifier + Structural Verifier)
7. Operational Constraints (Standard-Only, ColOfertasBrasilPro env, Owner-as-sole-approver)
8. References (ADR list, RCA, REMEDIATION_PLAN, EXECUTIVE_SUMMARY, MS Learn citations)

### 6.3 Deliverable

```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/PRD/
├── PRD_PMO_M365_v2_0_M2_FINAL.md
├── architectural_diagram.md (text-based, no graphics required)
├── ms_learn_citations.md
├── evidence/<ts>_gemini_lead_step.{md}
└── BACKFILL_MANIFEST.md (none expected — fully self-contained)
```

Replicate to `PRD/PRD_PMO_M365_v2_0_M2_FINAL.md` for repo standard location.

---

## 7. WORKSTREAM 2 — Manual Operacional v1.0 PT-BR (Gemini sub-2)

### 7.1 Scope

Refresh `docs/MANUAL_OPERACIONAL_PMO.md` to v1.0 covering all 12 operations users will see in 3.16 (5 PM0 card-first + 7 legacy chat-first), passo-a-passo em PT-BR, com screenshots reais quando disponíveis.

### 7.2 Required sections

1. **Apresentação e propósito** — para quem é (PMs, gerentes, executivos), pré-requisitos, acesso ao bot
2. **Como acessar o Assistente PMO** — Teams channel deep link, comando inicial
3. **5 operações card-first (PM0)** — uma seção por operação com:
   - Comando de exemplo no chat
   - Screenshot da resposta do bot (`<<TODO_BACKFILL: screenshot bot reply (depends on: .planning/comms/codex_pm0_remediation_20260522/CODEX2/SMOKE/<scenario>/evidence/*chat_screenshot.png)>>`)
   - Screenshot do Adaptive Card no Teams (`<<TODO_BACKFILL: screenshot Adaptive Card (depends on: .planning/comms/codex_pm0_remediation_20260522/GEMINI/CARDS/<card>/designer_render.png + smoke evidence)>>`)
   - O que esperar (campos preenchidos, lista, gráfico)
   - Variações comuns (skip de campos, datas, prioridades)
4. **7 operações chat-first (legacy)** — comando + resposta esperada, sem cards detalhados (são debt aceito)
5. **Casos de erro** — ContentFiltered (raro), FlowActionBadGateway, Tarefa não encontrada, ProjectID inválido — com screenshots reais (`<<TODO_BACKFILL: error case screenshot (depends on: smoke Section A failure paths if any)>>`)
6. **Tabela de comandos rápidos** — cheat sheet de 1 página
7. **FAQ** — 10 perguntas frequentes
8. **Suporte** — quem chamar, como reportar bugs, prazo de resposta

### 7.3 Backfill Manifest (mandatory at end of doc)

```markdown
## Backfill Manifest — Manual Operacional v1.0

| Placeholder ID | Section | Reason | Upstream evidence path | Responsible | Trigger |
|---|---|---|---|---|---|
| MAN-01 | §3 A1 ListarTarefas | Bot reply screenshot | `CODEX2/SMOKE/A1_ListarTarefas/evidence/*chat_screenshot.png` | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` in INVESTIGATION_LOG |
| MAN-02 | §3 A2 ConsultarPortfolio | Bot reply + card screenshot | `CODEX2/SMOKE/A2_ConsultarPortfolio/evidence/*` + `GEMINI/CARDS/ResumoExecutivoPortfolioCard_v316/designer_render.png` | Gemini sub-2 | Same |
| MAN-03 | §3 A3 CriarTarefa | Bot reply + card screenshot | `CODEX2/SMOKE/A3_CriarTarefa/evidence/*` + `GEMINI/CARDS/CriarTarefaCard_v316/designer_render.png` | Gemini sub-2 | Same |
| MAN-04 | §3 A4 AtualizarTarefa | Bot reply + card screenshot | `CODEX2/SMOKE/A4_AtualizarTarefa/evidence/*` + `GEMINI/CARDS/AtualizarTarefaCard_v316/designer_render.png` | Gemini sub-2 | Same |
| MAN-05 | §3 A5 AtualizarStatus | Bot reply + card screenshot | `CODEX2/SMOKE/A5_AtualizarStatus/evidence/*` + `GEMINI/CARDS/AtualizarStatusCard_v316/designer_render.png` | Gemini sub-2 | Same |
| MAN-06 | §5 Erros | Sample error screenshots | Smoke Section A any failure path OR synthetic | Gemini sub-2 | Same |
```

### 7.4 Deliverable

```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/MANUAL/
├── MANUAL_OPERACIONAL_PMO_v1_0.md
├── BACKFILL_MANIFEST.md
├── ms_learn_citations.md
├── evidence/<ts>_gemini_sub2_step.{md}
```

Replicate final to `docs/MANUAL_OPERACIONAL_PMO.md` after backfill complete.

---

## 8. WORKSTREAM 3 — Release Notes 3.16 PT-BR + EN (Gemini sub-2)

### 8.1 Scope

Two files — one PT-BR, one EN — describing what shipped in 3.16, what changed vs 3.15.1, and known limitations.

### 8.2 Required sections (each language)

1. **Release header** — version, date, environment, ship status (`<<TODO_BACKFILL: SHIP/NO-SHIP/ROLLBACK (depends on: Owner Gate 9 decision)>>`)
2. **Highlights** — card-first migration of 5 topics, full backend implementation, Adaptive Cards 1.5 design system
3. **What's new** — bullet list of features per topic
4. **Defects fixed** — `<<TODO_BACKFILL: total defect count by severity (depends on: CODEX2 final defect register, derive from 5 ALPHA/<flow>/DEFECT_FIX_REPORT.md and CODEX2 SMOKE_FINAL_REPORT.md)>>`
5. **Known limitations** — 7 legacy topics still on PMO_PA_*, ContentFiltered risk on legacy paths (accepted backlog debt per ADR_AQ08)
6. **Compatibility** — env constraints (ColOfertasBrasilPro Standard-Only)
7. **Upgrade path** — `<<TODO_BACKFILL: import command + SHA256 (depends on: CODEX2/PACKAGE/package_sha256.txt)>>`
8. **Rollback path** — to `3.10_POST_WFSET_CLEAN.zip` if needed
9. **References** — RCA, REMEDIATION_PLAN, ADR_AQ08

### 8.3 Backfill Manifest

```markdown
## Backfill Manifest — Release Notes 3.16

| Placeholder ID | Section | Reason | Upstream evidence path | Responsible | Trigger |
|---|---|---|---|---|---|
| REL-01 | §1 ship status | Owner SHIP decision | Owner reply in active thread | Gemini sub-2 | Owner replies SHIP/NO-SHIP/Rollback to Codex #2 Gate 9 ASK |
| REL-02 | §4 defect counts | Final aggregate | `CODEX2/SMOKE/SMOKE_FINAL_REPORT.md` + 5 ALPHA DEFECT_FIX_REPORT.md | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` |
| REL-03 | §7 SHA256 | Package hash | `CODEX2/PACKAGE/package_sha256.txt` | Gemini sub-2 | Codex #2 Gate 3 PASS |
```

### 8.4 Deliverable

```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/
├── RELEASE_NOTES_3_16_PT_BR.md
├── RELEASE_NOTES_3_16_EN.md
├── BACKFILL_MANIFEST.md
├── ms_learn_citations.md
└── evidence/<ts>_gemini_sub2_step.{md}
```

---

## 9. WORKSTREAM 5 — Owner Communication Plan (Gemini sub-2)

### 9.1 Scope

Communication artifacts to inform PMOs, executive stakeholders, and tenant administrators about 3.16 release.

### 9.2 Required artifacts

1. **Internal stakeholder Teams post** (PT-BR) — 1-paragraph announcement + cheat sheet of 5 new commands + link to manual + sample card screenshot (`<<TODO_BACKFILL: card sample screenshot (depends on: GEMINI/CARDS/<card>/designer_render.png + smoke evidence)>>`)
2. **Executive email** (PT-BR) — 3-paragraph summary for board: what shipped, why M1 → M2, what business value (operational visibility via cards), risk profile (debt accepted)
3. **PM kickoff training outline** (PT-BR) — 30-min agenda: bot access, 5 commands hands-on, Q&A, escalation path
4. **FAQ document** — 15 perguntas: como usar, como reportar bug, o que mudou vs antes, etc.
5. **Tenant admin notification** (PT-BR) — what changed in `pmo_AssistentePMO_V2` solution, new Adaptive Card volume in Teams channel, expected SP write rate change

### 9.3 Backfill Manifest

```markdown
## Backfill Manifest — Owner Communication Plan

| Placeholder ID | Section | Reason | Upstream evidence path | Responsible | Trigger |
|---|---|---|---|---|---|
| COM-01 | Stakeholder Teams post | Sample card screenshot | `GEMINI/CARDS/<card>/designer_render.png` + Codex #2 smoke render | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` and `[GEMINI CARDS COMPLETE]` |
| COM-02 | Executive email | Final ship status | Owner Gate 9 decision | Gemini sub-2 | Owner replies |
| COM-03 | Tenant admin notif | Final solution component count | `CODEX2/PACKAGE/package_inventory.md` | Gemini sub-2 | Codex #2 Gate 3 PASS |
```

### 9.4 Deliverable

```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/COMMS/
├── stakeholder_teams_post.md
├── executive_email.md
├── pm_kickoff_outline.md
├── faq.md
├── tenant_admin_notification.md
├── BACKFILL_MANIFEST.md
└── evidence/<ts>_gemini_sub2_step.{md}
```

---

## 10. EXECUTION SEQUENCE AND CONCURRENCY

| Workstream | Owner | Start at | Self-contained? | Depends on Codex #2 |
|---|---|---|---|---|
| 1 — Cards | Gemini sub-1 | T+0 | YES (use sample data) | NO |
| 2 — Manual | Gemini sub-2 | T+0 (structure) | NO (smoke screenshots) | Phase 2 backfill |
| 3 — Release Notes | Gemini sub-2 | T+0 (structure) | NO (defect counts, hash, ship status) | Phase 2 backfill |
| 4 — Monitoring Runbook | Gemini sub-1 | T+0 | YES | NO |
| 5 — Comms | Gemini sub-2 | T+0 (structure) | NO (card samples, ship status) | Phase 2 backfill |
| 6 — PRD v2.0 | Gemini Lead | T+0 | YES | NO |

Phase 2 backfill triggered by:
- `[CODEX2 SMOKE COMPLETE]` line in `INVESTIGATION_LOG.md` → backfill manual MAN-01 to MAN-06, release notes REL-02, comms COM-01
- Codex #2 Gate 3 PASS → backfill release notes REL-03, comms COM-03
- Owner Gate 9 decision → backfill release notes REL-01, comms COM-02

Within 10 minutes of trigger, the responsible Gemini agent backfills the placeholder, refreshes `Last updated:` header, logs in `DOC_UPDATES_LOG.md` with diff link.

---

## 11. EVIDENCE FOLDER STRUCTURE

```
.planning/comms/codex_pm0_remediation_20260522/GEMINI/
├── CARDS/                       (Workstream 1)
├── MANUAL/                      (Workstream 2)
├── RELEASE_NOTES/               (Workstream 3)
├── MONITORING_RUNBOOK/          (Workstream 4)
├── COMMS/                       (Workstream 5)
├── PRD/                         (Workstream 6)
├── INVESTIGATION_LOG.md         (your portion of the shared log)
├── DOC_UPDATES_LOG.md           (every doc edit)
├── EVIDENCE_LOG.md              (every triplet file indexed)
├── BACKFILL_TRACKER.md          (master list of all `<<TODO_BACKFILL:>>` across all workstreams)
└── GEMINI_FINAL_REPORT.md       (Lead consolidates)
```

`BACKFILL_TRACKER.md` is auto-generated by grep:
```powershell
git grep -F '<<TODO_BACKFILL:' '.planning/comms/codex_pm0_remediation_20260522/GEMINI/' | Out-File 'BACKFILL_TRACKER.md'
```
Re-run after every backfill action to confirm zero remaining placeholders before final delivery.

---

## 12. CONTINUOUS DOC UPDATES (mandatory, real-time)

After every workstream phase, every backfill, every card validation, every doc draft, update:

- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_TASKS_PLANNER.csv`
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_EXECUTIVE_20260522.md`
- `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` (10-min cadence)
- `.planning/comms/codex_pm0_remediation_20260522/DOC_UPDATES_LOG.md`

Header on every edit:
```
Last updated: <YYYY-MM-DD HH:mm:ss BRT> | Gemini <Lead|sub-1|sub-2> | <one-line reason>
```

---

## 13. METRICS AND ACCEPTANCE CRITERIA

Mission accepted only when ALL true:

| Metric | Target | Verification |
|---|---|---|
| 5 Adaptive Cards designed and validated | 5 cards in `GEMINI/CARDS/` | `CARDS_AUDIT_TABLE.md` |
| All 5 cards < 27KB | 5/5 PASS | `size_measurement.txt` per card |
| All 5 cards render in Adaptive Cards Designer | 5/5 with screenshot | `designer_render.png` per card |
| All 5 cards ASCII-only app-facing strings | 5/5 PASS | grep result |
| Manual Operacional v1.0 structure complete | 1 doc 8 sections | `MANUAL_OPERACIONAL_PMO_v1_0.md` |
| Manual placeholders backfilled | 0 `<<TODO_BACKFILL:>>` matches | `git grep -F '<<TODO_BACKFILL:' MANUAL_OPERACIONAL_PMO_v1_0.md` |
| Release Notes PT-BR + EN structure complete | 2 docs 9 sections each | files exist |
| Release Notes placeholders backfilled | 0 matches | grep |
| Monitoring Runbook complete | 1 doc 6 sections | file exists |
| PRD v2.0 complete | 1 doc 8 sections | file exists |
| Owner Communication Plan 5 artifacts | 5 files | folder list |
| Comms placeholders backfilled | 0 matches | grep |
| BACKFILL_TRACKER.md final state | empty (zero placeholders) | grep |
| All MS Learn citations present | every doc has `ms_learn_citations.md` | files exist |
| Project docs continuously updated | All within 10min of last action | `Last updated:` headers |
| EVIDENCE_LOG.md entries | One per workstream phase | master index |

---

## 14. FORBIDDEN

| Action | Why |
|---|---|
| Tenant write | Gemini is read-only for tenant; Codex owns tenant writes |
| Citing memory or third-party for Microsoft behavior | MS Learn only |
| Shipping a doc with open `<<TODO_BACKFILL:>>` placeholders | Placeholder Backfill Rule violation |
| Inventing MS Learn URLs | Must be real, accessed, timestamped |
| Skipping any of 6 workstreams | Acceptance failure |
| Editing tenant from Kiro instance | Kiro is read-only |
| Marking workstream DONE without all 3 Evidence Triplet elements | Golden Rule §0.2 |
| Deferring backfill beyond 10min after upstream evidence available | Continuous Documentation Update Rule + Placeholder Backfill Rule violation |
| Producing cards exceeding 27KB | Card render fails in Teams |
| Producing app-facing strings with non-ASCII | `CURRENT_BASELINE.md` compliance |

---

## 15. FINAL DELIVERY (Gemini Lead message in active thread when mission complete)

1. Confirmation of all 4 Golden Rules (§0) absorbed
2. Confirmation of all mandatory reading (§1.3) completed with one-line summary per file
3. Path to GEMINI_FINAL_REPORT.md (consolidated)
4. Per-workstream completion summary (6 rows: workstream, owner, deliverable path, triplet evidence count)
5. BACKFILL_TRACKER.md final state (must show zero `<<TODO_BACKFILL:>>` matches)
6. Path to PRD v2.0 file (replicated to `PRD/PRD_PMO_M365_v2_0_M2_FINAL.md`)
7. Path to Manual file (replicated to `docs/MANUAL_OPERACIONAL_PMO.md` post-backfill)
8. Path to Release Notes (PT-BR + EN)
9. Path to Comms artifacts (5 files)
10. Path to Cards (5 cards in `deploy/cards/` for Codex #2 package build)
11. Path to Monitoring Runbook
12. List of every project doc updated with timestamp BRT and reason
13. Confirmation no tenant write performed
14. Time stamps for Lead + sub-1 + sub-2 dispatch / completion / backfill phase

---

## 16. WHAT MUST NOT HAPPEN AGAIN

The reason this Gemini mission exists alongside Codex #1 + #2 is that prior releases (3.10 through 3.15.1) shipped without consolidated user documentation, without functional Adaptive Card designs, and without owner communication artifacts. PM users had no manual reflecting current bot behavior; executives had no release narrative; tenant admins were not notified.

3.16 will not ship that way. Every doc and every card produced by this mission must be evidence-backed, MS-Learn-cited, ASCII-compliant, and backfilled to zero placeholder count before Gate 9 SHIP.

If any backfill placeholder remains open at delivery time, or if any card exceeds 27KB, or if any MS Learn citation is missing or invented, the mission is NOT complete.

---

## END OF SPECIFICATION — Gemini Lead, dispatch sub-1 and sub-2 now, all 6 workstreams in parallel

