# ISSUE_RCA_PACK — ISSUE-001

## Title
Solution import 3.15.1 failed at "Inserciones de componentes raíz" with FormatException; tenant left in potentially inconsistent workflow state.

## Severity
SEV-0 (Stop-Ship — production environment integrity at risk)

## Impact (UNCONFIRMED, pending tenant state evidence)
- Potential: 12 PMO_PA_* workflows in deactivated state in `ColOfertasBrasilPro` environment
- If confirmed: bot runtime degraded across all PMO commands that depend on these workflows (criar tarefa, atualizar tarefa, consultar portfolio, listar tarefas, atualizar status, etc.)
- 5 in-scope topic botcomponents NOT modified (failure occurred before that phase)

## Timeline (UTC)

| When | What |
|---|---|
| 2026-05-21T18:58:00Z | Phase A independent review consolidated to PUBLISH_GO (4/4 leads) |
| 2026-05-21T19:12:15Z | Owner clicked Importar in Power Automate UI |
| 2026-05-21T19:12:15Z | Pacote transformations + XSD validation OK |
| 2026-05-21T19:12:21Z | Solución metadata error (first surface of FormatException) |
| 2026-05-21T19:12:25–52Z | 12 workflow definitions replaced (deactivate + new version) |
| 2026-05-21T19:13:26Z | "Inserciones de componentes raíz" failed: `0x80044150 Input string was not in a correct format` |
| 2026-05-21T19:13:27Z | Import aborted at 54.05% progress; duration 71.6s |
| 2026-05-21T19:13:27Z+ | Workflow activation phase recorded "Sin procesar" for all 12 — never executed |

## Root cause(s)

### Primary (confirmed by artifact inspection)
The hotfix `solution.xml` declares 5 RootComponent entries with `type="botcomponent"` (string):

```xml
<RootComponent type="botcomponent" id="{ec4416d0-...}" behavior="0" />
```

The Dataverse import engine attempts to parse the `type` attribute as the `componenttype` integer code (per Microsoft's componenttype OptionSet). Conversion of the string `"botcomponent"` to int fails with `FormatException`, surfaced as `0x80044150`.

### Procedural (confirmed by dispatch artifact)
- Track I dispatch authored by Kiro/Opus 4.7 instructed CODEX-PA to "Add five RootComponent entries of type botcomponent with the GUIDs from §2."
- The dispatch did not specify a canonical, schema-correct method for adding bot components to a solution manifest, and did not require validation of the `type` attribute against the Dataverse OptionSet.
- The instruction was followed literally, producing a hand-crafted solution.xml.

### Cultural / governance gap
GOLDEN_RULES.md explicitly forbids inference from memory:
> "Microsoft behavior is inferred from memory, blogs, or guesses instead of official Microsoft documentation."

The dispatch violated this rule. The Phase A independent review (4 leads) did not catch the violation because no audit gate covered Dataverse OptionSet validity for solution.xml type attributes.

## Contributing factors
- Power Automate solution.xml schema is intolerant of hand-edits (Owner-confirmed). Even if the integer were guessed correctly, hand-crafting the file is fundamentally unsafe.
- Original Track I motivation was to escape Code Editor paste-and-save unreliability. The chosen alternative (hand-craft ZIP) replaced one unreliable mechanism with another.
- Phase A audit gates G1–G9 included XML well-formedness (G1), workflow byte-equality (G2), YAML byte-equality (G3), GUID match (G4), binding key (G5), variable consistency (G6), legacy ref absence (G7), ASCII (G8), action name validity (G9). None validated Dataverse type-code OptionSet membership.

## Detection gaps (why this escaped)

| Gap | Why it matters |
|---|---|
| Phase A audit did not query Dataverse OptionSet for componenttype values | Could have flagged `type="botcomponent"` as not in valid integer set before import |
| No tooling validation: `pac solution check` was not run on the artifact | The official Microsoft validator would have caught the schema issue |
| Tests only validated structural shape, not Dataverse acceptance | Static XML checks are necessary but insufficient |
| Dispatch reviewer (the orchestrator) accepted "add RootComponent of type botcomponent" without doc evidence | Direct GOLDEN_RULES violation by orchestrator |

## Corrective actions (proposed, not yet executed)

### Immediate (NO-SHIP gate)
- [ ] **CA-001:** Verify tenant runtime state of 12 PMO_PA_* workflows. Owner to confirm via Power Automate UI. Evidence: `EVIDENCE_LOG.md` E-005.
- [ ] **CA-002:** If tenant degraded → execute staged rollback via `rollback_ready.ps1` (Codex #1 baseline). Evidence: `pre_publish_live_baseline/rollback_ready.ps1`.
- [ ] **CA-003:** Quarantine `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` — must NOT be re-imported.

### Replanning (post-tenant-stable)
- [ ] **CA-004:** Owner to specify the project's accepted official Microsoft tooling for shipping bot/topic changes (e.g., `pac copilot`, `pac solution`, Copilot Studio export-after-UI-edit, or other validated runbook).
- [ ] **CA-005:** Replan the topic remediation using ONLY the chosen official tooling. No hand-craft of any solution artifact.

### Prevention (recurrence guard)
- [ ] **CA-006:** Add audit gate to Phase A: run `pac solution check --path <zip>` (Microsoft's official validator) on every candidate ZIP before PUBLISH_GO.
- [ ] **CA-007:** Add `tests/Test-SolutionXmlSchemaValidity.ps1` that validates RootComponent `type` attributes against Dataverse componenttype OptionSet (queried live or cached from official docs link).
- [ ] **CA-008:** Update dispatch authoring rules: any instruction that causes hand-edit of platform schema artifacts requires explicit Owner pre-approval AND citation of official Microsoft documentation.
- [ ] **CA-009:** Add governance rule to project: never propose patch-and-retry on a failed schema-class incident. Re-build the artifact via official tooling.

## Prevent recurrence — explicit controls

| Control | Where enforced | Evidence path |
|---|---|---|
| `pac solution check` on every ZIP | Phase A pre-publish audit | (to be added) |
| Static schema gate `Test-SolutionXmlSchemaValidity.ps1` | tests/ + CI | (to be added) |
| Dispatch authoring rule (no hand-craft) | Kiro orchestrator default behavior | This RCA |
| Owner approval gate before any solution-manifest edit | GOLDEN_RULES already covers; reinforce in dispatch templates | GOLDEN_RULES.md |

## Sign-off
- **Author:** Kiro / Opus 4.7 (Incident Commander)
- **Authored UTC:** 2026-05-21T19:25:00Z
- **Status:** Initial — pending tenant evidence (E-005) before fix actions can be approved
