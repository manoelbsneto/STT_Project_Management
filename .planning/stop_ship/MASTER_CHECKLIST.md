# MASTER CHECKLIST

Status: 🔴 **NO-SHIP** — PM0 local source and scoped 3.16 package static gates pass, but no tenant import/publish/runtime smoke has been approved or run. AQ-08 routing PASS remains structural only. See `.planning/comms/codex_pm0_remediation_20260522/`.
Active plan: `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`
Last updated: 2026-05-22 17:13:10 BRT | Codex | PM0 local package static gates passed; runtime remains blocked.

## 🚨 CRITICAL DISCOVERY 2026-05-22 14:42 BRT

Original A1 failure found five non-dynamic PM0 caller responses. Local workflow/action/topic fixes now clear response semantics, topic/action/workflow contract propagation, placeholder/ASCII scans, and scoped package P0/P24/stop-ship/schema gates. This does not satisfy Functional DoD until the patched artifact is imported/published with explicit approval and runtime bot evidence is captured.

Codex #1 merged Alpha and Bravo evidence into the RCA, remediation plan, mitigation plan, and executive summary under `.planning/comms/codex_pm0_audit_20260522/`.

| Flow | Caller response | Audit classification |
|---|---|---|
| PM0_PA_Card_AtualizarStatus | "Status update card posted successfully." | `STUB` |
| PM0_PA_Card_AtualizarTarefa | "Task updated successfully." | `PARTIAL` |
| PM0_PA_Card_CriarTarefa | "Task created successfully." | `PARTIAL` |
| PM0_PA_Card_ListarTarefas | "Tasks retrieved successfully." | `PARTIAL` |
| PM0_PA_Card_ResumoExecutivoPortfolio | "Executive portfolio retrieved successfully." | `PARTIAL` |

## PM0 Local Remediation Snapshot 2026-05-22 17:13 BRT

| Gate | Status | Evidence |
|---|---|---|
| Local workflow response semantics | PASS | `.planning/comms/codex_pm0_remediation_20260522/ALPHA/evidence/20260522_162457_CodexLead_workflow_response_semantics_rerun.md` |
| Local topic/action/workflow propagation | PASS | `.planning/comms/codex_pm0_remediation_20260522/ALPHA/evidence/20260522_162538_CodexLead_topic_action_flow_contract_final.md` |
| Placeholder and ASCII scan | PASS_NO_MATCHES | `.planning/comms/codex_pm0_remediation_20260522/ALPHA/evidence/20260522_162457_CodexLead_placeholder_ascii_scan_rerun.md` |
| Scoped 3.16 package P0/P24/stop-ship/schema gates | PASS | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/PACKAGE_STATUS.md`; ZIP SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` (corrected 2026-05-22 18:06 BRT by Codex #2 Bravo; supersedes `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`) |
| Tenant import/publish | NOT_RUN | Requires explicit owner approval in active thread |
| AQ-09 runtime smoke | NOT_RUN | Requires imported/published artifact and Evidence Triplet |

## 2026-05-20 AQ-08 Hybrid Migration Gates

| Gate | Status | Evidence / next evidence |
|---|---|---|
| ADR accepted for hybrid card-first scope | DONE | `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` |
| `AtualizarStatus` routes to `PM0_PA_Card_AtualizarStatus` | **PASS** | T+1h reverify report `aq08_post_remediation_reverify_report.json` 2026-05-22 09:23 BRT |
| `AtualizarTarefa` routes to `PM0_PA_Card_AtualizarTarefa` | **PASS** | T+1h reverify report 2026-05-22 09:23 BRT |
| `ConsultarPortfolio` routes to `PM0_PA_Card_ResumoExecutivoPortfolio` | **PASS** | T+1h reverify report 2026-05-22 09:23 BRT |
| `CriarTarefa` routes to `PM0_PA_Card_CriarTarefa` | **PASS** | T+1h reverify report 2026-05-22 09:23 BRT |
| `ListarTarefas` routes to `PM0_PA_Card_ListarTarefas` | **PASS** | T+1h reverify report 2026-05-22 09:23 BRT |
| AQ-08 post-remediation verifier | **PASS** | `aq08_post_remediation_reverify_report.json` overall=PASS, blockingTopicCount=0 (T+5min and T+1h) |
| Pre-publish rollback evidence | DONE | `.planning/comms/rollback_evidence_pre_3_15_20260520/` |
| Drift monitor T+5min | **PASS** | `drift_monitoring_20260522_0816/T+5min/summary.md` |
| Drift monitor T+1h | **PASS** | `drift_monitoring_20260522_0816/T+1h/summary.md` |
| Drift monitor T+6h | SCHEDULED 14:23 BRT | `drift_monitoring_20260522_0816/T+6h/` |
| AQ-09 smoke and XPIA harness | **READY TO EXECUTE** | `.planning/comms/aq09_smoke_runbook_20260520/`; `.planning/comms/xpia_01_verify_20260520/` |

## 2026-05-20 Accepted Legacy Debt

These topics intentionally remain on legacy `PMO_PA_*` actions for the 3.15 release. They are backlog items, not AQ-08 publish blockers.

| Topic | Severity | Release Decision |
|---|---|---|
| `ConsultarProjeto` | P3 | Accepted legacy debt; migrate in future full card-first replan. |
| `CriarProjeto` | P3 | Accepted legacy debt; migrate in future full card-first replan. |
| `ExcluirProjeto` | P3 | Accepted legacy debt; migrate in future full card-first replan. |
| `ExcluirTarefa` | P2 | Accepted legacy debt; migrate in future full card-first replan due task-write impact. |
| `PedirDecisao` | P2 | Accepted legacy debt; migrate in future full card-first replan due decision-write impact. |
| `RegistrarBloqueio` | P2 | Accepted legacy debt; migrate in future full card-first replan due risk/blocker-write impact. |
| `RegistrarRisco` | P2 | Accepted legacy debt; migrate in future full card-first replan due risk/blocker-write impact. |

## Release Gates

| Gate | Status | Evidence / next evidence |
|---|---|---|
| All 8 PRD topics functional | PARTIAL | Active target is `Assistente PMO V2`. Topic Checker reported green by user. Runtime proof passed for CriarTarefa, ConsultarProjeto, ConsultarPortfolio; B3/B4/B5 pending; B6 needs 1.8 retest. |
| STT / long-text support | PARTIAL | CriarTarefa parses long input correctly. AtualizarStatus long-text wrote data but exposed RAG parser defect; 1.8 package fixes parser and needs import/retest. |
| Confirm-before-action | DONE for tested P0 topics | CriarTarefa, AtualizarStatus, RegistrarRisco, RegistrarBloqueio, and PedirDecisao confirmation observed. |
| V3 flow writes to `Projetos` | DONE | V2 runtime created `Teste Smoke Final V5` in SharePoint `Projetos` with `Prioridade=Alta`, `Ativo=True`, `Deleted=False`. |
| CriarTarefa binds to V3 | DONE | V2 runtime invoked SharePoint-backed create flow and created project item. |
| Cold Start NLU mitigation | DONE | Greeting warm-up + Fallback SmartRedirect deployed. 7/7 tests PASS (Session 19). V2 fallback routes expanded and imported. |
| All 10 PRD flows have runtime evidence | PARTIAL | CriarTarefa V3 has runtime evidence. Session 20 target flows imported/activated; B1-B6 runtime evidence pending. Recurrence/e2e evidence gaps remain for GAP-C2 through GAP-C4. |
| Ghost components cleaned | PENDING ADMIN | `deploy/Discover-GhostBotComponents.ps1` created and tested; deletion requires Human/Admin approval. |
| Automated tests green | PARTIAL | New local tests pass; live export audit still fails on GPT data ASCII/mojibake. |
| Operations Manual delivered | DONE | `docs/MANUAL_OPERACIONAL_PMO.md` exists and passes `Test-OperationsManualArtifact.ps1`. |
| Zero SEV-0 open | **DONE** | All SEV-0 items (A1, A2, Cold Start) resolved with live runtime evidence. |
| Zero P0 open | PARTIAL | B1-B6 implemented/imported/static green in Session 20 V2. Runtime Copilot + Power Automate + SharePoint validation remains the P0 blocker. |

## GAP Checklist

| GAP ID | Severity | Owner | Status | Evidence |
|---|---|---|---|---|
| GAP-A1 | SEV-0 | — | **DONE** | Flow rebuilt Session 18. Success run + duplicate detection PASS. |
| GAP-A2 | SEV-0 | — | **DONE** | Binding fixed Sessions 17-18. Topic published and tested. |
| COLD-START | SEV-0 | — | **DONE** | Greeting + Fallback deployed Session 19. 7/7 tests PASS. Commit `e2232ce`. |
| GAP-B1 | P0 | User/Opus | **PARTIAL** | `PMO_PA_ConsultarPortfolio` imported/activated in V2; static contract green. Need runtime proof that response is real SharePoint aggregation. |
| GAP-B2 | P0 | User/Opus | **DONE** | Runtime returned details for `QA Robust 20260513 F` after follow-up project answer; SP confirmed ItemId `33`, `ProjectID=PRJ-274E5ACC`, PM `mbenicios@minsait.com`, `Percentual=0`, `Deleted=false`, and 2 open risks. Inline project-name capture remains a hardening gap. |
| GAP-B3 | P0 | User/Opus | **DONE** | Runtime created `RISK-16E1AE89`; SP `Riscos e Bloqueios` ItemId `6`, `ProjectID=PRJ-274E5ACC`, `Tipo=Risco`, `Severidade=Alta`, `StatusRisco=Aberto`, `Deleted=false`. |
| GAP-B4 | P0 | User/Opus | **DONE** | Runtime created `BLOCK-ED57742E`; SP `Riscos e Bloqueios` ItemId `7`, `ProjectID=PRJ-274E5ACC`, `Tipo=Bloqueio`, `Severidade=Alta`, `Impacto=Alto`, `StatusRisco=Aberto`, `Deleted=false`. |
| GAP-B5 | P0 | User/Opus | **DONE** | Runtime created `DEC-313AA4D0`; SP `Decisoes do Board` ItemId `4`, `ProjectID=PRJ-274E5ACC`, `ApproverUPN=mbenicios@minsait.com`, `Impacto=Alto`, `StatusDecisao=Pendente`, `Deleted=false`. |
| GAP-B6 | P0 | User/Opus | **PARTIAL** | Runtime created `STU-20260513170804`; SP `Status Diario` preserved multiline text in `Resumo` and updated project `StatusRAG=Amarelo`, but `Risco`, `Bloqueio`, `ProximaAcao` stayed null and `Percentual=0`. |
| GAP-B7 | P0 | — | **DONE** | `sim` confirmation tested and working in Session 19. |
| GAP-B8 | P1 | User/Codex | LOCAL FIX READY / IMPORT + RUNTIME TEST PENDING | Local 2.2 package `Solution/PMO_v11_Tarefas_2_2_EXCLUIRTAREFA_MOTIVO_INLINE_FIX.zip` adds `ExcluirTarefa` parser support for `motivo <texto>` and trailing inline reason after task ID. Regression first failed on 2.1, then passed on 2.2. Owner import/publish and runtime proof still required. |
| GAP-C1 | P1 | Human/Admin | Pending admin | Discovery script ready. Deletion requires approval. |
| GAP-C2 | P1 | Opus | Open | Recurrence flow evidence needed. |
| GAP-C3 | P1 | Opus | Open | SyncPlannerStats pilot evidence needed. |
| GAP-C4 | P1 | Opus | Open | AlertaProjetoVermelho E2E needed. |
| GAP-C5 | P1 | — | **DONE** | `docs/MANUAL_OPERACIONAL_PMO.md` delivered. |
| GAP-D1 | P2 | Codex | Post-ship | Not release-blocking. |
| GAP-D2 | P2 | Codex | Post-ship | Not release-blocking. |

## Session 20 V2 Import Evidence

| Item | Status | Evidence |
|---|---|---|
| V2 package imported | DONE | `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (2).xml` parsed. Solution status `Procesado`, version `1.1.0.2`, 52 processed rows, no failed component rows. |
| Target flows activated | DONE | Import log rows confirm activation for `PMO_PA_ConsultarPortfolio`, `PMO_PA_ConsultarProjeto`, `PMO_PA_RegistrarRiscoBot`, `PMO_PA_RegistrarBloqueioBot`, `PMO_PA_PedirDecisaoBot`, `PMO_PA_AtualizarStatus`. |
| Replacement warnings | ACCEPTED | `0x80045042` rows are processed workflow replacement notices: original workflow definition deactivated and replaced. No failed target flow row found. |
| Static package validation | DONE | `.planning/stop_ship/SESSION20_IMPORT_ANALYSIS_AND_V2_PATCH.md` records V2 package hash and PASS contract checks. |
| Runtime validation | BLOCKING | Topic Checker has no issues by user report. V2 smoke partially green. Import/retest `Solution/PMO_v11_Tarefas_1_8_ATUALIZAR_STATUS_RAG_FIX.zip`, then finish B3/B4/B5/B6 SharePoint evidence. |

## Current Test Commands

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaContract.ps1 -TemplatePath deploy\copilot\AssistentePMO.template.yaml
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaFlowDefinition.ps1 -Path deploy\PA_CriarTarefa_Flow.ps1 -AllowRuntimeRawAuthentication
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotStopShipGaps.ps1 -TemplatePath deploy\copilot\AssistentePMO.template.yaml
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ConsultarPortfolioFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ConsultarProjetoFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-RegistrarRiscoFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-RegistrarBloqueioFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PedirDecisaoFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotGhostBotInventory.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-OperationsManualArtifact.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-Pm0TopicActionFlowContract.ps1 -SourceRoot "Local_Repo\Assistente PMO V2"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-Pm0WorkflowResponseSemantics.ps1 -SourceRoot "Local_Repo\Assistente PMO V2"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-Pm0RuntimeEvidence.ps1 -EvidencePath ".planning\comms\aq09_smoke_runbook_20260520\evidence"
```

## 2026-05-13 Active Checklist - Candidate 3.3

Status: SHIP for targeted 3.3 `CriarProjeto` content-safe/routing fix. Broader PMO release gates remain governed by the main checklist.

Issue tracking:
- [x] ISSUE-001 reproduced: `CriarProjeto` guided flow hit `ContentFiltered / openAIIndirectAttack` after success.
- [x] ISSUE-001 fixed locally: `CriarProjeto` maps `Topic.Result` to static safe activities.
- [x] ISSUE-001 regression test added: `tests/Test-CriarProjetoContentSafeOutput.ps1`.
- [x] ISSUE-002 reproduced: one-shot project creation routed to `CriarTarefa`.
- [x] ISSUE-002 fixed locally: GPT default and LowConfidence route project phrases to `CriarProjeto`.
- [x] ISSUE-002 regression test added: `tests/Test-CopilotRoutingInstructions.ps1`.
- [x] Candidate package built: `Solution/PMO_v11_Tarefas_3_3_CRIARPROJETO_CONTENT_ROUTE_SAFE_FIX.zip`.
- [x] Local gates green: stop-ship audit, P24, P0, content-safe, routing, project create, task create, soft delete.
- [x] Owner imports 3.3.
- [x] Owner publishes bot.
- [x] Runtime guided project test passes.
- [x] Runtime one-shot project routing test passes.
- [x] Read-only SharePoint verification confirms created projects.

Blocking decision:
- All targeted 3.3 runtime gates passed; unresolved broader PMO gaps are tracked outside this targeted fix.
