# External Source Review: openAIIndirectAttack / ContentFiltered

Date: 2026-05-14  
Input file: `C:\Users\dataops-lab\Downloads\openAIIndirectAttack_urls.csv`  
Rows reviewed: 7  
Purpose: Validate whether external community/admin reports support the PMO cards-first architecture decision.

## 1. Source Inventory

| Source | Type | URL | Relevance |
|---|---|---|---|
| Microsoft Learn - Understand error codes | Official Microsoft | https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/authoring/error-codes#openaindirectattack | Defines `OpenAIndirectAttack` as indirect attack content detected from external/grounded data. |
| Microsoft Learn - Resolve responsible AI content filter errors | Official Microsoft | https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/generative-answers/agent-response-filtered-by-responsible-ai | Confirms dual evaluation and diagnostic path through Application Insights/transcripts. |
| Doy's Microsoft 365 & Azure Dev Blog | Community/MVP blog | https://simondoy.com/2025/11/17/tackling-contentfiltered-errors-in-copilot-agents-rethinking-copilot-agent-architecture/ | Recommends rethinking agent architecture and reducing orchestration ambiguity. |
| IIU.dk - Autonomous Agents in Copilot Studio | Community blog | https://iiu.dk/2025/09/18/copilot-studio-contentfiltered/ | Recommends lowering moderation where policy allows, isolating instructions, reviewing tool descriptions, and testing smaller chunks. |
| Reddit - Child Agent Flow Fails with Blocked Step | Community/admin discussion | https://www.reddit.com/r/copilotstudio/comments/1sdqhn4/copilot_studio_child_agent_flow_fails_with/ | Describes openAIIndirectAttack during intermediate agent communication. |
| Reddit - Content Moderation Greyed Out | Community/admin discussion | https://www.reddit.com/r/copilotstudio/comments/1sfsvxo/copilot_studio_content_moderation_level_greyed/ | Reports openAIIndirectAttack against legitimate institutional websites and lack of documented allowlist. |
| Reddit - Clarification on ContentFiltered Messages | Community discussion | https://www.reddit.com/r/copilotstudio/comments/1n6hvy4/clarification_on_contentfiltered_messages_in/ | Discusses ContentFiltered handling and moderation level experiences. |

## 2. Official Microsoft Findings

Microsoft Learn confirms:

- `OpenAIndirectAttack` is a Responsible AI block for indirect attack content.
- The source can be information not directly supplied by the agent author or user, such as external documents or grounded data.
- The blocked category includes attempts to manipulate content, exfiltrate or remove data, block system capabilities, perform fraud, or execute code.
- Content can be evaluated before the final agent response.
- Application Insights and conversation transcripts are the supported diagnostic paths.
- Application Insights requires an Azure subscription and appropriate role access.

Impact on PMO:

- Our SharePoint and Flow outputs are part of the grounded/tool data path.
- Even if the final user-visible message is static, internal tool context can still be relevant to the moderation decision.
- Because we currently do not have Application Insights access, we should design out the risky data path instead of waiting for exact KQL evidence.

## 3. Community/Admin Findings

The external reports are not official proof, but they align with our observed behavior:

- Long or complex agent/tool/intermediate data increases false-positive risk.
- Multi-agent or nested orchestration increases the number of moderation checkpoints.
- Tool descriptions and hidden/intermediate outputs can influence the decision.
- Legitimate content can still be blocked when treated as untrusted grounded data.
- No public documented allowlist exists to bypass the indirect attack filter for specific trusted domains.
- A practical workaround described by Microsoft staff in community context is to sanitize/fetch externally and pass only structured data to the agent.
- Blogs recommend lowering moderation only when policy allows, but this is a mitigation, not an architecture fix.

## 4. Implication for Adaptive Cards

The reviewed sources strengthen the cards-first recommendation.

Adaptive Cards are helpful because they let us:

- show operational data in Teams instead of Copilot chat;
- submit structured form data to Power Automate;
- keep SharePoint/Planner payloads out of the LLM response path;
- reduce free-form intermediate agent communication;
- avoid using Copilot to summarize raw rows, URLs, HTML, or JSON.

Important caveat:

Adaptive Cards do not automatically eliminate XPIA risk if their content or response payload is later sent back into Copilot as prompt/context. The mitigation works only when Power Automate handles card data deterministically and Copilot receives static acknowledgements or tiny status codes.

## 5. Impact on Implementation Plan

The source review supports these implementation choices:

1. Do not return SharePoint or Planner result sets to Copilot Studio.
2. Do not use Copilot Studio as the task list renderer.
3. Do not pass raw Planner task descriptions, SharePoint rows, URLs, or JSON to the agent.
4. Use Power Automate as the controller.
5. Use Teams Adaptive Cards as the operational UI.
6. Keep Copilot topics as thin routers.
7. Keep moderation tuning as secondary, not primary.
8. Prefer one flow/action per business operation over nested agent-to-agent orchestration.
9. Add strict schemas and status-code outputs where Copilot must receive a result.
10. Use Application Insights later if available, but do not depend on it for the immediate mitigation.

## 6. Decision Recommendation

Proceed with the Adaptive Cards + Planner architecture as the preferred v3.16+ direction.

For fastest proof, implement `ListarTarefas` first because it is the cleanest known repro and does not require writes. Once the failing command stops producing `openAIIndirectAttack`, extend the same pattern to `CriarTarefa` and `AtualizarTarefa` with Planner integration.

