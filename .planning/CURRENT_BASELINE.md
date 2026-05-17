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

- Every new agent and every new chat must read `.planning/GOLDEN_RULES.md`, `.planning/CURRENT_BASELINE.md`, and `.planning/AGENT_CHECKIN_REGISTRY.md` before code, deploy, import, publish, tenant write, or release decision.
- For Adaptive Cards + Planner P0 work, every active agent must also read `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`, and `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md` before starting any task.
- Read `docs/MANUAL_OPERACIONAL_PMO.md` before touching PMO behavior, Copilot topics, flows, SharePoint lists, Teams cards, or release evidence.
- Treat ship diligence as SEV-0. Default state is NO-SHIP until current static and runtime evidence proves the exact artifact is safe.
- CI may be ignored only when explicitly owner-excluded. Every other quality gate is mandatory; if any non-CI gate is missing, failed, stale, unverified, or not tied to the current artifact, the release decision is `NO-SHIP`.
- Use official Microsoft documentation as the source of truth for Power Platform, Copilot Studio, Power Automate, Dataverse, SharePoint, Teams, Graph, Entra, and Microsoft 365 CLI behavior.
- Do not import, publish, deploy, commit, delete, modify portal/runtime, or write to production without explicit written approval from the project owner in the current thread.
- Local file edits, local package preparation, and local tests are allowed; production import and runtime validation remain owner-controlled unless explicitly delegated in writing.
- Use at most 3 parallel subagents unless the project owner explicitly approves more in writing.
- Do not ship with missing evidence, stale flow/topic bindings, ghost components, placeholders, confirm-only write paths, data-loss risk, failed tests, or unsupported Microsoft behavior.
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
