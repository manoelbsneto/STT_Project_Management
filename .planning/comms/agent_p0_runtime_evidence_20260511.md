# Agent 3 P0 Runtime Evidence Plan - 2026-05-11

Scope: P0 write flows after v1.10: AtualizarStatus, RegistrarRisco, RegistrarBloqueio, PedirDecisao, CriarTarefa.

Constraint honored: no browser chat attempted; no SharePoint writes performed by Agent 3.

## Programmatic Verification Performed

Read-only checks completed:

- `tests/Test-CriarTarefaFlowDefinition.ps1 -Path deploy/PA_CriarTarefa_Flow.ps1 -AllowRuntimeRawAuthentication` passed all 16 checks.
- In-memory static checks against `deploy/PA_BotTopicFlows.Factory.ps1` passed:
  - ASCII-only and no `padLeft`.
  - Project lookup filters `Ativo eq 1 and Deleted eq 0`.
  - AtualizarStatus creates `Status Diario` and patches `Projetos`.
  - RegistrarRisco creates `Riscos e Bloqueios` with `Tipo=Risco`.
  - RegistrarBloqueio creates `Riscos e Bloqueios` with `Tipo=Bloqueio`.
  - PedirDecisao creates `Decisoes do Board` with `StatusDecisao=Pendente`.
  - Write branches set `Deleted=false`.
  - Not-found branches return `PROJECT_NOT_FOUND`.

Existing v1.10 package evidence inspected:

- `.planning/comms/solution_1_10_project_lookup_normalize_20260511/unpacked/Workflows/PMO_PA_AtualizarStatus-C11A165B-C64C-F111-BEC7-7CED8D9559C1.json`
- `.planning/comms/solution_1_10_project_lookup_normalize_20260511/unpacked/Workflows/PMO_PA_RegistrarRiscoBot-EE732D46-C64C-F111-BEC7-7CED8D955C6C.json`
- `.planning/comms/solution_1_10_project_lookup_normalize_20260511/unpacked/Workflows/PMO_PA_RegistrarBloqueioBot-3EC37952-C64C-F111-BEC7-000D3ABC5CC6.json`
- `.planning/comms/solution_1_10_project_lookup_normalize_20260511/unpacked/Workflows/PMO_PA_PedirDecisaoBot-FEB79D54-C64C-F111-BEC7-7CED8D955C6C.json`
- `.planning/comms/solution_1_10_project_lookup_normalize_20260511/unpacked/Workflows/PMO_PA_CriarTarefa_V3-3104124D-364A-F111-BEC7-7CED8D955C6C.json`

All five package definitions include SharePoint write actions, `Deleted=false`, and active/non-deleted lookup filtering where applicable.

Existing Power Automate deployment evidence inspected:

- `pa_atualizarstatus_result_3890bac6-0bd0-4101-858b-eeaec6abd4f8.json`: `PMO_PA_AtualizarStatus`, state `Started`, last modified `2026-05-10T23:32:01Z`.
- `pa_registrarriscobot_result_7394d441-50d7-4b3b-ba4c-d14e2e5b9b77.json`: `PMO_PA_RegistrarRiscoBot`, state `Started`, last modified `2026-05-10T23:26:14Z`.
- `pa_registrarbloqueiobot_result_aee885f8-5947-41a6-a04b-1d46bd7e7746.json`: `PMO_PA_RegistrarBloqueioBot`, state `Started`, last modified `2026-05-10T23:26:40Z`.
- `pa_pedirdecisaobot_result_28bf33f2-0dd6-4755-97d9-57c42d93d316.json`: `PMO_PA_PedirDecisaoBot`, state `Started`, last modified `2026-05-10T23:27:56Z`.
- v1.10 package contains `PMO_PA_CriarTarefa_V3-3104124D-364A-F111-BEC7-7CED8D955C6C.json`.

Run-history inspection:

- Local run-history artifacts exist only for `ConsultarProjeto` under `.planning/comms/live_consultarprojeto_20260511`.
- Read-only Flow API run-history query for the five write flows returned `403 Forbidden` for each flow from this shell. Therefore runtime run history for the write flows cannot be closed by Agent 3 without User/Power Automate UI or elevated Flow permissions.

## Closure Status

| Task | Programmatic closure | Remaining closure |
|---|---|---|
| CriarTarefa | Static/source/package closure is sufficient for flow definition. | Runtime write proof requires Copilot Studio/Power Automate UI run and SharePoint query. |
| AtualizarStatus | Static/source/package closure is sufficient for flow definition. | Runtime write proof requires Copilot Studio/Power Automate UI run and SharePoint query. |
| RegistrarRisco | Static/source/package closure is sufficient for flow definition. | Runtime write proof requires Copilot Studio/Power Automate UI run and SharePoint query. |
| RegistrarBloqueio | Static/source/package closure is sufficient for flow definition. | Runtime write proof requires Copilot Studio/Power Automate UI run and SharePoint query. |
| PedirDecisao | Static/source/package closure is sufficient for flow definition. | Runtime write proof requires Copilot Studio/Power Automate UI run and SharePoint query. |

## Exact Test Messages

Use a controlled project name and keep the timestamp unchanged for traceability:

1. CriarTarefa

```text
Criar tarefa: Titulo=P0QA Agent3 20260511, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=8, Prioridade=Alta
```

Confirm with:

```text
sim
```

2. AtualizarStatus

```text
Atualizar status: Projeto=P0QA Agent3 20260511, RAG=Amarelo, Resumo=validacao programatica pos v1.10, Risco=risco controlado de QA, Bloqueio=nenhum, Proxima Acao=validar evidencias no SharePoint, Percentual=45
```

Confirm with:

```text
sim
```

3. RegistrarRisco

```text
Registrar risco: Projeto=P0QA Agent3 20260511, Descricao=risco controlado de QA pos v1.10, Severidade=Alta, Impacto=Alto
```

Confirm with:

```text
sim
```

4. RegistrarBloqueio

```text
Registrar bloqueio: Projeto=P0QA Agent3 20260511, Descricao=bloqueio controlado de QA pos v1.10, Impacto=Medio
```

Confirm with:

```text
sim
```

5. PedirDecisao

```text
Pedir decisao: Projeto=P0QA Agent3 20260511, Descricao=aprovar encerramento da validacao P0 pos v1.10, Impacto=Alto, Prazo=31/05/2026, Aprovador=mbenicios@minsait.com
```

Confirm with:

```text
sim
```

## Expected SharePoint Verification Queries

Site:

```text
https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
```

Read-only PnP verification:

```powershell
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
Connect-PnPOnline -Url $siteUrl -Interactive

Get-PnPListItem -List "Projetos" -PageSize 100 -Fields "ID","Title","ProjectID","NomeProjeto","PM","StatusRAG","Percentual","Prioridade","DataAlvo","UltimaAtualizacao","Deleted" |
  Where-Object { $_["NomeProjeto"] -eq "P0QA Agent3 20260511" -and $_["Deleted"] -ne $true } |
  Select-Object Id,@{n="ProjectID";e={$_.FieldValues.ProjectID}},@{n="NomeProjeto";e={$_.FieldValues.NomeProjeto}},@{n="StatusRAG";e={$_.FieldValues.StatusRAG}},@{n="Percentual";e={$_.FieldValues.Percentual}},@{n="Deleted";e={$_.FieldValues.Deleted}}

Get-PnPListItem -List "Status Diario" -PageSize 100 -Fields "ID","Title","StatusID","ProjectID","RAG","Resumo","Risco","Bloqueio","ProximaAcao","Percentual","OrigemEntrada","Deleted" |
  Where-Object { $_["Resumo"] -eq "validacao programatica pos v1.10" -and $_["Deleted"] -ne $true } |
  Select-Object Id,@{n="StatusID";e={$_.FieldValues.StatusID}},@{n="ProjectID";e={$_.FieldValues.ProjectID}},@{n="RAG";e={$_.FieldValues.RAG}},@{n="Percentual";e={$_.FieldValues.Percentual}},@{n="OrigemEntrada";e={$_.FieldValues.OrigemEntrada}},@{n="Deleted";e={$_.FieldValues.Deleted}}

Get-PnPListItem -List "Riscos e Bloqueios" -PageSize 100 -Fields "ID","Title","RiskID","ProjectID","Tipo","Severidade","Impacto","Descricao","StatusRisco","Deleted" |
  Where-Object { $_["Descricao"] -in @("risco controlado de QA pos v1.10","bloqueio controlado de QA pos v1.10") -and $_["Deleted"] -ne $true } |
  Select-Object Id,@{n="RiskID";e={$_.FieldValues.RiskID}},@{n="ProjectID";e={$_.FieldValues.ProjectID}},@{n="Tipo";e={$_.FieldValues.Tipo}},@{n="Severidade";e={$_.FieldValues.Severidade}},@{n="Impacto";e={$_.FieldValues.Impacto}},@{n="StatusRisco";e={$_.FieldValues.StatusRisco}},@{n="Deleted";e={$_.FieldValues.Deleted}}

Get-PnPListItem -List "Decisoes do Board" -PageSize 100 -Fields "ID","Title","DecisionID","ProjectID","Descricao","Solicitante","Aprovador","Prazo","StatusDecisao","Impacto","ApproverUPN","ResponseSource","CardVersion","Deleted" |
  Where-Object { $_["Descricao"] -eq "aprovar encerramento da validacao P0 pos v1.10" -and $_["Deleted"] -ne $true } |
  Select-Object Id,@{n="DecisionID";e={$_.FieldValues.DecisionID}},@{n="ProjectID";e={$_.FieldValues.ProjectID}},@{n="StatusDecisao";e={$_.FieldValues.StatusDecisao}},@{n="Impacto";e={$_.FieldValues.Impacto}},@{n="ApproverUPN";e={$_.FieldValues.ApproverUPN}},@{n="ResponseSource";e={$_.FieldValues.ResponseSource}},@{n="Deleted";e={$_.FieldValues.Deleted}}
```

Expected results:

- `Projetos`: one active row named `P0QA Agent3 20260511`; `ProjectID` present; `Deleted` false; after AtualizarStatus, `StatusRAG=Amarelo`, `Percentual=45`, `UltimaAtualizacao` populated.
- `Status Diario`: one row with `Resumo=validacao programatica pos v1.10`, `RAG=Amarelo`, `Percentual=45`, `OrigemEntrada=CopilotStudio`, `Deleted=false`.
- `Riscos e Bloqueios`: one `Tipo=Risco`, `Severidade=Alta`, `Impacto=Alto`, `StatusRisco=Aberto`; one `Tipo=Bloqueio`, `Impacto=Medio`, `StatusRisco=Aberto`; both `Deleted=false`.
- `Decisoes do Board`: one row with `StatusDecisao=Pendente`, `Impacto=Alto`, `ApproverUPN=mbenicios@minsait.com`, `ResponseSource=CopilotStudio`, `Deleted=false`.

## Cleanup / Safety Notes

Do not run destructive cleanup as part of Agent 3 runtime verification.

Documented cleanup controls exist in:

- `.planning/stop_ship/PROD_DATA_CLEANUP_AND_QA_PLAN_20260510.md`
- `.planning/stop_ship/TEST_DATA_CLEANUP_DECISION_20260510.md`
- `deploy/cleanup_test_projects.ps1`

The checked-in cleanup script only marks selected `Projetos` rows as logically deleted. There is no equivalent approved helper for `Status Diario`, `Riscos e Bloqueios`, or `Decisoes do Board` in this task scope, so any post-test cleanup for those lists must be handled by User/Admin under the cleanup plan.
