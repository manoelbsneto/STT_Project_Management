# AQ-08 Fixed Topic YAMLs - QA Evidence v2

Date BRT: 2026-05-21
Builder: `scripts/Build-Aq08FixedTopicYamls.py`
Builder command: `python scripts\Build-Aq08FixedTopicYamls.py`
Builder exit: `0`

## Scope

The v2 builder run fixes the output binding key for three PM0 card topic conversions:

| Topic | Expected PM0 action | Expected output binding | Matching `SendActivity` |
|---|---|---|---|
| `AtualizarStatus` | `PM0_PA_Card_AtualizarStatus` | `result: Topic.AtualizarStatusResult` | `{Topic.AtualizarStatusResult}` |
| `ConsultarPortfolio` | `PM0_PA_Card_ResumoExecutivoPortfolio` | `result: Topic.ConsultarPortfolioResult` | `{Topic.ConsultarPortfolioResult}` |
| `CriarTarefa` | `PM0_PA_Card_CriarTarefa` | `result: Topic.Result` | `{Topic.Result}` |

The binding key changed from legacy `message` to `result` because these PM0 card action component data files expose `outputs: result`, and the PM0 card workflow response schemas return `result`.

## Gate Results

The gated builder ran all eight gates before writing the final YAMLs.

| Topic | G1 | G2 | G3 | G4 | G5 | G6 | G7 | G8 | Result |
|---|---|---|---|---|---|---|---|---|---|
| `AtualizarStatus.yaml` | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| `AtualizarTarefa.yaml` | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| `ConsultarPortfolio.yaml` | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| `CriarTarefa.yaml` | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| `ListarTarefas.yaml` | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |

The v2 structural edit counts from the gate log are:

| Topic | Gate G5 result |
|---|---|
| `AtualizarStatus.yaml` | PASS, 13 edit lines across 4 ops |
| `ConsultarPortfolio.yaml` | PASS, 6 edit lines across 4 ops |
| `CriarTarefa.yaml` | PASS, 2 edit lines across 2 ops |

For `AtualizarStatus`, the final structural replacement rewrites the legacy `message: Topic.AtualizarStatusResult` output line and legacy flow id into `result: Topic.AtualizarStatusResult` on the PM0 card action call.

For `ConsultarPortfolio`, the final structural replacement rewrites the legacy `message: Topic.ConsultarPortfolioResult` output line and legacy flow id into `result: Topic.ConsultarPortfolioResult` on the PM0 card action call.

For `CriarTarefa`, the existing `BeginDialog` swap now also rewrites the legacy `message: Topic.Result` output line into `result: Topic.Result` for the PM0 card action call.

## Section B Addendum - Five-Topic Binding Sweep

The pre-repack sweep checked all five regenerated fixed topic YAMLs before rebuilding the 3.15.1 hotfix ZIP.

| Topic | Output binding | `SendActivity` Topic refs | Sweep result |
|---|---|---|---|
| `AtualizarStatus` | `result: Topic.AtualizarStatusResult` | `{Topic.AtualizarStatusResult}` | PASS |
| `AtualizarTarefa` | `result: Topic.message` | None; 3.15 runtime-bypass response text is static | PASS, no mismatched `{Topic.*}` reference |
| `ConsultarPortfolio` | `result: Topic.ConsultarPortfolioResult` | `{Topic.ConsultarPortfolioResult}` | PASS |
| `CriarTarefa` | `result: Topic.Result` | `{Topic.Result}` | PASS |
| `ListarTarefas` | `result: Topic.tarefas` | None; 3.15 runtime-bypass response text is static | PASS, no mismatched `{Topic.*}` reference |

All five action output bindings use the Track D `result` key. Every `{Topic.<var>}` reference that remains in a `SendActivity` matches the topic action output binding RHS in the same topic. `AtualizarTarefa` and `ListarTarefas` intentionally have static `SendActivity` success text in the 3.15 runtime-bypass line, so those topics have no `SendActivity` topic-variable reference to mismatch.

The same sweep found no legacy `PMO_PA_*` action refs, no non-ASCII characters, and the expected PM0 card action names for all five topics:

- `PM0_PA_Card_AtualizarStatus`
- `PM0_PA_Card_AtualizarTarefa`
- `PM0_PA_Card_ResumoExecutivoPortfolio`
- `PM0_PA_Card_CriarTarefa`
- `PM0_PA_Card_ListarTarefas`

## Owner Paste Batch

Section D requires a cache-clean Copilot Studio session and this order:

1. `CriarTarefa.yaml`
2. `ConsultarPortfolio.yaml`
3. `AtualizarStatus.yaml`

After each save, hard-refresh the Copilot Studio tab and confirm the topic still contains the expected `PM0_PA_Card_*` action reference and output binding pair before moving to the next file.
