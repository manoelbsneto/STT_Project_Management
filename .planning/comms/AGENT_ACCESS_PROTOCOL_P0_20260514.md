# Agent Access Protocol: P0 Adaptive Cards + Planner

Date: 2026-05-14
Status: MANDATORY
Owner: Project owner
Applies to: CODEX-LEAD, CODEX sub-agents, Gemini-PA, and any future agent

## 1. Non-Negotiable Rule

All tenant, SharePoint, Power Automate, Power Platform, Teams, Planner, Copilot Studio, and remote access actions must follow the project master documents and runbooks.

Agents must not improvise access methods.

This protocol must be read together with:

```text
.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
```

SEV-0 quality gates remain mandatory for all access, import, publish, runtime-readiness, and ship decisions. CI may be ignored only when explicitly owner-excluded; every other gate is blocking and missing/failed/stale evidence means `NO-SHIP`.

## 2. Mandatory Documents Before Any Access

Before proposing or running any command that touches tenant data, remote machines, Power Platform, SharePoint, Teams, Planner, or Copilot Studio, every agent must read:

1. `.planning/TENANT_COMMAND_RUNBOOK.md`
2. `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
3. `docs/TAILSCALE_SSH_CONNECTIVITY_GUIDE.md`
4. `.planning/CURRENT_BASELINE.md`
5. `.planning/GOLDEN_RULES.md`
6. `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`
7. `docs/MANUAL_OPERACIONAL_PMO.md` when PMO behavior, flows, cards, SharePoint lists, Teams cards, or release evidence are involved.

## 3. Explicitly Forbidden For This Project

The following are forbidden unless the owner explicitly changes this protocol in writing:

| Forbidden action | Reason |
|---|---|
| Microsoft 365 CLI / `m365` for discovery or Planner lookup | Owner rejected this access path. Use the master runbooks instead. |
| Graph direct calls | Master runbook says not to use Graph direct. |
| HTTP Premium connector paths | Master runbook says not to use premium HTTP connector. |
| ClientId / app registration / service principal / certificate auth | Master runbook forbids these paths for this tenant. |
| PowerShell 7 for legacy SharePoint PnP provisioning | SharePoint runbook requires Windows PowerShell 5.1 with legacy PnP. |
| `Connect-PnPOnline -Interactive` | SharePoint runbook requires `Connect-PnPOnline -UseWebLogin`. |
| Splitting SharePoint login and command execution into separate processes | The authenticated legacy PnP context must stay in the same Windows PowerShell 5.1 process. |

## 4. Required Access Paths

### SharePoint

Use Windows PowerShell 5.1 and `SharePointPnPPowerShellOnline 3.29.2101.0` exactly as documented in:

```text
.planning/SHAREPOINT_ACCESS_RUNBOOK.md
```

### Power Platform / Power Automate / Solution Operations

Use the exact PAC CLI and PowerApps module patterns documented in:

```text
.planning/TENANT_COMMAND_RUNBOOK.md
```

### Remote Machine Access

Use the Tailscale/SSH procedure documented in:

```text
docs/TAILSCALE_SSH_CONNECTIVITY_GUIDE.md
```

## 5. Owner Approval Gate

Even when the correct access path is known, agents must not execute:

- tenant import;
- Copilot publish;
- Power Automate save;
- SharePoint schema write;
- SharePoint item write;
- Planner task write;
- Teams production post;
- any destructive operation;
- any operation that changes runtime state;

without explicit owner approval in the current thread.

## 6. Read-Only Discovery

Read-only discovery is allowed only when all of these are true:

1. The owner has authorized the specific discovery.
2. The command follows the project master runbook.
3. The agent posts the exact command plan before execution.
4. The command does not mutate tenant state.
5. Results are recorded in the check-in board and the relevant planning artifact.

Planner bucket discovery is currently read-only authorized by the owner, but only through the approved runbook/remote access path. It must not use `m365`.

## 7. Check-In Requirement

Before any agent performs access-related work, it must write a check-in entry in:

```text
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

The check-in must state:

- which master document was read;
- exact command or access route planned;
- whether the action is read-only or write;
- owner approval reference;
- expected output file or evidence artifact.

## 8. Current Correction

On 2026-05-14, CODEX-LEAD attempted to check Microsoft 365 CLI status while investigating Planner discovery. This was incorrect for this project. No tenant write occurred. The protocol is now corrected: do not use `m365`; use the project master docs and runbooks only.
