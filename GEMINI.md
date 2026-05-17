# Gemini Agent Instructions

This repo uses shared multi-agent coordination. Documentation in `.planning/` is operational control, not optional background.

## Mandatory Startup Read

Every new agent and every new chat must read these files before code, deploy, import, publish, tenant write, or release decision:

1. `.planning/GOLDEN_RULES.md`
2. `.planning/CURRENT_BASELINE.md`
3. `.planning/AGENT_CHECKIN_REGISTRY.md`
4. `docs/MANUAL_OPERACIONAL_PMO.md` when touching PMO behavior, Copilot topics, Power Automate flows, SharePoint lists, Teams cards, or release evidence.

## SEV-0 Stop-Ship Diligence

Treat ship diligence as SEV-0. The system is NO-SHIP unless current runtime and static evidence prove the exact artifact is safe to ship. Missing evidence, stale flow/topic bindings, ghost components, placeholders, confirm-only write paths, data-loss risk, or non-ASCII user-facing artifacts in ASCII-required areas are stop-ship conditions.

## Human Approval Gate

Do not import, publish, deploy, commit, delete, modify the portal/runtime, or write to production without explicit written approval from the project owner in the current thread. Local file edits, local package preparation, and local tests are allowed. The project owner owns production import and runtime validation unless they explicitly delegate a specific action in writing.

## Agent Budget Gate

Use at most 3 parallel subagents unless the project owner explicitly approves more in writing. Prefer local execution over delegation when the task is already clear.

## Microsoft Documentation Requirement

For Power Platform, Copilot Studio, Power Automate, Dataverse, SharePoint, Teams, Graph, Entra, or Microsoft 365 CLI behavior, use official Microsoft documentation as the source of truth. Do not rely on memory, blogs, or old examples for current product behavior. Capture official doc links or command/runtime evidence whenever the behavior affects implementation or ship readiness.

## Pre-Code-Ship Rules

- Check `.planning/AGENT_CHECKIN_REGISTRY.md` dependencies and locks before work.
- Preserve edits by other agents. Do not revert work you did not make.
- Confirm the active baseline and evidence folder before using artifacts.
- Plan rollback before tenant writes, imports, publishes, deletes, or permission changes.
- Run relevant tests and attach evidence before marking work ship-ready.
- Leave the decision as NO-SHIP when evidence is incomplete.
