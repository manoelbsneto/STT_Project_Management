Last updated: 2026-05-22 16:50:19 BRT | Codex sub-2C | XPIA review completed from local PM0 workflow response bodies and prior RCA/STUDY docs

# XPIA Risk Assessment

## Scope

Reviewed local workflow response bodies for the five PM0 flows under `Local_Repo/Assistente PMO V2/workflows/**/workflow.json`.

No workflow, action, topic, card, or tenant artifact was modified.

## Microsoft Learn Citations

Citation source: `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md`, Entry 10.

URLs accessed by B2 at `2026-05-22T15:26:11-03:00 BRT`:

- https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/generative-answers/agent-response-filtered-by-responsible-ai
- https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/authoring/error-codes

The local citation index records Microsoft Learn support for `ContentFiltered`, prompt-injection moderation, and `OpenAIndirectAttack` as indirect attack content.

## Prior PMO XPIA Findings Applied

Reviewed:

- `.planning/stop_ship/RCA_COPILOT_STUDIO_OPENAIINDIRECTATTACK_3_15_20260514.md`
- `.planning/stop_ship/STUDY_XPIA_MITIGATION_v3_16_20260514.md`

Relevant local conclusion: prior PMO evidence treated hidden action/tool context, connector outputs, structured field-value pairs, alphanumeric IDs, email addresses, and long/serialized row data as high-risk trigger surfaces for Copilot Studio XPIA false positives.

## Flow Response Risk Table

| Flow | Response shape | Risk | Reason |
|---|---|---|---|
| `AtualizarStatus` | Returns `projectId`, `rag`, percent, Status Diario item ID, project item ID, Teams card ID | `MEDIUM_HIGH` | Uses structured IDs and backend item identifiers in the bot-visible response. Teams card action also embeds user-controlled `resumo` and `proximaAcao` in flow context. |
| `AtualizarTarefa` | Returns task ID, status, `responsavel`, due date, SharePoint item ID, Planner percent | `HIGH` | Includes user/controller-provided fields and possible email/UPN in `responsavel`, plus structured IDs. |
| `CriarTarefa` | Returns task title, ProjectID, SharePoint item ID, Planner task ID, bucket status | `HIGH` | Includes user-controlled title, ProjectID, SharePoint ID, and a long Planner ID. This matches prior RCA high-risk patterns. |
| `ListarTarefas` | Returns `outputs('Normalize_Tasks_Display')`; current compose serializes `string(body('Normalize_Tasks'))` | `HIGH` | Exposes serialized task arrays containing task titles, statuses, ProjectID, and Planner task IDs. This is the strongest XPIA regression risk. |
| `ConsultarPortfolio` | Returns counts for projects and tasks | `LOW_MEDIUM` | Count-only response is lower risk, but the flow still loads up to 100 SharePoint project rows and 100 task rows into action context. |

## Specific High-Risk Findings

1. `ListarTarefas` is the highest-risk response. `Normalize_Tasks_Display` currently builds a string from `body('Normalize_Tasks')`, which serializes a task array rather than a compact count-only or sanitized list. This reintroduces the same class of SharePoint/Planner row data that prior RCA/STUDY documents identified as likely XPIA trigger material.

2. `CriarTarefa` returns user-controlled title and backend IDs. Prior study recommended status-code-only flow outputs for create paths; the current response is richer and therefore higher risk.

3. `AtualizarTarefa` may expose `responsavel` directly. If that field is a UPN/email, it matches the prior high-risk pattern of email-like data in bot-visible responses.

4. `AtualizarStatus` avoids returning `resumo`, `risco`, `bloqueio`, and `proximaAcao` in the bot response, which is good, but those user-controlled fields are still embedded in the Teams card action body and therefore remain in the flow/action context.

5. `ConsultarPortfolio` is the safest current response because it is numeric. It should still avoid dumping project/task rows in the response or topic message.

## Recommendations

For Section A AQ-09 ship-gating flows, prefer one of these mitigations before publish:

| Flow | Recommended mitigation |
|---|---|
| `AtualizarStatus` | Return a short static/status-code response plus maybe one numeric status item ID only if runtime proves no XPIA. Keep user text out of bot-visible output. |
| `AtualizarTarefa` | Do not echo `responsavel` or dates from trigger input in the bot-visible response. Return static confirmation or status code and verify details in SharePoint evidence. |
| `CriarTarefa` | Replace rich response with static/status-code output. Avoid title, ProjectID, SharePoint ID, Planner ID, and bucket in the Copilot response. |
| `ListarTarefas` | Do not serialize task arrays into the response. Use count-only output or a short sanitized list with strict item count/length cap after runtime XPIA testing. |
| `ConsultarPortfolio` | Keep count-only output; avoid project names, titles, emails, or raw SharePoint rows. |

## Evidence

| Evidence | Path |
|---|---|
| Workflow response inventory JSON | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/XPIA_REVIEW/workflow_response_inventory.json` |
| Rendered response inventory output | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/XPIA_REVIEW/workflow_response_inventory.png` |
| Text output | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/XPIA_REVIEW/evidence/` |

## Conclusion

Current local 3.16 PM0 responses are functionally richer than the prior XPIA mitigation study recommended. That improves user-visible detail but raises the probability of `ContentFiltered` / `OpenAIndirectAttack` recurrence, especially for `ListarTarefas`, `CriarTarefa`, and `AtualizarTarefa`.
