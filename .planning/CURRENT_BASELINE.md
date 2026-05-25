# Current Baseline

Date: 2026-05-24
Last updated: 2026-05-24 03:16:05 BRT | Codex #2 Lead via Kiro | Tenant solution upgraded to 3.19.0.0 by Owner manual import 2026-05-23; AtualizarStatus activation FAILED post-import; RCA H1 CONFIRMED; 3.20 BUILD COMPLETE awaiting peer review.

The live tenant solution is `PMO_v11_Tarefas` 3.19.0.0 unmanaged (imported via Owner Apply Upgrade ~2026-05-23 19:34 BRT). The bot's last successful publish event is 2026-05-22 14:40 BRT, sourced from the 3.15.1 publish; no republish occurred from 3.18 or 3.19 because Track-Β halted on `PM0_PA_Card_AtualizarStatus` activation `0x80040216`. AQ-08 reverify post-3.19 import: BLOCK (blockingTopicCount=1, ListarTarefas).

Audit note: AQ-09 A1 failure originated SEV-0 RISK-013 (still OPEN). RCA H1 CONFIRMED 2026-05-24 02:55:01 BRT — root cause = missing `item/StatusID` in Create_StatusDiario action of `PM0_PA_Card_AtualizarStatus` workflow. H5 CONFIRMED — defect existed in 3.18, latent behind OrigemEntrada string-vs-object error. 3.20 BUILD COMPLETE 2026-05-24 03:16:05 BRT by Codex #2 Lead — SHA `ADE54BF23F60F7A9EA5AB054680640F00F4971BC201C82E130640AC1F3B28DAC`. Awaits Codex #1 Lead independent peer review.

## Active Solution Artifact (CURRENT)

- Live tenant solution: `PMO_v11_Tarefas` 3.19.0.0 unmanaged (imported by Owner 2026-05-23; AtualizarStatus in Borrador/Borrador)
- Latest local candidate: `Solution/PMO_v11_Tarefas_3_20_PM0_STATUSID_FIX.zip` SHA `ADE54BF23F60F7A9EA5AB054680640F00F4971BC201C82E130640AC1F3B28DAC` (BUILD COMPLETE 2026-05-24 03:16:05 BRT — peer review pending)
- Prior failed candidate: `Solution/PMO_v11_Tarefas_3_19_PM0_RUNTIME_FIX.zip` SHA `43A33783ABC30E7A3DC74EAED162558FBA0781AC163804F85FDC559023D514BF` (peer review PASS_WITH_NOTES; post-import activation FAIL on AtualizarStatus)
- Bot last publish UTC: `2026-05-22T11:15:52.9307207+00:00` (from 3.15.1 publish event; no republish from 3.18/3.19)
- Bot status: `Assistente PMO V2` Published / Active / Provisioned — runtime topic/flow set still backed by 3.15.1 publish; 3.19 imported workflows in tenant Dataverse but `PM0_PA_Card_AtualizarStatus` is in `Borrador/Borrador` state
- Environment: `ColOfertasBrasilPro` (e2d10003-4d8e-e007-9d63-76d5fe89ef56)
- AQ-08 reverify post-3.19 import: BLOCK (blockingTopicCount=1, ListarTarefas)
- RCA verdict (root cause confirmed): `.planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/RCA_3_19_ATUALIZARSTATUS_VERDICT.md`
- 3.20 build report: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_20/BUILD_REPORT.md`
- Remediation plan applied in 3.20: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/RCA_3_19_ATUALIZARSTATUS/REMEDIATION.md`
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
