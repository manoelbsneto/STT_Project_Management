# Test Strategy

Scope: CriarTarefa routing and action contract.

Automated regression:
- `tests/Test-CriarTarefaContract.ps1`
- Inputs: any Copilot `extract-template` YAML or repo template YAML.
- Checks: selectable intent, exact trigger phrases, fallback capability text, no stale ProjectID prompt/global, action call, output binding, action input/output contract.

Regression mapping:
- ISSUE-001: checks 1-5.
- ISSUE-002: checks 6-9.
- ISSUE-004: same checks against `deploy/copilot/AssistentePMO.template.yaml`.

Current results:
- Known-bad extract fails as expected: 7 failed checks.
- Fresh live extract passes: 9/9.
- Repo template passes: 9/9.
- Raw Dataverse fetch matches the clean contract.
- Live Power Automate flow returns `result` in success/error branches.

Not applicable / not yet available:
- Unit tests: Power Platform YAML and PAC deployment scripts are integration-contract artifacts; local unit granularity is limited.
- CI coverage: no CI definition or CI logs are present in the repo.
- Browser screenshots: not applicable to this backend Copilot routing issue.

Additional tests after SHIP:
- Manual Teams/channel transcript for user-facing acceptance.
- Optional concurrency test for ProjectID generation if project creation volume increases.
