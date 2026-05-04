# Tenant Command Runbook — PMO Intelligent Hub

Este documento é a referência operacional obrigatória para executar comandos no tenant deste projeto. Use exatamente estas versões, shells e padrões antes de declarar bloqueio.

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
