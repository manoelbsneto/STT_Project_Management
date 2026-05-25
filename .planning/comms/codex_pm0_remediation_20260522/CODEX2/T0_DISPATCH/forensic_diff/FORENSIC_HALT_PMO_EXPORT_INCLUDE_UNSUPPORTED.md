# FORENSIC HALT - PMO EXPORT INCLUDE UNSUPPORTED

| Field | Value |
|---|---|
| Agent | Codex #2 Lead |
| Timestamp | 2026-05-23 17:50:10 BRT |
| Screenshot path | $pngRel |
| Transition | BLOCKED |
| Tenant write commands run | No |

## Halt Reason

The requested read-only PMO export command failed before producing live_3_17_export.zip because the pinned PAC CLI rejected --include canvas.

Command attempted:

`powershell
pac solution export --name PMO_v11_Tarefas --path .\.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\forensic_diff\live_3_17_export.zip --managed false --include canvas
`

PAC output reported:

`	ext
Error: An unknown argument value for --include was passed.
Values: autonumbering, calendar, customization, emailtracking, externalapplications, general, isvconfig, marketing, outlooksynchronization, relationshiproles, sales
`

Per the dispatch stop condition, a non-403 export failure requires halt rather than silently changing the requested command.

## Completed Before Halt

| Solution | Exit Code | Artifact | SHA256 |
|---|---:|---|---|
| PMO_v11_Tarefas | 1 | not produced | n/a |
| PMO_AQ07_CopilotBinding | 0 | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/live_aq07_1_0_0_2_export.zip | $(@{name=PMO_AQ07_CopilotBinding; exit_code=0; path=.planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH\forensic_diff\live_aq07_1_0_0_2_export.zip; exists=True; sha256=A7C3B9D5E85265EE6CB299468B432EBC8F1D504D93DEE2CD7B6178923F5BD793; bytes=76817; output=Connected as mbenicios@minsait.com
Connected to... ColOfertasBrasilPro

Starting Solution Export...
Solution export succeeded.}.sha256) |

## Evidence

| Type | Path |
|---|---|
| Export TXT | $exportEvidenceRel |
| Export JSON | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/evidence/20260523_20260523_204840_Codex2Lead_forensic_diff_exports.json |
| Export PNG | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/forensic_diff/screenshots/20260523_20260523_204840_Codex2Lead_forensic_diff_exports.png |
| Halt TXT | $txtRel |
| Halt JSON | $jsonRel |
| Halt PNG | $pngRel |

## Recommended Unblock

Kiro/Owner should authorize one of these read-only continuations:

1. Rerun PMO export without --include canvas, since canvas apps are solution components and the pinned PAC CLI does not accept canvas as an include setting.
2. Upgrade/use a PAC CLI version whose pac solution export --include canvas semantics are confirmed, then rerun the exact requested command.

No Gate 4A, Gate 4B, import, publish, or cleanup command was executed.
