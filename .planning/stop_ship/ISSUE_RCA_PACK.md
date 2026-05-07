# ISSUE RCA PACK

## ISSUE-001 - PMO_PA_CriarTarefa invalid date padding expression

Severity: SEV-0

Impact: `PMO_PA_CriarTarefa` failed before SharePoint lookup/write. Bot cannot create a task/project.

Timeline:
- Detected in manual Power Automate run screenshot: `Compose_DataAlvo` failed.
- Error: `The template function 'padLeft' is not defined or not valid.`
- Fix implemented and imported before Stop-Ship reset: replaced `padLeft()` with supported `if/length/concat` expression.
- Verification: exported solution after import no longer contains `padLeft`.

Root cause:
- Flow used an unsupported Power Automate template function in `Compose_DataAlvo`.

Contributing factors:
- No direct flow regression test existed.
- Bot testing was attempted before proving the Power Automate flow independently.

Corrective action:
- Code fix: `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_src/Workflows/PMO_PA_CriarTarefa-71F62DA4-9748-F111-BEC7-6045BDF42CAE.json`
- Imported package: `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_20260506.zip`

Prevention:
- Add direct manual/automated flow test for `prazo=30/06/2026` and `prazo=2026-06-30`.

## ISSUE-002 - PMO_PA_CriarTarefa invalid SharePoint DateTime OData filter

Severity: SEV-0

Impact: `Get_Duplicate_Projects` fails with SharePoint BadRequest: string not recognized as valid DateTime.

Timeline:
- Detected in manual Power Automate run screenshot after ISSUE-001 fix.
- Failed action: `Get_Duplicate_Projects`.
- Current exported evidence before fix: `.planning/canonical/PMO_v11_Tarefas_VERIFY_FLOW_FIX_20260506_072447/Workflows/PMO_PA_CriarTarefa-71F62DA4-9748-F111-BEC7-6045BDF42CAE.json:101`
- Draft local fix prepared but not imported under Stop-Ship rule.

Root cause:
- OData filter compares SharePoint DateTime column `DataAlvo` using `DataAlvo eq 'yyyy-MM-dd'`, causing SharePoint to reject the date.

Proposed corrective action:
- Use a one-day DateTime range:
  `DataAlvo ge datetime'yyyy-MM-ddT00:00:00Z' and DataAlvo lt datetime'next-dayT00:00:00Z'`

Prevention:
- Regression test duplicate lookup path with `prazo=30/06/2026`.

## ISSUE-003 - PMO_PA_AtualizarTarefa unsafe project lookup

Severity: HIGH

Impact: Task update can succeed but project counter update can fail if `Get_Projeto_Item` returns zero rows.

Evidence:
- `.planning/canonical/PMO_v11_Tarefas_VERIFY_FLOW_FIX_20260506_072447/Workflows/PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json:276`
- Uses `first(body('Get_Projeto_Item')?['value'])` without a prior length guard.

Status: not reproduced manually yet.

## ISSUE-004 - PMO_PA_CheckInOnDemand unsafe project lookup / Teams dependency

Severity: HIGH

Impact: Flow may post a check-in card for a missing project or fail on Teams channel permissions.

Evidence:
- `.planning/canonical/PMO_v11_Tarefas_VERIFY_FLOW_FIX_20260506_072447/Workflows/PMO_PA_CheckInOnDemand-F5AAB85E-FF46-F111-BEC7-7CED8D955C6C.json:94`
- Uses `first(body('Get_Projeto')?['value'])` inside Teams card composition.

Status: not reproduced manually yet.

