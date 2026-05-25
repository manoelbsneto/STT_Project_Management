# T0 Gate 4C AQ07 Cleanup ASK Draft

Last updated: 2026-05-23 16:33:20 BRT | Codex #1 Lead | Scaffold drafted locally after Sub 1C platform auth failure.

## Status

Draft status: SCAFFOLD ONLY. Not signature-ready until Track Gamma publishes the AQ07 dependency tree audit and AQ-09 Section A passes after Gate 4B.

Gate 4C is irreversible cleanup work and requires explicit per-step Owner approval. The 4A/4B standing authorization does not cover 4C.

## Gate Summary

| Field | Value |
|---|---|
| Gate | 4C - AQ07 cleanup |
| Target transition solution | `PMO_AQ07_CopilotBinding` |
| Target environment | `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) |
| Required prior gates | Gate 4A import PASS, Gate 4B publish PASS, AQ-09 Section A A1-A5 PASS |
| Required dependency map | `.planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/T0_AQ07_DEPENDENCY_TREE_AUDIT.md` |
| Components to remove | `<<TODO_BACKFILL: component list pending Track Gamma dependency map (depends on: .planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/T0_AQ07_DEPENDENCY_TREE_AUDIT.md)>>` |
| Dependency graph reference | `<<TODO_BACKFILL: dependency graph reference pending Track Gamma dependency map (depends on: .planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/T0_AQ07_DEPENDENCY_TREE_AUDIT.md)>>` |

## Preconditions

- Gate 4A imported 3.16 package and read-back/SHA evidence matched.
- Gate 4B published `Assistente PMO V2`; PAC list showed `Published / Active / Provisioned`.
- AQ-09 Section A runtime smoke A1-A5 passed with evidence triplets.
- T+5min and T+1h drift monitor evidence is PASS.
- Track Gamma dependency audit confirms cleanup is safe.
- Owner gives explicit per-step approval for each cleanup action.

## Stop Conditions

Stop and do not request execution if any of these are true:

- Track Gamma finds dual ownership between `PMO_AQ07_CopilotBinding` and `PMO_v11_Tarefas` for live PM0 runtime components.
- Any `PMO_AQ07_CopilotBinding` component is still required by the published `Assistente PMO V2` runtime.
- AQ-09 Section A has not passed after Gate 4B.
- Owner approval is broad, ambiguous, or missing for a specific cleanup step.
- The cleanup command would physically delete unique live dependencies without a current backup and dependency graph.

## Cleanup Command Placeholder

Final command must be selected only after Track Gamma identifies the safe cleanup method. Candidate command shapes are:

```powershell
# Whole transition solution removal, only if Track Gamma proves no unique live dependencies.
pac solution delete `
  --solution-name PMO_AQ07_CopilotBinding `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

or a maker-portal/component-specific removal path if Track Gamma finds unique non-PM0 dependencies that must remain.

Official Microsoft PAC solution reference: `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution`

## Post-Cleanup Re-Verification Commands

Run AQ-09 A1-A5 evidence workflow after cleanup:

```powershell
# Evidence stubs and exact chat inputs are owned by Track E.
# Execute each AQ-09 Section A scenario in Copilot Studio/Teams and capture evidence triplets.
```

Run local/static guards after post-cleanup export is available:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\Test-CopilotRoutingInstructions.ps1" -PackagePath "<post_cleanup_export.zip>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\Test-CopilotPowerFxRegexSafety.ps1" -PackagePath "<post_cleanup_export.zip>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\Test-SolutionXmlSchemaValidity.ps1" -Path "<post_cleanup_export.zip>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\Test-SolutionZipP0Contracts.ps1" -PackagePath "<post_cleanup_export.zip>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\Test-SolutionZipP24Contracts.ps1" -PackagePath "<post_cleanup_export.zip>" -ExpectedVersion "3.16.0.0"
```

## Evidence Requirements

Every Gate 4C evidence entry must include:

- Agent name.
- Timestamp BRT in `YYYY-MM-DD HH:MM:SS BRT`.
- Screenshot path to a `.png`.
- Owner approval text for the exact cleanup step.
- Dependency graph reference.
- Cleanup command transcript or UI screenshot.
- Post-cleanup `pac copilot list` and AQ-09 A1-A5 evidence triplets.

## ASK Text

Do not use this ASK yet. After Track Gamma dependency audit, Gate 4B publish, AQ-09 Section A PASS, and drift monitor PASS, request explicit Owner approval to remove only the Track-Gamma-approved `PMO_AQ07_CopilotBinding` components listed in the dependency graph, then re-run AQ-09 A1-A5 and static guards before any SHIP wording.

## Backfill Manifest

| Placeholder | Upstream evidence | Responsible agent | Trigger |
|---|---|---|---|
| `<<TODO_BACKFILL: component list pending Track Gamma dependency map (depends on: .planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/T0_AQ07_DEPENDENCY_TREE_AUDIT.md)>>` | Track Gamma AQ07 dependency tree audit | Opus 4.6 + Codex #1 Lead | Gamma audit published |
| `<<TODO_BACKFILL: dependency graph reference pending Track Gamma dependency map (depends on: .planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/T0_AQ07_DEPENDENCY_TREE_AUDIT.md)>>` | Track Gamma AQ07 dependency tree audit | Opus 4.6 + Codex #1 Lead | Gamma audit published |
