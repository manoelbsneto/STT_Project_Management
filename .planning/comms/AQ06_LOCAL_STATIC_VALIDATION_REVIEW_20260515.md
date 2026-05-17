# AQ-06 Local Static Validation Review

Date: 2026-05-15
Scope: Current P0 local Adaptive Card and flow planning artifacts
Reviewed by: Codex local static validation
Access type: Local filesystem only
Release decision: NO-SHIP
Tenant execution authorized: false

## 1. Verdict

Result: PASS FOR LOCAL STATIC ARTIFACTS

Release status remains:

```text
NO-SHIP
```

This review validates local files only. It does not authorize tenant writes, Planner writes, SharePoint writes, Teams posts, Power Automate saves/imports, Copilot publishes, or runtime smoke execution.

## 2. Files Reviewed

Card files:

| File | Bytes | JSON parse | Version | Size gate |
|---|---:|---|---|---|
| `deploy/cards/ResumoExecutivoPortfolio.json` | 3676 | PASS | 1.4 | PASS: under 20 KB target and 27 KB hard guardrail |
| `deploy/cards/AtualizarStatusSingleBoxReviewCard.json` | 3230 | PASS | 1.4 | PASS: under 20 KB target and 27 KB hard guardrail |
| `deploy/cards/AtualizarStatusCard.json` | 2811 | PASS | 1.4 | PASS: under 20 KB target and 27 KB hard guardrail |
| `deploy/cards/ListarTarefasProjetoCard.json` | 3463 | PASS | 1.4 | PASS: under 20 KB target and 27 KB hard guardrail |
| `deploy/cards/CriarTarefaCard.json` | 3105 | PASS | 1.4 | PASS: under 20 KB target and 27 KB hard guardrail |
| `deploy/cards/AtualizarTarefaCard.json` | 3758 | PASS | 1.4 | PASS: under 20 KB target and 27 KB hard guardrail |

Flow artifact files:

| File | Result |
|---|---|
| `.planning/comms/p0_flow_artifacts_20260514/flow_pseudocode_definitions.json` | PASS: parses with `ConvertFrom-Json` |
| `.planning/comms/p0_flow_artifacts_20260514/route_and_output_contract.md` | PASS: exact route keys present |
| `.planning/comms/p0_flow_artifacts_20260514/schema_dependencies.md` | PASS: AQ-04 Planner IDs present |
| `.planning/comms/p0_flow_artifacts_20260514/rollback_and_gate_plan.md` | PASS: local rollback and gate notes present |
| `.planning/comms/p0_flow_artifacts_20260514/README.md` | PASS: local-only scope retained |
| `.planning/comms/p0_flow_artifacts_20260514/VALIDATION.md` | PASS: AQ-05 local validation summary present |

## 3. Checks

| Check | Finding | Evidence |
|---|---|---|
| Six P0 card JSON files parse | PASS | All six scoped files parsed with `ConvertFrom-Json` |
| Card schema/type/version | PASS | All six cards have Adaptive Card schema, `type = AdaptiveCard`, and `version = 1.4` |
| Card size target | PASS | Largest scoped card is `AtualizarTarefaCard.json` at 3758 bytes, below 20 KB target |
| Card hard size limit | PASS | All scoped cards are below 27 KB hard guardrail |
| Required submit metadata | PASS | Every `Action.Submit.data` reviewed includes `action`, `operationId`, `cardVersion`, and `source` |
| Project metadata where relevant | PASS | Project-scoped submit actions include `projectId`; portfolio aggregate actions without a project scope omit it appropriately |
| Entity metadata where relevant | PASS | Task actions include `taskId` and/or `plannerTaskId` where applicable |
| Route keys exact | PASS | Unique local flow route keys are exactly `board.status`, `pmo.ops`, `pm.status.updates`, and `task.card.route` |
| Flow pseudocode JSON parses | PASS | `flow_pseudocode_definitions.json` parsed with `ConvertFrom-Json` |
| Flow count | PASS | Parsed pseudocode contains 5 P0 flows |
| AQ-04 `groupId` present | PASS | `96c5b0c4-46cc-46cd-8695-50451db74994` present in flow artifacts |
| AQ-04 `planId` present | PASS | `-1kBj1PLv0qQM-R4PwkqbpcABv_P` present in flow artifacts |
| AQ-04 six bucket IDs present | PASS | `Piloto e Implantacao`, `Testes`, `Cancelado`, `Concluido`, `Em andamento`, and `Pendente` bucket IDs present |
| `releaseDecision` gate | PASS | `flow_pseudocode_definitions.json` keeps `releaseDecision = NO-SHIP` |
| `tenantExecutionAuthorized` gate | PASS | `flow_pseudocode_definitions.json` keeps `tenantExecutionAuthorized = false` |
| ASCII scan of touched planning artifact | PASS | This report was scanned for non-ASCII characters after creation |

## 4. Action Metadata Detail

| Card | Submit actions | Metadata result |
|---|---:|---|
| `ResumoExecutivoPortfolio.json` | 5 | PASS: required metadata present; project-specific actions include `projectId` |
| `AtualizarStatusSingleBoxReviewCard.json` | 3 | PASS: required metadata and `projectId` present |
| `AtualizarStatusCard.json` | 2 | PASS: required metadata and `projectId` present |
| `ListarTarefasProjetoCard.json` | 5 | PASS: required metadata and task/project IDs present where applicable |
| `CriarTarefaCard.json` | 2 | PASS: required metadata and `projectId` present |
| `AtualizarTarefaCard.json` | 3 | PASS: required metadata and task/project/Planner IDs present where applicable |

## 5. Planner ID Baseline

AQ-04 owner-provided Planner constants are present in local flow artifacts:

| Item | Value |
|---|---|
| `groupId` | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| `planId` | `-1kBj1PLv0qQM-R4PwkqbpcABv_P` |
| `Piloto e Implantacao` | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` |
| `Testes` | `7QYPufh54kum7MP4KUzzAZcAL6Ik` |
| `Cancelado` | `90TcFTFup0CjiHIdzY4gG5cALWKL` |
| `Concluido` | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` |
| `Em andamento` | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` |
| `Pendente` | `HmzyGOgC4k6uOPm_cwG3zZcAGiAG` |

## 6. Findings

PASS:

- The six P0 card files parse and stay under both size guardrails.
- Required submit action metadata is present where applicable.
- Local flow route keys match the expected exact key set.
- Flow pseudocode JSON parses and includes AQ-04 Planner constants.
- Local release and tenant execution controls remain blocked: `NO-SHIP` and `false`.

FLAG:

- AQ-06 is local static validation only. It does not prove tenant importability, Power Automate runtime behavior, Teams rendering, Copilot routing, SharePoint writes, or Planner writes.
- AQ-02 evidence still shows the live `Tarefas` list missing the five Planner mapping fields until AQ-03 is separately approved and executed.
- The flow artifact remains `local-pseudocode-not-importable`; AQ-07 must inspect the actual owner-approved flow package before any runtime claim.

BLOCK:

- SHIP remains blocked by missing tenant/runtime gates: AQ-03 schema write evidence, AQ-07 flow save/import evidence, AQ-08 Copilot publish/update evidence, AQ-09 runtime smoke and XPIA regression evidence, and AQ-10 final owner release decision.

## 7. Commands Used

Local-only commands used for this review:

```powershell
Get-Content -Raw deploy/cards/<card>.json | ConvertFrom-Json
Get-Content -Raw .planning/comms/p0_flow_artifacts_20260514/flow_pseudocode_definitions.json | ConvertFrom-Json
rg -n "board\.status|pmo\.ops|pm\.status\.updates|task\.card\.route|releaseDecision|tenantExecutionAuthorized|groupId|planId|bucketId" .planning/comms/p0_flow_artifacts_20260514
Select-String -Path .planning/comms/AQ06_LOCAL_STATIC_VALIDATION_REVIEW_20260515.md -Pattern '[^\x00-\x7F]'
```

No tenant command was run.
No Planner command was run.
No SharePoint write was run.
No Teams post was run.
No flow save, import, or publish was run.
