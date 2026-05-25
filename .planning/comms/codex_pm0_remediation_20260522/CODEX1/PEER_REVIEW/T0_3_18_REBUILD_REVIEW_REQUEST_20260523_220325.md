# T0 3.18 Rebuild Peer Review Request

- Requester: Codex #2 Lead
- Timestamp: 2026-05-23 19:03:25 BRT
- Scope: Local-only 3.18 rebuild; no tenant write performed
- Owner ratification: 2026-05-23 18:40 BRT approved overriding live 3.17 input stubs with 3.16 functional bindings

## Package

- Path: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/package/PMO_v11_Tarefas_3_18_PM0_FUNCTIONAL_FIX.zip
- SHA256: 270F569A0D34CB596115B8776A8354F88F184F1D2F772755416175A80D0A12FD
- Version: 3.18.0.0
- Baseline: live 3.17 Owner export
- Live-only addition PM0_PA_OpsFailureHandling preserved: yes
- Managed flag: 0 in solution.xml

## Build Notes

- Applied 3.16 PM0 functional bindings for 5 PM0 card workflows, 4 PM0 action data files, 4 PM0 topic data files, and portfolio metadata per Codex #1 recipe.
- Reconciled solution.xml, customizations.xml, and Assets/botcomponent_workflowset.xml from live 3.17 plus the 5 PM0 card workflow definitions/root components.
- Restored PMO_PA_CriarProjeto action data from 3.16 fix to preserve Embedded connection mode required by the repository P24 publish-binding contract.
- Removed unused gstf_sharepoint connection reference during XML reconciliation to satisfy the existing stop-ship contract.

## Static Gates

All 9 gates passed:

- Test-SolutionXmlSchemaValidity.ps1
- PM0 placeholder scan
- Test-Pm0WorkflowResponseSemantics.ps1
- Test-Pm0TopicActionFlowContract.ps1
- Test-PMOFlowStopShipAudit.ps1
- Test-SolutionZipP0Contracts.ps1
- Test-SolutionZipP24Contracts.ps1 -ExpectedVersion 3.18.0.0
- Test-CopilotRoutingInstructions.ps1
- Test-CopilotPowerFxRegexSafety.ps1

## Evidence Index

- Final gates TXT: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/evidence/20260523_20260523_215927_Codex2Lead_3_18_static_gates_final.txt
- Final gates JSON: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/evidence/20260523_20260523_215927_Codex2Lead_3_18_static_gates_final.json
- Final gates screenshot: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/screenshots/20260523_20260523_215927_Codex2Lead_3_18_static_gates_final.png
- Package inventory: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/reports/package_inventory.md
- 3.18 vs 3.17 diff: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/reports/diff_3_18_vs_3_17.md
- Build manifest: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/reports/build_manifest.json
- CriarProjeto Embedded patch evidence: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_18/evidence/20260523_20260523_215535_Codex2Lead_3_18_criarprojeto_embedded_patch.txt

## Review Requested

Please independently rerun the 9 static gates, verify the per-file recipe, confirm solution.xml Version=3.18.0.0 and Managed=0, then update the Gate 4A ASK with the SHA above if PASS.
