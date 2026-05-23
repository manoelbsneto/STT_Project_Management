# Gemini-PA Track G — AQ-09 SharePoint Side-Effect Verification Harness

Date BRT: 2026-05-21T10:57:00-03:00
Owner: Manoel Benicio
Author: Opus 4.7
Target: Gemini-PA
Estimated: 90 min, fully parallel
Severity: HIGH (defensive — accelerates AQ-09 smoke and post-publish verification)

## Mandatory References

| Reference | Purpose |
|---|---|
| `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md` | The 5 in-scope tests and their expected SharePoint side effects. |
| `.planning/comms/aq09_smoke_runbook_20260520/EVIDENCE_TEMPLATE.md` | Stub schema. Harness output must populate the `pnp_output_path` and `actual` SharePoint side-effect fields. |
| `docs/SCHEMA_SHAREPOINT_PMO.md` | The 5 SharePoint list schemas (Projetos, Tarefas, Status Diario, Riscos e Bloqueios, Decisoes do Board). |
| `.planning/cleanup/sharepoint_deleted_flag_log_20260510_105318.md` | Deleted=1 logical-delete convention; harness must filter `Deleted ne 1` everywhere. |

## Mission

Build a read-only PowerShell harness `tests/Test-Aq09SharePointSideEffects.ps1` that, given a smoke-run timestamp window (start, end), queries the five SharePoint lists via PnP and produces a structured JSON report mapping each in-scope test (A1-A5) to its expected and observed side effects. Owner runs this once after the AQ-09 smoke chat session and copy-pastes the resulting `pnp_output_path` reference into each evidence stub.

## Functional Requirements

### Inputs

```powershell
.\tests\Test-Aq09SharePointSideEffects.ps1 `
    -SmokeStartUtc "2026-05-21T18:00:00Z" `
    -SmokeEndUtc   "2026-05-21T20:00:00Z" `
    -OutputDir     ".planning\comms\aq09_smoke_runbook_20260520\sp_side_effects\<YYYYMMDD-HHMM>" `
    -ProjectScope  "QA Robust 20260513 F"
```

### Per-test checks

| Test | Expected SP side effect | Required output |
|---|---|---|
| A1 ListarTarefas | None (read-only). Verify project exists and has at least 1 task. | Project row dict; task count for project; first 5 tasks (Title, Responsavel, Prazo, Status). |
| A2 ConsultarPortfolio | None (read-only). Verify portfolio query baseline. | Active project count (`Deleted ne 1`); 10 most recent projects. |
| A3 CriarTarefa | Exactly one new Tarefas row in the smoke window for the scope project, Title ~= "QA CriarTarefa Smoke 315 20260520". | Matched row dict OR `NO_MATCH`; expected vs actual field values (Titulo, Responsavel, Prazo, Horas, Prioridade, Deleted). |
| A4 AtualizarTarefa | Tarefas row ItemId=15 modified in window. Optional fields preserved (Responsavel, Prazo, Horas), Status changed to "Em andamento". | Row dict before-modified flag (we cannot read history; rely on current values vs expected); explicit per-optional-field "preserved" check (Responsavel, Prazo, Horas non-blank). |
| A5 AtualizarStatus | Exactly one new Status Diario row in window for the scope project, status=Amarelo, percentual=45. | Matched row dict OR `NO_MATCH`; expected vs actual values. |

### Output structure

Single JSON report at `<OutputDir>/aq09_sp_side_effects_report.json`:

```json
{
  "generatedAt": "<ISO-8601 BRT>",
  "smokeWindow": { "startUtc": "...", "endUtc": "..." },
  "projectScope": "QA Robust 20260513 F",
  "lists": {
    "Projetos": { "totalActive": <int>, "sampleRows": [...] },
    "Tarefas": { "rowsInWindow": [...] },
    "StatusDiario": { "rowsInWindow": [...] },
    "RiscosBloqueios": { "rowsInWindow": [...] },
    "DecisoesBoard": { "rowsInWindow": [...] }
  },
  "tests": {
    "A1_CMD-12-H": { "status": "PASS|FAIL|NO_DATA", "details": "...", "evidence": {...} },
    ...
  },
  "decision": "PASS_ALL|MIXED|FAIL_ALL"
}
```

Per-list raw output also saved as `<list_name>_rows_in_window.json` for evidence trail.

### Hard requirements

- Read-only PnP. Never call `Set-PnPListItem`, `Add-PnPListItem`, `Remove-PnPListItem`, or any `Update-PnP*`.
- All list queries MUST include `Deleted ne 1` filter.
- All datetime comparisons use UTC; convert to BRT for display only.
- If PnP authentication fails or env mismatched (env != `ColOfertasBrasilPro`), fail fast with clear error.
- Must run idempotently — repeated invocations produce the same report for the same input window.
- Output JSON MUST be UTF-8 without BOM.

## Out of Scope

- Reading bot chat transcripts (Owner's manual paste step).
- Updating registry rows.
- Modifying any AQ-09 evidence stub. The harness produces the JSON; Owner pastes the path into stubs.
- Power Automate run URLs (separate flow-history harness).

## Deliverables

1. `tests/Test-Aq09SharePointSideEffects.ps1` (the harness).
2. `.planning/comms/aq09_sp_side_effects_harness_20260521/HARNESS_README.md` — usage, examples, input/output contract.
3. `.planning/comms/aq09_sp_side_effects_harness_20260521/sample_outputs/` — one dry-run report against current SharePoint state for each test scenario (use mock window 2026-05-21T00:00 to 2026-05-21T11:00 UTC). Confirms harness works without smoke run yet.
4. Append a one-line entry to AQ-09 runbook noting the harness availability.

## Hard Prohibitions

No tenant writes. No PnP write subcommands. No Copilot Studio UI. No SharePoint UI changes. No solution import. No git commit.

## Acceptance

Harness usable when:
1. Script exits 0 against current SP state for the dry-run window.
2. Sample outputs cover all 5 in-scope tests with explicit `NO_DATA` for tests where smoke has not been run yet.
3. README documents the exact invocation Owner will use after AQ-09 smoke.

End of dispatch.
