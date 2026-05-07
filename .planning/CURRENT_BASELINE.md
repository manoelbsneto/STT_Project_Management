# Current Baseline

Date: 2026-05-06

This repository is now using the T-004 decimal fix baseline for the PMO v11 Tarefas solution. Do not use old `.planning/comms` packages or old `.planning/stopship` evidence. The active evidence folder is `.planning/stop_ship`.

## Active Solution Artifacts

- Source folder: `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_src`
- Imported package: `.planning/canonical/PMO_v11_Tarefas_T004_DECIMAL_FIX_20260506_1115.zip`
- Imported package SHA256: `84BB2A57A784DF16C1887FEA982490BCC6EE5C341C5EFCA759BD45B928573EA8`
- Post-import export: `.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120.zip`
- Post-import export SHA256: `1543027EE27248293C9C03014317667E2E36098A050BBE53DA3B2E6D90A725AC`
- Post-import unpacked export: `.planning/canonical/PMO_v11_Tarefas_POST_T004_DECIMAL_FIX_IMPORT_20260506_1120`
- Pre-import rollback backup: `.planning/canonical/PMO_v11_Tarefas_PRE_T004_DECIMAL_FIX_IMPORT_20260506_1115.zip`

## Current Rules

- Test flows one by one.
- All shipped app-facing text must be ASCII only.
- Do not use accents, cedilla, emojis, smart punctuation, or mojibake in cards, bot topics, flow labels, or deploy scripts.
- Use Portuguese words only when they are ASCII safe, for example `Concluida`, `Critica`, `Media`, `Proxima acao`.

## Verified Checks

- `tests/Test-PMOFlowStopShipAudit.ps1` passed against the post-import export.
- `tests/Test-CriarTarefaFlowDefinition.ps1` passed against the post-import `PMO_PA_CriarTarefa` workflow.
- `rg -n "[^\x00-\x7F]"` returned no matches in the post-import export, deploy cards, copilot template, or current tests.
- T-004 decimal regression is guarded by `CheckIn percent does not force integer`.

## Next Manual Test

Flow: `PMO_PA_CheckInOnDemand`

Use:

```text
ProjectID: PRJ-2127A0E4
Status: Verde
Resumo: Teste T-004 check-in decimal fix
Percentual: 10.5
Risco: Nenhum
Bloqueio: Nenhum
ProximaAcao: Validar gravacao decimal apos correcao
```

Warning: old Teams cards already posted before the ASCII fix will still show the previous broken text. Runs started before the 2026-05-06 11:20 decimal fix import can still fail with the previous `int` conversion error. Only fresh runs started after that import validate this fix.
