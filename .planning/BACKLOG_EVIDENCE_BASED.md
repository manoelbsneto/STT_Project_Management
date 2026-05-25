# PMO Backlog Evidence Based V1

Generated: 2026-05-23 19:11 BRT
Last updated: 2026-05-24 03:16:05 BRT | Codex #2 Lead via Kiro | P0 item updated to track 3.20 BUILD COMPLETE awaiting peer review + Owner Gate 4A.
Owner directive: strategic and realistic backlog planning based on data, not guesses.

## 1. Methodology

This register replaces `.planning/PENDING_ITEMS_REGISTER.md` as the active backlog source. I verified each V1 item against the current status files, stop-ship checklist, risk register, requirements, roadmap, AQ-08 ADR, Codex mission evidence, git history since 2026-04-15, and solution ZIP timestamps. Items stay in Active Backlog only when current-state evidence proves they are still open. Effort estimates use comparable completed work when available: package cycle times from `Solution/PMO_v11_Tarefas_*.zip`, close commit spacing from `git log --since="2026-04-15"`, and cited planning evidence. When no comparable completed item exists, the estimate is marked `UNVERIFIED_ESTIMATE`. This follows the Owner directive that answers must be grounded in documented data, not speculation (`OPEN_QUESTIONS_CONSOLIDATED_20260522.md:17`).

## 2. Executive Summary Table

| Severity | Active verified items | Active with unverified effort | Notes |
|---|---:|---:|---|
| P0 / SEV-0 | 1 | 1 | 3.18 static gates passed locally, but tenant import/publish/AQ-09 runtime proof is still open. |
| P1 | 5 | 4 | GAP-B8 and GAP-C1..C4 remain open in stop-ship evidence. Only GAP-B8 has a package-cycle basis. |
| P2 | 4 | 2 | Cleanup and batch work have historical cycle evidence; runtime QA and screenshot refresh depend on tenant/runtime access. |
| P3 | 0 | 0 | Vertex AI and legacy-topic migration are not active operational backlog. |
| Retired / future / retrospective | 12+ | n/a | LEGACY-* moved to future migration appendix; PROC-* moved to retrospective; AQ07 1.0.0.1 missing baseline retired as forensic gap. |

## 3. Active Backlog

| ID | Title | Severity | Source | Current evidence | Effort estimate (basis) | Suggested execution order |
|---|---|---|---|---|---|---|
| P0-AQ09-SECTION-A-RUNTIME | Ship 3.20 (StatusID fix) → Owner Gate 4A import → post-import activation verify → Gate 4B publish → AQ-09 Section A runtime evidence for the five PM0 card-first flows | P0 / SEV-0 | `RISK_REGISTER.md:8`; `MASTER_CHECKLIST.md:29`; `MASTER_CHECKLIST.md:30`; `OPEN_QUESTIONS_CONSOLIDATED_20260522.md:526`; RCA verdict `.planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/RCA_3_19_ATUALIZARSTATUS_VERDICT.md` | 3.20 BUILD COMPLETE 2026-05-24 03:16:05 BRT SHA `ADE54BF23F60F7A9EA5AB054680640F00F4971BC201C82E130640AC1F3B28DAC` (`.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_20/BUILD_REPORT.md`); supersedes failed 3.19 candidate `43A33783...D514BF`; Codex #1 Lead peer review and Owner Gate 4A approval still pending. Tenant remains on 3.19.0.0 with AtualizarStatus Borrador/Borrador. | Peer review ~30-45min (basis: 3.19 peer review took ~12min from 21:34:51 to 21:46:03 BRT); import + verify ~25min; publish ~5min; AQ-09 retest UNVERIFIED (~2h per `START_HERE_CURRENT_STATUS.md:81`). | 1 |
| P1-GAP-B8-EXCLUIRTAREFA-RUNTIME | Prove `ExcluirTarefa` inline motivo fix in tenant runtime | P1 | `MASTER_CHECKLIST.md:94` | `MASTER_CHECKLIST.md:94` says local 2.2 package fix ready, import plus runtime proof still required | About 30-60m local/package basis: `Solution/PMO_v11_Tarefas_2_1_LISTARTAREFAS_INLINE_PARSER_FIX.zip` 2026-05-11 20:06:53 to `Solution/PMO_v11_Tarefas_2_2_EXCLUIRTAREFA_MOTIVO_INLINE_FIX.zip` 2026-05-11 20:33:57 was 27m; tenant proof remains unverified. | 2, after 3.18 publish path is stable |
| P1-GAP-C2-RECURRENCE-EVIDENCE | Capture recurrence flow run history, interval, and 24h success evidence | P1 | `PENDING_ITEMS_REGISTER.md:70`; `MASTER_CHECKLIST.md:96` | `RISK_REGISTER.md:15` says recurrence evidence is still not proven in current gate; `MASTER_CHECKLIST.md:96` remains Open | `UNVERIFIED_ESTIMATE`: V1 claimed ~2h, but current evidence requires a 24h window and I found no comparable completed 24h recurrence evidence task in git/package history. | 3, can run after publish and in parallel with C3/C4 |
| P1-GAP-C3-PLANNER-SYNC-PILOT | Capture SyncPlannerStats pilot E2E evidence | P1 | `PENDING_ITEMS_REGISTER.md:71`; `PENDING_TESTS_FEATURES_PRIORITY_20260513.md:33`; `PENDING_TESTS_FEATURES_PRIORITY_20260513.md:59` | `MASTER_CHECKLIST.md:97` remains Open; `RISK_REGISTER.md:15` says planner sync is not proven in current gate | `UNVERIFIED_ESTIMATE`: `PENDING_TESTS_FEATURES_PRIORITY_20260513.md:33` lists a 45m pilot, but I found no completed comparable pilot duration in git/package evidence. | 4, after runtime smoke confirms bot stability |
| P1-GAP-C4-ALERTA-VERMELHO-E2E | Capture AlertaProjetoVermelho E2E Teams/SP evidence | P1 | `PENDING_ITEMS_REGISTER.md:72`; `PENDING_TESTS_FEATURES_PRIORITY_20260513.md:29` | `MASTER_CHECKLIST.md:98` remains Open; `RISK_REGISTER.md:15` says red project alert is not proven in current gate | `UNVERIFIED_ESTIMATE`: `PENDING_TESTS_FEATURES_PRIORITY_20260513.md:29` lists a 30m E2E check, but no completed comparable duration was found. | 4, after runtime smoke confirms bot stability |
| P1-GAP-C1-GHOST-COMPONENTS | Run ghost bot component discovery and perform admin-approved cleanup | P1 | `PENDING_ITEMS_REGISTER.md:73`; `MASTER_CHECKLIST.md:95` | `RISK_REGISTER.md:14` says ghost components may pollute routing and cleanup is pending admin; `MASTER_CHECKLIST.md:95` says deletion requires approval | `UNVERIFIED_ESTIMATE`: V1 claimed ~1h, but git history has no isolated completed admin cleanup cycle; task is approval-bound. | 5, after 3.18 import/publish evidence is captured |
| P2-CARD-RUNTIME-QA | Full Copilot/Teams runtime conversation QA beyond AQ-09 Section A | P2 | `PENDING_ITEMS_REGISTER.md:86`; `STATE.md:59`; `ROADMAP.md:73` | `ROADMAP.md:73` says Teams conversation and write validation were deferred to Phase 6 QA; `STATE.md:59` still lists runtime conversation QA under Phase 6 | `UNVERIFIED_ESTIMATE`: V1 and `START_HERE_CURRENT_STATUS.md:81` imply ~2h for runtime retest, but no complete Teams conversation QA run is present as comparable evidence. | 6, after P0 AQ-09 pass |
| P2-CLEANUP-TEST-DATA | Logical-delete remaining SharePoint test/trash data rows | P2 | `PENDING_ITEMS_REGISTER.md:82`; `STATE.md:92` | `STATE.md:92` says W1 cleanup test data remains; V1 still tracks logical delete of 2026-05-10/13 rows | About 15-30m based on completed cleanup commit sequence: `30e7faa` at 2026-05-10 10:47 added logical delete fields, `f3a874d` at 10:51 discovered candidates, `26ebacd` at 10:55 marked test data logically deleted. New execution still needs tenant authorization. | 7, after runtime tests no longer need the data |
| P2-BATCH-WRITE-REQ16 | Implement `Gerar_Multiplos_Projetos` full write path, replacing preview-only behavior | P2 | `PENDING_ITEMS_REGISTER.md:83`; `REQUIREMENTS.md:23`; `ROADMAP.md:107`; `ROADMAP.md:111`; `ROADMAP.md:118` | `START_HERE_CURRENT_STATUS.md:311` still says batch write is preview-only. 3.18 static gates confirm topic routing/subtest (`20260523_20260523_215927_Codex2Lead_3_18_static_gates_final.txt:1591`, `:1596`, `:1636`) but do not prove full SharePoint write runtime. | About 2h local package basis: `Solution/PMO_v11_Tarefas_2_3_EXCLUIRTAREFA_PROJECT_SCOPE_FIX.zip` 2026-05-11 21:29:28 to `Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip` 2026-05-11 23:22:55 was 1h53m; runtime validation remains unverified. | 8, after current PM0 ship path |
| P2-DOC-RUNTIME-SCREENSHOTS | Refresh operations manual with live runtime screenshots and PMO user review findings | P2 / SEVERITY_UNVERIFIED | `PENDING_ITEMS_REGISTER.md:68`; `RISK_REGISTER.md:16` | `MASTER_CHECKLIST.md:76` says the manual exists and passes its test; `RISK_REGISTER.md:16` says review and runtime detail incorporation remain after browser/runtime tests | `UNVERIFIED_ESTIMATE`: docs/manual work is mixed into broad commits such as `5ee1950` to `8a724c9` (~22h across many artifacts), not an isolated comparable screenshot-refresh duration. | 9, after runtime QA produces real screenshots |

## 4. Resolved Items

| ID | Disposition | Closure evidence |
|---|---|---|
| P1-DOC-MANUAL | Resolved for local manual delivery; only runtime screenshot refresh remains active as P2-DOC-RUNTIME-SCREENSHOTS. | `MASTER_CHECKLIST.md:76` says `docs/MANUAL_OPERACIONAL_PMO.md` exists and passes `Test-OperationsManualArtifact.ps1`; `MASTER_CHECKLIST.md:99` marks GAP-C5 DONE. |
| P1-PLAN-CONSOLIDATION | Resolved by this V1 evidence-based register plus pointer updates in `STATE.md` and `START_HERE_CURRENT_STATUS.md`. | Source item `PENDING_ITEMS_REGISTER.md:69`; replacement file is `.planning/BACKLOG_EVIDENCE_BASED.md`. |
| P1-LIVE-NON-ASCII | Resolved for the 3.18 package; no longer a standalone active backlog item. Runtime import/publish remains covered by P0-AQ09-SECTION-A-RUNTIME. | Old V1 source `PENDING_ITEMS_REGISTER.md:74`; old risk `RISK_REGISTER.md:17`; new evidence `T0_3_18_REBUILD_REVIEW_REQUEST_20260523_220325.md:32` includes `Test-PMOFlowStopShipAudit.ps1`; static gate evidence shows that audit ran (`20260523_20260523_215927_Codex2Lead_3_18_static_gates_final.txt:745`) and final summary passed 9/9 (`:1755`). |
| P2-AT-DISPLAY-PATCH | Resolved for the 3.18 package; no active backlog unless runtime QA proves a regression. | Source `PENDING_ITEMS_REGISTER.md:84`; static evidence includes `AtualizarTarefa skip semantics subtest` at `20260523_20260523_215927_Codex2Lead_3_18_static_gates_final.txt:1661` and skip-token preservation evidence at `:1329`. |
| ACT-003 / CMD-13A skip semantics | Resolved into the same 3.18 static evidence as P2-AT-DISPLAY-PATCH. | Source `PENDING_TESTS_FEATURES_PRIORITY_20260513.md:15` and `:17`; closure evidence same as above. |

## 5. Retired Items

| ID | Disposition | Rationale / evidence |
|---|---|---|
| LEGACY-01 through LEGACY-07 | Retired from active backlog; moved to Appendix A as a future migration project. | ADR accepts the seven legacy topics as non-blocking scope (`ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md:46`, `:66`, `:96`, `:105`, `:166`-`:176`). `RISK_REGISTER.md:20` says do not treat legacy-topic XPIA as AQ-08/AQ-09 ship blocker unless Owner changes scope. |
| P2-AQ07-1001-MISSING | Retired as forensic gap, not operational backlog. | V1 source `PENDING_ITEMS_REGISTER.md:85`; Codex #2 forensic report says AQ07 1.0.0.1 local baseline was not found and the gap was logged as non-blocking (`T0_LIVE_TENANT_3_17_FORENSIC_DIFF.md:63`). |
| P3-VERTEX-AI | Inactive/deferred, not active backlog. | V1 source `PENDING_ITEMS_REGISTER.md:94`; git commit `0122137` added Vertex AI test scripts on 2026-05-17, but I found no current owner/risk/roadmap evidence making it an active business priority. |
| PROC-01 through PROC-05 | Retired from backlog tracking; moved to Appendix B as mission retrospective notes. | V1 starts PROC tracking at `PENDING_ITEMS_REGISTER.md:102`; these are coordination/process findings, not product or operational backlog. |

## 6. Recommended Execution Sequence

1. Execute P0-AQ09-SECTION-A-RUNTIME first. The current package has local static proof, but Functional DoD is not satisfied until import, publish, and runtime evidence exist (`MASTER_CHECKLIST.md:3`, `:9`, `:29`, `:30`).
2. Prove GAP-B8 while the publish/runtime path is fresh. It already has a local package-cycle basis and only lacks tenant runtime proof (`MASTER_CHECKLIST.md:94`).
3. Capture GAP-C2 recurrence evidence next because it may require elapsed wall-clock time; start it as soon as the published artifact is stable (`MASTER_CHECKLIST.md:96`).
4. Run GAP-C3 and GAP-C4 in parallel after AQ-09 pass. Both are runtime/e2e proof tasks and share the same evidence owner/risk bucket (`RISK_REGISTER.md:15`).
5. Run GAP-C1 ghost component cleanup only after the runtime-safe package is confirmed, because admin deletion affects tenant routing and requires approval (`RISK_REGISTER.md:14`).
6. Finish broader card runtime QA, then cleanup test data. Cleanup should wait until no active runtime tests need the rows (`STATE.md:92`).
7. Defer batch write and runtime screenshot/manual refresh until after the current ship path. Both are real work, but neither has evidence outranking the current P0/P1 blockers.

## 7. Appendix A: Future Migration Projects

This is a future project, not current active backlog. The seven legacy topics are accepted by AQ-08 ADR scope and should be grouped as `BACKLOG-PM0-LEGACY-MIGRATION-WAVE2`, not treated as 3.18 ship blockers.

| Legacy item | Topic | Current classification | Evidence |
|---|---|---|---|
| LEGACY-01 | `ConsultarProjeto` | Future migration | `PENDING_ITEMS_REGISTER.md:52`; ADR scope acceptance `ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md:46`, `:166`-`:176` |
| LEGACY-02 | `CriarProjeto` | Future migration | Same ADR scope evidence |
| LEGACY-03 | `ExcluirProjeto` | Future migration | Same ADR scope evidence |
| LEGACY-04 | `ExcluirTarefa` | Future migration | Same ADR scope evidence; GAP-B8 runtime proof remains tracked separately because it has current stop-ship evidence. |
| LEGACY-05 | `PedirDecisao` | Future migration | Same ADR scope evidence |
| LEGACY-06 | `RegistrarBloqueio` | Future migration | Same ADR scope evidence |
| LEGACY-07 | `RegistrarRisco` | Future migration | Same ADR scope evidence |

ADR estimate retained for future planning only: about 3-5 days build plus about 1 day publish/smoke (`ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md:123`, `:176`). This estimate is not applied to the current active backlog.

## 8. Appendix B: Mission Retrospective Notes

These are lessons learned/process notes from the PM0 remediation mission, not backlog items for product delivery.

| Retrospective item | Source | Treatment |
|---|---|---|
| PROC-01 sub-agent spawn/token refresh failure | `PENDING_ITEMS_REGISTER.md:102` | Keep as orchestration retrospective; not active backlog. |
| PROC-02 / PROC-03 evidence/check-in friction | `PENDING_ITEMS_REGISTER.md:117` closure bucket | Fold into future mission playbook review; not active backlog. |
| PROC-04 / PROC-05 process or fallback concerns | `PENDING_ITEMS_REGISTER.md:147` closure bucket | Retain in retrospective notes only unless Owner creates a product/business requirement. |

## 9. Evidence Index

| Evidence | Used for |
|---|---|
| `.planning/PENDING_ITEMS_REGISTER.md` | V1 source item identification and retirement/resolution mapping. |
| `.planning/STATE.md` | Current-state pointers for runtime QA and cleanup status; updated to point to this register. |
| `.planning/START_HERE_CURRENT_STATUS.md` | AQ-09 retest context, current release context, and pointer update. |
| `.planning/stop_ship/MASTER_CHECKLIST.md` | Current blocker/open/done status for import, runtime smoke, GAP-B8, GAP-C1..C5, and manual delivery. |
| `.planning/stop_ship/RISK_REGISTER.md` | Severity evidence for RISK-013, RISK-006, RISK-007, RISK-008, RISK-009, RISK-012. |
| `.planning/comms/PENDING_TESTS_FEATURES_PRIORITY_20260513.md` | Historical pending runtime tests/features for CMD-13A, CARD-04/05, planner pilot, REQ-16. |
| `.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md` | Owner data-based methodology directive and runtime-smoke gate interpretation. |
| `.planning/REQUIREMENTS.md` | REQ-16 batch write requirement status. |
| `.planning/ROADMAP.md` | Deferred Phase 6 runtime validation and Phase 2.4 batch-write dependency context. |
| `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` | Legacy-topic scope retirement and future migration estimate. |
| `.planning/comms/codex_pm0_remediation_20260522/CODEX1/PEER_REVIEW/T0_3_18_REBUILD_REVIEW_REQUEST_20260523_220325.md` | 3.18 local-only package, owner ratification, and static gate list. |
| `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/evidence/20260523_20260523_215927_Codex2Lead_3_18_static_gates_final.txt` | 3.18 package static gate pass, placeholder scan, stop-ship audit, batch topic subtest, and AtualizarTarefa skip semantics evidence. |
| `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/T0_LIVE_TENANT_3_17_FORENSIC_DIFF.md` | AQ07 1.0.0.1 missing-baseline non-blocking forensic gap evidence. |
| `git log --oneline --since="2026-04-15"` | Actual commit chronology for cleanup, cold-start, Vertex AI, and large documentation/package waves. |
| Commits `30e7faa`, `f3a874d`, `26ebacd` | Completed cleanup/data logical-delete comparable duration. |
| Commit `0122137` | Vertex AI tests added but no active priority evidence found. |
| Commits `5ee1950`, `8a724c9` | Broad documentation/test/manual wave; used only to show no isolated screenshot-refresh estimate exists. |
| `Solution/PMO_v11_Tarefas_*.zip` timestamps | Actual package cycle durations; specifically 2.1 to 2.2 (27m), 2.3 to 2.4 (1h53m), and 3.15.1 to 3.16 package rebuild context. |

