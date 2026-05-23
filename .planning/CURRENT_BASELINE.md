# Current Baseline

Date: 2026-05-22
Last updated: 2026-05-22 17:13:10 BRT | Codex | Clarified local 3.16 package/static-gate state versus live tenant.

The active baseline is the 3.15.1 hotfix package, imported and published in `Assistente PMO V2` on `ColOfertasBrasilPro`. AQ-08 reverify PASS at T+5min and T+1h. Drift monitor stable.

Audit note: AQ-09 A1 failure keeps this baseline under SEV-0 NO-SHIP review. The merged Codex audit found `STUB=1`, `PARTIAL=4`, `REAL=0` across the five audited PM0 workflow bodies and missing topic/action input propagation on four required paths. Local 3.16 source and package static gates now pass, but the live tenant remains 3.15.1 until explicit owner Gate 4 approval, tenant import, publish, and runtime proof complete.

## Active Solution Artifact (CURRENT)

- Active package: `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`
- Publish UTC label: `2026-05-22T11:15:52.9307207+00:00`
- Bot: `Assistente PMO V2` (Published / Active / Provisioned)
- Environment: `ColOfertasBrasilPro` (e2d10003-4d8e-e007-9d63-76d5fe89ef56)
- AQ-08 verifier T+5min: PASS — `aq08_post_remediation_reverify_report.json`
- AQ-08 verifier T+1h: PASS — `aq08_post_remediation_reverify_report.json`
- Drift monitor T+6h: SCHEDULED 14:23 BRT
- Pre-publish rollback evidence: `.planning/comms/rollback_evidence_pre_3_15_20260520/`
- Rollback target if needed: `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` (SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`)

## Local Remediation Artifact (NOT LIVE)

- Local source target: 3.16 PM0 functional fix
- Local package target: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip`
- Local package SHA256: `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` (corrected 2026-05-22 18:06 BRT by Codex #2 Bravo; supersedes failed candidate `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`; evidence: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/evidence/20260522_180600_Codex2_package_consistency_strict.md`)
- Evidence root: `.planning/comms/codex_pm0_remediation_20260522/`
- Local guards with triplet evidence:
  - Workflow dynamic response semantics: `.planning/comms/codex_pm0_remediation_20260522/ALPHA/evidence/20260522_162457_CodexLead_workflow_response_semantics_rerun.md`
  - Placeholder/ASCII scan: `.planning/comms/codex_pm0_remediation_20260522/ALPHA/evidence/20260522_162457_CodexLead_placeholder_ascii_scan_rerun.md`
  - Topic/action/workflow contract: `.planning/comms/codex_pm0_remediation_20260522/ALPHA/evidence/20260522_162538_CodexLead_topic_action_flow_contract_final.md`
- Status: local source guards and local package static gates pass. No tenant write, import, publish, AQ-09 runtime smoke, or SHIP decision has occurred.

## Five In-Scope Topics — AQ-08 Structural Route PASS Only

| Topic | Action component | Workflow ID |
|---|---|---|
| AtualizarStatus | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| AtualizarTarefa | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| ConsultarPortfolio | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| CriarTarefa | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| ListarTarefas | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

## Legacy Baseline Artifacts (HISTORICAL — do not use as current)

- T-004 decimal fix baseline (2026-05-06): `.planning/canonical/PMO_v11_Tarefas_T004_DECIMAL_FIX_20260506_1115.zip`
- 3.10 post-workflowset clean (2026-05-13): `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` — kept as rollback target
- 3.15 list static runtime bypass (2026-05-14): `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` — superseded by 3.15.1

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
