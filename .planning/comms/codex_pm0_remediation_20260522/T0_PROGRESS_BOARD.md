# T0 Fan-out Progress Board — PM0 3.16 Ship

> **Canonical public progress view.** All 15 actors post status updates here every 5 min while active and on every state transition. This is the only file the Owner needs to read to see where the mission is.

| Field | Value |
|---|---|
| Mission | Ship 3.16 PM0 Functional Fix |
| Trigger | Owner "go" 2026-05-23 16:15 BRT |
| Coordinator | Kiro |
| Dispatch file | `.planning/comms/codex_pm0_remediation_20260522/T0_FANOUT_DISPATCH_20260523_1615.md` |
| Decision audit | `.planning/comms/codex_pm0_remediation_20260522/DECISION_RESPONSES/AGENT_DECISION_RESPONSES_PM0_CONTAINMENT_20260523.md` |
| Active package | `PMO_v11_Tarefas_3_20_PM0_STATUSID_FIX.zip` SHA `ADE54BF23F60F7A9EA5AB054680640F00F4971BC201C82E130640AC1F3B28DAC` (BUILD COMPLETE 2026-05-24 03:16:05 BRT — peer review pending; supersedes failed 3.19 candidate `43A33783ABC30E7A3DC74EAED162558FBA0781AC163804F85FDC559023D514BF`) |
| Environment | `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) |
| Bot | `Assistente PMO V2` |
| Last refreshed | 2026-05-24 11:55:06 BRT | Codex #2 Lead | PM0-3_20-POST-PUBLISH-ALL-RECHECK COMPLETE - verdict HOLD; AtualizarStatus still Borrador/Borrador and AQ-08 BLOCK | screenshot: .planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\post_publish_all\screenshots\20260524T145506Z_Codex2Lead_post_publish_all_recheck_halt.png |

---

## Status legend

| Symbol | Meaning |
|---|---|
| ⏸️ | NOT STARTED — actor has not been launched yet |
| 🟡 | IN PROGRESS — actively working |
| 🟢 | COMPLETE — task finished, evidence published |
| 🔴 | BLOCKED — waiting on external dependency or halted on stop-condition |
| ⚠️ | NEEDS ATTENTION — degraded but proceeding |

---

## Mission phase progress

| Phase | Status | Started BRT | Ended BRT | Notes |
|---|---|---|---|---|
| **T0** — Pre-stage fan-out (5 tracks parallel) | 🟢 COMPLETE | 2026-05-23 16:15 | 2026-05-23 17:47 | All 8 criteria PASS. Promoted by Kiro 17:47 BRT. |
| **T1** — Preflight rerun + Α static cross-check | 🟢 COMPLETE | 2026-05-23 16:32 | 2026-05-23 17:14 | Work executed in parallel during T0; preflight GREEN with BLK-LIVE-317 finding; Α static gates 9/9 exit 0. Promoted by Kiro 17:47 BRT. |
| **T2** — Gate 4A tenant import | 🔴 BLOCKED | 2026-05-23 19:34 | — | 3.19 imported and version/SHA identity confirmed, but post-import verification failed: PM0_PA_Card_AtualizarStatus activation 0x80040216, flow remains Borrador, AQ-08 BLOCK. No Gate 4B. RCA H1 CONFIRMED 2026-05-24 02:55:01 BRT — root cause = missing `item/StatusID` in Create_StatusDiario. 3.20 BUILD COMPLETE 2026-05-24 03:16:05 BRT (Codex #2 Lead) SHA `ADE54BF23F60F7A9EA5AB054680640F00F4971BC201C82E130640AC1F3B28DAC` with +1 line minimal patch per REMEDIATION.md; new import attempt awaits Codex #1 Lead peer review + Owner Gate 4A go-ahead. |
| **T3** — Gate 4B publish bot | ⏸️ WAITING | — | — | Gated on T2 SHA read-back match + Owner Gate 4B confirmation |
| **T4** — AQ-09 Section A smoke (A1–A5) | ⏸️ WAITING | — | — | Gated on T3 Published/Active/Provisioned |
| **T5** — Drift T+5min then T+1h wait | ⏸️ WAITING | — | — | Gated on T4 all 5 PASS |
| **T6** — Gate 4C AQ07 cleanup | ⏸️ WAITING | — | — | Gated on T5 PASS + explicit Owner approval |
| **T7** — SHIP | ⏸️ WAITING | — | — | Final Opus 4.6 sign-off + comms dispatch |

---

## All 15 actors — current status

### Track Α — Gate ASK + Peer Review (4 actors)

| Actor | Status | Current task | Last check-in BRT | Evidence path | Screenshot path | Blocker |
|---|---|---|---|---|---|---|
| **Codex #1 Lead** | COMPLETE | 3.20 StatusID fix peer review PASS_WITH_NOTES; verdict published | 2026-05-24 08:07:43 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/PEER_REVIEW/T0_3_20_STATUSID_FIX_PEER_REVIEW_VERDICT.md` + `.planning/comms/codex_pm0_remediation_20260522/CODEX1/PEER_REVIEW/evidence/20260524_110743_Codex1Lead_3_20_statusid_fix_peer_review_pass_with_notes.{txt,json,png}` | `D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX1\PEER_REVIEW\evidence\20260524_110743_Codex1Lead_3_20_statusid_fix_peer_review_pass_with_notes.png` | — |
| Sub 1A | 🟢 | Gate 4A draft completed by Lead after spawn auth failure | 2026-05-23 16:37:10 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/T0_GATE4A_IMPORT_ASK_DRAFT.md` | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/screenshots/20260523_163710_Codex1Lead_track_alpha_report_complete.png` | Process degradation recorded |
| Sub 1B | 🟢 | Gate 4B draft completed by Lead after spawn auth failure | 2026-05-23 16:37:10 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/T0_GATE4B_PUBLISH_ASK_DRAFT.md` | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/screenshots/20260523_163710_Codex1Lead_track_alpha_report_complete.png` | Process degradation recorded |
| Sub 1C | 🟢 | Gate 4C scaffold completed by Lead; waits Γ dependency map for backfill | 2026-05-23 16:37:10 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/T0_GATE4C_AQ07_CLEANUP_ASK_DRAFT.md` | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/screenshots/20260523_163710_Codex1Lead_track_alpha_report_complete.png` | Waiting Γ dependency map for final component list |

### Track Β — Preflight + Tenant Write (4 actors) — **CRITICAL PATH**

| Actor | Status | Current task | Last check-in BRT | Evidence path | Screenshot path | Blocker |
|---|---|---|---|---|---|---|
| **Codex #2 Lead** | 🔴 | PM0-3_20-POST-PUBLISH-ALL-RECHECK complete; post-publish-all did not activate AtualizarStatus and AQ-08 now BLOCKs 3 topics | 2026-05-24 11:55:06 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/post_publish_all/POST_PUBLISH_ALL_RECHECK.md` + `HALT_REPORT_DELTA.md` | `.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\post_publish_all\screenshots\20260524T145506Z_Codex2Lead_post_publish_all_recheck_halt.png` | HOLD: AtualizarStatus Borrador/Borrador; AQ-08 BLOCK blockingTopicCount=3 |
| Sub 2A | 🟢 | Dataverse 403 cleared via PAC FetchXML fallback after AZ/PAC identity mismatch | 2026-05-23 17:14:15 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/T0_PREFLIGHT_RERUN_MANIFEST.md` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_171415_Codex2Lead_preflight_rerun_manifest.png` | — |
| Sub 2B | 🟡 | Historical fallback validation complete; standby for Owner manual export paths | 2026-05-23 16:44:41 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/20260523_164223_Codex2Sub2B_historical_fallback_validation.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_164223_Codex2Sub2B_historical_fallback_validation.png` | Owner backup paths TBD |
| Sub 2C | 🟢 | SHA compare tool + post-publish runbook complete and parser-checked | 2026-05-23 17:14:15 BRT | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/T0_SHA_COMPARE.ps1` + `T0_POST_PUBLISH_RUNBOOK.md` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_171415_Codex2Lead_preflight_rerun_manifest.png` | — |

### Track Γ — Architecture + Risk (1 actor)

| Actor | Status | Current task | Last check-in BRT | Evidence path | Screenshot path | Blocker |
|---|---|---|---|---|---|---|
| **Opus 4.6** | 🟢 | AQ07 dependency tree audit COMPLETE + gate transition sanity protocol COMPLETE; standby for AQ-09 cross-validation | 2026-05-23 16:37:00 BRT | `.planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/T0_AQ07_DEPENDENCY_TREE_AUDIT.md` + `T0_GATE_TRANSITION_SANITY_PROTOCOL.md` | `.planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/screenshots/20260523_163300_Opus46_launch_required_reading.md` | — |

### Track Δ — Cards + Docs (3 actors)

| Actor | Status | Current task | Last check-in BRT | Evidence path | Screenshot path | Blocker |
|---|---|---|---|---|---|---|
| **Gemini Flash #2 (Δ Lead role)** | 🟢 | Track Delta deliverables complete, report consolidated | 2026-05-23 17:50:00 BRT | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/evidence/20260523_175000_GeminiFlash2Delta_completed.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/screenshots/T0_TRACK_DELTA_REPORT.png` | — |
| Sub G2A acting as Δ G1A | 🟢 | Re-validating 5 Adaptive Cards complete | 2026-05-23 17:40:00 BRT | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/evidence/20260523_174000_GeminiFlash2SubG2A_DeltaCompleted.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/T0_CARDS_REVALIDATION_REPORT.md` | — |
| Sub G2B acting as Δ G1B | 🟢 | Aligning release notes PT/EN and versions to 3.18 complete | 2026-05-23 17:42:00 BRT | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/evidence/20260523_174200_GeminiFlash2SubG2B_DeltaCompleted.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/T0_RELEASE_NOTES_ALIGNMENT_DIFF.md` | — |

### Track Ε — Evidence + Comms (3 actors)

| Actor | Status | Current task | Last check-in BRT | Evidence path | Screenshot path | Blocker |
|---|---|---|---|---|---|---|
| **Gemini Flash #2 Lead** | 🟢 | Standby — Track E deliverables complete, awaiting T4 trigger | 2026-05-23 16:46:06 BRT | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/evidence/20260523_164606_GeminiFlash2Lead_standby.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/screenshots/20260523_164606_GeminiFlash2Lead_standby.png` | — |
| Sub G2A | 🟢 | Staging T0_DRIFT_MONITOR_COMMANDS.ps1 drift commands complete | 2026-05-23 16:38:00 BRT | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/evidence/20260523_163800_GeminiFlash2SubG2A_drift_staging.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/screenshots/20260523_163800_GeminiFlash2SubG2A_drift_staging.png` | — |
| Sub G2B | 🟢 | Pre-filling A1–A5 evidence stubs complete | 2026-05-23 16:42:00 BRT | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/evidence/20260523_164200_GeminiFlash2SubG2B_stubs_completed.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/screenshots/20260523_164200_GeminiFlash2SubG2B_stubs_completed.png` | — |

---

## T0 success criteria checklist (all 8 must PASS before T1)

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | Α-Lead peer-review PASS for 4A and 4B ASK drafts | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/screenshots/20260523_163606_Codex1Lead_ask_peer_review.png` |
| 2 | Α-Lead local static cross-check PASS (8/8 gates exit 0) on 3.16 package | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/screenshots/20260523_163320_Codex1Lead_static_gates.png` |
| 3 | Β-Sub 2A: Dataverse 403 cleared (or escalation file produced) | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_171415_Codex2Lead_preflight_rerun_manifest.png` |
| 4 | Β-Lead: Run-Gate4-Preflight.ps1 reaches end without further halts | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_171415_Codex2Lead_preflight_rerun_manifest.png` |
| 5 | Β-Sub 2C: SHA compare tool tested and ready | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_171415_Codex2Lead_preflight_rerun_manifest.png` |
| 6 | Γ: AQ07 dependency tree audit complete | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/T0_AQ07_DEPENDENCY_TREE_AUDIT.md` — Opus 4.6, 2026-05-23 16:37:00 BRT |
| 7 | Δ: Cards re-validated, release notes aligned, monitoring runbook updated | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/T0_TRACK_DELTA_REPORT.md` |
| 8 | Ε: Drift monitor staged, A1–A5 stubs pre-filled, comms PASS/FAIL drafts ready | 🟢 | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/T0_TRACK_EPSILON_REPORT.md` |

---

## Active blockers (🔴)

| ID | Description | Owner | Since BRT | Mitigation in progress |
|---|---|---|---|---|
| BLK-LIVE-317 | Tenant PMO_v11_Tarefas moved to 3.17 during Owner manual export; 3.18 rebuild required before Gate 4A | Codex #2 Lead | 2026-05-23 17:31 | ⚠️ GATE 4A VERSION CLEARED, GATE 4B HOLD — tenant now reports 3.18.0.0 and AQ-08 PASS, but import log has PM0_PA_Card_AtualizarStatus activation error 0x80040216. Evidence: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/import_log_review/T0_IMPORT_LOG_DEEP_DIVE.md`; screenshot: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/import_log_review/screenshots/20260523_235318_Codex2Lead_import_log_review_hold.png`. |
| BLK-RUNTIME-DEFECTS | 3.20 post-publish-all runtime still not clean: AtualizarStatus remains Borrador and AQ-08 blocks 3 topics | Codex #2 Lead | 2026-05-23 21:27 | HOLD Gate 4B. 3.20 source/content defect is fixed (`item/StatusID` present; zero 0x80040216), tenant solution remains `3.20.0.0`, but after Owner clicked `Publicar todas as personalizacoes`, `PM0_PA_Card_AtualizarStatus` still reports `Borrador/Borrador` and AQ-08 returns `BLOCK`, `blockingTopicCount=3` for AtualizarTarefa, ConsultarPortfolio, and CriarTarefa action references. Evidence: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/post_publish_all/POST_PUBLISH_ALL_RECHECK.md`; screenshot: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/post_publish_all/screenshots/20260524T145506Z_Codex2Lead_post_publish_all_recheck_halt.png`. |
| BLK-POST-PUBLISH-ALL-3_20 | Owner publish-all-customizations did not clear runtime blockers | Codex #2 Lead | 2026-05-24 11:55 | `PM0_PA_Card_AtualizarStatus` still `Borrador/Borrador`; AQ-08 `overall=BLOCK`, `blockingTopicCount=3`; bot and solution identity remain healthy. Required next step: investigate why publish-all did not activate AtualizarStatus and why three topic action references are not detected after publish-all. Evidence: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/post_publish_all/HALT_REPORT_DELTA.md`; screenshot: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/post_publish_all/screenshots/20260524T145506Z_Codex2Lead_post_publish_all_recheck_halt.png`. |
| AUTH-PAC-3_20 | PAC auth resolved; Gate 4B now held only on missing post-import `Publicar todas as personalizacoes` runtime propagation | Codex #2 Lead | 2026-05-24 09:22:08 | AUTH CLEARED by A.4 (`pac auth create --tenant ... --environment https://colofertasbrasilpro.crm4.dynamics.com/`). Tenant now verifies `PMO_v11_Tarefas 3.20.0.0 Managed=False`; export has `item/StatusID`; source-vs-tenant PM0 workflows have zero functional diffs; AQ-08 PASS with `blockingTopicCount=0`; bot Published/Active/Provisioned with publishedon `22/05/2026 14:40`. HOLD remains because `PM0_PA_Card_AtualizarStatus` is `Borrador/Borrador` and Owner confirmed `Publicar todas as personalizacoes` has not yet been executed. Evidence: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/T0_IMPORT_LOG_DEEP_DIVE_3_20_CANONICAL.md`; screenshot: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4b/recovery/import_log_review_canonical/screenshots/20260524T140124Z_Codex2Lead_full_validate_v2_hold_publish_all_customizations.png`. |
| BLK-BACKUP | Owner manual export paths for both solutions | Owner | 2026-05-23 16:13 | ✅ CLEARED 2026-05-23 18:01 BRT — Owner provided: `C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_3_17.zip` + `C:\Users\dataops-lab\Downloads\PMO_AQ07_CopilotBinding_1_0_0_2.zip`. Owner directed validation bypass; files accepted on trust. Recovery use: primary targets if 3.18 import fails post-Gate-4A. |

---

## Recent events feed (latest 10, newest at top)

| Timestamp BRT | Actor | Event |
|---|---|---|
| 2026-05-24 11:55:06 BRT | Codex #2 Lead | PM0-3_20-POST-PUBLISH-ALL-RECHECK COMPLETE - verdict HOLD - AtualizarStatus still Borrador/Borrador and AQ-08 BLOCK blockingTopicCount=3 - see .planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\post_publish_all\screenshots\20260524T145506Z_Codex2Lead_post_publish_all_recheck_halt.png |
| 2026-05-24 11:51:20 BRT | Codex #2 Lead | PM0-3_20-POST-PUBLISH-ALL-RECHECK CLAIMED - Owner publicou todas personalizacoes 11:48 BRT, mini recheck em curso - see .planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\post_publish_all\screenshots\20260524T145120Z_Codex2Lead_post_publish_all_recheck_claim.png |
| 2026-05-24 11:01:24 BRT | Codex #2 Lead | PM0-3_20-CANONICAL-FULL-VALIDATE-V2 COMPLETE - verdict HOLD_PENDING_OWNER_PUBLISH_ALL_CUSTOMIZATIONS - 3.20 content/AQ PASS, AtualizarStatus Borrador until Publish all customizations - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\screenshots\20260524T140124Z_Codex2Lead_full_validate_v2_hold_publish_all_customizations.png |
| 2026-05-24 10:40:23 BRT | Codex #2 Lead | PM0-3_20-CANONICAL-FULL-VALIDATE-V2 CLAIMED - comprometido com leitura linear integral dos 4 docs master, zero tolerancia a HOLD precipitado, ciente da clausula FAIL_DISCIPLINE - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\screenshots\20260524T134023Z_Codex2Lead_full_validate_v2_claim.png |
| 2026-05-24 10:00:29 BRT | Codex #2 Lead | CANONICAL DEEP DIVE COMPLETE - verdict HOLD - PAC re-auth requires interactive login; import_41 clean for 0x80040216 but AtualizarStatus activation row still Sin procesar - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\screenshots\20260524T130029Z_Codex2Lead_canonical_deep_dive_halt.png |
| 2026-05-24 09:54:17 BRT | Codex #2 Lead | PM0-3_20-CANONICAL-IMPORT-DEEP-DIVE CLAIMED - leitura obrigatoria em curso, alvo: import_41.xml - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4b\recovery\import_log_review_canonical\screenshots\20260524T125417Z_Codex2Lead_canonical_deep_dive_claim.png |
| 2026-05-24 09:26:48 BRT | Codex #2 Lead | HOLD amended - Owner export filename ignored; internal solution.xml Version=3.18 while StatusID is present - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4a\import_log_review_3_20\screenshots\20260524T122648Z_Codex2Lead_3_20_owner_export_amendment_hold.png |
| 2026-05-24 09:22:08 BRT | Codex #2 Lead | DEEP DIVE 3.20 COMPLETE - verdict HOLD - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4a\import_log_review_3_20\screenshots\20260524T121908Z_Codex2Lead_3_20_deep_dive_hold.png |
| 2026-05-24 09:12:47 BRT | Codex #2 Lead | PM0-3_20-POST-IMPORT-VERIFY CLAIMED - leitura obrigatoria em curso, import log alvo: import_39.xml - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\post_4a\import_log_review_3_20\screenshots\20260524T121247Z_Codex2Lead_3_20_post_import_claim.png |
| 2026-05-24 03:16:05 BRT | Codex #2 Lead | BUILD 3.20 COMPLETE - peer review requested - see D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\PACKAGE\v3_20\screenshots\20260524_061605_Codex2Lead_3_20_build_complete.png |

---

### THE THREE-ELEMENT CHECK-IN RULE (MANDATORY — no exceptions)

Every single check-in entry on this board, in `AGENT_CHECKIN_REGISTRY.md`, or in any communication, **must contain all three of**:

| # | Element | Format | Example |
|---|---|---|---|
| 1 | **Agent name (full label)** | Lead/Sub identifier exactly as in this board | `Codex #2 Sub 2A`, `Gemini Flash #1 Lead`, `Opus 4.6` |
| 2 | **Full timestamp BRT** | `YYYY-MM-DD HH:MM:SS BRT` | `2026-05-23 16:24:37 BRT` |
| 3 | **Screenshot path** | Full repo-relative `.png` path under your track's evidence root | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/20260523_162437_Codex2Sub2A_az_role_check.png` |

A check-in missing any of the three is **invalid**. Kiro will revert invalid check-ins on sight and post a correction notice in "Recent events feed". The actor must re-post with the missing element(s) before continuing.

### Cadence

- Every **5 min** while you are actively executing a task (current-state screenshot, even mid-work).
- On **every state transition**: start of task, completion of task, raise blocker, clear blocker (state-evidence screenshot).

### What to update per check-in

1. **Your row in the "All 15 actors" section:**
   - `Status` emoji
   - `Current task` (one short line)
   - `Last check-in BRT` (full timestamp `YYYY-MM-DD HH:MM:SS BRT`)
   - `Evidence path` (now means: full path to triplet base, e.g. `.../20260523_162437_Codex2Sub2A_az_role_check.{txt,json,png}`)
   - `Screenshot path` column (new — see updated table below)
   - `Blocker` (text or `—`)

2. **Append one line to "Recent events feed"** with format:
   `| YYYY-MM-DD HH:MM:SS BRT | <agent name> | <one-line event> — see <screenshot path> |`
   Trim feed to latest 10 entries.

3. **Update "Last refreshed"** at top of board with: `YYYY-MM-DD HH:MM:SS BRT | <agent name> | <one-line summary> | screenshot: <path>`

4. **If your task closes a "T0 success criteria" item:** flip its row to 🟢, paste the screenshot path into Evidence column.

5. **If you raise/clear a blocker:** update the "Active blockers" table; include screenshot path in mitigation column.

### What NOT to update

- Other actors' rows in the actor table.
- The Status legend.
- Mission phase progress rows (only Kiro promotes T0→T1, etc.).
- Success criteria item descriptions.

### Evidence triplet rule (still applies for all artifacts)

Every artifact you produce must publish three files under your track's evidence root:
- `<UTC>_<AgentLabel>_<artifact_name>.txt` — log
- `<UTC>_<AgentLabel>_<artifact_name>.json` — structured
- `<UTC>_<AgentLabel>_<artifact_name>.png` — screenshot ← **the one you reference in your check-in**

The `.png` is what satisfies the mandatory check-in screenshot element.

### Conflict resolution

If two actors race on the same edit, the second writer must **merge — never overwrite** — and re-add any displaced entry to "Recent events feed" with the original timestamp + a re-post timestamp.

### Why this is mandatory

The Owner reads this board as the single source of truth on mission progress. A claim of "task done" without a screenshot has no evidentiary value and cannot be trusted. The triplet (name + timestamp + screenshot) is non-negotiable for SEV-0 SHIP discipline.

---

## Phase transition rules (Kiro-only)

Kiro promotes phase rows (T0→T1, T1→T2, etc.) only when:
- All success criteria for the closing phase are 🟢, AND
- No active blockers tagged with that phase, AND
- For tenant-write transitions (T2, T3, T6): standing auth or explicit Owner approval is on record in DECISION_RESPONSES.

When Kiro promotes a phase, Kiro appends to "Recent events feed" with the rationale and timestamp.


