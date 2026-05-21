# XPIA-01 Verify Harness

Date: 2026-05-20  
Prepared by: CODEX-PA  
Scope: Post-publish Owner evidence capture and offline validation  
Ship rule: only in-scope P0 topics determine XPIA-01 RESOLVED/RECURS.

## In-Scope P0 Tests

These five tests determine the release XPIA gate:

| ID | Topic | Expected if XPIA Recurs | Expected if v3.15/P0 Bypass Works |
|---|---|---|---|
| A1_CMD-12-H | ListarTarefas | Bot may send success/static task text, then Copilot appends `ContentFiltered` and canvas shows `openAIIndirectAttack` | Bot sends only static/plain task response; no blocked step; no `ContentFiltered` |
| A2_CMD-15 | ConsultarPortfolio | Bot may send counts, then `ContentFiltered` appears after the response | Bot sends numeric counts only; no blocked step; no `ContentFiltered` |
| A3_CMD-11-P0 | CriarTarefa | Task may be created, then chat appends `ContentFiltered`; user sees ambiguous success/error | Bot confirms creation without blocked step; SharePoint row exists |
| A4_CMD-13A | AtualizarTarefa | Task may update/preserve fields, then chat appends `ContentFiltered`; user sees ambiguous success/error | Bot confirms update/preservation without blocked step; no `FlowActionBadGateway`; no `ContentFiltered` |
| A5_CMD-10 | AtualizarStatus | Status row may be created, then chat appends `ContentFiltered` | Bot confirms parsed fields and status row exists; no blocked step; no `ContentFiltered` |

## Legacy Evidence Only

The following topics are accepted legacy debt for this release and do not determine XPIA-01:

```text
ConsultarProjeto
CriarProjeto
ExcluirProjeto
ExcluirTarefa
PedirDecisao
RegistrarBloqueio
RegistrarRisco
```

If `ContentFiltered` recurs in legacy tests, record it as backlog evidence. Do not use it to block ship unless there is data loss, duplicate writes, or an unexpected write after cancel/invalid input.

## Diagnostic Signals To Capture Per Test

| Signal | What Owner Captures | Required For Gate |
|---|---|---|
| Chat reply | Full visible bot transcript, including any appended `ContentFiltered` message | Yes |
| Network trace if available | Browser HAR or copied failed request details from DevTools | Best effort |
| Run history | Power Automate run URL/ID and green/red action summary for actions called | Yes for write/action tests |

## Evidence File Naming

Save text evidence under:

```text
.planning/comms/aq09_smoke_runbook_20260520/evidence/
```

Recommended filenames:

```text
A1_CMD-12-H.md
A2_CMD-15.md
A3_CMD-11-P0.md
A4_CMD-13A.md
A5_CMD-10.md
B1_ConsultarProjeto.md
B2_CriarProjeto.md
B3_ExcluirProjeto.md
B4_ExcluirTarefa.md
B5_PedirDecisao_InvalidUPN.md
B6_RegistrarBloqueio.md
B7_RegistrarRisco.md
```

Screenshots go under:

```text
.planning/comms/aq09_smoke_runbook_20260520/screenshots/
```

## Decision Rules

| Evidence Outcome | Decision |
|---|---|
| 0 `ContentFiltered` / `openAIIndirectAttack` across all five in-scope P0 tests | XPIA-01 RESOLVED |
| 1 or more `ContentFiltered` / `openAIIndirectAttack` across any in-scope P0 test | XPIA-01 RECURS; escalate to Opus 4.7 for fallback strategy |
| In-scope evidence missing | XPIA-01 UNKNOWN; NO-SHIP until evidence exists |
| Legacy-only `ContentFiltered` | Accepted debt evidence; backlog item, not XPIA release gate |

## Validator

Post-execution validator:

```text
tests/Test-Aq09SmokeEvidence.ps1
```

Usage after Owner saves evidence:

```powershell
.\tests\Test-Aq09SmokeEvidence.ps1 -EvidenceDir ".planning\comms\aq09_smoke_runbook_20260520\evidence"
```

The validator scans Markdown/TXT/JSON/LOG evidence for:

```text
ContentFiltered
openAIIndirectAttack
Responsible AI restrictions
Etapa Bloqueada
```

The script emits a JSON report and fails if any in-scope P0 test is missing evidence or contains XPIA markers.

## Scope Boundary

CODEX-PA did not execute Copilot chat tests, did not publish, did not write SharePoint/Planner, did not save any topic, and did not run tenant mutation.
