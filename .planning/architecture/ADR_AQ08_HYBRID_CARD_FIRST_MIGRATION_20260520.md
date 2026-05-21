# ADR: Hybrid Card-First Migration for AQ-08 Publish Gate

ADR ID: ADR-AQ08-HYBRID-MIGRATION-20260520
Date: 2026-05-20
Status: Accepted
Author: Opus 4.7 (Principal Solutions Microsoft Architect)
Owner approval: Manoel Benicio (in-thread, 2026-05-20 16:19 BRT)
Project: PMO Intelligent Hub — `Assistente PMO V2`
Environment: `ColOfertasBrasilPro`
Active package: `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip`
Supersedes: none
Tenant changes executed: None by this ADR

---

## 1. Context

### 1.1 Trigger

On 2026-05-20, CODEX-PA executed the read-only AQ-08-PRE topic routing verification (TASK 1 of `CODEX_5_5_DISPATCH_PROMPT_P0_RELEASE_CLOSEOUT_20260520`). The verification produced a Dataverse-backed inventory under `.planning/comms/aq08_topic_routing_verification_20260520/` showing that:

- All 12 legacy `PMO_PA_*` workflows are active in the tenant.
- All 6 new `PM0_PA_*` action components and workflows from AQ-07 are active and bindable.
- All 11 active topics in `pmo_AssistentePMO_V2` still route to the legacy `PMO_PA_*` action components or call legacy workflow IDs directly.

CODEX-PA correctly stopped per coordination rule 2 (notify Owner on STALE finding) and classified all routed topics as STALE against the expectation "every topic should call PM0_PA_*".

### 1.2 Architectural intent of the 2026-05-14 P0 replan

The original P0 replan documents (`AS_IS_TO_BE_ADAPTIVE_CARDS_PLANNER_20260514.md`, `P0_POWER_AUTOMATE_FLOW_DESIGN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `CHANGE_REQUEST_CARD_FIRST_PLANNER_P0_20260514.md`) define a **scoped** card-first migration with five (5) operational scenarios:

1. Executive visibility (portfolio summary).
2. PM update loop with multiline / single-box review-before-write.
3. Task list (read).
4. Task create.
5. Task update.

The replan does NOT include card-first migration of project create/read/delete, task delete, decisions, risks, or blockers. Those remain in the prior chat-first pattern intentionally, deferred for a future replan.

### 1.3 Mismatch resolved by this ADR

CODEX-PA's STALE classification is correct against a "migrate everything" expectation, but incorrect against the actual P0 replan scope. This ADR resolves the mismatch by recording the **intended** target end-state for AQ-08-PUBLISH:

- Five (5) topics migrate to `PM0_PA_Card_*` (in-scope of the P0 replan).
- Seven (7) topics remain on `PMO_PA_*` legacy by design.
- AQ-08-PUBLISH unblocks after the five in-scope topics are remediated; the seven legacy topics do not block the release.

---

## 2. Decision

### 2.1 In-Scope: Five topics migrate to PM0_PA_Card_*

Owner will manually remediate the following five topics in the Copilot Studio UI before the AQ-08-PUBLISH gate opens. After remediation, each topic must reference the listed `PM0_PA_Card_*` action component (not the direct legacy workflow ID and not the legacy `PMO_PA_*` action component).

| Topic | Target action component | Target workflow ID | Replan rationale |
|---|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` | Replan §1: PM update cards multiline/single-box. |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` | Replan §3: task management card-first (update path). |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` | Replan §1 (priority 1): executive visibility. Semantic alignment: ResumoExecutivoPortfolio supersedes ConsultarPortfolio. |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` | Replan §3: task management card-first (create path). |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` | Replan §3: task management card-first (list path). |

The shared error-handling component `pmo_AssistentePMO_V2.action.PM0_PA_OpsFailureHandling` (`9531fbc7-a250-f111-bec7-000d3abc5cc6`) is reusable cross-topic and does not require its own topic.

### 2.2 Accepted Legacy Debt: Seven topics remain on PMO_PA_*

The following seven topics keep their current legacy `PMO_PA_*` routing for this release. They are accepted as documented technical debt, not as defects.

| Topic | Current legacy workflow | Legacy workflow ID | Out-of-scope rationale |
|---|---|---|---|
| `ConsultarProjeto` | `PMO_PA_ConsultarProjeto` | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | No `PM0_PA_Card_ConsultarProjeto` exists. Not part of P0 replan §1-3. |
| `CriarProjeto` | `PMO_PA_CriarProjeto` | `3104124d-364a-f111-bec7-7ced8d955c6c` | No `PM0_PA_Card_CriarProjeto` exists. Project creation kept chat-first by design. |
| `ExcluirProjeto` | `PMO_PA_ExcluirProjeto` | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | Soft-delete admin path, low frequency, not card-first relevant. |
| `ExcluirTarefa` | `PMO_PA_ExcluirTarefa` | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | Already validated runtime-PASS in 3.10/3.15; debt is ContentFilter risk only. |
| `PedirDecisao` | `PMO_PA_PedirDecisaoBot` | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | Decision-board flow has its own adaptive card (`RegistrarDecisaoBoard`), but topic still uses legacy invoke. |
| `RegistrarBloqueio` | `PMO_PA_RegistrarBloqueioBot` | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | Risk/blocker entry, kept chat-first. |
| `RegistrarRisco` | `PMO_PA_RegistrarRiscoBot` | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | Risk/blocker entry, kept chat-first. |

### 2.3 Non-routed topics (PASS, no action)

| Topic | Status |
|---|---|
| `Greeting` | PASS — warm-up topic, no flow call. |
| `LowConfidence` | PASS — fallback router, indirectly routes to other topics; smoke must verify after item 2.1 remediation. |
| `SeHouverErro` | PASS — error handler, no flow call. |
| `Gerar_Multiplos_Projetos` | PASS — preview-only topic, no flow call (per 2.7 release decision). |

### 2.4 Gate decision

`AQ-08-PUBLISH` is **CONDITIONALLY UNBLOCKED**. The conditions for unblock are:

1. Owner manually remediates the five topics in §2.1 in the Copilot Studio UI.
2. CODEX-PA re-runs the AQ-08-PRE read-only verification post-remediation.
3. The new diff matrix shows the five in-scope topics now reference `PM0_PA_Card_*` action components.
4. The seven legacy topics may continue to show `PMO_PA_*` references; this is expected.

When all four conditions are met, Owner may proceed with `pac solution import` of `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` and `pac copilot publish` for `Assistente PMO V2`.

### 2.5 XPIA-01 verification scope adjustment

The `XPIA-01-VERIFY` task (TASK 4 of the closeout dispatch) is split into two evidence sections:

- **Section A — In-scope P0 (5 commands):** corresponds to the five migrated topics. **Zero `ContentFiltered` / `openAIIndirectAttack` recurrences are required**. Any recurrence here = NO-SHIP.
- **Section B — Legacy out-of-scope (7 commands):** corresponds to the seven legacy topics. `ContentFiltered` recurrences here are recorded as evidence but do **not** block ship. They feed the legacy debt register.

---

## 3. Consequences

### 3.1 Accepted positive consequences

1. **Faster ship**: AQ-08-PUBLISH unblocks today after five manual UI changes instead of a multi-day rebuild of seven additional `PM0_PA_Card_*` flows.
2. **Honest scope**: the release matches what the 2026-05-14 P0 replan actually promised, no scope creep.
3. **Auditable trail**: this ADR plus the CODEX-PA evidence pack form a complete record of why mixed routing exists in production.
4. **Risk localized**: XPIA-01 risk is verified only on the five in-scope topics; legacy topics retain their pre-existing risk profile, which has not regressed.

### 3.2 Accepted negative consequences

1. **Mixed routing pattern in production**: until a future replan migrates the seven legacy topics, the bot will exhibit two operational patterns simultaneously (card-first for 5, chat-first for 7). End users may experience inconsistent UX between domains (task management is card-first; project management is chat-first).
2. **XPIA recurrence risk on legacy topics**: the seven `PMO_PA_*` topics still expose dynamic operational data to Copilot post-processing. They may continue to trigger `ContentFiltered` / `openAIIndirectAttack` after successful writes. This is documented as known debt, not a regression.
3. **Documentation burden**: support and ops material must document the dual pattern until full migration.
4. **Future migration cost**: the seven legacy topics will require a new replan, new flow design, new build, new publish, and new runtime smoke. Estimated effort: ~3-5 days of build + 1 day of publish/smoke per the velocity observed on the AQ-07 wave.

### 3.3 Out of debt criterion

The legacy debt is considered closed when **all seven** legacy topics have been replaced by `PM0_PA_Card_*` equivalents and the AQ-08-PRE verification reports zero STALE topics. Until that point, this ADR remains the canonical justification for mixed routing.

---

## 4. Evidence

### 4.1 Tenant state evidence (read-only PAC)

| Artifact | Path |
|---|---|
| PAC environment confirmation | `.planning/comms/aq08_topic_routing_verification_20260520/pac_env_who.txt` |
| Active topic + workflow inventory | `.planning/comms/aq08_topic_routing_verification_20260520/botcomponent_workflow_inventory.txt` |
| Workflow-level inventory | `.planning/comms/aq08_topic_routing_verification_20260520/workflow_inventory.txt` |
| Topic body inspection | `.planning/comms/aq08_topic_routing_verification_20260520/botcomponent_topics_inventory.txt` |
| FetchXML used | `.planning/comms/aq08_topic_routing_verification_20260520/fetch_*.xml` |

### 4.2 Architectural source documents

| Document | Role |
|---|---|
| `.planning/architecture/AS_IS_TO_BE_ADAPTIVE_CARDS_PLANNER_20260514.md` | Defines the AS-IS / TO-BE scope of the P0 replan |
| `.planning/architecture/P0_POWER_AUTOMATE_FLOW_DESIGN_ADAPTIVE_CARDS_PLANNER_20260514.md` | Specifies the five in-scope `PM0_PA_Card_*` flows |
| `.planning/architecture/CHANGE_REQUEST_CARD_FIRST_PLANNER_P0_20260514.md` | Formal change request authorizing the card-first model |
| `.planning/architecture/ADR_FINAL_OWNER_DECISIONS_ROUTING_PLANNER_ACCESS_20260514.md` | Prior ADR fixing route keys, Planner buckets, access protocol |
| `.planning/comms/AQ07_FINAL_BINDING_ACTIVE_VERIFICATION_20260515.md` | Confirms AQ-07 produced active `PM0_PA_*` action components |
| `.planning/comms/AQ08_PREP_VERIFICATION_CHECKLIST_20260515.md` | Prior AQ-08 preparation checklist |
| `.planning/comms/aq08_topic_routing_verification_20260520/AQ08_TOPIC_ROUTING_VERIFICATION.md` | CODEX-PA's TASK 1 verification report (raw STALE finding) |

### 4.3 Stop-ship and content-filter context

| Document | Role |
|---|---|
| `.planning/stop_ship/RCA_COPILOT_STUDIO_OPENAIINDIRECTATTACK_3_15_20260514.md` | RCA on `ContentFiltered` recurrence pattern |
| `.planning/stop_ship/STUDY_XPIA_MITIGATION_v3_16_20260514.md` | Mitigation study informing the static-output bypass approach |

---

## 5. Backlog Item Created

The seven legacy topics in §2.2 enter the project backlog as a single grouped initiative:

```text
Item ID: BACKLOG-PM0-LEGACY-MIGRATION-WAVE2
Severity: P2 (post-pilot)
Description: Migrate the seven remaining `PMO_PA_*` legacy topics to a `PM0_PA_Card_*` card-first pattern, mirroring the AQ-07 wave 1 approach.
Topics in scope: ConsultarProjeto, CriarProjeto, ExcluirProjeto, ExcluirTarefa, PedirDecisao, RegistrarBloqueio, RegistrarRisco.
Acceptance: AQ-08-PRE re-verification shows zero STALE topics.
Dependency: requires a new replan document, new flow design, new package build, new publish, and new runtime smoke.
Owner: Owner + Opus 4.7 (architecture) + CODEX-PA (build).
Estimated effort: ~3-5 days build + ~1 day publish/smoke.
Triggers reopen: any recurring XPIA-01 incident on a legacy topic in production after the 3.15 publish.
```

This backlog item should be referenced by the next planning cycle.

---

## 6. Approvals

| Role | Name | Signoff |
|---|---|---|
| Architect | Opus 4.7 | 2026-05-20 16:19 BRT (in-thread) |
| Owner | Manoel Benicio | 2026-05-20 16:19 BRT (in-thread, "sim pode fazer autorizado") |
| Integration / QA | CODEX-PA | Will sign on the post-remediation re-verification of TASK 1 |

This ADR is treated as accepted documentation control. No tenant write authorization flows from this ADR alone; tenant writes still require explicit owner approval per `AGENT_ACCESS_PROTOCOL_P0_20260514.md`.
