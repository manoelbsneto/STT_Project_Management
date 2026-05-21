# AQ-09 Smoke Runbook

Date: 2026-05-20  
Executor: Owner only for chat/runtime tests  
Prepared by: CODEX-PA  
Environment: ColOfertasBrasilPro  
Bot: Assistente PMO V2  
Decision rule: Section A is ship-gating. Section B is accepted legacy debt evidence only.

## Do Not Run Until

1. Owner manually remediates the five in-scope P0 topic bindings:
   - `AtualizarStatus` -> `PM0_PA_Card_AtualizarStatus`
   - `AtualizarTarefa` -> `PM0_PA_Card_AtualizarTarefa`
   - `ConsultarPortfolio` -> `PM0_PA_Card_ResumoExecutivoPortfolio`
   - `CriarTarefa` -> `PM0_PA_Card_CriarTarefa`
   - `ListarTarefas` -> `PM0_PA_Card_ListarTarefas`
2. CODEX-PA re-runs AQ-08 read-only verification and confirms those five topics reference `PM0_PA_Card_*`.
3. Owner imports/publishes the approved package/bot.
4. Owner opens a fresh Copilot Studio chat session.

## Shared Preconditions

| Field | Value |
|---|---|
| Active project name | `QA Robust 20260513 F` |
| Active ProjectID | `PRJ-274E5ACC` |
| Active project SharePoint item | `33` |
| Known active task for update | `15` unless Owner chooses a newer active task |
| Known deleted task for audit | `13` |
| SharePoint site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |

## PnP Read-Only Setup

Owner runs this once in Windows PowerShell 5.1, then runs the per-test read commands in the same process:

```powershell
$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin
```

## Section A - In-Scope P0 Ship Gate

Any FAIL or any `ContentFiltered` / `openAIIndirectAttack` in Section A is `NO-SHIP`.

### A1 - CMD-12-H - ListarTarefas

| Field | Value |
|---|---|
| Exact chat input | `listar tarefas QA Robust 20260513 F` |
| Expected bot output | Static plain-text list or static completion text; no markdown pipes; no responsible email exposed |
| Expected SharePoint side effect | None |
| XPIA check | Must NOT trigger `ContentFiltered` or `openAIIndirectAttack` |
| Screenshot target | `.planning/comms/aq09_smoke_runbook_20260520/screenshots/A1_CMD-12-H_chat.png` |

PnP read command:

```powershell
Get-PnPListItem -List "Tarefas" -PageSize 100 -Fields "ID","Title","ProjectID","Status","Responsavel","DataFim","Prioridade","HorasRealizadas","Deleted" |
  Where-Object { $_["ProjectID"] -eq "PRJ-274E5ACC" } |
  Select-Object Id,@{n="Title";e={$_["Title"]}},@{n="Status";e={$_["Status"]}},@{n="Deleted";e={$_["Deleted"]}}
```

### A2 - CMD-15 - ConsultarPortfolio

| Field | Value |
|---|---|
| Exact chat input | `consultar portfolio` |
| Expected bot output | Static numeric counts for portfolio/RAG/drift |
| Expected SharePoint side effect | None |
| XPIA check | Must NOT trigger `ContentFiltered` or `openAIIndirectAttack` |
| Screenshot target | `.planning/comms/aq09_smoke_runbook_20260520/screenshots/A2_CMD-15_chat.png` |

PnP read command:

```powershell
Get-PnPListItem -List "Projetos" -PageSize 100 -Fields "ID","Title","ProjectID","StatusRAG","Ativo","Deleted","UltimaAtualizacao" |
  Where-Object { $_["Ativo"] -eq $true -and $_["Deleted"] -ne $true } |
  Group-Object {
    $rag = $_["StatusRAG"]
    if ($rag -and $rag.PSObject.Properties.Name -contains "LookupValue") { $rag.LookupValue } else { [string]$rag }
  } |
  Select-Object Name,Count
```

### A3 - CMD-11-P0 - CriarTarefa

| Field | Value |
|---|---|
| Exact chat input | `criar tarefa: projeto=QA Robust 20260513 F, titulo=QA CriarTarefa Smoke 315 20260520, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media` then `sim` |
| Expected bot output | Static task-created confirmation; no raw SharePoint JSON; no responsible email required in final response |
| Expected SharePoint side effect | One new `Tarefas` row with `ProjectID=PRJ-274E5ACC`, `Deleted=false`, title marker `QA CriarTarefa Smoke 315 20260520` |
| XPIA check | Must NOT trigger `ContentFiltered` or `openAIIndirectAttack` |
| Screenshot target | `.planning/comms/aq09_smoke_runbook_20260520/screenshots/A3_CMD-11-P0_chat.png` |

PnP read command:

```powershell
Get-PnPListItem -List "Tarefas" -PageSize 100 -Fields "ID","Title","ProjectID","Status","Responsavel","DataFim","Prioridade","HorasEstimadas","Deleted" |
  Where-Object { $_["Title"] -eq "QA CriarTarefa Smoke 315 20260520" } |
  Select-Object Id,@{n="Title";e={$_["Title"]}},@{n="ProjectID";e={$_["ProjectID"]}},@{n="Status";e={$_["Status"]}},@{n="Deleted";e={$_["Deleted"]}}
```

### A4 - CMD-13A - AtualizarTarefa Skip

| Field | Value |
|---|---|
| Exact chat input | `atualizar tarefa` then `15, em andamento, 2, nao, nao, nao, sim` |
| Expected bot output | Bot preserves existing optional fields; no `FlowActionBadGateway`; if BLK-AT-001 display patch is applied, visible optional fields show `(mantido)` instead of raw `nao` |
| Expected SharePoint side effect | Task `15` preserves `Responsavel`, `DataFim`, and `Prioridade`; updates status/hours only as intended |
| XPIA check | Must NOT trigger `ContentFiltered` or `openAIIndirectAttack` |
| Screenshot target | `.planning/comms/aq09_smoke_runbook_20260520/screenshots/A4_CMD-13A_chat.png` |

PnP read command:

```powershell
Get-PnPListItem -List "Tarefas" -Id 15 -Fields "ID","Title","ProjectID","Status","Responsavel","DataFim","Prioridade","HorasRealizadas","Deleted" |
  Select-Object Id,@{n="Title";e={$_["Title"]}},@{n="Status";e={$_["Status"]}},@{n="Responsavel";e={$_["Responsavel"]}},@{n="DataFim";e={$_["DataFim"]}},@{n="Prioridade";e={$_["Prioridade"]}},@{n="HorasRealizadas";e={$_["HorasRealizadas"]}},@{n="Deleted";e={$_["Deleted"]}}
```

Known issue rule: if BLK-AT-001 display patch was not applied, raw `nao` in display is a known issue to capture. It is still a Section A product defect, but classify it under BLK-AT-001 rather than XPIA-01.

### A5 - CMD-10 - AtualizarStatus

| Field | Value |
|---|---|
| Exact chat input | `atualizar status: projeto=QA Robust 20260513 F, status=Amarelo, resumo=Smoke 3.15 multilinha, percentual=45, risco=Nenhum, bloqueio=Nenhum, proxima acao=Revisar` then `sim` |
| Expected bot output | Confirmation with parsed fields |
| Expected SharePoint side effect | One `Status Diario` row created with structured fields populated |
| XPIA check | Must NOT trigger `ContentFiltered` or `openAIIndirectAttack` |
| Screenshot target | `.planning/comms/aq09_smoke_runbook_20260520/screenshots/A5_CMD-10_chat.png` |

PnP read command:

```powershell
Get-PnPListItem -List "Status Diario" -PageSize 100 -Fields "ID","StatusID","ProjectID","RAG","Resumo","Percentual","Risco","Bloqueio","ProximaAcao","Deleted","Created" |
  Where-Object { $_["ProjectID"] -eq "PRJ-274E5ACC" -and $_["Resumo"] -like "*Smoke 3.15 multilinha*" } |
  Sort-Object { $_["Created"] } -Descending |
  Select-Object -First 3 Id,@{n="StatusID";e={$_["StatusID"]}},@{n="RAG";e={$_["RAG"]}},@{n="Resumo";e={$_["Resumo"]}},@{n="Percentual";e={$_["Percentual"]}},@{n="Deleted";e={$_["Deleted"]}}
```

## Section B - Legacy Out-of-Scope Debt Evidence

These seven legacy topics remain on `PMO_PA_*` by accepted architectural debt. XPIA recurrence here is logged as backlog evidence and does not block ship for this release unless it causes data loss, duplicate writes, or other high-severity business damage.

### B0 - SP-AUDIT - Deleted Task Audit

| Field | Value |
|---|---|
| Exact chat input | None |
| Expected bot output | n/a |
| Expected SharePoint side effect | None |
| XPIA check | n/a |
| Screenshot target | `.planning/comms/aq09_smoke_runbook_20260520/screenshots/B0_SP-AUDIT_pnp.png` |

PnP read command:

```powershell
Get-PnPListItem -List "Tarefas" -Id 13 -Fields "ID","Title","Deleted","DeletedAt","DeletedReason","DeletedByUPN" |
  Select-Object Id,@{n="Title";e={$_["Title"]}},@{n="Deleted";e={$_["Deleted"]}},@{n="DeletedAt";e={$_["DeletedAt"]}},@{n="DeletedReason";e={$_["DeletedReason"]}},@{n="DeletedByUPN";e={$_["DeletedByUPN"]}}
```

### B1 - ConsultarProjeto

Exact chat input:

```text
consultar projeto QA Robust 20260513 F
```

Expected: project summary if legacy route works. `ContentFiltered` is accepted as legacy debt evidence.

### B2 - CriarProjeto Duplicate Guard

Exact chat input:

```text
criar projeto: NomeProjeto=QA Robust 20260513 F, PM=mbenicios@minsait.com, Prazo=30/06/2026, Prioridade=Media
```

Then:

```text
sim
```

Expected: duplicate guard or no duplicate active project. `ContentFiltered` is accepted as legacy debt evidence.

PnP read:

```powershell
Get-PnPListItem -List "Projetos" -PageSize 100 -Fields "ID","Title","NomeProjeto","ProjectID","Ativo","Deleted" |
  Where-Object { $_["Title"] -eq "QA Robust 20260513 F" -or $_["NomeProjeto"] -eq "QA Robust 20260513 F" } |
  Select-Object Id,@{n="Title";e={$_["Title"]}},@{n="NomeProjeto";e={$_["NomeProjeto"]}},@{n="ProjectID";e={$_["ProjectID"]}},@{n="Ativo";e={$_["Ativo"]}},@{n="Deleted";e={$_["Deleted"]}}
```

### B3 - ExcluirProjeto Cancel Path

Exact chat input:

```text
excluir projeto: projeto=QA Robust 20260513 F, motivo=smoke legacy cancelamento
```

Then:

```text
nao
```

Expected: no deletion. `ContentFiltered` is accepted as legacy debt evidence.

### B4 - ExcluirTarefa Cancel Path

Exact chat input:

```text
excluir tarefa: projeto=QA Robust 20260513 F, tarefa=15, motivo=smoke legacy cancelamento
```

Then:

```text
nao
```

Expected: task `15` remains active. `ContentFiltered` is accepted as legacy debt evidence.

### B5 - PedirDecisao Invalid UPN

Exact chat input:

```text
pedir decisao: projeto=QA Robust 20260513 F, descricao=Validar publish regex 3.4 negativo, impacto=Alto, prazo=30/06/2026, aprovador=UPN ?
```

Expected: controlled invalid-UPN message; no row created in `Decisoes do Board`. `ContentFiltered` is accepted as legacy debt evidence.

PnP read:

```powershell
Get-PnPListItem -List "Decisoes do Board" -PageSize 100 -Fields "ID","DecisionID","ProjectID","Descricao","Aprovador","StatusDecisao","Deleted","Created" |
  Where-Object { $_["Descricao"] -like "*Validar publish regex 3.4 negativo*" } |
  Select-Object Id,@{n="DecisionID";e={$_["DecisionID"]}},@{n="Descricao";e={$_["Descricao"]}},@{n="StatusDecisao";e={$_["StatusDecisao"]}},@{n="Deleted";e={$_["Deleted"]}}
```

### B5b - PedirDecisao Valid Path Optional

Run only if Owner wants positive legacy write evidence.

Exact chat input:

```text
pedir decisao: projeto=QA Robust 20260513 F, descricao=Aprovar smoke 3.15 pos-publish, impacto=Alto, prazo=30/06/2026, aprovador=mbenicios@minsait.com
```

Then:

```text
sim
```

Expected: new row in `Decisoes do Board`, `StatusDecisao=Pendente`. `ContentFiltered` is accepted as legacy debt evidence.

### B6 - RegistrarBloqueio Cancel Path

Exact chat input:

```text
registrar bloqueio: projeto=QA Robust 20260513 F, descricao=Smoke legacy bloqueio cancelado, impacto=Baixo
```

Then:

```text
nao
```

Expected: no row created. `ContentFiltered` is accepted as legacy debt evidence.

### B7 - RegistrarRisco Cancel Path

Exact chat input:

```text
registrar risco: projeto=QA Robust 20260513 F, descricao=Smoke legacy risco cancelado, severidade=Baixa
```

Then:

```text
nao
```

Expected: no row created. `ContentFiltered` is accepted as legacy debt evidence.

## Stop Conditions

| Condition | Decision |
|---|---|
| Any Section A test has `ContentFiltered` or `openAIIndirectAttack` | NO-SHIP |
| Any Section A write/read side effect fails | NO-SHIP |
| A4 data is preserved but display still shows raw `nao` and BLK-AT-001 patch was not applied | Known issue; capture under BLK-AT-001 |
| Any Section B test has XPIA recurrence only | Backlog evidence; not ship-blocking |
| Any Section B test causes data loss or unexpected write despite cancel/invalid path | NO-SHIP |

## Evidence Storage

Save chat transcripts, copied error text, PnP output, run history IDs, and screenshot paths under:

```text
.planning/comms/aq09_smoke_runbook_20260520/evidence/
```

Use `EVIDENCE_TEMPLATE.md` in this folder for PASS/FAIL capture.
