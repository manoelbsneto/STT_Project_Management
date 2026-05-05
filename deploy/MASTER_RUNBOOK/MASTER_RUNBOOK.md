# Master Remote Access Runbook — Power Platform & M365 Automation

> **Official guide for all projects.** This document is the single authoritative reference for any AI agent or engineer operating on this tenant. It supersedes `SHAREPOINT_ACCESS_RUNBOOK.md` (now deprecated). All operations — SharePoint, Power Automate, Copilot Studio, Solutions, Teams — are cataloged here with exact versions, shells, commands, and proven patterns.
>
> **Last updated:** 2026-05-04 — Consolidated from TENANT_COMMAND_RUNBOOK.md + SHAREPOINT_ACCESS_RUNBOOK.md.

Este documento é a referência operacional obrigatória para executar comandos no tenant. Use exatamente estas versões, shells e padrões antes de declarar bloqueio.

## Valores Fixos Do Tenant

| Item | Valor |
|---|---|
| Tenant ID | `7808e005-1489-4374-954b-d3b08f193920` |
| Power Platform environment | `ColOfertasBrasilPro` |
| Environment ID | `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| Environment URL | `https://colofertasbrasilpro.crm4.dynamics.com/` |
| Organization ID | `e0b9c35e-79a2-ef11-8a66-000d3a24857a` |
| Organization unique name | `unqe0b9c35e79a2ef118a66000d3a248` |
| SharePoint site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |
| Teams Group ID | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Teams Channel ID | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` |

## Versões Instaladas Confirmadas

| Ferramenta | Versão / caminho |
|---|---|
| Windows PowerShell | `5.1.26100.8115` |
| PowerShell Core | `7.6.1` |
| PAC CLI | `2.6.4+ga488322 (.NET Framework 4.8.9325.0)` |
| SharePointPnPPowerShellOnline | `3.29.2101.0` em `C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\3.29.2101.0\SharePointPnPPowerShellOnline.psd1` |
| Microsoft.PowerApps.PowerShell | `1.0.45` em `C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1` |
| Microsoft.PowerApps.Administration.PowerShell | `2.0.217` em `C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1` |

## Regras Que Não Podem Ser Quebradas

- Não usar Default environment. Sempre `ColOfertasBrasilPro`.
- Não usar PowerShell 7 para SharePoint legado PnP.
- Não usar `Connect-PnPOnline -Interactive` neste projeto.
- Não usar PnP.PowerShell moderno para o provisionamento SharePoint deste tenant.
- Não usar `ClientId`, app registration, service principal, certificate auth, Graph direto ou HTTP Premium.
- Não usar `Test-PowerAppsAccount` como pré-teste obrigatório; ele pode travar mesmo quando `Get-Flow` funciona.
- Não declarar bloqueio antes de testar Windows PowerShell 5.1 com import absoluto dos módulos.

## 1. SharePoint — Login E Execução Correta

Use Windows PowerShell 5.1 e `SharePointPnPPowerShellOnline 3.29.2101.0`.

Comando interativo recomendado:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass
```

Dentro da janela Windows PowerShell 5.1:

```powershell
$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"
$repo = "D:\VMs\STT_Project_Management"
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"

Set-Location $repo
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin

.\deploy\SP_Provisioning.ps1 -SiteUrl $siteUrl -SkipConnection
```

Importante: `Connect-PnPOnline` e o script que usa PnP devem rodar no mesmo processo PowerShell.

Verificação SharePoint no mesmo processo:

```powershell
$lists = "Projetos","Status Diario","Riscos e Bloqueios","Decisoes do Board"
foreach ($list in $lists) {
  $l = Get-PnPList -Identity $list -Includes Fields,Views,ItemCount
  [pscustomobject]@{
    List = $l.Title
    ItemCount = $l.ItemCount
    CustomFields = @($l.Fields | Where-Object { -not $_.Hidden -and -not $_.ReadOnlyField }).Count
    Views = (($l.Views | Select-Object -ExpandProperty Title) -join ", ")
  }
}
```

## 2. PAC CLI — Ambiente, Conexões E Solutions

Verificar autenticação:

```powershell
pac auth list
pac env who
```

Se não estiver autenticado ou se estiver em outro ambiente:

```powershell
pac auth create --name COLQA0424 --deviceCode --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
pac env select --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
pac env who
```

Conferir conexões Standard:

```powershell
pac connection list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

Conexões confirmadas para este projeto:

| Conector | Connection ID |
|---|---|
| SharePoint | `44f187cde7f54f208cf22bac4e533816` |
| Teams | `shared-teams-1440d346-f1dd-44ea-912f-3787038ac333` |
| Office 365 Outlook | `306d783533364cb6948ab2830fc3b188` |

Listar solutions:

```powershell
pac solution list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

Exportar solution:

```powershell
pac solution export --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --name <SolutionUniqueName> --path ".\exports\<SolutionUniqueName>.zip" --overwrite
```

Unpack:

```powershell
pac solution unpack --zipfile ".\exports\<SolutionUniqueName>.zip" --folder ".\exports\<SolutionUniqueName>_unpacked" --processCanvasApps
```

Pack:

```powershell
pac solution pack --zipfile ".\exports\<SolutionUniqueName>_patched.zip" --folder ".\exports\<SolutionUniqueName>_unpacked"
```

Import:

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path ".\exports\<SolutionUniqueName>_patched.zip" --activate-plugins
```

## 3. Power Automate — Método Que Funciona

Use Windows PowerShell 5.1 com import absoluto do módulo `Microsoft.PowerApps.PowerShell`.

Comando base:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass
```

Dentro da janela:

```powershell
$ErrorActionPreference = "Stop"
$envId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
$repo = "D:\VMs\STT_Project_Management"

$powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"
$adminModule = "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1"

Set-Location $repo
Import-Module $adminModule -ErrorAction Stop
Import-Module $powerAppsModule -ErrorAction Stop
```

Se precisar login interativo:

```powershell
Add-PowerAppsAccount -Endpoint prod
```

Quando pedir senha/MFA, o usuário deve completar a janela interativa. Não substituir por username/password se MFA estiver exigido.

Não rode `Test-PowerAppsAccount` como bloqueio. Teste diretamente:

```powershell
Get-Flow -EnvironmentName $envId -Top 5
```

## 4. Inventário Dos Flows PMO

```powershell
$envId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
Get-Flow -EnvironmentName $envId -Top 200 |
  Where-Object { $_.DisplayName -like "PMO_PA_*" } |
  Select-Object DisplayName,FlowName,Enabled,CreatedTime,LastModifiedTime,
    @{n="State";e={$_.Internal.properties.state}},
    @{n="WorkflowEntityId";e={$_.Internal.properties.workflowEntityId}} |
  ConvertTo-Json -Depth 8
```

Flows G2 confirmados em `ColOfertasBrasilPro`:

| Flow | FlowName |
|---|---|
| `PMO_PA_AlertaProjetoVermelho` | `5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd` |
| `PMO_PA_ProcessarRespostaCheckIn` | `6c8ae320-46e0-42da-bc05-5d5a9622be03` |
| `PMO_PA_CheckInOnDemand` | `c9e51483-38e7-422a-98cd-cf7604d14a16` |
| `PMO_PA_EnviarCheckInDiario` | `e117bbc5-5684-4191-8d03-fb183452ac5f` |
| `PMO_PA_AlertaSemAtualizacao` | `0550c8ba-faf8-4e21-864e-d1fa5f625ce7` |

## 5. Exportar Definição De Um Flow

```powershell
$envId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
$flowName = "6c8ae320-46e0-42da-bc05-5d5a9622be03"
$out = ".planning\comms\flow_definition_$flowName.json"

$flow = Get-Flow -EnvironmentName $envId -FlowName $flowName -ErrorAction Stop
$flow.Internal.properties.definition |
  ConvertTo-Json -Depth 100 |
  Set-Content -LiteralPath $out -Encoding UTF8
```

Resumo de triggers/actions:

```powershell
$flow = Get-Flow -EnvironmentName $envId -FlowName $flowName -ErrorAction Stop
$flow.Internal.properties.definitionSummary | ConvertTo-Json -Depth 20
```

## 6. Patch ProcessSimple De Flow Existente

Este é o padrão usado no projeto anterior e deve ser reaproveitado para trocar placeholders por definições reais.

```powershell
$envId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
$flowName = "<FLOW_GUID>"
$displayName = "<FLOW_DISPLAY_NAME>"
$definitionPath = ".\deploy\flows\<definition>.json"

$definition = Get-Content -LiteralPath $definitionPath -Raw | ConvertFrom-Json -Depth 100

$body = [ordered]@{
  name = $flowName
  type = "Microsoft.ProcessSimple/environments/flows"
  id = "/providers/Microsoft.ProcessSimple/environments/$envId/flows/$flowName"
  properties = [ordered]@{
    apiId = "/providers/Microsoft.PowerApps/apis/shared_logicflows"
    displayName = $displayName
    definition = $definition
    connectionReferences = [ordered]@{
      shared_sharepointonline = [ordered]@{
        connectionName = "44f187cde7f54f208cf22bac4e533816"
        connectionReferenceLogicalName = "pmo_sharepoint"
        source = "Invoker"
        id = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
        displayName = "SharePoint"
        tier = "Standard"
        apiName = "sharepointonline"
        isProcessSimpleApiReferenceConversionAlreadyDone = $false
      }
      shared_teams = [ordered]@{
        connectionName = "shared-teams-1440d346-f1dd-44ea-912f-3787038ac333"
        connectionReferenceLogicalName = "pmo_teams"
        source = "Invoker"
        id = "/providers/Microsoft.PowerApps/apis/shared_teams"
        displayName = "Microsoft Teams"
        tier = "Standard"
        apiName = "teams"
        isProcessSimpleApiReferenceConversionAlreadyDone = $false
      }
      shared_office365 = [ordered]@{
        connectionName = "306d783533364cb6948ab2830fc3b188"
        connectionReferenceLogicalName = "pmo_office365"
        source = "Invoker"
        id = "/providers/Microsoft.PowerApps/apis/shared_office365"
        displayName = "Office 365 Outlook"
        tier = "Standard"
        apiName = "office365"
        isProcessSimpleApiReferenceConversionAlreadyDone = $false
      }
    }
    flowOpenAiData = [ordered]@{
      isConsequential = $false
      isConsequentialFlagOverwritten = $false
    }
  }
}

$body | ConvertTo-Json -Depth 100 |
  Set-Content -LiteralPath ".planning\comms\processsimple_patch_request_$flowName.json" -Encoding UTF8

InvokeApi `
  -Method PATCH `
  -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$envId/flows/$flowName" `
  -Body $body `
  -ApiVersion "2016-11-01" `
  -ThrowOnFailure |
  ConvertTo-Json -Depth 100 |
  Set-Content -LiteralPath ".planning\comms\processsimple_patch_result_$flowName.json" -Encoding UTF8
```

## 7. Criar Flow Via ProcessSimple

Use apenas quando o flow ainda não existir.

```powershell
$envId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
$flowName = [guid]::NewGuid().ToString()
$displayName = "<FLOW_DISPLAY_NAME>"
$definition = Get-Content ".\deploy\flows\<definition>.json" -Raw | ConvertFrom-Json -Depth 100

$body = [ordered]@{
  name = $flowName
  type = "Microsoft.ProcessSimple/environments/flows"
  id = "/providers/Microsoft.ProcessSimple/environments/$envId/flows/$flowName"
  properties = [ordered]@{
    apiId = "/providers/Microsoft.PowerApps/apis/shared_logicflows"
    displayName = $displayName
    definition = $definition
    connectionReferences = [ordered]@{
      shared_sharepointonline = @{
        connectionName = "44f187cde7f54f208cf22bac4e533816"
        source = "Invoker"
        id = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
        displayName = "SharePoint"
        tier = "Standard"
        apiName = "sharepointonline"
        isProcessSimpleApiReferenceConversionAlreadyDone = $false
      }
    }
    flowOpenAiData = @{
      isConsequential = $false
      isConsequentialFlagOverwritten = $false
    }
  }
}

InvokeApi `
  -Method POST `
  -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$envId/flows" `
  -Body $body `
  -ApiVersion "2016-11-01" `
  -ThrowOnFailure
```

## 8. Capturar Runs E Actions De Um Flow

Listar runs:

```powershell
$envId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
$flowName = "<FLOW_GUID>"

InvokeApi `
  -Method GET `
  -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$envId/flows/$flowName/runs?api-version=2016-11-01" `
  -ApiVersion "2016-11-01" |
  ConvertTo-Json -Depth 100 |
  Set-Content ".planning\comms\flow_runs_$flowName.json" -Encoding UTF8
```

Capturar actions de um run:

```powershell
$runName = "<RUN_NAME>"
InvokeApi `
  -Method GET `
  -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$envId/flows/$flowName/runs/$runName/actions?api-version=2016-11-01" `
  -ApiVersion "2016-11-01" |
  ConvertTo-Json -Depth 100 |
  Set-Content ".planning\comms\flow_run_actions_${flowName}_${runName}.json" -Encoding UTF8
```

## 9. G2 Wiring — Campos Corretos

Para `PMO_PA_ProcessarRespostaCheckIn`, o card `deploy/cards/CheckInDiario.json` envia:

| Payload | Destino correto |
|---|---|
| `projectId` | `Status Diario.ProjectID`; usado para buscar `Projetos.ProjectID` |
| `statusRAG` | `Status Diario.RAG`; `Projetos.StatusRAG` |
| `percentual` | `Status Diario.Percentual`; `Projetos.Percentual` |
| `resumo` | `Status Diario.Resumo` |
| `risco` | `Status Diario.Risco` |
| `bloqueio` | `Status Diario.Bloqueio` |
| `proximaAcao` | `Status Diario.ProximaAcao` |

Campos reais da lista `Status Diario`:

- `StatusID`
- `ProjectID`
- `DataRegistro`
- `PM`
- `RAG`
- `Resumo`
- `Risco`
- `Bloqueio`
- `ProximaAcao`
- `Percentual`
- `OrigemEntrada`
- `ResumoTarefas`
- `CardVersion`

Não usar `StatusRAG`, `DataCheckin` ou `Bloqueios` como campos da lista `Status Diario`; esses nomes não são os internal names criados no G1.

Para atualizar `Projetos`, primeiro buscar o item:

```text
Get items Projetos filter: ProjectID eq '<projectId>'
```

Depois usar o SharePoint item `ID` retornado no `Update item`.

## 10. Comandos Que Geraram Perda De Tempo E Devem Ser Evitados

Não usar:

```powershell
pwsh -File .\deploy\SP_Provisioning.ps1
Connect-PnPOnline -Interactive
Import-Module PnP.PowerShell
Test-PowerAppsAccount
Add-PowerAppsAccount -Username <user> -Password <secureString>
m365 status
pac flow ...
```

Motivos:

- `pwsh`/PnP moderno não é o caminho validado para o SharePoint deste tenant.
- `Connect-PnPOnline -Interactive` falhou neste ambiente.
- `Test-PowerAppsAccount` pode travar mesmo com `Get-Flow` funcionando.
- Username/password falha quando MFA é exigido.
- `m365` estava logged out e não foi o caminho usado no projeto anterior para Flow.
- PAC CLI `2.6.4` não possui comando `pac flow`.

## 11. Protocolo Antes De Declarar Bloqueio

Execute nesta ordem:

1. `pac env who`
2. `pac connection list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`
3. Windows PowerShell 5.1 com import absoluto de `Microsoft.PowerApps.PowerShell`.
4. `Get-Flow -EnvironmentName $envId -Top 5`
5. Inventário `PMO_PA_*`.
6. Export da definição do flow alvo.
7. Patch ProcessSimple com evidence JSON.
8. Validação via `Get-Flow` e run history.

Se algum passo pedir senha/MFA, parar e pedir ao usuário para completar a autenticação interativa naquela janela. Não trocar automaticamente de método.

## 12. Copilot Studio — Operações Completas Via PAC CLI

### 12.1 Autenticação PAC

```powershell
pac auth list
pac auth create --name COLQA0424 --deviceCode --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
pac env select --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
pac env who
```

### 12.2 Listar Bots

```powershell
pac copilot list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

### 12.3 Publicar Bot

```powershell
pac copilot publish --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --bot <BotId>
```

Bot ID do Assistente PMO: `0c4a9729-d55d-483c-8ec3-db9369583155`

### 12.4 Extrair Template Do Bot

```powershell
pac copilot extract-template --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --bot 0c4a9729-d55d-483c-8ec3-db9369583155 --templateFile ".\exports\AssistentePMO_template.yaml" --overwrite
```

### 12.5 Fetch Dados Org (FetchXML)

```powershell
pac org fetch --xmlFile ".\fetch_query.xml"
```

### 12.6 Adicionar Componentes Ao Bot

Componentes do bot (topics, actions, knowledge) são importados via **solution import** (ver §13). Cada componente é um diretório com `botcomponent.xml` + `data`.

Tipos de componenttype:
| Tipo | Código | Exemplo |
|------|--------|---------|
| AdaptiveDialog (Topic) | `9` | `pmo_AssistentePMO.topic.CriarTarefa` |
| TaskDialog (Action) | `9` | `pmo_AssistentePMO.action.PMO_PA_CriarTarefa` |
| KnowledgeSource | `16` | `pmo_AssistentePMO.topic.PMOSharePointKnowledge` |

## 13. Solution Lifecycle — Export / Unpack / Pack / Import / Delete

### 13.1 Listar Solutions

```powershell
pac solution list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

### 13.2 Exportar Solution

```powershell
pac solution export --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --name <SolutionUniqueName> --path ".\exports\<name>.zip" --overwrite
```

### 13.3 Unpack Solution

```powershell
pac solution unpack --zipfile ".\exports\<name>.zip" --folder ".\exports\<name>_unpacked" --processCanvasApps
```

### 13.4 Pack Solution

```powershell
pac solution pack --zipfile ".\exports\<name>_patched.zip" --folder ".\exports\<name>_unpacked"
```

### 13.5 Importar Solution (PROGRAMÁTICO)

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path ".\exports\<name>.zip" --publish-changes
```

**NUNCA usar import manual quando PAC CLI está disponível.** Este é o padrão validado em CS_G4_Complete.ps1, CS_G4_AddKnowledge.ps1, e Deploy_CopilotTopics.ps1.

### 13.6 Deletar Solution

```powershell
pac solution delete --solution-name <SolutionUniqueName> --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

### 13.7 Helper Invoke-Pac (Padrão Obrigatório)

```powershell
function Invoke-Pac {
    param([string]$Command, [string]$LogPath, [switch]$AllowFailure)
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $Command *>&1
    $output | Set-Content -LiteralPath $LogPath -Encoding UTF8
    $text = $output | Out-String
    $containsPacFailure = $text -match "(?m)^\s*Error:" -or $text -match "FAILURE:"
    if ((($LASTEXITCODE -ne 0) -or $containsPacFailure) -and -not $AllowFailure) {
        throw "PAC command failed with exit code $LASTEXITCODE. See $LogPath"
    }
    [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        LogPath = $LogPath
        ContainsFailure = $containsPacFailure
    }
}
```

### 13.8 Estrutura De Solution ZIP

```
solution.xml              ← manifest com publisher + version
customizations.xml        ← empty Workflows node para bot components
[Content_Types].xml       ← MIME mappings para cada data file
botcomponents/
  pmo_*.topic.X/
    botcomponent.xml      ← metadata (schemaname, componenttype, parentbotid)
    data                  ← YAML content (AdaptiveDialog ou TaskDialog)
  pmo_*.action.Y/
    botcomponent.xml
    data
bots/
  pmo_AssistentePMO/
    bot.xml               ← bot metadata
    configuration.json    ← channels, AI settings, GPT settings
```

**Cuidado:** `[Content_Types].xml` contém colchetes. Usar sempre `-LiteralPath` em PowerShell.

### 13.9 ZIP Com System.IO.Compression (Bracket-Safe)

```powershell
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in Get-ChildItem -LiteralPath $packageRoot -Recurse -File) {
        $relative = $file.FullName.Substring($packageRoot.Length).TrimStart('\', '/').Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $relative) | Out-Null
    }
} finally { $zip.Dispose() }
```

**Não usar `Compress-Archive`** para pacotes com `[Content_Types].xml` — PowerShell interpreta colchetes como wildcards.

## 14. SharePoint — Catálogo Completo De Operações

### 14.1 Shell e Módulo

| Componente | Valor |
|---|---|
| Shell | Windows PowerShell 5.1 (`powershell.exe`) |
| Módulo | `SharePointPnPPowerShellOnline` v`3.29.2101.0` |
| Auth | `Connect-PnPOnline -Url <site> -UseWebLogin` |
| Disconnect | `Disconnect-PnPOnline` |

### 14.2 Listas — CRUD

```powershell
# CREATE
New-PnPList -Title "NomeLista" -Template GenericList -OnQuickLaunch

# READ
Get-PnPList -Identity "NomeLista" -Includes Fields,Views,ItemCount

# UPDATE (rename, settings)
Set-PnPList -Identity "NomeLista" -Title "NovoNome"

# DELETE
Remove-PnPList -Identity "NomeLista" -Force
```

### 14.3 Campos — CRUD

```powershell
# CREATE (vários tipos)
Add-PnPField -List "Lista" -DisplayName "Campo" -InternalName "Campo" -Type Text -Required
Add-PnPField -List "Lista" -DisplayName "Num"   -InternalName "Num"   -Type Number
Add-PnPField -List "Lista" -DisplayName "Data"  -InternalName "Data"  -Type DateTime
Add-PnPField -List "Lista" -DisplayName "Pessoa" -InternalName "Pessoa" -Type User
Add-PnPField -List "Lista" -DisplayName "Ativo"  -InternalName "Ativo"  -Type Boolean
Add-PnPField -List "Lista" -DisplayName "Notas"  -InternalName "Notas"  -Type Note
Add-PnPField -List "Lista" -DisplayName "Link"   -InternalName "Link"   -Type URL
Add-PnPField -List "Lista" -DisplayName "Status" -InternalName "Status" -Type Choice -Choices "Opt1","Opt2","Opt3"

# CREATE via XML (campos complexos)
Add-PnPFieldFromXml -List "Lista" -FieldXml '<Field Type="DateTime" DisplayName="Data" Name="Data" Format="DateOnly" />'

# UPDATE (default value, indexação)
Set-PnPField -List "Lista" -Identity "Campo" -Values @{DefaultValue="valor"}
Set-PnPField -List "Lista" -Identity "Campo" -Values @{Indexed=$true}

# DELETE
Remove-PnPField -List "Lista" -Identity "Campo" -Force
```

### 14.4 Views

```powershell
# CREATE
New-PnPView -List "Lista" -Title "MinhaView" -ViewType Html -Fields "Campo1","Campo2" -Query '<OrderBy><FieldRef Name="Campo1" /></OrderBy>'

# DELETE
Remove-PnPView -List "Lista" -Identity "ViewName" -Force
```

### 14.5 Itens — CRUD

```powershell
# CREATE
Add-PnPListItem -List "Lista" -Values @{Campo1="valor1"; Campo2="valor2"}

# READ
Get-PnPListItem -List "Lista" -Query '<View><Query><Where><Eq><FieldRef Name="ProjectID"/><Value Type="Text">PRJ-001</Value></Eq></Where></Query></View>'

# UPDATE
Set-PnPListItem -List "Lista" -Identity <ItemId> -Values @{Status="Concluída"}

# DELETE
Remove-PnPListItem -List "Lista" -Identity <ItemId> -Force
```

### 14.6 Permissões

```powershell
# Quebrar herança
Set-PnPList -Identity "Lista" -BreakRoleInheritance -CopyRoleAssignments

# Remover role de grupo
Set-PnPListPermission -Identity "Lista" -Group "GroupName" -RemoveRole "Editar"

# Adicionar role de grupo
Set-PnPListPermission -Identity "Lista" -Group "GroupName" -AddRole "Leer"

# Roles disponíveis neste tenant (espanhol):
# Editar, Colaborar, Leer, Control total, Diseñar
```

### 14.7 Verificação Pós-Provisioning

```powershell
$lists = "Projetos","Status Diario","Riscos e Bloqueios","Decisoes do Board","Tarefas"
foreach ($list in $lists) {
    $l = Get-PnPList -Identity $list -Includes Fields,Views,ItemCount
    [pscustomobject]@{
        List = $l.Title; ItemCount = $l.ItemCount
        Fields = @($l.Fields | Where-Object { -not $_.Hidden -and -not $_.ReadOnlyField }).Count
        Views = ($l.Views | Select-Object -ExpandProperty Title) -join ", "
    }
}
```

## 15. Power Automate — Catálogo Completo De Operações

### 15.1 Shell e Módulos

| Componente | Valor |
|---|---|
| Shell | Windows PowerShell 5.1 |
| Admin Module | `Microsoft.PowerApps.Administration.PowerShell` v`2.0.217` |
| PowerApps Module | `Microsoft.PowerApps.PowerShell` v`1.0.45` |
| Auth | `Add-PowerAppsAccount -Endpoint prod` |

Paths absolutos:
```powershell
$adminModule = "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1"
$powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"
```

### 15.2 Flow Operations

| Operação | Comando | API |
|---|---|---|
| **Listar flows** | `Get-Flow -EnvironmentName $envId -Top 200` | PowerApps module |
| **Obter flow** | `Get-Flow -EnvironmentName $envId -FlowName $guid` | PowerApps module |
| **Habilitar flow** | `Enable-Flow -EnvironmentName $envId -FlowName $guid` | PowerApps module |
| **Desabilitar flow** | `Disable-Flow -EnvironmentName $envId -FlowName $guid` | PowerApps module |
| **Criar flow** | `InvokeApi -Method POST` via ProcessSimple | REST API |
| **Atualizar flow** | `InvokeApi -Method PATCH` via ProcessSimple | REST API |
| **Deletar flow** | `Remove-Flow -EnvironmentName $envId -FlowName $guid` | PowerApps module |
| **Vincular a solution** | `Set-FlowAsSolutionAware -EnvironmentName $envId -FlowName $guid -SolutionId $sid` | Admin module |
| **Listar runs** | `InvokeApi GET .../flows/$guid/runs` | ProcessSimple |
| **Listar actions de run** | `InvokeApi GET .../flows/$guid/runs/$runId/actions` | ProcessSimple |
| **Exportar definição** | `$flow.Internal.properties.definition \| ConvertTo-Json` | PowerApps module |

### 15.3 ProcessSimple REST API

Base URL: `https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$envId`

| Método | Rota | Operação |
|---|---|---|
| `POST` | `/flows` | Criar flow |
| `PATCH` | `/flows/$flowName` | Atualizar flow |
| `GET` | `/flows?api-version=2016-11-01` | Listar todos |
| `GET` | `/flows/$flowName` | Obter flow |
| `GET` | `/flows/$flowName/runs` | Listar runs |
| `GET` | `/flows/$flowName/runs/$runId/actions` | Actions do run |

`InvokeApi` é uma função interna do módulo PowerApps que gerencia auth automaticamente.

### 15.4 Trigger Types Usados

| Trigger Kind | Uso | Exemplo |
|---|---|---|
| `Skills` | Copilot Studio "When agent calls flow" | CriarTarefa, ListarTarefas, AtualizarTarefa |
| `Request` (manual) | Manual trigger | N/A neste projeto |
| `Recurrence` | Agendamento | ResumoDiarioBoard (17h), ResumoSemanal (Monday 8h) |
| `PostCardAndWaitForResponse` | Card interativo → wait response | EnviarCheckInDiario, CheckInOnDemand |

### 15.5 Connection References Deste Tenant

| Conector | Connection ID | API Name |
|---|---|---|
| SharePoint | `44f187cde7f54f208cf22bac4e533816` | `shared_sharepointonline` |
| Teams | `shared-teams-1440d346-f1dd-44ea-912f-3787038ac333` | `shared_teams` |
| Office 365 Outlook | `306d783533364cb6948ab2830fc3b188` | `shared_office365` |
| Planner | criado via portal | `shared_planner` |

## 16. Flows Inventário Completo

### v1.0 (P0 — G2)

| Flow | GUID | Trigger |
|---|---|---|
| PMO_PA_AlertaProjetoVermelho | `5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd` | Recurrence |
| PMO_PA_ProcessarRespostaCheckIn | `6c8ae320-46e0-42da-bc05-5d5a9622be03` | PostCardWait |
| PMO_PA_CheckInOnDemand | `c9e51483-38e7-422a-98cd-cf7604d14a16` | PostCardWait |
| PMO_PA_EnviarCheckInDiario | `e117bbc5-5684-4191-8d03-fb183452ac5f` | Recurrence |
| PMO_PA_AlertaSemAtualizacao | `0550c8ba-faf8-4e21-864e-d1fa5f625ce7` | Recurrence |

### v1.0 (P1/P2 — G3)

| Flow | GUID | Trigger |
|---|---|---|
| PMO_PA_ResumoDiarioBoard | `a2cf01fb-8559-4398-96b8-c0e0a1c1d8a2` | Recurrence 17h |
| PMO_PA_RegistrarDecisaoBoard | `f67daf7b-53a7-4d35-9275-7c8c42a35896` | Skills |
| PMO_PA_SyncPlannerStats_Standard | `3eb1be49-a9ff-48ca-888d-847ca7ae8b04` | Recurrence |
| PMO_PA_EscalarRiscoCritico | `cd0467a2-c989-474e-a629-28c704913489` | Skills |
| PMO_PA_ResumoSemanal | `1964c4bf-ef25-4e46-a88d-4a5a89c71bfb` | Recurrence Mon 8h |

### v1.1 (Task CRUD — G8)

| Flow | GUID | Trigger |
|---|---|---|
| PMO_PA_CriarTarefa | `4b6b0fe9-9866-4cec-b66a-6a22c366223f` | Skills |
| PMO_PA_ListarTarefas | `9aeed2ff-1fb3-4e75-bc2c-dcbe950c834a` | Skills |
| PMO_PA_AtualizarTarefa | `cf4a5713-68fe-416c-b4e3-562e70fd6708` | Skills |

## 17. Copilot Studio — Componentes Do Bot

Bot: `Assistente PMO` — `0c4a9729-d55d-483c-8ec3-db9369583155`

### v1.0 Topics (8)

| Topic | Tipo |
|---|---|
| ConsultarPortfolio | AdaptiveDialog |
| AtualizarProjeto | AdaptiveDialog |
| ConsultarProjeto | AdaptiveDialog |
| RegistrarRisco | AdaptiveDialog |
| SolicitarDecisao | AdaptiveDialog |
| Saudacao | AdaptiveDialog |
| Ajuda | AdaptiveDialog |
| FallbackDesconhecido | AdaptiveDialog |

### v1.0 Actions (3)

| Action | Flow Vinculado |
|---|---|
| PMO_PA_CheckInOnDemand | `f5aab85e-ff46-f111-bec7-7ced8d955c6c` |
| PMO_PA_EscalarRiscoCritico | `e5381002-0547-f111-bec7-000d3abc5cc6` |
| PMO_PA_RegistrarDecisaoBoard | `b308fe0b-0547-f111-bec7-7ced8d955c6c` |

### v1.1 Topics (3 — Phase 9)

| Topic | Tipo | Padrão |
|---|---|---|
| CriarTarefa | AdaptiveDialog | 6 perguntas + BooleanPrebuiltEntity confirm |
| ListarTarefas | AdaptiveDialog | Adaptive Card v1.5 output |
| AtualizarTarefa | AdaptiveDialog | 6 perguntas + BooleanPrebuiltEntity confirm |

### v1.1 Actions (3 — Phase 9)

| Action | Flow GUID Vinculado |
|---|---|
| PMO_PA_CriarTarefa | `4b6b0fe9-9866-4cec-b66a-6a22c366223f` |
| PMO_PA_ListarTarefas | `9aeed2ff-1fb3-4e75-bc2c-dcbe950c834a` |
| PMO_PA_AtualizarTarefa | `cf4a5713-68fe-416c-b4e3-562e70fd6708` |

## 18. Deploy Scripts — Inventário E Propósito

| Script | Fase | Propósito |
|---|---|---|
| `deploy/SP_Provisioning.ps1` | G1 | Provisionar 4 listas SharePoint + views + seed data |
| `deploy/SP_Provisioning_Tarefas.ps1` | G7 | Provisionar lista Tarefas + 8 colunas + indexes + permissions |
| `deploy/PA_Provisioning_P0.ps1` | G2 | Criar 5 flows P0 via ProcessSimple POST |
| `deploy/PA_Patch_G2_Wiring.ps1` | G2 | Wiring fix para ProcessarRespostaCheckIn + AlertaVermelho |
| `deploy/PA_Redesign_G2_PostCardWait.ps1` | G2 | Redesign para PostCardAndWaitForResponse |
| `deploy/PA_Phase3_P1P2.ps1` | G3 | Criar 5 flows P1/P2 via ProcessSimple |
| `deploy/CS_G4_Complete.ps1` | G4 | Bot complete: solution-aware flows + action bindings + solution import |
| `deploy/CS_G4_AddKnowledge.ps1` | G4 | Adicionar SharePoint Knowledge Source ao bot |
| `deploy/Teams_Phase5_Tabs.ps1` | G5 | Criar tabs SharePoint no Teams (tentativa PnP) |
| `deploy/Teams_Phase5_GraphTabs.ps1` | G5 | Criar tabs via Graph API (bloqueado por RBAC) |
| `deploy/Teams_Phase5_InteractiveTabs.ps1` | G5 | Tabs interativos (bloqueado por RBAC) |
| `deploy/QA_Phase6_Automated.ps1` | G6 | QA automatizado: 14 testes (SP, flows, bot) |
| `deploy/flows/Deploy_CriarTarefa.ps1` | G8 | Criar flow CriarTarefa via ProcessSimple |
| `deploy/flows/Deploy_ListarTarefas.ps1` | G8 | Criar flow ListarTarefas via ProcessSimple |
| `deploy/flows/Deploy_AtualizarTarefa.ps1` | G8 | Criar flow AtualizarTarefa via ProcessSimple |
| `deploy/copilot/Deploy_CopilotTopics.ps1` | G9 | Empacotar + importar solution com 6 bot components |

## 19. Padrões De Código Obrigatórios

### 19.1 Evidence Pattern

Todo deploy DEVE gerar evidence JSON em `.planning/comms/`:
```powershell
$manifest = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    status = "PASS"
    environmentName = $envId
    # ... detalhes da operação
}
$manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
```

### 19.2 Retry Pattern

```powershell
function Invoke-WithRetry {
    param([string]$Operation, [int]$Attempts=4, [int]$DelaySeconds=8, [scriptblock]$ScriptBlock)
    for ($i = 1; $i -le $Attempts; $i++) {
        try { return & $ScriptBlock }
        catch {
            if ($i -eq $Attempts) { throw }
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}
```

### 19.3 Choice Fields Em ProcessSimple

Choice fields **DEVEM** ser enviados como Object, não String:
```powershell
# ❌ ERRADO
Status = "Pendente"

# ✅ CORRETO
Status = @{ Value = "Pendente" }
```

### 19.4 Flow Trigger Kind Para Copilot

Flows chamados pelo Copilot usam `kind = "Skills"`, **não** `PowerAppV2`:
```json
"triggers": {
    "manual": {
        "type": "Request",
        "kind": "Skills",
        "inputs": { "schema": { ... } }
    }
}
```

## 20. Adaptive Cards — Referência

| Item | Valor |
|---|---|
| Schema version | `1.5` |
| Tamanho máximo | `< 27 KB` |
| Renderização | Teams Desktop + Mobile |
| Botões interativos | Premium-only (não usar) |
| Formatação texto | `TextBlock` com `wrap: true` |

Cards deste projeto: `deploy/cards/CheckInDiario.json`

## 21. Operações Matrix — Resumo Rápido

| Operação | Ferramenta | Comando/API |
|---|---|---|
| **SP: Criar lista** | PnP Legacy 3.29 | `New-PnPList` |
| **SP: Criar campo** | PnP Legacy 3.29 | `Add-PnPField` |
| **SP: Indexar campo** | PnP Legacy 3.29 | `Set-PnPField -Values @{Indexed=$true}` |
| **SP: Criar view** | PnP Legacy 3.29 | `New-PnPView` |
| **SP: Quebrar permissões** | PnP Legacy 3.29 | `Set-PnPList -BreakRoleInheritance` |
| **SP: Mudar role** | PnP Legacy 3.29 | `Set-PnPListPermission` |
| **SP: CRUD itens** | PnP Legacy 3.29 | `Add/Get/Set/Remove-PnPListItem` |
| **PA: Criar flow** | ProcessSimple POST | `InvokeApi -Method POST` |
| **PA: Atualizar flow** | ProcessSimple PATCH | `InvokeApi -Method PATCH` |
| **PA: Listar flows** | PowerApps module | `Get-Flow` |
| **PA: Habilitar/Desabilitar** | PowerApps module | `Enable-Flow` / `Disable-Flow` |
| **PA: Deletar flow** | PowerApps module | `Remove-Flow` |
| **PA: Vincular solution** | Admin module | `Set-FlowAsSolutionAware` |
| **PA: Runs/Actions** | ProcessSimple GET | `InvokeApi -Method GET` |
| **CS: Listar bots** | PAC CLI | `pac copilot list` |
| **CS: Publicar bot** | PAC CLI | `pac copilot publish` |
| **CS: Extrair template** | PAC CLI | `pac copilot extract-template` |
| **CS: Adicionar components** | PAC CLI | `pac solution import` (solution ZIP) |
| **SOL: Listar solutions** | PAC CLI | `pac solution list` |
| **SOL: Exportar** | PAC CLI | `pac solution export` |
| **SOL: Unpack** | PAC CLI | `pac solution unpack` |
| **SOL: Pack** | PAC CLI | `pac solution pack` |
| **SOL: Importar** | PAC CLI | `pac solution import --publish-changes` |
| **SOL: Deletar** | PAC CLI | `pac solution delete` |
| **ORG: Fetch data** | PAC CLI | `pac org fetch` |
| **ENV: Info** | PAC CLI | `pac env who` |
| **CONN: Listar** | PAC CLI | `pac connection list` |

## 22. Known Gotchas — Erros Que Custaram Tempo (Leitura Obrigatoria)

Estes bugs foram descobertos durante o deploy real. Todo agente DEVE ler esta secao antes de escrever scripts.

### 22.1 Windows 8.3 Short Name vs Long Path Mismatch

**Problema:** `$env:TEMP` retorna o path com 8.3 short name (ex: `C:\Users\DATAOP~1\AppData\Local\Temp`) mas `Get-ChildItem` retorna paths com long name (ex: `C:\Users\dataops-lab\AppData\Local\Temp`). Quando voce usa `$file.FullName.Substring($packageRoot.Length)`, o offset esta errado e os paths relativos ficam com prefixo aleatorio (ex: `57/solution.xml` em vez de `solution.xml`).

**Solucao:** Sempre resolver o path real depois de criar o diretorio:
```powershell
New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
$packageRoot = (Resolve-Path -LiteralPath $packageRoot).Path
$rootLen = $packageRoot.TrimEnd('\','/').Length + 1
# Depois usar: $file.FullName.Substring($rootLen)
```

**Impacto:** ZIP com paths errados causa `Error: The solution file is invalid` no `pac solution import`.

### 22.2 Unicode/Emoji Em Scripts PowerShell 5.1

**Problema:** Scripts com caracteres Unicode (emojis como checkmark, bullet, arrows, box-drawing) falham com parser errors no PowerShell 5.1 mesmo que o arquivo esteja salvo em UTF-8. O parser do PS 5.1 nao interpreta certos multi-byte sequences corretamente.

**Caracteres proibidos e substituicoes:**
| Proibido | Substituicao |
|---|---|
| checkmark emoji | `[OK]` |
| warning emoji | `[WARN]` |
| bullet | `-` |
| right arrow | `->` |
| multiplication sign | `x` |
| box-drawing lines | `-` |

**Solucao:** Apos gerar o script, verificar e forcar ASCII:
```powershell
# Verificar
[byte[]]$b = [System.IO.File]::ReadAllBytes('script.ps1')
$non = @(); for($i=0;$i -lt $b.Length;$i++){if($b[$i] -gt 127){$non += $i}}
"Non-ASCII bytes: $($non.Count)"

# Corrigir
$c = [System.IO.File]::ReadAllText('script.ps1', [System.Text.Encoding]::UTF8)
$c = $c -replace '\u2500','-' -replace '\u2014','--' -replace '\u00d7','x'
[System.IO.File]::WriteAllText('script.ps1', $c, [System.Text.Encoding]::ASCII)
```

### 22.3 False-Positive Error Detection Em Invoke-Pac

**Problema:** O regex `$text -match "(?m)^\s*Error:"` captura textos informativos do PAC CLI que contem a palavra `Error:` mesmo quando o exit code eh 0 e a operacao foi bem-sucedida.

**Solucao:** Usar apenas `FAILURE:` como marker no `Invoke-Pac` helper. Verificar `Error:` separadamente no caller com contexto:
```powershell
# NO HELPER: so checar FAILURE:
$containsPacFailure = $text -match "FAILURE:"

# NO CALLER: checar Error: com contexto
if ($import.Output -match "(?m)^\s*Error:") {
    # Analisar se eh real antes de throw
}
```

### 22.4 Compress-Archive Quebra [Content_Types].xml

**Problema:** `Compress-Archive` do PowerShell trata colchetes `[]` como wildcards (glob patterns). O arquivo `[Content_Types].xml` nao eh incluido no ZIP ou causa erro.

**Solucao:** Sempre usar `System.IO.Compression.ZipFile`:
```powershell
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
# ...usar CreateEntryFromFile com paths literais...
$zip.Dispose()
```

### 22.5 `-LiteralPath` vs `-Path` Em PowerShell

**Problema:** `-Path` interpreta wildcards e caracteres especiais. Qualquer operacao com arquivos que contenham `[`, `]`, `*`, `?` no nome DEVE usar `-LiteralPath`.

**Regra:** Em TODO script deste projeto, usar `-LiteralPath` para:
- `Test-Path -LiteralPath`
- `Get-Content -LiteralPath`
- `Set-Content -LiteralPath`
- `Copy-Item -LiteralPath`
- `Remove-Item -LiteralPath`
- `Get-ChildItem -LiteralPath`

### 22.6 PAC CLI Nao Possui `pac flow`

**Problema:** PAC CLI `2.6.4` nao tem subcomando `pac flow`. Agentes frequentemente tentam `pac flow list` ou `pac flow create` que nao existem.

**Solucao:** Para operacoes de flow, usar o modulo `Microsoft.PowerApps.PowerShell` (`Get-Flow`, `Enable-Flow`, etc.) ou a API REST ProcessSimple (`InvokeApi`). Ver secoes 3, 15.2, e 15.3.

### 22.7 Invoke-Pac Deve Capturar Output

**Problema:** O helper original nao retornava o texto do output, impossibilitando analise pos-execucao pelo caller.

**Solucao:** Sempre incluir `Output = $text` no retorno:
```powershell
[pscustomobject]@{
    ExitCode = $LASTEXITCODE
    LogPath  = $LogPath
    Output   = $text       # <-- OBRIGATORIO
    ContainsFailure = $containsPacFailure
}
```

