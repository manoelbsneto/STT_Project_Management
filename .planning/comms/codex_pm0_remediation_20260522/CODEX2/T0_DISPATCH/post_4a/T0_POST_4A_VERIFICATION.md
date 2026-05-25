# T0 Post-4A Verification

| Field | Value |
|---|---|
| Agent | Codex #2 Lead |
| Timestamp BRT | 2026-05-23 19:47:18 BRT |
| Tenant write commands | None by Codex #2 |
| Export path | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/post_import_3_18_export.zip |
| Expected package SHA256 | 270F569A0D34CB596115B8776A8354F88F184F1D2F772755416175A80D0A12FD |
| Post-import export SHA256 | 66F81669BEA3035728ECE22E7BBBB146FE92721558C3EDECEE30444398F9D8D8 |
| Classification | FAIL |
| Final verdict | HOLD |
| Screenshot path | .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/screenshots/20260523_20260523_224718_Codex2Lead_post_4a_verification_fail.png |

## SHA Comparison

- Result: FAIL
- Byte-identical: no
- Structural-equivalent path: failed because manifest and PM0 file checks do not match expected 3.18 state.

## solution.xml Manifest Confirmation

| Field | Expected | Actual | Result |
|---|---|---|---|
| UniqueName | PMO_v11_Tarefas | PMO_v11_Tarefas | PASS |
| Version | 3.18.0.0 | 3.17 | FAIL |
| Managed | 0 | 0 | PASS |

## Structural Checks

| Check | Expected | Actual | Result |
|---|---:|---:|---|
| PM0 workflow JSON files | 5 | 0 | FAIL |
| PM0 action component dirs | 5 | 5 | PASS |
| PM0 action data files with ManualTaskInput | 5 | 0 | FAIL |
| PM0 topic data files with input.binding | 5 | 0 | FAIL |
| OpsFailureHandling preserved | 1 | 1 | PASS |

## AQ-08 Reverify Result

Not run. Verification halted before downstream AQ-08 because exported tenant state is still PMO_v11_Tarefas version 3.17 and structurally lacks the 3.18 PM0 workflow files.

## pac copilot list Output

Not run. Verification halted before Gate 4B readiness checks because post-import solution verification failed.

## pac flow list Output

Not run. Verification halted before flow readiness checks because post-import solution verification failed.

## Read-Only Evidence

- PAC export log: .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/evidence/20260523_20260523_224437_Codex2Lead_post_4a_pac_solution_export.txt
- PAC env who: .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/evidence/20260523_20260523_224550_pac_env_who_post_4a.txt
- PAC solution list: .planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/post_4a/evidence/20260523_20260523_224550_pac_solution_list_post_4a.txt

## Final Verdict

HOLD. Do not proceed to Gate 4B. Current PAC-visible tenant solution remains PMO_v11_Tarefas 3.17, not 3.18.0.0.
