# ContentFiltered Research Findings

Agent: Codex with subagents Copernicus and Kierkegaard
Timestamp BRT: 2026-05-14 14:35

## Conclusion

The 3.15 static-output mitigation is technically justified. Microsoft documents that Copilot Studio responsible AI checks can filter both input and generated responses, and related error-code guidance confirms that previous action outputs, called tools, and conversation history can be part of the model request. Therefore, SharePoint/Power Automate outputs must be minimized and sanitized before anything is exposed to Copilot text generation or post-processing.

## Official Evidence

| Finding | Source |
|---|---|
| `ContentFiltered` is the user-facing Copilot Studio Responsible AI block condition. | https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/generative-answers/agent-response-filtered-by-responsible-ai |
| `OpenAIndirectAttack` means an indirect attack was detected from external/untrusted information. | https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/authoring/error-codes |
| OpenAI requests can include user input, previous action outputs, tools, and conversation history; Microsoft recommends scoping tool output. | https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/authoring/error-codes |
| Agent flows can return only typed output and should limit connector output size. | https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output |
| Prompt Shields scan prompts/documents for indirect attacks before generation. | https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection |
| Deterministic topics can use fixed message, question, condition, variable, and tool nodes. | https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-create-edit-topics |

## Community Signal

| Finding | Source |
|---|---|
| Benign Teams/Copilot Studio scenarios can still hit `ContentFiltered`. | https://learn.microsoft.com/en-us/answers/questions/4430992/contentfiltered-error-on-teams-deployed-ai-assista |
| SharePoint document/link style outputs have been reported as blocked by Copilot Studio/M365 Copilot. | https://www.reddit.com/r/copilotstudio/comments/1rdhafx/m365_copilot_blocking_sharepoint_link/ |
| Power Automate/connector text output has community reports of `ContentFiltered`; workaround pattern is reduce and sanitize output. | https://community.powerplatform.com/forums/thread/details/?threadid=05877127-7245-f011-877a-7c1e52189d0f |

## Design Decision

For 3.15:

- Flow outputs exposed to the bot are static, single-field `result` strings.
- Topic messages do not echo raw SharePoint title, email, date, hours, or list rows.
- Runtime task IDs are validated outside Copilot by read-only SharePoint evidence.
- User-facing Copilot commands use known IDs from that evidence.

## Known Limitation

This is risk reduction, not a Microsoft-guaranteed bypass. Copilot Studio moderation may still produce false positives. If 3.15 still triggers `ContentFiltered`, the next escalation is Microsoft support with conversation ID, timestamp, bot ID, environment ID, and the static package evidence.
