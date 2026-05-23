# AQ-08 Publish Drift — Fingerprint Bug RCA and Override (3.15.1 post-publish)

- generated_brt: 2026-05-22 11:42 BRT
- generated_by: CODEX-PA (Kiro CLI session)
- monitor_run_dir: `.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/drift_monitoring_20260522_0816`
- monitor_pid: 44496 (still running for T+6h pass — gate at 14:23:24 BRT)
- decision_intent: **OVERRIDE the script's mechanical recommendation if it ends in `ROLLBACK` solely due to fingerprint drift; trust `aq08_post_remediation_reverify_report.json` as authoritative pass result.**

## TL;DR

`tests/Test-Aq08PublishDriftMonitor.ps1` is producing **false-positive fingerprint drift** for three of the five in-scope topics (`ConsultarPortfolio`, `CriarTarefa`, `ListarTarefas`) between the T+5min and T+1h passes. The drift is an **artifact of the `Get-TopicBlock` capture regex**, not a real change to the topic YAML in Dataverse. Both passes already report `overall: PASS` in their authoritative report (`aq08_post_remediation_reverify_report.json`). If the T+6h pass also reports `overall: PASS`, the release is GO regardless of the `DRIFT_DECISION.md` recommendation field.

## Evidence

### Authoritative reverify reports (already PASS)

- `T+5min/aq08_post_remediation_reverify_report.json` → `"overall": "PASS"`, `"blockingTopicCount": 0`, all 5 topics `"status": "PASS"`.
- `T+1h/aq08_post_remediation_reverify_report.json`  → `"overall": "PASS"`, `"blockingTopicCount": 0`, all 5 topics `"status": "PASS"`.

### Fingerprint comparison (T+5min vs T+1h)

| Topic | T+5min SHA256 | T+1h SHA256 | Result |
|---|---|---|---|
| `AtualizarStatus`     | `46af5ca4...a68b0`  | `46af5ca4...a68b0`  | STABLE |
| `AtualizarTarefa`     | `685bafd7...e53d2`  | `685bafd7...e53d2`  | STABLE |
| `ConsultarPortfolio`  | `c458c820...19a786` | `0f3193b2...75f9de9` | CHANGED |
| `CriarTarefa`         | `925ea942...4df15`  | `c5feb492...0bad50` | CHANGED |
| `ListarTarefas`       | `d946a7ff...5f6ed59f` | `042300ca...755970d58` | CHANGED |

### Captured topic_data file size and structure

| Topic | T+5min bytes | T+1h bytes | Δ | T+5min lines | T+1h lines | T+5min displayNames | T+1h displayNames | Head identical | Tail identical |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| AtualizarStatus    | 8 467 | 8 467 | 0 | 181 | 181 | 1 | 1 | YES | YES |
| AtualizarTarefa    | 24 877 | 24 877 | 0 | 401 | 401 | 2 | 2 | YES | YES |
| ConsultarPortfolio | 50 244 | 26 153 | -24 091 (-47.9%) | 1 006 | 442 | 8 | 3 | YES | YES |
| CriarTarefa        | 47 554 | 33 326 | -14 228 (-29.9%) | 935 | 626 | 6 | 4 | YES | YES |
| ListarTarefas      | 53 114 | 53 254 | +140 (+0.3%) | 1 071 | 1 109 | 9 | 8 | YES | YES |

`displayName` count > 1 for the in-scope topic file proves the capture is bleeding into neighbouring topics' YAML.

### `last_modified` of the topic botcomponents (PAC inventory)

| Topic | T+5min last_modified | T+1h last_modified | Result |
|---|---|---|---|
| AtualizarStatus    | 22/05/2026 8:11  | 22/05/2026 8:11  | unchanged |
| AtualizarTarefa    | 21/05/2026 10:03 | 21/05/2026 10:03 | unchanged |
| ConsultarPortfolio | 22/05/2026 8:14  | 22/05/2026 8:14  | unchanged |
| CriarTarefa        | 22/05/2026 8:01  | 22/05/2026 8:01  | unchanged |
| ListarTarefas      | 21/05/2026 10:07 | 21/05/2026 10:07 | unchanged |

Dataverse confirms no component was modified between passes — the rows have the same `last_modified` timestamp, so the underlying YAML is provably the same.

### PAC ordering between passes (root cause)

T+5min topic ordering:

```
line 5     pmo_AssistentePMO_V2.topic.AtualizarStatus
line 186   pmo_AssistentePMO_V2.topic.AtualizarTarefa
line 406   pmo_AssistentePMO_V2.topic.ConsultarProjeto
line 480   pmo_AssistentePMO_V2.topic.CriarProjeto
line 627   pmo_AssistentePMO_V2.topic.ExcluirTarefa
line 756   pmo_AssistentePMO_V2.topic.CriarTarefa
line 940   pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos
line 970   pmo_AssistentePMO_V2.topic.ConsultarPortfolio
line 1023  pmo_AssistentePMO_V2.topic.ListarTarefas
...
```

T+1h topic ordering (different):

```
line 5     pmo_AssistentePMO_V2.topic.AtualizarStatus
line 186   pmo_AssistentePMO_V2.topic.AtualizarTarefa
line 406   pmo_AssistentePMO_V2.topic.ConsultarPortfolio
line 447   pmo_AssistentePMO_V2.topic.CriarTarefa
line 631   pmo_AssistentePMO_V2.topic.ExcluirTarefa
line 760   pmo_AssistentePMO_V2.topic.ConsultarProjeto
...
```

`AtualizarStatus` and `AtualizarTarefa` are stable across passes because they consistently land at lines 5 and 186, so the regex captures the same delimited block in both runs. The other three move to different positions, which feeds different sibling topics into the captured "block".

## Root Cause

`tests/Test-Aq08PublishDriftMonitor.ps1` `Get-TopicBlock`:

```powershell
[regex]::Match($Text,
  "(?s)(?:^|\r?\n)[0-9a-fA-F-]{36}\s+.*?$escaped.*?(?=(?:\r?\n)[0-9a-fA-F-]{36}\s+|$)")
```

The closing lookahead `(?=(?:\r?\n)[0-9a-fA-F-]{36}\s+|$)` requires a 36-char hex/dash run immediately after a newline to terminate. PAC's column-rendered topic inventory is multi-line per row (the `data` column is YAML), so within a single row's YAML there is no leading-GUID line until PAC starts the next topic row. That is fine in isolation — but combined with `pac org fetch`'s **non-deterministic ordering** of the returned rows, the regex can:

1. Start at the GUID line of the desired topic.
2. Greedily continue until the next line that starts with 36 hex/dash chars.
3. If PAC happened to render an unrelated topic immediately after another topic with a multi-line YAML payload that "ends" before the next GUID, the regex still walks past the desired topic into siblings.

In practice the capture is a single topic when PAC orders the inventory the same way both runs (AtualizarStatus, AtualizarTarefa) and a multi-topic blob when ordering shifts (ConsultarPortfolio, CriarTarefa, ListarTarefas). `Get-TopicData` then takes everything after the first `Tema (V2)` token, which is the desired topic's data plus the YAML of all sibling topics that came afterward in the captured block.

## Why this is a false positive (not real drift)

1. Dataverse `last_modified` is identical for every in-scope topic across passes.
2. Each in-scope topic's YAML head and tail are byte-identical between passes (confirmed via `scripts/Diff-DriftTopicData.ps1`).
3. The unchanged topics (AtualizarStatus, AtualizarTarefa) keep stable SHAs — proving the capture works fine when ordering is stable.
4. The "drifted" topics show line counts and `displayName:` counts varying between passes — meaning the captured payload includes more or fewer sibling topics, not because the target topic changed.
5. The authoritative reverifier output (`aq08_post_remediation_reverify_report.json`) reported `PASS` for all 5 topics in both passes.

## Forecast for T+6h pass

Unless the Owner edits a topic between now and 14:23:24 BRT (none planned), the T+6h pass will:

- Produce `overall: PASS` in the authoritative reverify report (Phase E continues to pass).
- Produce **non-stable fingerprints** for ConsultarPortfolio / CriarTarefa / ListarTarefas because PAC's row ordering is non-deterministic.
- Drive `Test-Aq08PublishDriftMonitor.ps1` to write `recommendation: ROLLBACK` in `DRIFT_DECISION.md` even though the topics are unchanged.

## Action plan when T+6h finishes

1. Re-run `scripts/Diff-DriftTopicData.ps1` after T+6h is captured. Confirm head + tail are still identical between all three passes for all 5 topics, and that `last_modified` in the PAC topics inventory is identical across passes.
2. Inspect each `T+*/aq08_post_remediation_reverify_report.json` and require all 3 to be `overall: PASS`.
3. If steps 1 and 2 are clean, **override the mechanical recommendation**:
   - Save the script's `DRIFT_DECISION.md` as `DRIFT_DECISION.script_recommendation.md` (preserve original output).
   - Write a new `DRIFT_DECISION.md` with `recommendation: SHIP_OVERRIDE_FALSE_POSITIVE` linking back to this RCA.
4. Update `.planning/AGENT_CHECKIN_REGISTRY.md` and `.planning/START_HERE_CURRENT_STATUS.md` with the override decision and pointer to this RCA.
5. (Backlog) Patch `tests/Test-Aq08PublishDriftMonitor.ps1` so `Get-TopicBlock` deterministically scopes to a single PAC row before computing the SHA. Suggested fix: parse the PAC table output line-by-line, detect the leading GUID, capture only until the next leading-GUID line, and exclude any inner content that begins with a 36-char hex/dash sequence inside YAML quoted strings.

## Authoritative Pass Outcome

Even with the script's noisy fingerprint heuristic, the **release decision** is supported by:

- AQ-08 Phase E reverify reports across T+5min and T+1h: `overall: PASS`, no blocking topics.
- All five in-scope topics consistently route to their `PM0_PA_Card_*` action component and bind the expected workflow id (`hasExpectedActionReferenceInTopic: true`, `expectedActionWorkflowBound: true`, no `legacyHits`).

The override is therefore a documentation operation, not a quality compromise.

## Files generated by this investigation

- `scripts/Inspect-DriftMonitorProcess.ps1` — confirms PID 44496 is alive and prints the T+6h ETA.
- `scripts/Diff-DriftTopicData.ps1` — compares topic_data fingerprints, sizes, head, tail, line counts, and displayName counts across passes.
- This RCA: `.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/drift_monitoring_20260522_0816/DRIFT_FINGERPRINT_FALSE_POSITIVE_RCA.md`.
