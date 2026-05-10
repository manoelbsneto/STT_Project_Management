# W1-01 CriarTarefa V3 ProcessSimple Blocker

Date: 2026-05-10 10:59 BRT
Owner: Codex 5.5
Status: BLOCKED for live PATCH; definition is validated

## Summary

Codex rebuilt and validated the `PMO_PA_CriarTarefa_V3` definition programmatically, including:

- Real SharePoint `Projetos` `PostItem` write path.
- Duplicate check by `NomeProjeto + DataAlvo`.
- Duplicate check excludes logically deleted records with `Deleted ne 1`.
- New `Projetos` records set `Deleted = false`.
- `PM/Claims`, `StatusRAG/Value`, and `Prioridade/Value` field mapping.
- No `padLeft`.
- ASCII-only operational text.

The ProcessSimple PATCH call to update existing flow `PMO_PA_CriarTarefa_V3` failed with HTTP 500 on four attempts.

## Evidence

| Evidence | Path |
|---|---|
| Build-only validated definition | `.planning/comms/pa_criartarefa_buildonly_20260510_105659.json` |
| ProcessSimple request payload | `.planning/comms/processsimple_criartarefa_request_89050663-1163-b36c-659b-6fcaa0edfee0.json` |
| ProcessSimple error | `.planning/comms/pa_criartarefa_error_20260510_105744.json` |
| Flow inventory | `.planning/comms/w1_01_criartarefa_flow_inventory_20260510_105900.json` |
| Source test | `tests/Test-CriarTarefaFlowDefinition.ps1 -Path deploy/PA_CriarTarefa_Flow.ps1 -AllowRuntimeRawAuthentication` passed |
| Build JSON test | `tests/Test-CriarTarefaFlowDefinition.ps1 -Path .planning/comms/pa_criartarefa_buildonly_20260510_105659.json -AllowRuntimeRawAuthentication` passed |

## Live Flow Inventory

| DisplayName | FlowName | WorkflowEntityId | State |
|---|---|---|---|
| PMO_PA_CriarTarefa_V3 | `89050663-1163-b36c-659b-6fcaa0edfee0` | `3104124d-364a-f111-bec7-7ced8d955c6c` | Started |
| Clean_PMO_PA_CriarTarefa | `953b36ea-972e-ec8b-d050-647eaa918cd4` | `42d9abd1-8849-f111-bec7-7ced8d955c6c` | Started |

## Required Opus / Browser Action

Open Power Automate UI and rebuild/update `PMO_PA_CriarTarefa_V3` manually using the validated definition from:

`.planning/comms/pa_criartarefa_buildonly_20260510_105659.json`

Minimum UI checklist:

1. Open flow `PMO_PA_CriarTarefa_V3`.
2. Confirm trigger is `Run a flow from Copilot` / Skills.
3. Confirm inputs: `titulo`, `responsavel`, `prazo`, `horas`, `prioridade`, optional `nomeProjeto`.
4. Add/verify duplicate query:
   `NomeProjeto eq '<name>' and Deleted ne 1 and DataAlvo ge <day start> and DataAlvo lt <next day start>`.
5. Add/verify SharePoint Create item in `Projetos`.
6. Confirm fields include:
   - `Title`
   - `ProjectID`
   - `NomeProjeto`
   - `StatusRAG/Value = Verde`
   - `Percentual = 0`
   - `Ativo = true`
   - `Deleted = false`
   - `PM/Claims = concat('i:0#.f|membership|', responsavel)`
   - `DataAlvo`
   - `Prioridade/Value`
   - `UltimaAtualizacao`
   - `ResumoExecutivo`
7. Save.
8. Run T-007 create path from Copilot after topic binding/publish.

## Current Gate Result

W1-01 remains blocked only because ProcessSimple PATCH returned HTTP 500. The definition and tests are green.
