# B2 Microsoft Learn Citation Index

Last updated: 2026-05-22T15:26:16-03:00 BRT | Codex #2 B2 | Initial Microsoft Learn evidence index

Scope: citation evidence for Microsoft product-behavior claims needed by the 2026-05-22 PM0 SEV-0 audit. Only `learn.microsoft.com` pages are used. The raw HTML snapshots below were fetched with `Invoke-WebRequest` on 2026-05-22 BRT.

## Evidence Rules

- `Supported` means the stated audit claim is directly supported by an official Microsoft Learn page listed in that entry.
- `Partial` means Learn supports the runtime/UI behavior but does not document an exact exported YAML or workflow-definition key requested by the audit.
- `CITATION_PENDING` means no official Learn page was located for the exact requested key or command during this pass. The index does not substitute local exports, blogs, Q&A, GitHub, or memory for those exact claims.
- Accessed timestamp for every source in this first pass: `2026-05-22T15:26:11-03:00 BRT`.

## Entry 01 - Copilot Studio flow action protocol and Skills metadata

Status: `Partial`

Claim supported:

- A flow used as a Copilot Studio agent action must use the agent-call trigger, return through the agent response action in real time, and return within the documented action window.
- Copilot Studio can map a flow trigger input to an action-node variable and surface a response output variable back into the topic.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent | `raw/copilot_flow_modify_use_with_agent_20260522_152611_BRT.html` | "`When an agent calls the flow`" and "`Respond to the agent`" |
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output | `raw/copilot_flow_input_output_20260522_152611_BRT.html` | "`String_Input`" maps from a topic variable; "`String_Output`" is inserted back into the topic. |

Boundary:

- `CITATION_PENDING`: the exact exported Power Automate workflow-definition metadata `kind: Skills` was not located in Microsoft Learn.
- Attempt evidence: `raw/pending_kind_skills_learn_search_20260522_152611_BRT.html`.

## Entry 02 - Copilot Studio TaskDialog InvokeFlowTaskAction export schema

Status: `CITATION_PENDING`

Claim requested but not asserted:

- Exact exported Copilot Studio YAML keys `kind: TaskDialog`, `inputs:`, `outputs:`, `action.kind: InvokeFlowTaskAction`, `flowId`, and `connectionProperties`.

Sources checked:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/topics-code-editor | `raw/copilot_topics_code_editor_20260522_152611_BRT.html` | Topic YAML is generated and can be edited in the code editor. |

Pending attempt:

- Learn search attempt at `2026-05-22T15:26:11-03:00 BRT`: `raw/pending_taskdialog_learn_search_20260522_152611_BRT.html`.
- The code-editor page supports use of generated topic YAML and mentions flow-ID edits, but it is not a schema reference for the requested export keys.

## Entry 03 - BeginDialog input Power Fx mapping syntax

Status: `Partial`

Claim supported:

- Copilot Studio topic YAML uses a `beginDialog` block.
- Power Fx references topic-scoped variables with the `Topic.` prefix and formulas are written with a leading `=` in Learn topic YAML examples.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/topics-code-editor | `raw/copilot_topics_code_editor_20260522_152611_BRT.html` | YAML example contains `beginDialog` and `userInput: =System.Activity.Text`. |
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-power-fx | `raw/copilot_power_fx_20260522_152611_BRT.html` | Topic variables use the `Topic.` prefix. |

Boundary:

- `CITATION_PENDING`: the exact `BeginDialog input:` mapping shape requested for passing topic variables into an action was not located in Learn.
- Attempt evidence: `raw/pending_begindialog_input_learn_search_20260522_152611_BRT.html`.

## Entry 04 - Power Automate Copilot trigger inputs and schema validation

Status: `Partial`

Claim supported:

- Copilot Studio agent flows have documented supported primitive input and output parameter types.
- A flow action can fail when the flow input/output schema no longer matches the agent, and null or missing inputs can trigger the documented bad-request error.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output | `raw/copilot_flow_input_output_20260522_152611_BRT.html` | Supported flow parameter types include Number, String, Boolean. |
| https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/channels/agent-flow-action-bad-request | `raw/copilot_flow_schema_mismatch_20260522_152611_BRT.html` | "`schema mismatch`"; null or missing inputs can trigger the error. |

Boundary:

- `CITATION_PENDING`: Learn evidence was not found for an exported Request trigger property named `kind: Skills`, or for an exact exported-schema rule that labels those request inputs required versus optional.
- Attempt evidence: `raw/pending_kind_skills_learn_search_20260522_152611_BRT.html`.

## Entry 05 - Power Automate response action and Copilot outputs

Status: `Supported`

Claim supported:

- The response action is part of the required agent-flow contract.
- When used on multiple flow branches, response action usages must expose the same outputs.
- Flow response outputs are surfaced for use in the Copilot Studio topic action path.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent | `raw/copilot_flow_modify_use_with_agent_20260522_152611_BRT.html` | Response uses the same outputs at each branch usage. |
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output | `raw/copilot_flow_input_output_20260522_152611_BRT.html` | Add the response output and use it in the topic message. |

## Entry 06 - SharePoint Standard connector item operations

Status: `Supported`

Claim supported:

- The SharePoint connector is a Standard connector for Power Automate and documents list item read/create/update operations.
- For the requested item operations, Learn names operation IDs `GetItems`, `PostItem`, and `PatchItem`.
- The documented item parameters use `dataset` for Site Address and `table` for List Name.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/connectors/sharepoint/ | `raw/sharepoint_connector_20260522_152611_BRT.html` | `GetItems`, `PostItem`, `PatchItem`; Site Address key `dataset`; List Name key `table`. |

## Entry 07 - Teams Standard connector card posting

Status: `Supported`

Claim supported:

- The Teams connector documents `PostCardToConversation` for posting a card in a chat or channel.
- Its documented required action parameters are post-as, post-in, and a dynamic post-card request body.
- Learn documents an approximately 28 KB size limit for Teams connector message/card posting actions.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/connectors/teams/ | `raw/teams_connector_20260522_152611_BRT.html` | `PostCardToConversation`; keys `poster`, `location`, `body`. |

## Entry 08 - Planner Standard connector task operations

Status: `Supported`

Claim supported:

- The Planner connector documents requested task operation IDs `CreateTask_V3`, `UpdateTask_V2`, and `ListTasks_V3`.
- Learn shows group and plan inputs for create/list operations and bucket placement for create-task.
- The connector notes that Group Id populates dependent Plan Id dropdowns for certain actions.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/connectors/planner/ | `raw/planner_connector_20260522_152611_BRT.html` | `CreateTask_V3`, `UpdateTask_V2`, `ListTasks_V3`; Group Id, Plan Id, Bucket Id. |

## Entry 09 - Adaptive Cards in Teams version, size, and rendering guidance

Status: `Supported`

Claim supported:

- Copilot Studio Learn says Teams is limited to Adaptive Cards version 1.5.
- Teams Learn says Adaptive Card rendering/formatting can differ across desktop, mobile, and browser clients.
- Learn supports a 28 KB Teams connector action/message guardrail; the local 27 KB PMO guardrail is stricter project policy, not a Learn size ceiling.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/microsoft-copilot-studio/adaptive-cards-overview | `raw/adaptive_cards_overview_20260522_152611_BRT.html` | Teams is limited to version 1.5. |
| https://learn.microsoft.com/en-us/connectors/teams/ | `raw/teams_connector_20260522_152611_BRT.html` | Card/message action limit is approximately 28 KB. |
| https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-format | `raw/teams_card_format_20260522_152611_BRT.html` | Rendering can differ between Teams client form factors. |

## Entry 10 - ContentFiltered and OpenAIndirectAttack guidance

Status: `Supported`

Claim supported:

- `ContentFiltered` is the Copilot Studio Responsible AI filter error code documented by Learn.
- Learn says moderation policies address prompt injection and evaluate content both on input and before the response.
- Learn documents `OpenAIndirectAttack` as indirect attack content from information not directly supplied by the author or user, and gives instruction-alignment/user-guidance mitigation direction.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/generative-answers/agent-response-filtered-by-responsible-ai | `raw/responsible_ai_contentfiltered_20260522_152611_BRT.html` | `ContentFiltered`; policy also addresses prompt injection. |
| https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/authoring/error-codes | `raw/copilot_error_codes_20260522_152611_BRT.html` | `OpenAIndirectAttack`: indirect attack content was detected. |

## Entry 11 - `pac solution import`

Status: `Supported`

Claim supported:

- `pac solution import` imports a solution into Dataverse and requires connection to an environment through PAC auth.
- The CLI reference documents `--force-overwrite`, `--publish-changes`, holding import, settings-file, dependency, lower-version, and stage-upgrade import flags.
- Learn's `--force-overwrite` description is overwrite of unmanaged customizations; this is not a general rollback flag.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution | `raw/pac_solution_cli_20260522_152611_BRT.html` | `pac solution import`; `--force-overwrite`; `--publish-changes`; PAC auth remark. |

## Entry 12 - Functional testing and monitoring of flows

Status: `Partial`

Claim supported:

- Microsoft Power Automate documentation includes explicit cloud-flow testing guidance that triggers a saved flow and observes the result.
- Monitoring guidance says flow runs, triggers, and actions are telemetry and that each cloud-flow execution can be recorded in Dataverse `FlowRun` with times, status, and errors.

Sources:

| URL | Raw HTML | Brief relevant excerpt |
|---|---|---|
| https://learn.microsoft.com/en-us/power-automate/get-started-logic-flow | `raw/power_automate_cloud_flow_test_20260522_152611_BRT.html` | `Test your flow` triggers the saved cloud flow. |
| https://learn.microsoft.com/en-us/power-automate/guidance/coding-guidelines/monitoring-and-alerting | `raw/power_automate_monitoring_20260522_152611_BRT.html` | `FlowRun` includes status and detailed error messages. |

Boundary:

- `CITATION_PENDING`: this pass found no Microsoft Learn Power Platform CLI reference for a `pac flow run` command. The CLI search results surfaced CLI reference groups such as `solution` and `test`, not a documented `flow run` command.

## Pending Citation Register

| Pending exact claim | Attempt timestamp BRT | Attempt evidence |
|---|---|---|
| Power Automate exported trigger metadata `kind: Skills` | 2026-05-22T15:26:11-03:00 | `raw/pending_kind_skills_learn_search_20260522_152611_BRT.html` |
| Copilot Studio exported `TaskDialog` / `InvokeFlowTaskAction` action schema keys | 2026-05-22T15:26:11-03:00 | `raw/pending_taskdialog_learn_search_20260522_152611_BRT.html` |
| Exact `BeginDialog input:` YAML action-mapping syntax | 2026-05-22T15:26:11-03:00 | `raw/pending_begindialog_input_learn_search_20260522_152611_BRT.html` |
| Microsoft Learn CLI reference for `pac flow run` | 2026-05-22T15:29:13-03:00 | `raw/pending_pac_flow_run_learn_search_20260522_152913_BRT.html` |
