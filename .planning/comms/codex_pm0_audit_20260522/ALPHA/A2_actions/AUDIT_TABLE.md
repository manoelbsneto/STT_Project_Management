# Alpha A2 Action Contract Audit Table

## Scope

This table consolidates the five local action audits requested for:

- `PM0_PA_Card_AtualizarStatus`
- `PM0_PA_Card_AtualizarTarefa`
- `PM0_PA_Card_ResumoExecutivoPortfolio`
- `PM0_PA_Card_CriarTarefa`
- `PM0_PA_Card_ListarTarefas`

All workflow trigger schemas below were derived directly from the matching local `workflow.json` files. No A1 report dependency was used.

## Consolidated Findings

| Action | Matching workflow trigger evidence | Action `inputs:` block | Required workflow trigger fields | Required fields not declared by action | Output `result` declaration | Headline finding |
|---|---|---|---|---|---|---|
| `PM0_PA_Card_AtualizarStatus` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarStatus-1721e0a3-a250-f111-bec7-000d3abc5cc6/workflow.json:30-56` | Missing | `routeKey` | `routeKey` | Present and response schema-aligned | Required `routeKey` mapping absent |
| `PM0_PA_Card_AtualizarTarefa` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarTarefa-7c6300c2-a250-f111-bec7-000d3abc5cc6/workflow.json:42-81` | Missing | `action` | `action` | Present and response schema-aligned | Required `action` mapping absent |
| `PM0_PA_Card_ResumoExecutivoPortfolio` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333bd91-a250-f111-bec7-000d3abc5cc6/workflow.json:27-39` | Missing | None | None | Present and response schema-aligned | Missing action `inputs:` block does not omit a required workflow trigger field |
| `PM0_PA_Card_CriarTarefa` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_CriarTarefa-7f662db7-a250-f111-bec7-000d3abc5cc6/workflow.json:42-94` | Missing | `projectId`, `action` | `projectId`, `action` | Present and response schema-aligned | Two required trigger mappings absent |
| `PM0_PA_Card_ListarTarefas` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json:36-63` | Missing | `action`, `projectId` | `action`, `projectId` | Present and response schema-aligned | Two required trigger mappings absent |

## Cross-Cut Summary

1. All five audited action YAML files are exported `kind: TaskDialog` actions that invoke their matching flow IDs and declare one output property, `result`.
2. All five audited action YAML files omit a top-level `inputs:` block.
3. Four of five matching workflow triggers require at least one request body field that the action YAML does not declare.
4. `PM0_PA_Card_ResumoExecutivoPortfolio` is the only audited action whose matching workflow trigger has no required request body fields.
5. The action output declaration alone does not validate the input side of a flow contract.

## Microsoft Learn Basis

Official Microsoft Learn says agent flow inputs are defined on the "When an agent calls the flow" trigger, outputs are defined on the "Respond to the agent" action, and the flow input parameter is set on the action node that calls the flow. It also documents a Copilot Studio error condition for a flow parameter missing in the "Call Flow" action.  
URL: https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output  
URL: https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/authoring/error-codes  
Accessed: `2026-05-22 15:24:16 -03:00`

Microsoft Learn shows a Copilot Studio tool definition using `dialog.kind: TaskDialog`, an `action.kind`, and input and response schema metadata for a task action. The Microsoft Learn pages located for this audit do not publish a dedicated exported `.mcs.yml` schema reference for `InvokeFlowTaskAction` fields such as local `ManualTaskInput.propertyName` and `value`; field-presence checks for those exported local YAML names are kept as local evidence in the per-action reports.  
URL: https://learn.microsoft.com/en-ie/microsoft-copilot-studio/authoring-send-event-activities  
Accessed: `2026-05-22 15:24:16 -03:00`
