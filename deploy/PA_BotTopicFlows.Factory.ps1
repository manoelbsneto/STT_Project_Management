[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("ConsultarPortfolio", "ConsultarProjeto", "RegistrarRiscoBot", "RegistrarBloqueioBot", "PedirDecisaoBot")]
    [string]$FlowKind,

    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$EnvironmentDisplayName = "ColOfertasBrasilPro",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [string]$EvidenceDir = ".planning\comms",
    [switch]$ForceCreate,
    [switch]$BuildOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
. (Join-Path $repoRoot "deploy\PMO_FlowScript.Common.ps1")
$evidenceRoot = Initialize-PMOFlowScript -RepositoryRoot $repoRoot -EvidenceDir $EvidenceDir -SkipModuleImport:$BuildOnly
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

function New-ProjectLookupActions {
    param(
        [string]$InputName,
        [hashtable]$RunAfter
    )

    [ordered]@{
        Compose_ProjectName = New-PMOCompose -Inputs "@trim(coalesce(triggerBody()?['$InputName'], triggerBody()?['projectName'], triggerBody()?['nomeProjeto'], ''))" -RunAfter $RunAfter
        Get_Projeto = New-PMOSharePointGetItems `
            -SiteUrl $SiteUrl `
            -ListName "Projetos" `
            -Filter "NomeProjeto eq '@{replace(outputs('Compose_ProjectName'),'''','''''')}' and Ativo eq 1" `
            -Top 1 `
            -RunAfter @{ Compose_ProjectName = @("Succeeded") }
    }
}

function New-ChoiceMapCompose {
    param(
        [string]$InputName,
        [string]$Default,
        [string]$CriticalValue = "Critica",
        [hashtable]$RunAfter
    )

    New-PMOCompose -RunAfter $RunAfter -Inputs "@if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], '$Default')), 'cr'), '$CriticalValue', if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], '$Default')), 'a'), 'Alto', if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], '$Default')), 'm'), 'Medio', if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], '$Default')), 'b'), 'Baixo', '$Default'))))"
}

function New-SeverityMapCompose {
    param(
        [string]$InputName,
        [string]$Default = "Media",
        [hashtable]$RunAfter
    )

    New-PMOCompose -RunAfter $RunAfter -Inputs "@if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], '$Default')), 'cr'), 'Critica', if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], '$Default')), 'a'), 'Alta', if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], '$Default')), 'b'), 'Baixa', '$Default')))"
}

function New-DateOnlyCompose {
    param(
        [string]$InputName,
        [hashtable]$RunAfter
    )

    New-PMOCompose -RunAfter $RunAfter -Inputs "@if(or(empty(triggerBody()?['$InputName']), not(contains(string(triggerBody()?['$InputName']), '/'))), triggerBody()?['$InputName'], concat(last(split(string(triggerBody()?['$InputName']), '/')), '-', if(equals(length(first(skip(split(string(triggerBody()?['$InputName']), '/'), 1))), 1), concat('0', first(skip(split(string(triggerBody()?['$InputName']), '/'), 1))), first(skip(split(string(triggerBody()?['$InputName']), '/'), 1))), '-', if(equals(length(first(split(string(triggerBody()?['$InputName']), '/'))), 1), concat('0', first(split(string(triggerBody()?['$InputName']), '/'))), first(split(string(triggerBody()?['$InputName']), '/')))))"
}

function New-PortfolioDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{} -Required @()
    $actions = [ordered]@{
        Get_Projetos_Ativos = New-PMOSharePointGetItems -SiteUrl $SiteUrl -ListName "Projetos" -Filter "Ativo eq 1" -Top 500
        Initialize_Total = New-PMOInitializeIntegerVariable -Name "varTotal" -RunAfter @{ Get_Projetos_Ativos = @("Succeeded") }
        Initialize_Verde = New-PMOInitializeIntegerVariable -Name "varVerde" -RunAfter @{ Initialize_Total = @("Succeeded") }
        Initialize_Amarelo = New-PMOInitializeIntegerVariable -Name "varAmarelo" -RunAfter @{ Initialize_Verde = @("Succeeded") }
        Initialize_Vermelho = New-PMOInitializeIntegerVariable -Name "varVermelho" -RunAfter @{ Initialize_Amarelo = @("Succeeded") }
        Initialize_SemUpdate = New-PMOInitializeIntegerVariable -Name "varSemUpdate" -RunAfter @{ Initialize_Vermelho = @("Succeeded") }
        Apply_to_each_Projeto = [ordered]@{
            type = "Foreach"
            foreach = "@body('Get_Projetos_Ativos')?['value']"
            actions = [ordered]@{
                Increment_Total = New-PMOIncrementVariable -Name "varTotal"
                Switch_StatusRAG = [ordered]@{
                    type = "Switch"
                    expression = "@coalesce(item()?['StatusRAG']?['Value'], item()?['StatusRAG'], '')"
                    cases = [ordered]@{
                        Verde = [ordered]@{
                            case = "Verde"
                            actions = [ordered]@{ Increment_Verde = New-PMOIncrementVariable -Name "varVerde" }
                        }
                        Amarelo = [ordered]@{
                            case = "Amarelo"
                            actions = [ordered]@{ Increment_Amarelo = New-PMOIncrementVariable -Name "varAmarelo" }
                        }
                        Vermelho = [ordered]@{
                            case = "Vermelho"
                            actions = [ordered]@{ Increment_Vermelho = New-PMOIncrementVariable -Name "varVermelho" }
                        }
                    }
                    default = [ordered]@{ actions = [ordered]@{} }
                    runAfter = @{ Increment_Total = @("Succeeded") }
                }
                Condition_Sem_Update = [ordered]@{
                    type = "If"
                    expression = [ordered]@{
                        and = @(
                            [ordered]@{ not = [ordered]@{ equals = @("@item()?['UltimaAtualizacao']", $null) } },
                            [ordered]@{ less = @("@ticks(item()?['UltimaAtualizacao'])", "@ticks(addDays(utcNow(), -1))") }
                        )
                    }
                    actions = [ordered]@{ Increment_SemUpdate = New-PMOIncrementVariable -Name "varSemUpdate" }
                    else = [ordered]@{ actions = [ordered]@{} }
                    runAfter = @{ Switch_StatusRAG = @("Succeeded") }
                }
            }
            runAfter = @{ Initialize_SemUpdate = @("Succeeded") }
        }
        Response_OK = New-PMOResponse -RunAfter @{ Apply_to_each_Projeto = @("Succeeded") } -Result "@{concat('Portfolio PMO: ', string(variables('varTotal')), ' projetos ativos. Verde: ', string(variables('varVerde')), ' | Amarelo: ', string(variables('varAmarelo')), ' | Vermelho: ', string(variables('varVermelho')), '. Projetos sem update (>24h): ', string(variables('varSemUpdate')), '.')}"
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

function New-ConsultarProjetoDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{ nomeProjeto = New-PMOStringProperty "Nome do projeto" } -Required @("nomeProjeto")
    $lookup = New-ProjectLookupActions -InputName "nomeProjeto" -RunAfter @{}
    $actions = [ordered]@{}
    foreach ($key in $lookup.Keys) { $actions[$key] = $lookup[$key] }
    $actions.Condition_Projeto_Encontrado = [ordered]@{
        type = "If"
        expression = [ordered]@{ greater = @("@length(body('Get_Projeto')?['value'])", 0) }
        actions = [ordered]@{
            Get_Riscos_Abertos = New-PMOSharePointGetItems `
                -SiteUrl $SiteUrl `
                -ListName "Riscos e Bloqueios" `
                -Filter "ProjectID eq '@{replace(body('Get_Projeto')?['value']?[0]?['ProjectID'],'''','''''')}' and StatusRisco eq 'Aberto'" `
                -Top 100
            Response_OK = New-PMOResponse -RunAfter @{ Get_Riscos_Abertos = @("Succeeded") } -Result "@{concat('Projeto ', coalesce(body('Get_Projeto')?['value']?[0]?['NomeProjeto'], '-'), ': RAG ', coalesce(body('Get_Projeto')?['value']?[0]?['StatusRAG']?['Value'], body('Get_Projeto')?['value']?[0]?['StatusRAG'], '-'), ', Percentual ', coalesce(string(body('Get_Projeto')?['value']?[0]?['Percentual']), '0'), '%, Data alvo ', coalesce(string(body('Get_Projeto')?['value']?[0]?['DataAlvo']), '-'), ', PM ', coalesce(body('Get_Projeto')?['value']?[0]?['PM']?['Email'], body('Get_Projeto')?['value']?[0]?['PM']?['DisplayName'], '-'), ', Ultima atualizacao ', coalesce(string(body('Get_Projeto')?['value']?[0]?['UltimaAtualizacao']), '-'), ', Riscos abertos ', string(length(body('Get_Riscos_Abertos')?['value'])), '.')}"
        }
        else = [ordered]@{
            actions = [ordered]@{
                Response_Project_Not_Found = New-PMOResponse -Result "Projeto nao encontrado. Codigo: PROJECT_NOT_FOUND."
            }
        }
        runAfter = @{ Get_Projeto = @("Succeeded") }
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

function New-RegistrarRiscoDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{
        projectName = New-PMOStringProperty "Nome do projeto"
        descricao = New-PMOStringProperty "Descricao do risco"
        severidade = New-PMOStringProperty "Severidade"
    } -Required @("projectName", "descricao", "severidade")
    $lookup = New-ProjectLookupActions -InputName "projectName" -RunAfter @{}
    $actions = [ordered]@{}
    foreach ($key in $lookup.Keys) { $actions[$key] = $lookup[$key] }
    $actions.Map_Severidade = New-SeverityMapCompose -InputName "severidade" -RunAfter @{ Get_Projeto = @("Succeeded") }
    $actions.Compose_RiskID = New-PMOCompose -Inputs "@concat('RISK-', toUpper(substring(guid(), 0, 8)))" -RunAfter @{ Map_Severidade = @("Succeeded") }
    $actions.Condition_Projeto_Encontrado = [ordered]@{
        type = "If"
        expression = [ordered]@{ greater = @("@length(body('Get_Projeto')?['value'])", 0) }
        actions = [ordered]@{
            Create_Risco_SharePoint = New-PMOSharePointPostItem `
                -SiteUrl $SiteUrl `
                -ListName "Riscos e Bloqueios" `
                -ItemFields @{
                    "Title" = "@outputs('Compose_RiskID')"
                    "RiskID" = "@outputs('Compose_RiskID')"
                    "ProjectID" = "@body('Get_Projeto')?['value']?[0]?['ProjectID']"
                    "Tipo/Value" = "Risco"
                    "Severidade/Value" = "@outputs('Map_Severidade')"
                    "Descricao" = "@triggerBody()?['descricao']"
                    "DataCriacao" = "@utcNow()"
                    "StatusRisco/Value" = "Aberto"
                }
            Response_OK = New-PMOResponse -RunAfter @{ Create_Risco_SharePoint = @("Succeeded") } -Result "@{concat('Risco ', outputs('Compose_RiskID'), ' registrado para projeto ', outputs('Compose_ProjectName'), '. Severidade: ', outputs('Map_Severidade'), '.')}"
            Response_Error_Write = New-PMOResponse -StatusCode 500 -RunAfter @{ Create_Risco_SharePoint = @("Failed", "TimedOut") } -Result "Erro ao registrar risco no SharePoint. Codigo: SP_WRITE_FAILED."
        }
        else = [ordered]@{ actions = [ordered]@{ Response_Project_Not_Found = New-PMOResponse -Result "Projeto nao encontrado. Codigo: PROJECT_NOT_FOUND." } }
        runAfter = @{ Compose_RiskID = @("Succeeded") }
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

function New-RegistrarBloqueioDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{
        projectName = New-PMOStringProperty "Nome do projeto"
        descricao = New-PMOStringProperty "Descricao do bloqueio"
        impacto = New-PMOStringProperty "Impacto"
    } -Required @("projectName", "descricao", "impacto")
    $lookup = New-ProjectLookupActions -InputName "projectName" -RunAfter @{}
    $actions = [ordered]@{}
    foreach ($key in $lookup.Keys) { $actions[$key] = $lookup[$key] }
    $actions.Map_Impacto = New-ChoiceMapCompose -InputName "impacto" -Default "Medio" -CriticalValue "Critico" -RunAfter @{ Get_Projeto = @("Succeeded") }
    $actions.Map_Severidade = New-PMOCompose -Inputs "@if(equals(outputs('Map_Impacto'), 'Critico'), 'Critica', if(equals(outputs('Map_Impacto'), 'Alto'), 'Alta', if(equals(outputs('Map_Impacto'), 'Baixo'), 'Baixa', 'Media')))" -RunAfter @{ Map_Impacto = @("Succeeded") }
    $actions.Compose_RiskID = New-PMOCompose -Inputs "@concat('BLOCK-', toUpper(substring(guid(), 0, 8)))" -RunAfter @{ Map_Severidade = @("Succeeded") }
    $actions.Condition_Projeto_Encontrado = [ordered]@{
        type = "If"
        expression = [ordered]@{ greater = @("@length(body('Get_Projeto')?['value'])", 0) }
        actions = [ordered]@{
            Create_Bloqueio_SharePoint = New-PMOSharePointPostItem `
                -SiteUrl $SiteUrl `
                -ListName "Riscos e Bloqueios" `
                -ItemFields @{
                    "Title" = "@outputs('Compose_RiskID')"
                    "RiskID" = "@outputs('Compose_RiskID')"
                    "ProjectID" = "@body('Get_Projeto')?['value']?[0]?['ProjectID']"
                    "Tipo/Value" = "Bloqueio"
                    "Severidade/Value" = "@outputs('Map_Severidade')"
                    "Impacto/Value" = "@outputs('Map_Impacto')"
                    "Descricao" = "@triggerBody()?['descricao']"
                    "DataCriacao" = "@utcNow()"
                    "StatusRisco/Value" = "Aberto"
                }
            Response_OK = New-PMOResponse -RunAfter @{ Create_Bloqueio_SharePoint = @("Succeeded") } -Result "@{concat('Bloqueio ', outputs('Compose_RiskID'), ' registrado para projeto ', outputs('Compose_ProjectName'), '. Impacto: ', outputs('Map_Impacto'), '.')}"
            Response_Error_Write = New-PMOResponse -StatusCode 500 -RunAfter @{ Create_Bloqueio_SharePoint = @("Failed", "TimedOut") } -Result "Erro ao registrar bloqueio no SharePoint. Codigo: SP_WRITE_FAILED."
        }
        else = [ordered]@{ actions = [ordered]@{ Response_Project_Not_Found = New-PMOResponse -Result "Projeto nao encontrado. Codigo: PROJECT_NOT_FOUND." } }
        runAfter = @{ Compose_RiskID = @("Succeeded") }
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

function New-PedirDecisaoDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{
        projectName = New-PMOStringProperty "Nome do projeto"
        descricao = New-PMOStringProperty "Descricao da decisao"
        impacto = New-PMOStringProperty "Impacto"
        prazo = New-PMOStringProperty "Prazo"
        aprovador = New-PMOStringProperty "UPN do aprovador"
        solicitante = New-PMOStringProperty "UPN do solicitante"
    } -Required @("projectName", "descricao", "impacto", "prazo", "aprovador")
    $lookup = New-ProjectLookupActions -InputName "projectName" -RunAfter @{}
    $actions = [ordered]@{}
    foreach ($key in $lookup.Keys) { $actions[$key] = $lookup[$key] }
    $actions.Map_Impacto = New-ChoiceMapCompose -InputName "impacto" -Default "Medio" -CriticalValue "Critico" -RunAfter @{ Get_Projeto = @("Succeeded") }
    $actions.Compose_Prazo = New-DateOnlyCompose -InputName "prazo" -RunAfter @{ Map_Impacto = @("Succeeded") }
    $actions.Compose_DecisionID = New-PMOCompose -Inputs "@concat('DEC-', toUpper(substring(guid(), 0, 8)))" -RunAfter @{ Compose_Prazo = @("Succeeded") }
    $actions.Compose_Solicitante = New-PMOCompose -Inputs "@coalesce(triggerBody()?['solicitante'], triggerBody()?['aprovador'])" -RunAfter @{ Compose_DecisionID = @("Succeeded") }
    $actions.Condition_Projeto_Encontrado = [ordered]@{
        type = "If"
        expression = [ordered]@{ greater = @("@length(body('Get_Projeto')?['value'])", 0) }
        actions = [ordered]@{
            Create_Decisao_SharePoint = New-PMOSharePointPostItem `
                -SiteUrl $SiteUrl `
                -ListName "Decisoes do Board" `
                -ItemFields @{
                    "Title" = "@outputs('Compose_DecisionID')"
                    "DecisionID" = "@outputs('Compose_DecisionID')"
                    "ProjectID" = "@body('Get_Projeto')?['value']?[0]?['ProjectID']"
                    "Descricao" = "@triggerBody()?['descricao']"
                    "Solicitante/Claims" = "@concat('i:0#.f|membership|', outputs('Compose_Solicitante'))"
                    "Aprovador/Claims" = "@concat('i:0#.f|membership|', triggerBody()?['aprovador'])"
                    "Prazo" = "@outputs('Compose_Prazo')"
                    "StatusDecisao/Value" = "Pendente"
                    "Impacto/Value" = "@outputs('Map_Impacto')"
                    "ApproverUPN" = "@triggerBody()?['aprovador']"
                    "ResponseSource/Value" = "CopilotStudio"
                    "CardVersion" = "1.0"
                }
            Response_OK = New-PMOResponse -RunAfter @{ Create_Decisao_SharePoint = @("Succeeded") } -Result "@{concat('Decisao ', outputs('Compose_DecisionID'), ' registrada para projeto ', outputs('Compose_ProjectName'), '.')}"
            Response_Error_Write = New-PMOResponse -StatusCode 500 -RunAfter @{ Create_Decisao_SharePoint = @("Failed", "TimedOut") } -Result "Erro ao registrar decisao no SharePoint. Codigo: SP_WRITE_FAILED."
        }
        else = [ordered]@{ actions = [ordered]@{ Response_Project_Not_Found = New-PMOResponse -Result "Projeto nao encontrado. Codigo: PROJECT_NOT_FOUND." } }
        runAfter = @{ Compose_Solicitante = @("Succeeded") }
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

$flowConfig = @{
    ConsultarPortfolio = @{ DisplayName = "PMO_PA_ConsultarPortfolio"; Prefix = "pa_consultarportfolio"; Builder = { New-PortfolioDefinition } }
    ConsultarProjeto = @{ DisplayName = "PMO_PA_ConsultarProjeto"; Prefix = "pa_consultarprojeto"; Builder = { New-ConsultarProjetoDefinition } }
    RegistrarRiscoBot = @{ DisplayName = "PMO_PA_RegistrarRiscoBot"; Prefix = "pa_registrarriscobot"; Builder = { New-RegistrarRiscoDefinition } }
    RegistrarBloqueioBot = @{ DisplayName = "PMO_PA_RegistrarBloqueioBot"; Prefix = "pa_registrarbloqueiobot"; Builder = { New-RegistrarBloqueioDefinition } }
    PedirDecisaoBot = @{ DisplayName = "PMO_PA_PedirDecisaoBot"; Prefix = "pa_pedirdecisaobot"; Builder = { New-PedirDecisaoDefinition } }
}[$FlowKind]

$definition = & $flowConfig.Builder

if ($BuildOnly) {
    $buildPath = Join-Path $evidenceRoot "$($flowConfig.Prefix)_buildonly_$timestamp.json"
    Save-PMOJson -Data ([ordered]@{
        timestamp = (Get-Date).ToString("o")
        status = "BUILD_ONLY"
        displayName = $flowConfig.DisplayName
        definition = $definition
        triggerType = "Request/Skills"
        connectors = @("shared_sharepointonline")
        standardOnly = $true
    }) -Path $buildPath
    Write-Host "Build-only evidence: $buildPath"
    exit 0
}

try {
    $result = Set-PMOProcessSimpleFlow `
        -EnvironmentName $EnvironmentName `
        -DisplayName $flowConfig.DisplayName `
        -Definition $definition `
        -SharePointConnectionName $SharePointConnectionName `
        -EvidenceRoot $evidenceRoot `
        -EvidencePrefix $flowConfig.Prefix `
        -ForceCreate:$ForceCreate

    $evidencePath = Join-Path $evidenceRoot "$($flowConfig.Prefix)_flow_$timestamp.json"
    Save-PMOJson -Data ([ordered]@{
        timestamp = (Get-Date).ToString("o")
        status = $result.status
        environmentName = $EnvironmentName
        environmentDisplayName = $EnvironmentDisplayName
        siteUrl = $SiteUrl
        displayName = $result.displayName
        flowName = $result.flowName
        workflowEntityId = $result.workflowEntityId
        enabled = $result.enabled
        state = $result.state
        requestPath = $result.requestPath
        resultPath = $result.resultPath
        connectors = @("shared_sharepointonline")
        standardOnly = $true
        triggerType = "Request/Skills"
    }) -Path $evidencePath

    Write-Host "$($flowConfig.DisplayName) deployed: $evidencePath"
    Write-Host "FlowName: $($result.flowName)"
    Write-Host "WorkflowEntityId: $($result.workflowEntityId)"
    exit 0
}
catch {
    $errorPath = Join-Path $evidenceRoot "$($flowConfig.Prefix)_error_$timestamp.json"
    Save-PMOJson -Data ([ordered]@{
        timestamp = (Get-Date).ToString("o")
        status = "FAILED"
        displayName = $flowConfig.DisplayName
        error = $_.Exception.Message
    }) -Path $errorPath
    Write-Error $_.Exception.Message
    exit 1
}
