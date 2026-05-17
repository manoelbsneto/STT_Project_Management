# SEV-0 Stop-Ship Quality Gates Protocol

Date: 2026-05-14
Status: MANDATORY
Applies to: CODEX-LEAD, CODEX sub-agents, Gemini-PA, and any future agent
Priority: Highest

## 1. Non-Negotiable Release Rule

The project is in SEV-0 stop-ship discipline.

No code, package, flow, topic, card, schema change, import, publish, or runtime release may be declared ship-ready unless all mandatory quality gates are green.

The only allowed gate exception for the current mission is:

```text
CI gate may be ignored when explicitly owner-excluded.
```

All other quality gates are mandatory. There is no exception.

If any non-CI gate is missing, failed, stale, unverified, or not tied to the current artifact, the release decision is:

```text
NO-SHIP
```

## 2. Mandatory Gates

| Gate | Required State | Release Decision if Missing/Failed |
|---|---|---|
| Critical issue RCA | RCA-grade diagnosis exists for incident-class issues | NO-SHIP |
| Reproduction evidence | Critical issue has deterministic repro or documented reason why runtime-only evidence is the best available proof | NO-SHIP |
| Automated/local tests | Relevant static/local tests pass for changed artifacts | NO-SHIP |
| Runtime evidence | Owner/runtime validation proves the current imported/published artifact | NO-SHIP |
| Security | No known high/critical security finding without documented owner-approved exception and compensating control | NO-SHIP |
| Performance / payload size | No material regression; cards stay within size guardrails | NO-SHIP |
| Backward compatibility | Contracts, schemas, topic bindings, route keys, and migrations are validated | NO-SHIP |
| Rollback | Rollback plan exists before tenant write/import/publish | NO-SHIP |
| Evidence log | Evidence points to exact files, commands, outputs, screenshots, run IDs, or artifact hashes | NO-SHIP |
| Access protocol | Access follows project master runbooks; no forbidden access path | NO-SHIP |
| ASCII app-facing text | Shipped app-facing text is ASCII safe unless explicitly allowed | NO-SHIP |
| No raw Copilot tool output | Copilot does not expose raw SharePoint/Planner JSON or long rows | NO-SHIP |

## 3. CI Exception Scope

The CI gate exception does not weaken the rest of the gates.

Allowed:

- Release planning may continue without CI evidence if the owner explicitly excludes CI for the mission.
- Local/static/runtime evidence may substitute only for the CI gate.

Not allowed:

- Treating missing runtime proof as acceptable because CI is excluded.
- Treating failed local gates as acceptable because CI is excluded.
- Shipping with missing RCA, missing rollback, failed static tests, missing screenshots/run IDs, or stale evidence.

## 4. Required Evidence Standard

Every ship-safety claim must include at least one of:

- file path and line reference;
- command and output snippet;
- test result path;
- package hash;
- runtime screenshot;
- Power Automate run ID/URL;
- SharePoint item before/after evidence;
- Teams card route evidence;
- Planner task/bucket evidence when Planner is in scope.

Uncited claims are not release evidence.

## 5. Required Artifacts Before Ship Decision

At minimum, the release package must have:

| Artifact | Purpose |
|---|---|
| `EXEC_SUMMARY` or release status summary | C-level status: SHIP / NO-SHIP, risks, mitigations |
| RCA / issue pack | Root cause and corrective actions for incident-class issues |
| Evidence log | Evidence table with paths, commands, snippets, notes |
| Test strategy / QA matrix | Coverage and regression mapping |
| Release readiness checklist | Gate-by-gate decision and rollback plan |

Existing project artifacts may satisfy these requirements if they are current and tied to the artifact under review.

## 6. Agent Communication Requirement

Every active agent update must state:

- what was done;
- what was found with evidence;
- what changed;
- what remains risky;
- next step and ETA in work items.

Any agent that cannot prove a required gate must mark the release path:

```text
NO-SHIP
```

## 7. Current P0 Application

For Adaptive Cards + Planner P0, the immediate mandatory gates are:

1. Card JSON parse, ASCII, size, and action metadata gates.
2. Route decisions and route evidence gates.
3. Flow/topic static output gate to prevent raw SharePoint/Planner data in Copilot.
4. SharePoint schema compatibility gate for `Tarefas` Planner mapping fields.
5. Planner read-only discovery gate through master runbook only.
6. Runtime smoke evidence gate after owner import/publish.
7. Known `openAIIndirectAttack` / `ContentFiltered` repro gate.
8. Rollback plan before tenant write/import/publish.

CI remains owner-excluded for this mission only. All gates above remain mandatory.
