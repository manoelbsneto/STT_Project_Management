# CriarTarefa Risk Register

| ID | Severity | Risk | Status | Mitigation / Proof |
|---|---:|---|---|---|
| R-001 | P0 | CriarTarefa intent routes to LowConfidence. | Closed. | Regression harness fails old extract and passes fresh live extract. |
| R-002 | P0 | Copilot Studio rejects CriarTarefa topic output binding `result`. | Closed. | Live no-output Dataverse proof shows CriarTarefa has no topic `output:` binding and no `Topic.message`; action/flow can still expose `result`. |
| R-003 | P1 | `pac copilot publish` reports stale failure despite bot list showing Published. | Closed with runbook substitute evidence. | `pac solution import --publish-changes`, `pac copilot list`, fresh extract, and raw Dataverse fetch prove active clean components. |
| R-004 | P1 | Repo template drifts from live bot. | Mitigated. | `deploy/copilot/AssistentePMO.template.yaml` now contains action component and action-calling topic; regression passes. |
| R-005 | P1 | Sequential ProjectID generation can race under concurrent creates. | Accepted residual risk outside routing hotfix. | Track in next data-integrity phase. |
| R-006 | P2 | Raw `prazo` and `Prioridade` input can violate SharePoint schema choices/date expectations. | Accepted residual risk outside routing hotfix. | Track in next data-validation phase. |
