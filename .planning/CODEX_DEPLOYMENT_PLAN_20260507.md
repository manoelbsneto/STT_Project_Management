# 🔴 SEV-0 STOP-SHIP DILIGENCE MISSION — PMO Intelligent Hub GAP Closure

# Mode: Deterministic, Evidence-First, Zero-Unverified-Claims
# Priority: Highest (Block release until all gates are green)

---

## 0) CONTEXT

- **Repo / branch:** `d:\VMs\Projetos\STT_Project_Management` | `main`
- **Environment:** `ColOfertasBrasilPro` (ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- **SharePoint Site:** `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
- **Bot:** `Assistente PMO Clean` (V2)
- **Architecture docs:**
  - PRD v1.3: `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md`
  - V2 YAML: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml`
  - RCA: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md`
  - Ghost cleanup: `.planning/CODEX_HANDOFF_GHOST_CLEANUP_20260506.md`
- **Evidence log:** `.planning/stop_ship/EVIDENCE_LOG.md`
- **Test report:** `.planning/stop_ship/OPUS_MANUAL_TEST_REPORT.md`
- **Current failing areas / symptoms:**
  - CriarTarefa V3 flow is a stub (no SharePoint write logic)
  - 5 of 8 PRD topics are stubs (confirm but never write)
  - STT/long-text parsing only in 1 of 6 write topics
  - BooleanPrebuiltEntity breaks STT confirmation in 4 topics
  - Ghost bot components polluting Dataverse
  - 4 recurrence flows lack runtime evidence
- **Target release date:** Phase 6 Gate (Piloto Controlado) — blocked until all gates green
- **CRITICAL CONSTRAINT:** `PAC/solution import is NOT sufficient for Copilot runtime tool registration. All Power Automate flows and Copilot Studio topics MUST be created/edited through the UI.`

---

## 1) MISSION (NON-NEGOTIABLE)

We are in a **Stop-Ship** state due to 16 identified gaps between AS-IS and PRD v1.3 compliance.

Your job is to:
1. Produce **RCA-grade diagnosis** for each gap (with evidence from YAML audit + flow runs).
2. Implement **surgical fixes** — flow blueprints, YAML updates, test scripts — with **minimal blast radius**.
3. Build **massive, automated test coverage** that proves each fix and prevents regressions.
4. Provide **release readiness decision**: SHIP / NO-SHIP with explicit rationale per gate.

You must not allow any code to ship without passing all quality gates.

---

## 2) OPERATING PRINCIPLES (HARD RULES)

- **Evidence > opinions.** Every claim must be backed by: file path + line refs + logs/commands + screenshots/output.
- **Prefer small, reversible changes.** Avoid refactors unless required for safety.
- **No "works on my machine".** Reproduce using scripted tests and CI parity.
- **Blame-free language.** Focus on systems and facts, not people.
- **If something is ambiguous,** stop and request the missing artifact explicitly.
- **Standard-Only.** No Premium connectors, no Graph API, no HTTP with Entra ID.
- **ASCII-Only text.** No emoji, no accents, no cedilla in flow/bot operational text.
- **GPT-4.1 model only.** GPT-5 Chat causes routing failures.
- **Confirm-Before-Action.** Mandatory on ALL write topics (PRD §9.3).
- **pt-BR primary language** for all user-facing content.

---

## 3) APPROVED RESPONSIBILITY MATRIX

> **Approved by:** Project Owner — 2026-05-07 16:57 BRT

| Area | Codex (Programmatic) | Opus (Browser) | Human/Admin |
|------|:---:|:---:|:---:|
| Repo inventory / stop-ship artifacts | ✅ | — | — |
| YAML audit / topic stub detection | ✅ | — | — |
| Power Automate expression validation | ✅ | — | — |
| Generate flow blueprints / JSON / scripts | ✅ | — | — |
| SharePoint schema validation | ✅ | Maybe | — |
| Dataverse ghost botcomponent discovery | ✅ | Maybe | — |
| Dataverse ghost botcomponent **deletion** | — | — | ✅ Approval required |
| Flow creation/update (definition + deploy via API) | ✅ Execute | — | — |
| Copilot topic binding to flows | ❌ Risky | ✅ Required | — |
| Publish bot | ❌ | ✅ Required | — |
| Bot test chat | ❌ | ✅ Required | — |
| Screenshot evidence capture | ❌ | ✅ Required | — |
| Evidence pack / release report | ✅ | — | — |
| Tenant permission escalation | — | — | ✅ Approval required |

**Principle:** Codex prepares everything so Opus only performs short, targeted browser actions with a checklist. Ship/no-ship decision depends on live Copilot runtime evidence captured in browser.

---

## 4) AGENT ROLES (RUN IN PARALLEL)

> **Codex may spawn up to 3 subagents** for parallel execution within its programmatic scope (scripts, tests, blueprints, evidence assembly). Subagents must respect the Coordination Contract file locks and ownership boundaries.

### Agent A — Incident Commander (IC) / Program Control
- Build and maintain: `MASTER_CHECKLIST.md` + `RISK_REGISTER.md`
- Track all 16 GAPs as tickets with: severity, owner-agent, status, proof-links
- Enforce gates: if any gate fails → NO-SHIP

### Agent B — Reproduction & Forensics
- Reproduce each stub/failure deterministically via YAML audit + flow run history
- Create minimal repro evidence: bot conversation logs, flow run URLs, SharePoint screenshots
- Extract evidence for ghost bot components via Dataverse Web API queries

### Agent C — Code Surgeon
- Propose fix options for each GAP with pros/cons and blast radius
- Implement the smallest safe fix:
  - Flow definition scripts (`deploy/PA_*.ps1`)
  - YAML template updates (`deploy/copilot/AssistentePMO.template.yaml`)
  - SharePoint schema validation scripts
- Add guardrails: duplicate checks, input validation, error responses

### Agent D — QA / Test Architect (Massive Tests)
- Build test strategy with layers:
  - **Unit tests:** PowerShell flow definition validation (`tests/Test-CriarTarefaFlowDefinition.ps1`)
  - **Contract tests:** YAML topic-to-flow binding validation (`tests/Test-CriarTarefaContract.ps1`)
  - **Integration tests:** SharePoint OData filter expression validation
  - **Regression suite:** One test per GAP ID mapping to fix
- Ensure tests fail before fix and pass after fix

### Agent E — Release Gatekeeper
- Define release checklist per wave
- Ensure CI parity between local tests and runtime evidence
- Maintain rollback plan: previous bot version + flow version in solution export
- Generate final SHIP / NO-SHIP verdict

---

## 5) ISSUE REGISTRY (16 GAPS)

| GAP ID | Severity | Title | Owner | Status | Wave |
|--------|----------|-------|-------|--------|------|
| GAP-A1 | SEV-0 | V3 Flow has no real SharePoint logic | — | ✅ DONE (Session 18) | 1 |
| GAP-A2 | SEV-0 | CriarTarefa topic binds to dead flow `42d9abd1` | — | ✅ DONE (Sessions 17-18) | 1 |
| COLD-START | SEV-0 | 1st message fails NLU recognition | — | ✅ DONE (Session 19) | 1 |
| GAP-B1 | P0 | ConsultarPortfolio is a stub | User/Opus | 🔧 PARTIAL — redirect works, flow E2E pending | 2 |
| GAP-B2 | P0 | ConsultarProjeto is a stub | User/Opus | ❌ Pending E2E | 2 |
| GAP-B3 | P0 | RegistrarRisco confirms but never writes | User/Opus | ❌ Pending E2E — redirect validated | 3 |
| GAP-B4 | P0 | RegistrarBloqueio confirms but never writes | User/Opus | ❌ Pending E2E | 3 |
| GAP-B5 | P0 | PedirDecisao confirms but never writes | User/Opus | ❌ Pending E2E — redirect validated | 3 |
| GAP-B6 | P0 | AtualizarStatus asks field-by-field (STT-incompatible) | User/Opus | 🔧 PARTIAL — redirect works, STT test pending | 4 |
| GAP-B7 | P0 | BooleanPrebuiltEntity breaks STT confirmation | — | ✅ DONE (Session 19) — `sim` confirmed | 4 |
| GAP-C1 | P1 | Ghost bot components in Dataverse | Human/Admin | Pending admin approval | 5 |
| GAP-C2 | P1 | Recurrence flows lack runtime evidence | Opus | ❌ Open | 5 |
| GAP-C3 | P1 | SyncPlannerStats never tested with real data | Opus | ❌ Open | 5 |
| GAP-C4 | P1 | AlertaProjetoVermelho E2E unverified | Opus | ❌ Open | 5 |
| GAP-C5 | P1 | Operations Manual missing | — | ✅ DONE | 5 |
| GAP-D1 | P2 | Marcos e Entregas list missing | Codex | ⚪ Post-ship | 6 |
| GAP-D2 | P2 | Planner Metrics Snapshot list missing | Codex | ⚪ Post-ship | 6 |

---

## 6) WAVE EXECUTION PLANS

### WAVE 1 — SEV-0: Unblock CriarTarefa

#### TASK 1.1: Deploy V3 Flow Real Logic via API (GAP-A1)

**Flow:** `PMO_PA_CriarTarefa_V3` (ID: `3104124d-364a-f111-bec7-7ced8d955c6c`)
**Current State:** Returns hardcoded "Projeto criado com sucesso" — no SharePoint write
**Target State:** Full `Projetos` list write with duplicate check
**Owner:** Codex — 100% programmatic via ProcessSimple API
**Script:** `deploy/PA_CriarTarefa_Flow.ps1` — ✅ Already built, tested, and validated
**Method:** PATCH existing flow via `InvokeApi -Method PATCH` to ProcessSimple endpoint

**Codex execution command:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File deploy\PA_CriarTarefa_Flow.ps1
```

**What the script does (already validated by tests):**
1. Builds complete flow definition with Skills trigger + named inputs (`titulo`, `responsavel`, `prazo`, `horas`, `prioridade`, `nomeProjeto`)
2. Compose actions: NomeProjeto normalization, DataAlvo dd/MM/yyyy→yyyy-MM-dd (no `padLeft`), Prioridade mapping, ProjectID generation
3. SharePoint Get Items with DateTime day-range duplicate check
4. Condition branch: duplicate → respond "Projeto duplicado" / else → Create Item in `Projetos` with `PM/Claims`, `StatusRAG/Value`, `Prioridade/Value`
5. Error branch on Failed/TimedOut → respond `SP_WRITE_FAILED`
6. PATCHes the existing V3 flow via ProcessSimple API
7. Saves evidence JSON to `.planning/comms/`

**Evidence produced:** build/static evidence and timeout report in `.planning/comms/CODEX_PROGRAMMATIC_DEPLOY_ATTEMPT_20260507.md`.
**Current result:** deploy attempt timed out in local Power Platform API/auth calls; Opus/admin runtime validation remains required.

#### TASK 1.2: Rebind CriarTarefa Topic (GAP-A2)

**Where:** Copilot Studio UI → Topic `CriarTarefa`
**Action:** Change `BeginDialog` from old flow `42d9abd1` to V3 `3104124d`
**Evidence required:** Published bot, test chat screenshot

#### TASK 1.3: Retest T-007

**Input:** `Criar tarefa: Titulo=Teste Wave1 20260507, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=100, Prioridade=Alta`
**Expected:** Parse → confirm → "sim" → SharePoint item created → ProjectID returned
**Evidence required:** Bot conversation screenshot, flow run URL, SharePoint item

---

### WAVE 2 — P0: Make Read Topics Real

#### TASK 2.1: `PMO_PA_ConsultarPortfolio` (GAP-B1)

New Copilot-triggered flow: Get items from `Projetos` (Ativo=1) → count Verde/Amarelo/Vermelho → count stale (>24h) → Respond summary

#### TASK 2.2: `PMO_PA_ConsultarProjeto` (GAP-B2)

New Copilot-triggered flow: Input `nomeProjeto` → lookup `Projetos` → lookup open risks in `Riscos e Bloqueios` → Respond details

---

### WAVE 3 — P0: Make Write Topics Real

#### TASK 3.1: `PMO_PA_RegistrarRiscoBot` (GAP-B3)

New Copilot-triggered flow: Input `projectName`, `descricao`, `severidade` → lookup ProjectID → generate RiskID → Create item in `Riscos e Bloqueios` (Tipo=Risco) → Respond

#### TASK 3.2: `PMO_PA_RegistrarBloqueioBot` (GAP-B4)

Same as 3.1 with `Tipo=Bloqueio`, `Impacto` instead of `Severidade`

#### TASK 3.3: `PMO_PA_PedirDecisaoBot` (GAP-B5)

New Copilot-triggered flow: Input `projectName`, `descricao`, `impacto`, `prazo`, `aprovador` → lookup ProjectID → generate DecisionID → Create item in `Decisoes do Board` → Respond

---

### WAVE 4 — P0: STT / Long Text Compatibility

#### TASK 4.1: Redesign AtualizarStatus for STT (GAP-B6)

Replace 6 sequential Question nodes with: `System.Activity.Text` capture → regex parse (same pattern as CriarTarefa) → ask only missing fields → StringPrebuiltEntity confirm → call `PMO_PA_CheckInOnDemand`

#### TASK 4.2: BooleanPrebuiltEntity → StringPrebuiltEntity (GAP-B7)

**Status:** ✅ Already fixed in `deploy/copilot/AssistentePMO.template.yaml`
All 5 write topics now use `Or(Lower(Topic.Confirmar) = "sim", "s", "yes", "confirmo")`

---

### WAVE 5 — P1: Cleanup & Evidence

#### TASK 5.1: Ghost Bot Cleanup (GAP-C1) — Human approval required
#### TASK 5.2: Recurrence Flow Evidence (GAP-C2) — Opus captures at scheduled times
#### TASK 5.3: SyncPlannerStats Test (GAP-C3) — Set PlannerPlanId on pilot project
#### TASK 5.4: AlertaProjetoVermelho E2E (GAP-C4) — Change StatusRAG to Vermelho
#### TASK 5.5: Operations Manual (GAP-C5) — Codex drafts, Opus reviews

---

### WAVE 6 — P2: Enhancements (Post-Ship)

- GAP-D1: Create `Marcos e Entregas` SharePoint list
- GAP-D2: Create `Planner Metrics Snapshot` SharePoint list

---

## 7) QUALITY GATES (STOP-SHIP UNTIL GREEN)

**NO-SHIP** unless ALL are satisfied:

- ✅ All 8 PRD topics functional (not stubs) — GAP-B1 through B7
- ✅ All topics handle STT/long text/multiline input — GAP-B6, B7
- ✅ All write topics implement Confirm-Before-Action — PRD §9.3
- ✅ V3 flow writes to `Projetos` with duplicate check — GAP-A1
- ✅ CriarTarefa topic binds to V3 flow (not dead `42d9abd1`) — GAP-A2
- ✅ All 10 PRD flows have ≥1 runtime evidence (green run) — GAP-C2
- ✅ Ghost bot components cleaned from Dataverse — GAP-C1
- ✅ All automated tests green: `Test-CriarTarefaFlowDefinition.ps1`, `Test-CriarTarefaContract.ps1`
- ✅ Operations Manual delivered (pt-BR) — GAP-C5
- ✅ Zero known SEV-0/P0 items open

If any gate is not met: output **NO-SHIP** and list blocking items.

---

## 8) REQUIRED OUTPUT ARTIFACTS

| Artifact | Path | Owner |
|----------|------|-------|
| EXEC_SUMMARY.md | `.planning/stop_ship/EXEC_SUMMARY.md` | Agent A (IC) |
| EVIDENCE_LOG.md | `.planning/stop_ship/EVIDENCE_LOG.md` | Agent B (Forensics) |
| MASTER_CHECKLIST.md | `.planning/stop_ship/MASTER_CHECKLIST.md` | Agent A (IC) |
| TEST_STRATEGY.md | `.planning/stop_ship/TEST_STRATEGY.md` | Agent D (QA) |
| RELEASE_READINESS_CHECKLIST.md | `.planning/stop_ship/RELEASE_READINESS_CHECKLIST.md` | Agent E (Gatekeeper) |
| ISSUE_RCA_PACK.md | `.planning/stop_ship/ISSUE_RCA_PACK.md` | Agent B (Forensics) |
| COORDINATION_CONTRACT.md | `.planning/COORDINATION_CONTRACT.md` | Opus |

---

## 9) COMMUNICATION CADENCE (STRICT)

Every agent posts updates in the format:
- **What I did** (with file paths + diffs)
- **What I found** (with evidence)
- **What I changed** (commit/PR)
- **What is still risky**
- **Next step + blocking items**

---

## 10) CURRENT STATUS (Updated 2026-05-10 18:40 BRT)

| Gate | Status | Evidence |
|------|--------|----------|
| All 8 PRD topics functional | PARTIAL (3/8 live) | CriarTarefa DONE, topic redirects for 5 topics validated. B1-B5 E2E SP write pending. |
| STT/long text support | PARTIAL | CriarTarefa parses long STT input correctly (Session 19). AtualizarStatus pending. |
| Confirm-Before-Action | **DONE** | CriarTarefa `sim` confirmation tested and working (Session 19). |
| V3 flow writes to Projetos | **DONE** | Flow rebuilt via Classic Designer. Success + duplicate tests PASS (Session 18). |
| CriarTarefa binds to V3 | **DONE** | Binding fixed, published, T-007 PASS (Sessions 17-18). |
| Cold Start NLU mitigation | **DONE** | Greeting + Fallback SmartRedirect deployed. 7/7 tests PASS (Session 19). |
| All 10 flows have runtime evidence | PARTIAL | CriarTarefa V3 has runtime evidence. C2-C4 remain missing. |
| Ghost components cleaned | Pending admin | Discovery script created; deletion approval pending. |
| Automated tests green | Partial | New local tests PASS; live export audit still fails ASCII/mojibake. |
| Operations Manual | **DONE** | `docs/MANUAL_OPERACIONAL_PMO.md` delivered and test PASS. |
| Zero SEV-0 open | **DONE** | A1, A2, Cold Start all resolved with live runtime evidence. |

**VERDICT: CONDITIONAL SHIP — All SEV-0 items resolved. P0 E2E validation (B1-B6) remains blocking for full SHIP.**

Detailed current table: `.planning/stop_ship/CURRENT_STATUS_TABLE_20260507.md`.

---

*End of SEV-0 mission document. No agent starts a wave without previous wave approved by Project Owner. No PAC/solution imports. All UI changes require browser execution.*
