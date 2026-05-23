# AQ-08 Track B Anomaly Diagnosis - 2026-05-21

## Decision

Recommendation: **publish NOT acceptable** at this checkpoint.

The owner-confirmed root cause for the three-topic disappearance observed at the 2026-05-21 04:57 BRT reverify is a stale Copilot Studio Code Editor client-side draft cache before browser cleanup. Browser cache and cookie cleanup is mandatory before future paste-and-save deliveries in Copilot Studio Code Editor.

The post-cleanup re-paste restored the expected action references for the three previously affected topics in the first reverify, but that same reverify returned `BLOCK` / exit `1` because `CriarTarefa` no longer had its expected action reference. The remediation gate requires the first and second reverifies to both return five-topic `PASS`; Section C was therefore not started.

The v2 remediation Section B check also found the same output-key defect in `AtualizarStatus` that was already identified for `ConsultarPortfolio`: the saved topic binds the legacy `message` output key while the `PM0_PA_Card_AtualizarStatus` action component and workflow schema expose `result`. Its right-hand variable and downstream `SendActivity` still agree on `Topic.AtualizarStatusResult`.

## Evidence

| Evidence | Path |
|---|---|
| Pre-remediation report JSON available in repo | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/aq08_post_remediation_reverify_report.json` |
| 2026-05-21 01:34 BRT PASS report | `.planning/comms/aq08_topic_routing_verification_20260520/preflight_p0_w2_4/aq08_post_remediation_reverify_report.json` |
| 2026-05-21 04:57 BRT anomaly report | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/post_owner_edits_20260521_0453/aq08_post_remediation_reverify_report.json` |
| Post-repaste run1 report | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/post_owner_edits_20260521_repaste_run1/aq08_post_remediation_reverify_report.json` |
| Post-repaste topic snapshots and fixed-file diffs | `.planning/comms/aq08_topic_routing_verification_20260520/anomaly_20260521_0457/topic_data_after_repaste/` |

The mandatory post-repaste snapshots capture live PAC `botcomponent.data` text for `AtualizarTarefa`, `ConsultarPortfolio`, and `ListarTarefas` from run1. Their diffs against `fixed_topic_yamls/*.yaml` are stored beside the snapshots. Those diffs show Copilot Studio serialization changes after save, including whitespace and scalar quoting normalization. `ConsultarPortfolio` also differs in its saved output binding from the fixed delivery YAML while still retaining the expected `PM0_PA_Card_ResumoExecutivoPortfolio` action reference checked by the AQ-08 routing verifier.

## Timeline

| Date/time BRT | Run | Observed result | Notes |
|---|---|---|---|
| 2026-05-20 16:38 | Yesterday BLOCK baseline cited by dispatch | `BLOCK` | Dispatch baseline for pre-remediation tenant state. The repo JSON report currently available at 2026-05-20 17:26:33 BRT shows the same five-topic BLOCK shape. |
| 2026-05-21 01:34:35 | Pre-flight after owner edits | `PASS` | All five topics had expected action references and empty legacy hit lists. |
| 2026-05-21 04:57:00 | Confirmation reverify before re-paste | `BLOCK` | `AtualizarTarefa`, `ConsultarPortfolio`, and `ListarTarefas` had neither expected action references nor legacy hits. |
| 2026-05-21 10:17:29 | Post-cleanup re-paste run1 | `BLOCK` | The three re-pasted topics passed. `CriarTarefa` blocked because `hasExpectedActionReferenceInTopic` was false. |
| Not run | Post-repaste run2 | Not started | Section C requires run1 five-topic PASS before the 120-second stability reverify. |

## Per-Topic Reverify Shape

`E` is `hasExpectedActionReferenceInTopic`. `L` is the count of `legacyHitsInTopic`.

| Topic | 2026-05-20 baseline | 2026-05-21 01:34 | 2026-05-21 04:57 | 2026-05-21 repaste run1 |
|---|---|---|---|---|
| AtualizarStatus | `BLOCK E=false L=2` | `PASS E=true L=0` | `PASS E=true L=0` | `PASS E=true L=0` |
| AtualizarTarefa | `BLOCK E=false L=2` | `PASS E=true L=0` | `BLOCK E=false L=0` | `PASS E=true L=0` |
| ConsultarPortfolio | `BLOCK E=false L=2` | `PASS E=true L=0` | `BLOCK E=false L=0` | `PASS E=true L=0` |
| CriarTarefa | `BLOCK E=false L=2` | `PASS E=true L=0` | `PASS E=true L=0` | `BLOCK E=false L=0` |
| ListarTarefas | `BLOCK E=false L=0` | `PASS E=true L=0` | `BLOCK E=false L=0` | `PASS E=true L=0` |

## Hypothesis Ranking

1. **Confirmed for the 04:57 three-topic anomaly: Copilot Studio Code Editor stale client-side draft cache.** Owner cleared browser cache and cookies, re-pasted the three affected topics, refreshed, and confirmed persistence for those saves. Run1 then observed the expected action references again for those three topics.
2. **Still possible as a secondary tenant-state risk: later draft cleanup or another overwrite path.** The earlier PASS to BLOCK drift remains the reason the remediation dispatch requires a delayed second reverify after a passing run1. That stability check has not yet been reached in this checkpoint.
3. **Observed but not sufficient as the three-topic root cause: Copilot Studio parse-and-save serialization.** The post-repaste diffs show saved `botcomponent.data` normalization and at least one saved binding-shape difference for `ConsultarPortfolio`; however, the three repasted topics retained their expected action references in run1 after the browser cleanup.

## Publish Monitoring

After the pre-publish gate is cleared and the owner publishes 3.15, run post-publish AQ-08 drift monitoring at:

1. +5 minutes.
2. +1 hour.
3. +6 hours.

Capture the post-publish checks under `.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/drift_monitoring_20260521/`.

## V2 Section B - AtualizarStatus Content Integrity

Section A captured a fresh five-topic live snapshot set at `.planning/comms/aq08_topic_routing_verification_20260520/anomaly_20260521_0457/topic_data_full_5/`.

`AtualizarStatus` is not runtime-safe in the current tenant state:

| Check | Result | Evidence |
|---|---|---|
| Expected action reference | PASS | Live snapshot contains `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus`. |
| Output binding key vs PM0 card action schema | FAIL | Live topic uses `message: Topic.AtualizarStatusResult`; the PM0 action component data and workflow response schema expose `result`. |
| Binding RHS variable vs `SendActivity` variable | PASS | Both use `Topic.AtualizarStatusResult`. |

Section D must include `AtualizarStatus.yaml` after `CriarTarefa.yaml` and the v2 `ConsultarPortfolio.yaml`.

## Next Gate

Owner follow-up is required before publish readiness can resume:

1. Restore and persist the expected action reference for `CriarTarefa` using the cache-clean browser path.
2. Re-run remediation Section B and require five-topic `PASS` / exit `0`.
3. Sleep at least 120 seconds, then run remediation Section C and require identical five-topic `PASS` with no per-topic content drift.

Only after both reverifies pass and this diagnosis can be replaced with a `publish acceptable` recommendation should corrective dispatch Sections B-F resume.
