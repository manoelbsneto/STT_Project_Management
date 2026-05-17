# Golden Rules

Status: mandatory for every new agent and every new chat.

## Mandatory Read Before Work

Before any code, deploy, import, publish, tenant write, or release decision, read:

1. `.planning/GOLDEN_RULES.md`
2. `.planning/CURRENT_BASELINE.md`
3. `.planning/AGENT_CHECKIN_REGISTRY.md`
4. `docs/MANUAL_OPERACIONAL_PMO.md` when the task touches PMO behavior, Copilot topics, flows, SharePoint lists, Teams cards, or release evidence.
5. `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` when the task touches tenant access, SharePoint, Power Automate, Power Platform, Teams, Planner, Copilot Studio, or remote machines.
6. `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md` before any ship, release, import, publish, package, or runtime-readiness decision.

If any file conflicts with a newer user instruction, follow the newer user instruction and update the relevant planning file only when asked or required for durable coordination.

## Human Approval Gate

No agent may import, publish, deploy, commit, delete, modify the portal/runtime, or write to production without explicit written approval from the project owner in the current thread. Local file edits, local package preparation, and local tests are allowed. The project owner is responsible for production import and runtime validation unless they explicitly delegate a specific action in writing.

## Access Runbook Gate

No agent may improvise tenant or remote access. Use the project master docs/runbooks. Microsoft 365 CLI / `m365` is not approved for discovery or Planner lookup in this project unless the owner explicitly changes the protocol in writing.

Required access references:

- `.planning/TENANT_COMMAND_RUNBOOK.md`
- `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
- `docs/TAILSCALE_SSH_CONNECTIVITY_GUIDE.md`
- `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`

Before any access-related command, post the exact planned command/access route in the active check-in board and wait for the required owner approval gate.

## Agent Budget Gate

Use at most 3 parallel subagents unless the project owner explicitly approves more in writing. Prefer local execution over delegation when the task is already clear.

## SEV-0 Stop-Ship Diligence Mission

Treat ship diligence as SEV-0. The default state is NO-SHIP until evidence proves otherwise.

CI gate exception: CI can be ignored only when explicitly owner-excluded for the current mission. All other gates remain mandatory. No exception is allowed for non-CI gates.

Stop shipment immediately if any of these are true:

- Runtime evidence is missing, stale, or not tied to the current imported/published artifact.
- A flow, topic, card, connector, or list write is stubbed, placeholder-only, confirm-only, or bound to an old ID.
- Any user-facing app artifact contains non-ASCII text where ASCII is required.
- Tests or static audits fail, are skipped without written reason, or do not cover the changed path.
- Any non-CI quality gate is missing, failed, stale, unverified, or not tied to the exact artifact under review.
- A change risks data loss, physical deletion, permission drift, or tenant-wide impact without explicit approval and rollback evidence.
- Ghost/orphan Copilot components are unresolved or not formally accepted by the responsible owner.
- Microsoft behavior is inferred from memory, blogs, or guesses instead of official Microsoft documentation.

## Official Microsoft Docs Rule

For Power Platform, Copilot Studio, Power Automate, Dataverse, SharePoint, Teams, Graph, Entra, or Microsoft 365 CLI behavior, use official Microsoft documentation as the source of truth.

Required practice:

- Prefer `learn.microsoft.com`, official product docs, official CLI docs, and tenant/runtime evidence.
- Do not rely on third-party blogs, old examples, or model memory for current product behavior.
- Record doc links or exact command evidence in release notes, blockers, or stop-ship evidence when a Microsoft behavior affects implementation.
- If official docs and runtime behavior conflict, capture both and keep the release NO-SHIP until the discrepancy is resolved or accepted by the owner.

## Pre-Code-Ship Rules

Before changing code or deployable artifacts:

- Read the mandatory files above.
- Check the agent registry, dependencies, and locks.
- Confirm the current baseline artifact and active evidence folder.
- Preserve edits by other agents. Do not revert work you did not make.
- Identify the rollback path before tenant writes, imports, publishes, deletes, or permission changes.
- Keep app-facing strings ASCII safe unless the current baseline explicitly allows otherwise.

Before declaring ship-ready:

- Run the relevant static tests and runtime checks.
- Attach evidence paths, run URLs, screenshots, exports, hashes, or command output as appropriate.
- Re-read the registry and baseline to ensure the decision is based on the latest state.
- Leave the decision as NO-SHIP when evidence is incomplete.
