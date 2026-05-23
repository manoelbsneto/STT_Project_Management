# Microsoft-Documented Remediation Path - Incident 3.15.1

Date: 2026-05-21
Surface: Copilot Studio authoring plus Power Platform Solutions ALM. This is not a Power Automate expression, Azure Logic Apps expression, Power Automate Desktop, or Power Fx fix.

## Decision

The failed 3.15.1 ZIP must not be retried or hand-corrected.

For existing in-place topic edits, Microsoft documents this authoring rule:

```text
Edit Copilot topics through the Copilot Studio authoring surface.
Do not change agent topic components directly from the solution component surface.
```

Source:

- https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export

The supported ALM carrier after that authoring step is a Power Platform solution export/import route. The official PAC solution command surface documents `export`, `import`, `clone`, `pack`, `sync`, and `check`:

- https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution

However, the Microsoft Learn material reviewed does not document a standard five-existing-topic in-place package transport that also proves these two constraints at packaging time:

1. exclude the 12 existing workflow solution components from the imported solution carrier;
2. update exactly five existing topic botcomponent rows in place.

That means the official path is known, but the exact topic-only hotfix topology requested by this incident is not proven by Microsoft documentation for the current workflow-bearing `PMO_v11_Tarefas` solution. The release remains `NO-SHIP` until the Owner chooses one documented tradeoff and package/runtime evidence closes the workflow regression risk.

## Options Evaluated

| Option | Microsoft documentation | Pros | Cons / risk | Recommendation |
|---|---|---|---|---|
| `pac copilot pull/push` | PAC Copilot reference: https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot | None for this requested command pair. | Current official PAC Copilot reference does not document `pull` or `push`. | Discard as `NOT MICROSOFT-DOCUMENTED` for this incident. |
| `pac solution clone` + edit source + `pac solution pack` | PAC Solution reference: https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution | Official CLI for solution project clone/pack. | Copilot docs warn topic edits should be made with standard Copilot Studio authoring and not direct component changes from the solution. It also repeats the failed hand-edit risk class. | Discard for bot topic changes. |
| `pac solution sync` | PAC Solution reference: https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution#pac-solution-sync | Official organization-to-local solution project sync. | The docs do not present it as a selective Copilot topic deployment path. It does not solve topic authoring or workflow exclusion. | Do not use as remediation ship path. |
| Copilot Studio topic authoring + solution export/import | Copilot solution ALM: https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export ; PAC Solution reference: https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution | Official authoring route for topics and official solution transport. Preserves vendor-generated schema. | A solution that still carries the 12 workflows can reprocess them during import. Microsoft docs reviewed do not promise topic-only export from the current solution shape. | Primary supported in-place topic path, gated by package diff and workflow regression evidence. |
| Copilot Studio VS Code extension workspace | https://learn.microsoft.com/en-us/microsoft-copilot-studio/visual-studio-code-extension-overview | Official YAML authoring/sync workflow. `Apply` updates the agent in the environment without publishing. | Microsoft still points multi-environment deployment to solutions. VS Code `Apply` is an environment write and is not a proven topic-only solution ZIP route. | Authoring aid only; not selected for this PROD hotfix transport. |
| Maker portal `Add existing -> Bot -> include subcomponents` | Current Copilot solution docs describe `Add existing -> Agent` and `Advanced -> Add required objects`: https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export | Might resemble old maker practice. | Current Learn material reviewed does not document a five-topic `Bot -> include subcomponents` route for this incident. | Discard as `NOT MICROSOFT-DOCUMENTED` for the requested selector. |
| Component collections | https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-export-import-copilot-components | Microsoft documents selecting topics, setting a primary agent, excluding dependencies for smaller collections, and exporting/importing collections or solutions that contain them. | Components added from an agent are moved to the collection and the agent references the collection. That is a topology change, not an in-place five-row hotfix guarantee. | Best documented selective-component mechanism for a future structured ALM path; not a zero-structure-change emergency retry. |

## Chosen Path For Existing In-Place Topics

### Supported path

1. Author only the five topic changes in Copilot Studio for the existing solution-aware agent.
2. Keep the authoring action in the intended solution context or preferred-solution context.
3. Export/import a solution generated by Microsoft tooling only.
4. Publish the agent after import and capture smoke evidence.

### Blocking scope caveat

If the exported solution carrier still contains the 12 workflows, the incident cannot claim `workflow untouched` from documentation alone. The release decision must stay `NO-SHIP` until:

- package composition is reviewed after the Microsoft-generated export;
- `tests/Test-SolutionXmlSchemaValidity.ps1` passes;
- workflow component inclusion is either removed by a documented topology decision or accepted with explicit rollback/runtime evidence;
- post-import read-only workflow state and clientdata hashes are reverified before bot smoke tests.

## Exact Commands For The Standard Solution Carrier

These are the Microsoft-documented PAC solution commands for a Microsoft-generated solution package. They are not authorized for this agent to execute in the target tenant.

Source export after Copilot Studio authoring:

```powershell
pac env select --environment <source-environment-id-or-url>
pac solution export --environment <source-environment-id-or-url> --name PMO_v11_Tarefas --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip" --overwrite
```

Local gates before any import:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionXmlSchemaValidity.ps1 -Path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip"
pac solution check --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip"
```

Owner-only import after gates and package-scope review:

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip" --publish-changes
```

`--publish-changes` is documented on the PAC solution import reference. Bot publish still requires verification in Copilot Studio/runtime evidence; do not treat a CLI option as a substitute for runtime proof.

## Where To Apply

| Step | Environment | Surface |
|---|---|---|
| Topic authoring | Source environment chosen by Owner for the solution-aware agent | Copilot Studio |
| Microsoft-generated export | Same source environment | Solutions/PAC |
| Target import | `ColOfertasBrasilPro` only after Owner approval | Solutions/PAC or maker import UI |
| Agent publish and smoke | `ColOfertasBrasilPro` after approved import | Copilot Studio/runtime test harness |

## Prerequisites

- Active PAC auth in the intended source/target environment.
- Copilot Studio permissions to edit the existing agent and topics.
- Dataverse solution permissions to export/import the selected solution.
- Owner approval for every tenant write, import, publish, and rollback action.
- A package diff proving the generated ZIP has the approved scope.
- Rollback readiness before import.

## Post-Requisites

- Re-run read-only FetchXML for the 12 workflows and the five topic payloads.
- Publish or verify published agent state as approved by Owner.
- Smoke the five topic routes.
- Capture logs, package hashes, solution version, import log, and post-import workflow state.

## Microsoft Documentation Notes

The official solutioncomponent reference documents `SolutionComponent.ComponentType` as the `componenttype` global choice:

- https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/solutioncomponent#componenttype-choicesoptions

The official botcomponent reference documents Copilot bot authoring components and topic component types:

- https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/botcomponent

These references support schema validation and botcomponent identification. They do not license hand-crafted RootComponent manifest edits.

