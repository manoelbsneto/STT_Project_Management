# Session 20 Premium Feature Audit

Date: 2026-05-10
Bot checked in UI: `Assistente PMO Clean`

## UI Finding

Copilot Studio shows:

- Warning: `This agent uses premium features. You'll need an upgraded license to publish it.`
- Category: `Licensing`
- Source: `Premium Features`
- Topic Checker: no topic issues reported by user.

Conclusion: this is a licensing/configuration issue, not a YAML topic syntax issue.

## Local Package Evidence

Audited package folder:

- `.planning/comms/solution_patch_v2_zip_verify_20260510_2145`

Final imported package:

- `Solution/PMO_v11_Tarefas_1_1_0_2_SESSION20_PATCHED_V2.zip`

### Premium / Preview Candidates Found

| Candidate | Evidence path | Why it is suspect |
|---|---|---|
| Work IQ Copilot MCP Preview | `.planning/comms/solution_patch_v2_zip_verify_20260510_2145/botcomponents/pmo_AssistentePMO_Clean.topic.WorkIQCopilotPreview/data` | Uses `InvokeExternalAgentTaskAction`, `ModelContextProtocolMetadata`, and connection reference to `shared_a365copilotchatmcp`. |
| Work IQ User MCP Preview | `.planning/comms/solution_patch_v2_zip_verify_20260510_2145/botcomponents/pmo_AssistentePMO_Clean.topic.WorkIQUserPreview/data` | Uses `InvokeExternalAgentTaskAction`, `ModelContextProtocolMetadata`, and connection reference to `shared_a365memcp`. |
| Work IQ Copilot MCP Preview on V2 | `.planning/comms/solution_patch_v2_zip_verify_20260510_2145/botcomponents/pmo_AssistentePMO_V2.action.WorkIQCopilotPreview/data` | Same Work IQ MCP pattern exists on V2. |
| Work IQ User MCP Preview on V2 | `.planning/comms/solution_patch_v2_zip_verify_20260510_2145/botcomponents/pmo_AssistentePMO_V2.action.WorkIQUserPreview/data` | Same Work IQ MCP pattern exists on V2. |
| Work IQ connection references | `.planning/comms/solution_patch_v2_zip_verify_20260510_2145/customizations.xml` | Contains `shared_a365copilotchatmcp` and `shared_a365memcp` connection references. |
| GPT-5 Chat on active Clean bot | `.planning/comms/solution_patch_v2_zip_verify_20260510_2145/botcomponents/pmo_AssistentePMO_Clean.gpt.default/data` | `modelNameHint: GPT5Chat`; project rule requires GPT-4.1 and no GPT-5 Chat. |
| Generative orchestration settings | `.planning/comms/solution_patch_v2_zip_verify_20260510_2145/bots/pmo_AssistentePMO_Clean/configuration.json` and `.../pmo_AssistentePMO_V2/configuration.json` | `GenerativeActionsEnabled: true` and recognizer `$kind: GenerativeAIRecognizer`; older validated template uses `GenerativeActionsEnabled: false`. |

### Standard / Expected Items

These were not identified as premium blockers in the Session 20 target flows:

- `shared_sharepointonline`
- Agent flow trigger/actions used by `PMO_PA_ConsultarPortfolio`, `PMO_PA_ConsultarProjeto`, `PMO_PA_RegistrarRiscoBot`, `PMO_PA_RegistrarBloqueioBot`, `PMO_PA_PedirDecisaoBot`, `PMO_PA_AtualizarStatus`

## Microsoft Documentation Basis

- Microsoft documents Copilot Credits and billed feature categories for Copilot Studio, including agent actions, agent flow actions, generative answers, tenant graph grounding, and text/generative AI tools.
- Microsoft documents Work IQ MCP as a preview feature and says a Microsoft 365 Copilot license is required to use Work IQ MCP servers.
- Microsoft documents GPT-4.1 as the default public model and classifies Claude Opus 4.6 as a `Deep` model; deep/reasoning models carry higher cost/risk and are not aligned with this project's no-premium constraint.

## Recommended No-Premium Remediation

Do not change B1-B6 topic YAML logic or target SharePoint flows.

Low-blast-radius cleanup:

1. Remove Work IQ MCP Preview components from both agents:
   - `pmo_AssistentePMO_Clean.topic.WorkIQCopilotPreview`
   - `pmo_AssistentePMO_Clean.topic.WorkIQUserPreview`
   - `pmo_AssistentePMO_V2.action.WorkIQCopilotPreview`
   - `pmo_AssistentePMO_V2.action.WorkIQUserPreview`

2. Remove corresponding connection references:
   - `shared_a365copilotchatmcp`
   - `shared_a365memcp`

3. Set active Clean GPT model back to GPT-4.1:
   - replace `modelNameHint: GPT5Chat` with `modelNameHint: GPT41`

4. Disable generative orchestration if UI warning remains:
   - set `GenerativeActionsEnabled: false`
   - align with validated `deploy/copilot/AssistentePMO.template.yaml`

5. Reimport no-premium package over the existing unmanaged solution.

6. Reopen Copilot Studio, confirm:
   - Topic Checker green
   - Premium warning gone
   - Publish available

## Stop Condition

If removing Work IQ and reverting GPT-4.1 does not clear the premium warning, stop and capture the Copilot Studio warning details before removing any additional component.
