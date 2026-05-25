# T0 3.19 Runtime Fix Peer Review Request

- Requesting agent: Codex #2 Lead
- Timestamp: 2026-05-23 21:34:51 BRT
- Screenshot: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/screenshots/20260524_003451_Codex2Lead_3_19_runtime_fix_complete.png
- Tenant writes: none

## Request

Please peer review the 3.19 runtime fix package before any Owner import decision.

Package: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/package/PMO_v11_Tarefas_3_19_PM0_RUNTIME_FIX.zip
SHA256: 43A33783ABC30E7A3DC74EAED162558FBA0781AC163804F85FDC559023D514BF
Version: 3.19.0.0

## Required Review Scope

1. Confirm the package SHA above.
2. Independently rerun the 9 static gates with expected version 3.19.0.0.
3. Verify the four runtime fixes:
   - PM0_PA_Card_AtualizarStatus: item/OrigemEntrada/Value = CopilotStudio.
   - PM0_PA_Card_AtualizarStatus: project item/Percentual uses coalesce(triggerBody()?['percentual'], existing, 0).
   - PM0_PA_Card_AtualizarStatus: Status Diario item/Percentual uses coalesce(triggerBody()?['percentual'], 0).
   - PM0_PA_Card_AtualizarTarefa: item/HorasRealizadas uses coalesce(triggerBody()?['horasRealizadas'], existing, 0).
4. Confirm no empty() or length() remains against numeric trigger fields in the five PM0 card workflows.
5. Confirm solution.xml version is 3.19.0.0 and Managed is 0.

## Evidence

- Runtime audit: .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/T0_RUNTIME_DEFECT_AUDIT.md
- Static gates: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/evidence/static_gates_3_19.log
- Build manifest: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/reports/build_manifest.json
