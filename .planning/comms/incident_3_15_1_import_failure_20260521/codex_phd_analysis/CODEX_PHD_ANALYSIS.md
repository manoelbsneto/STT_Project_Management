# CODEX PHD Analysis - Incident 3.15.1

Date: 2026-05-21
Status: `NO-SHIP`
Surface declared before action: `Dataverse solution import + Power Platform Solutions framework + PAC CLI read-only FetchXML`. This is not a Power Automate Cloud Flow expression, Azure Logic Apps expression, Power Automate Desktop expression, or Power Fx expression task.

## Stage 1 - Entendimento

The 3.15.1 import failed with `0x80044150 Input string was not in a correct format`.
The import log places the fatal failure in `Inserciones de componentes raiz`, after workflow definition processing and before workflow activation processing completed.
Expected behavior was a versioned topic hotfix: update five existing topic payloads, keep the twelve 3.15 workflow definitions and activation state intact, and bump solution version from 3.15 to 3.15.1.
If the failed import had left workflows deactivated in the production-like tenant, bot commands that depend on those flows could have degraded at runtime.
Read-only PAC evidence now shows the twelve queried workflow rows are active and their `clientdata` hashes still match the pre-publish baseline.

## Stage 2 - RCA

### Symptom observed

Evidence from `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (36).xml`:

- Solution `PMO_v11_Tarefas` import status is `Error`.
- Progress stopped at `54.05%` after `71.6s`.
- Fatal phase: `Inserciones de componentes raiz`.
- Fatal code/text: `0x80044150 Input string was not in a correct format`.
- Workflow rows were processed with `0x80045042 The original workflow definition has been deactivated and replaced`.
- Workflow activation steps were recorded as `Sin procesar`.

### Technical root cause

The quarantined hotfix solution manifest contains five hand-added root entries such as:

```xml
<RootComponent type="botcomponent" id="{ec4416d0-0744-4e8c-b937-aae4ad9c605b}" behavior="0" />
```

The working base 3.15 manifest uses numeric RootComponent types such as:

```xml
<RootComponent type="29" id="{0a5d2a41-24c0-4d5e-9f6d-000000000241}" behavior="0" />
```

Microsoft Learn documents `SolutionComponent.ComponentType` as the Dataverse `componenttype` global choice whose values are integer component codes:

- https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/solutioncomponent#componenttype-choicesoptions

The local recurrence guard now validates RootComponent `type` as an integer componenttype value before import. It passes base 3.15 and fails the quarantined 3.15.1 ZIP on the five string `botcomponent` entries.

The RCA pack is therefore validated for the failure class: the hand-crafted string RootComponent type is invalid for Dataverse root component insertion and triggers the observed format failure. The owner directive forbidding hand-crafted `solution.xml` is correct.

### Trigger condition

Trigger condition:

1. A Microsoft-generated solution XML manifest is manually edited.
2. A RootComponent `type` attribute is inserted as string token `botcomponent`.
3. Dataverse import reaches root component insertion and parses the RootComponent type as componenttype identity.

### Functional impact from tenant evidence

Read-only evidence captured after failure:

- `FORENSIC_TENANT_STATE.md`
- `evidence/pac_fetch_workflow_runtime_state_supported_columns.txt`
- `evidence/workflow_clientdata_hash_compare.txt`
- `evidence/topic_raw_fetch_hash_compare.txt`

Current queried impact:

- The 12 in-scope workflows are currently `Activado` / `Activado`.
- The 12 workflow `clientdata` payload hashes match the pre-publish baseline.
- The 5 in-scope topic `data` raw PAC captures match the pre-publish baseline.
- The solution remains version `3.15`.

This contradicts the initial unconfirmed worst case that the workflows were left deactivated. It does not clear ship readiness because the failure class and delivery-path gap remain.

### Operational impact

- Owner import window was consumed by a schema-class failure.
- The failed ZIP is quarantined and cannot be repaired by manual manifest edits.
- Release governance missed a componenttype-schema gate before production-like import.
- The team still needs an Owner-approved Microsoft-supported delivery path for the five topic changes.

### Regression risk

Regression remains high if:

- topic ZIPs are hand-crafted again;
- a Microsoft-generated solution carrier still includes workflows and is imported without workflow scope/readiness evidence;
- a method is selected from blogs, memory, or undocumented PAC command names.

## Stage 3 - Avaliacao De Abordagens

Detailed comparison is in `MICROSOFT_REMEDIATION_PATH.md`.

| Approach | Microsoft Learn source | Pros | Cons / risk | Recommendation |
|---|---|---|---|---|
| `pac copilot pull/push` | https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot | None for the requested commands. | Current official PAC Copilot reference does not document `pull` or `push`. | Discard. |
| `pac solution clone` + source edit + `pac solution pack` | https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution | Official solution CLI surface. | Copilot topic authoring docs warn against topic changes by direct solution component edit. | Discard for topic content remediation. |
| `pac solution sync` | https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution#pac-solution-sync | Official solution project sync. | No documented five-topic selective Copilot ship semantics. | Do not use as ship path. |
| Copilot Studio UI authoring + solution export/import | https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export | Supported topic authoring and supported solution transport. | Current workflow-bearing solution can still carry workflows. Package scope must be proven. | Selected supported in-place authoring/ALM path, with hold gates. |
| Copilot Studio VS Code extension | https://learn.microsoft.com/en-us/microsoft-copilot-studio/visual-studio-code-extension-overview | Official YAML authoring workspace and environment apply. | Apply is an environment write; docs still direct multi-environment deployment to solutions. | Authoring aid only for this incident. |
| Maker portal `Add existing -> Bot -> include subcomponents` | Current Learn path documents Agent/Add required objects: https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export | Familiar maker idea. | Exact five-topic `Bot` selector path was not found in current Learn docs. | Discard as undocumented for this incident. |
| Component collections | https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-export-import-copilot-components | Documented topic selection and dependency exclusion for primary-agent collections. | Moves components to a collection and changes agent topology. | Candidate for future selective ALM, not an in-place emergency retry. |

## Stage 4 - Solucao Recomendada

### Method selected

Use the Microsoft-supported authoring rule for existing topics:

1. edit the five topics through Copilot Studio authoring in the intended solution-aware agent context;
2. use a Microsoft-generated Power Platform solution export/import as ALM carrier only after package-scope review;
3. do not hand-edit `solution.xml`, botcomponent XML, or ZIP structure.

### Critical hold

Microsoft Learn material reviewed does not prove an in-place five-existing-topic solution carrier that also excludes the twelve workflows already present in the current `PMO_v11_Tarefas` solution. Therefore:

- the selected official authoring/ALM path is correct;
- the current import retry path is still `NO-SHIP` until a Microsoft-generated export is scope-reviewed and Owner accepts the workflow inclusion decision or uses a documented alternate topology.

### Commands in order

Owner/source-authoring steps:

1. Open the existing solution-aware agent in Copilot Studio from the intended solution context.
2. Edit only `AtualizarStatus`, `AtualizarTarefa`, `ConsultarPortfolio`, `CriarTarefa`, and `ListarTarefas`.
3. Export a Microsoft-generated solution package.

PAC export command:

```powershell
pac solution export --environment <source-environment-id-or-url> --name PMO_v11_Tarefas --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip" --overwrite
```

Local gates before import:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionXmlSchemaValidity.ps1 -SelfTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionXmlSchemaValidity.ps1 -Path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip"
pac solution check --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip"
```

Owner-only target import after written approval and scope review:

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip" --publish-changes
```

Post-import read-only verification pattern:

```powershell
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <workflow state FetchXML>
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <five topic data FetchXML>
```

### Where apply

| Action | Surface | Environment |
|---|---|---|
| Topic authoring | Copilot Studio | Owner-selected source environment for solution-aware agent |
| Export and local gates | PAC + local tests | Source environment and local workspace |
| Import | PAC or maker import UI | `ColOfertasBrasilPro`, Owner-only |
| Publish and smoke | Copilot Studio + runtime | `ColOfertasBrasilPro`, Owner-only unless explicitly delegated |

### Prerequisites

- Valid PAC auth to the selected source and target environment.
- Copilot Studio maker permissions for the agent/topics.
- Dataverse solution export/import permissions.
- Microsoft-generated ZIP only.
- Quarantined failed ZIP remains untouched.
- Rollback plan and runtime smoke window ready.

### Post-requisites

- Verify bot publish state and run five-topic smoke.
- Re-capture workflow state and clientdata hashes.
- Re-capture five topic data payloads and compare to expected topic set.
- Capture import log, package SHA256, solution version, and runtime evidence.

## Stage 5 - Quality Gates

| Gate | Validation | Result |
|---|---|---|
| A - Compatibility | PAC `2.6.4` exposes official `pac solution export/import/check` and tenant OrganizationVersion evidence is `9.2.26042.165`. Microsoft docs support the solution command family and Copilot Studio solution ALM. | Supported surface; requested topic-only exclusion is not doc-proven. |
| B - Syntax | Commands shown use documented PAC solution syntax and local PowerShell syntax verified by test runs. | Pass for shown commands. |
| C - Null safety | If one of five topics is missing, FetchXML returns fewer rows and the delivery path must stop. If auth expired, PAC auth/env check stops before fetch/import. | Stop-on-missing required. |
| D - Typing | `RootComponent.type` must be integer componenttype, not string label. Workflow/topic IDs are GUIDs. PAC `--environment` accepts ID or URL. | Incident type bug guarded. |
| E - Encoding | Topic YAML is transported by Copilot Studio/solution tooling, not regex manipulation. Local guard reads XML/ZIP without rewriting. Any authored YAML diff must be checked for BOM/CRLF policy before package acceptance. | No manual encode/decode path selected. |
| F - Regex safety | Regex is not the remediation method. The guard parses XML and ZIP structure. Existing topic Power Fx regex content is payload, not touched by this RCA fix. | N/A for remediation. |
| G - Regression | Current post-failure evidence shows 12 workflows active and unchanged. Future package must prove workflow scope. Do not claim a no-workflow-touch import if exported package includes those workflows without explicit risk acceptance. | Current tenant safe; future ship gate open. |
| H - Security | No token output is copied into deliverables. Tenant route is read-only evidence until Owner write approval. | Pass for this work. |
| I - Observability | Use import logs, PAC auth/env identity, FetchXML outputs, package hashes, local test outputs, post-import workflow state, topic payload hashes, and bot smoke evidence. | Pass for diagnosis path. |

## Stage 6 - Matriz De Testes

| # | Case | Input / precondition | Expected output / decision |
|---:|---|---|---|
| 1 | Happy path | Five authored topics in a Microsoft-generated approved package; all gates green. | Import/publish only after Owner approval; five routes smoke; 12 workflows post-verify unchanged or accepted scope is documented. |
| 2 | Topic missing | One of five botcomponent IDs absent from pre-import FetchXML. | Stop. Do not package/import under a missing-row assumption. |
| 3 | Auth expired | `pac env who` or FetchXML fails before evidence capture. | Stop and re-auth through approved route. No write fallback. |
| 4 | Network timeout | PAC fetch/export/import transport times out. | Preserve logs, stop retries that could mutate target, rerun only approved read-only evidence after connectivity recovers. |
| 5 | Malformed topic YAML | Copilot authoring/import validation rejects topic or generated export fails. | Stop; correct through Copilot Studio authoring, not ZIP edit. |
| 6 | Idempotent topic | One of five topic payloads has no semantic change. | Package diff records no payload delta for that topic; no fake drift claim. |
| 7 | Bot not published | Import succeeds but runtime uses old published bindings. | Publish/verify bot per Owner-approved route; smoke remains blocked until publish evidence exists. |
| 8 | Version conflict | Solution export/import version conflicts with current target version. | Stop; resolve through supported solution versioning path; never patch manifest by hand. |
| 9 | Unicode topic content | Topic content includes non-ASCII payload or authored text outside project policy. | ASCII gate blocks app-facing text unless Owner explicitly authorizes exception. |
| 10 | Rollback needed | Post-import workflow/topic/runtime evidence fails. | Owner executes approved rollback path; capture rollback and post-rollback evidence. |
| 11 | Schema guard positive | Input: `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip`. | Output: guard JSON has `passed=true`, `rootComponentCount=12`, `invalidRootComponentCount=0`. |
| 12 | Schema guard negative | Input: quarantined `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`. | Output: guard fails with five invalid `type='botcomponent'` RootComponents. |

### Concrete input/output examples

Positive guard example:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionXmlSchemaValidity.ps1 -Path .\Solution\PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip
```

Expected output fields:

```json
{
  "passed": true,
  "rootComponentCount": 12,
  "invalidRootComponentCount": 0
}
```

Negative guard example:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionXmlSchemaValidity.ps1 -Path .\Solution\PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip
```

Expected output fields and terminal decision:

```json
{
  "passed": false,
  "rootComponentCount": 17,
  "invalidRootComponentCount": 5
}
```

Expected decision: non-zero failure because five RootComponent entries use string `type="botcomponent"`.

## Stage 7 - Final Para Implementacao

### Solucao escolhida

Copilot Studio authoring of the five existing topics in the solution-aware agent context, followed only by Microsoft-generated solution export/import after package scope review and local guards.

### Motivo tecnico com Microsoft Learn

- Topic edits must be authored through Copilot Studio, not direct topic component edits from solution assets: https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export
- PAC solution export/import/check are the documented solution CLI operations: https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution
- Current PAC Copilot docs do not document `pac copilot pull/push`: https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot
- Component collections are the documented selective-component option, but they move components into a collection and change topology: https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-export-import-copilot-components

### Comandos exatos

```powershell
pac solution export --environment <source-environment-id-or-url> --name PMO_v11_Tarefas --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip" --overwrite
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionXmlSchemaValidity.ps1 -SelfTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionXmlSchemaValidity.ps1 -Path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip"
pac solution check --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip"
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path ".\exports\PMO_v11_Tarefas_3_15_1_from_copilot_studio.zip" --publish-changes
```

Import command is Owner-only and not executed in this analysis.

### Onde aplicar

- Author/export in Owner-selected source environment for the solution-aware agent.
- Target import/publish in `ColOfertasBrasilPro` only after Owner approval.

### Pre-requisitos

- PAC auth and correct environment selection.
- Copilot Studio edit rights and Dataverse solution ALM rights.
- Microsoft-generated ZIP only.
- Local schema guard pass, package-scope diff, rollback readiness, and Owner write approval.

### Risco residual

Microsoft docs reviewed do not prove a standard topic-only existing-component solution export that excludes the current twelve workflow solution components. If the generated package carries those workflows, import risk remains and must be handled with explicit scope acceptance plus workflow evidence/rollback.

### Checklist de deploy

1. Keep failed 3.15.1 ZIP quarantined.
2. Edit only five topics through Copilot Studio authoring.
3. Export Microsoft-generated package.
4. Run local schema guard and `pac solution check`.
5. Review ZIP scope and hashes.
6. Import only with Owner approval.
7. Verify version, workflow state/hashes, topic payloads, publish state, and five-topic runtime smoke.

### Checklist de rollback

1. Stop on any import, publish, workflow state, topic hash, or smoke failure.
2. Preserve import log and post-failure read-only snapshot.
3. Owner decides rollback using the approved rollback package/script path.
4. Capture post-rollback solution version, workflow state, topic payloads, and smoke evidence.

### Casos de teste validados

- Local schema guard self-tests pass for XML and generated ZIP fixtures.
- Base 3.15 ZIP passes the schema guard.
- Quarantined hotfix 3.15.1 ZIP fails the schema guard with five string RootComponent types.
- Read-only post-failure tenant workflow state shows 12 active workflow rows.
- Read-only post-failure workflow clientdata hashes match the pre-publish baseline.
- Read-only post-failure five-topic data captures match the pre-publish baseline.

