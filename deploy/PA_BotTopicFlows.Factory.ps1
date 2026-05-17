[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("ConsultarPortfolio", "ConsultarProjeto", "RegistrarRiscoBot", "RegistrarBloqueioBot", "PedirDecisaoBot", "AtualizarStatus")]
    [string]$FlowKind,

    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$EnvironmentDisplayName = "ColOfertasBrasilPro",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [ValidateSet("Embedded", "Invoker")]
    [string]$SharePointRuntimeSource = "Embedded",
    [string]$EvidenceDir = ".planning\comms",
    [switch]$ForceCreate,
    [switch]$BuildOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
. (Join-Path $repoRoot "deploy\PMO_FlowScript.Common.ps1")
$evidenceRoot = Initialize-PMOFlowScript -RepositoryRoot $repoRoot -EvidenceDir $EvidenceDir -SkipModuleImport:$BuildOnly
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

function New-ProjectNameNormalizeExpression {
    param([string]$InputName)

    $rawProjectName = "trim(coalesce(triggerBody()?['$InputName'], triggerBody()?['projectName'], triggerBody()?['nomeProjeto'], ''))"
    "@if(startsWith(toLower($rawProjectName), 'projeto='), trim(substring($rawProjectName, 8, sub(length($rawProjectName), 8))), if(startsWith(toLower($rawProjectName), 'projeto:'), trim(substring($rawProjectName, 8, sub(length($rawProjectName), 8))), $rawProjectName))"
}

function New-ProjectLookupActions {
    param(
        [string]$InputName,
        [hashtable]$RunAfter,
        [switch]$AllowIncludeDeletedParameter
    )

    $projectFilter = "NomeProjeto eq '@{replace(outputs('Compose_ProjectName'),'''','''''')}' and Ativo eq 1 and Deleted eq 0"
    if ($AllowIncludeDeletedParameter) {
        $projectFilter = "@{if(or(equals(toLower(string(triggerBody()?['includeDeleted'])), 'sim'), equals(toLower(string(triggerBody()?['includeDeleted'])), 'true'), equals(toLower(string(triggerBody()?['includeDeleted'])), 'yes')), concat('NomeProjeto eq ''', replace(outputs('Compose_ProjectName'),'''',''''''), ''' and Ativo eq 1'), concat('NomeProjeto eq ''', replace(outputs('Compose_ProjectName'),'''',''''''), ''' and Ativo eq 1 and Deleted eq 0'))}"
    }

    [ordered]@{
        Compose_ProjectName = New-PMOCompose -Inputs (New-ProjectNameNormalizeExpression -InputName $InputName) -RunAfter $RunAfter
        Get_Projeto = New-PMOSharePointGetItems `
            -SiteUrl $SiteUrl `
            -ListName "Projetos" `
            -Filter $projectFilter `
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

function New-RAGMapCompose {
    param(
        [string]$InputName,
        [hashtable]$RunAfter
    )

    New-PMOCompose -RunAfter $RunAfter -Inputs "@if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], 'Verde')), 'verm'), 'Vermelho', if(startsWith(toLower(coalesce(triggerBody()?['$InputName'], 'Verde')), 'a'), 'Amarelo', 'Verde'))"
}

function New-PortfolioDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{ includeDeleted = New-PMOStringProperty "Incluir registros excluidos? sim/nao" } -Required @()
    $actions = [ordered]@{
        Get_Projetos_Ativos = New-PMOSharePointGetItems -SiteUrl $SiteUrl -ListName "Projetos" -Filter "@{if(or(equals(toLower(string(triggerBody()?['includeDeleted'])), 'sim'), equals(toLower(string(triggerBody()?['includeDeleted'])), 'true'), equals(toLower(string(triggerBody()?['includeDeleted'])), 'yes')), 'Ativo eq 1', 'Ativo eq 1 and Deleted eq 0')}" -Top 500
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
                            [ordered]@{ less = @("@ticks(coalesce(item()?['UltimaAtualizacao'], utcNow()))", "@ticks(addDays(utcNow(), -1))") }
                        )
                    }
                    actions = [ordered]@{ Increment_SemUpdate = New-PMOIncrementVariable -Name "varSemUpdate" }
                    else = [ordered]@{ actions = [ordered]@{} }
                    runAfter = @{ Switch_StatusRAG = @("Succeeded") }
                }
            }
            runAfter = @{ Initialize_SemUpdate = @("Succeeded") }
        }
        Select_Projetos_Nomes = [ordered]@{
            type = "Select"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                select = "@coalesce(item()?['NomeProjeto'], item()?['Title'], item()?['ProjectID'], '-')"
            }
            runAfter = @{ Apply_to_each_Projeto = @("Succeeded") }
        }
        Compose_Projetos_Nomes = New-PMOCompose -RunAfter @{ Select_Projetos_Nomes = @("Succeeded") } -Inputs "@if(equals(length(body('Select_Projetos_Nomes')), 0), 'nenhum', join(body('Select_Projetos_Nomes'), ', '))"
        Response_OK = New-PMOResponse -RunAfter @{ Compose_Projetos_Nomes = @("Succeeded") } -Result "@{concat('Portfolio PMO: ', string(variables('varTotal')), ' projetos ativos. Verde: ', string(variables('varVerde')), ' | Amarelo: ', string(variables('varAmarelo')), ' | Vermelho: ', string(variables('varVermelho')), '. Projetos sem update (>24h): ', string(variables('varSemUpdate')), '. Projetos: ', outputs('Compose_Projetos_Nomes'), '.')}"
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

function New-ConsultarProjetoDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{
        nomeProjeto = New-PMOStringProperty "Nome do projeto"
        includeDeleted = New-PMOStringProperty "Incluir registros excluidos? sim/nao"
    } -Required @("nomeProjeto")
    $lookup = New-ProjectLookupActions -InputName "nomeProjeto" -RunAfter @{} -AllowIncludeDeletedParameter
    $actions = [ordered]@{}
    foreach ($key in $lookup.Keys) { $actions[$key] = $lookup[$key] }
    $actions.Condition_Projeto_Encontrado = [ordered]@{
        type = "If"
        expression = [ordered]@{ greater = @("@length(body('Get_Projeto')?['value'])", 0) }
        actions = [ordered]@{
            Get_Riscos_Abertos = New-PMOSharePointGetItems `
                -SiteUrl $SiteUrl `
                -ListName "Riscos e Bloqueios" `
                -Filter "@{if(or(equals(toLower(string(triggerBody()?['includeDeleted'])), 'sim'), equals(toLower(string(triggerBody()?['includeDeleted'])), 'true'), equals(toLower(string(triggerBody()?['includeDeleted'])), 'yes')), concat('ProjectID eq ''', replace(body('Get_Projeto')?['value']?[0]?['ProjectID'],'''',''''''), ''' and StatusRisco eq ''Aberto'''), concat('ProjectID eq ''', replace(body('Get_Projeto')?['value']?[0]?['ProjectID'],'''',''''''), ''' and StatusRisco eq ''Aberto'' and Deleted eq 0'))}" `
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
        impacto = New-PMOStringProperty "Impacto"
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
                    "Impacto/Value" = "@triggerBody()?['impacto']"
                    "Descricao" = "@triggerBody()?['descricao']"
                    "DataCriacao" = "@utcNow()"
                    "StatusRisco/Value" = "Aberto"
                    "Deleted" = $false
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
                    "Deleted" = $false
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
    $actions.Compose_Solicitante = New-PMOCompose -Inputs "@trim(coalesce(triggerBody()?['solicitante'], triggerBody()?['aprovador']))" -RunAfter @{ Compose_DecisionID = @("Succeeded") }
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
                    "Aprovador/Claims" = "@concat('i:0#.f|membership|', trim(triggerBody()?['aprovador']))"
                    "Prazo" = "@outputs('Compose_Prazo')"
                    "StatusDecisao/Value" = "Pendente"
                    "Impacto/Value" = "@outputs('Map_Impacto')"
                    "ApproverUPN" = "@trim(triggerBody()?['aprovador'])"
                    "ResponseSource/Value" = "CopilotStudio"
                    "CardVersion" = "1.0"
                    "Deleted" = $false
                }
            Response_OK = New-PMOResponse -RunAfter @{ Create_Decisao_SharePoint = @("Succeeded") } -Result "@{concat('Decisao ', outputs('Compose_DecisionID'), ' registrada para projeto ', outputs('Compose_ProjectName'), '.')}"
            Response_Error_Write = New-PMOResponse -StatusCode 500 -RunAfter @{ Create_Decisao_SharePoint = @("Failed", "TimedOut") } -Result "Erro ao registrar decisao no SharePoint. Codigo: SP_WRITE_FAILED."
        }
        else = [ordered]@{ actions = [ordered]@{ Response_Project_Not_Found = New-PMOResponse -Result "Projeto nao encontrado. Codigo: PROJECT_NOT_FOUND." } }
        runAfter = @{ Compose_Solicitante = @("Succeeded") }
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

function New-AtualizarStatusDefinition {
    $triggers = New-PMOSkillsTrigger -Properties @{
        nomeProjeto = New-PMOStringProperty "Nome do projeto"
        rag = New-PMOStringProperty "Status RAG"
        resumo = New-PMOStringProperty "Resumo do status"
        percentual = New-PMONumberProperty "Percentual concluido"
        risco = New-PMOStringProperty "Risco informado"
        bloqueio = New-PMOStringProperty "Bloqueio informado"
        proximaAcao = New-PMOStringProperty "Proxima acao"
    } -Required @("nomeProjeto", "rag", "resumo")

    $lookup = New-ProjectLookupActions -InputName "nomeProjeto" -RunAfter @{}
    $actions = [ordered]@{}
    foreach ($key in $lookup.Keys) { $actions[$key] = $lookup[$key] }
    $actions.Map_RAG = New-RAGMapCompose -InputName "rag" -RunAfter @{ Get_Projeto = @("Succeeded") }
    $actions.Compose_Percentual = New-PMOCompose -Inputs "@if(empty(string(triggerBody()?['percentual'])), 0, int(triggerBody()?['percentual']))" -RunAfter @{ Map_RAG = @("Succeeded") }
    $actions.Compose_StatusID = New-PMOCompose -Inputs "@concat('STU-', formatDateTime(utcNow(), 'yyyyMMddHHmmss'))" -RunAfter @{ Compose_Percentual = @("Succeeded") }
    $actions.Condition_Projeto_Encontrado = [ordered]@{
        type = "If"
        expression = [ordered]@{ greater = @("@length(body('Get_Projeto')?['value'])", 0) }
        actions = [ordered]@{
            Create_Status_Diario = New-PMOSharePointPostItem `
                -SiteUrl $SiteUrl `
                -ListName "Status Diario" `
                -ItemFields @{
                    "Title" = "@outputs('Compose_StatusID')"
                    "StatusID" = "@outputs('Compose_StatusID')"
                    "ProjectID" = "@body('Get_Projeto')?['value']?[0]?['ProjectID']"
                    "DataRegistro" = "@utcNow()"
                    "RAG/Value" = "@outputs('Map_RAG')"
                    "Resumo" = "@triggerBody()?['resumo']"
                    "Risco" = "@coalesce(triggerBody()?['risco'], '')"
                    "Bloqueio" = "@coalesce(triggerBody()?['bloqueio'], '')"
                    "ProximaAcao" = "@coalesce(triggerBody()?['proximaAcao'], '')"
                    "Percentual" = "@outputs('Compose_Percentual')"
                    "OrigemEntrada/Value" = "CopilotStudio"
                    "Deleted" = $false
                }
            Update_Projeto = New-PMOSharePointPatchItem `
                -SiteUrl $SiteUrl `
                -ListName "Projetos" `
                -Id "@body('Get_Projeto')?['value']?[0]?['ID']" `
                -ItemFields @{
                    "Title" = "@body('Get_Projeto')?['value']?[0]?['Title']"
                    "ProjectID" = "@body('Get_Projeto')?['value']?[0]?['ProjectID']"
                    "NomeProjeto" = "@body('Get_Projeto')?['value']?[0]?['NomeProjeto']"
                    "StatusRAG/Value" = "@outputs('Map_RAG')"
                    "Percentual" = "@outputs('Compose_Percentual')"
                    "UltimaAtualizacao" = "@utcNow()"
                    "Deleted" = $false
                } `
                -RunAfter @{ Create_Status_Diario = @("Succeeded") }
            Response_OK = New-PMOResponse -RunAfter @{ Update_Projeto = @("Succeeded") } -Result "@{concat('Status ', outputs('Compose_StatusID'), ' registrado para projeto ', outputs('Compose_ProjectName'), '. RAG: ', outputs('Map_RAG'), '. Percentual: ', string(outputs('Compose_Percentual')), '%.')}"
            Response_Error_Create = New-PMOResponse -StatusCode 500 -RunAfter @{ Create_Status_Diario = @("Failed", "TimedOut") } -Result "Erro ao registrar status no SharePoint. Codigo: SP_STATUS_WRITE_FAILED."
            Response_Error_Update = New-PMOResponse -StatusCode 500 -RunAfter @{ Update_Projeto = @("Failed", "TimedOut") } -Result "Erro ao atualizar projeto no SharePoint. Codigo: SP_PROJECT_UPDATE_FAILED."
        }
        else = [ordered]@{ actions = [ordered]@{ Response_Project_Not_Found = New-PMOResponse -Result "Projeto nao encontrado. Codigo: PROJECT_NOT_FOUND." } }
        runAfter = @{ Compose_StatusID = @("Succeeded") }
    }
    New-PMOFlowDefinition -Triggers $triggers -Actions $actions
}

$flowConfig = @{
    ConsultarPortfolio = @{ DisplayName = "PMO_PA_ConsultarPortfolio"; Prefix = "pa_consultarportfolio"; Builder = { New-PortfolioDefinition } }
    ConsultarProjeto = @{ DisplayName = "PMO_PA_ConsultarProjeto"; Prefix = "pa_consultarprojeto"; Builder = { New-ConsultarProjetoDefinition } }
    RegistrarRiscoBot = @{ DisplayName = "PMO_PA_RegistrarRiscoBot"; Prefix = "pa_registrarriscobot"; Builder = { New-RegistrarRiscoDefinition } }
    RegistrarBloqueioBot = @{ DisplayName = "PMO_PA_RegistrarBloqueioBot"; Prefix = "pa_registrarbloqueiobot"; Builder = { New-RegistrarBloqueioDefinition } }
    PedirDecisaoBot = @{ DisplayName = "PMO_PA_PedirDecisaoBot"; Prefix = "pa_pedirdecisaobot"; Builder = { New-PedirDecisaoDefinition } }
    AtualizarStatus = @{ DisplayName = "PMO_PA_AtualizarStatus"; Prefix = "pa_atualizarstatus"; Builder = { New-AtualizarStatusDefinition } }
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
        connectionReferences = [ordered]@{
            shared_sharepointonline = [ordered]@{
                connectionName = $SharePointConnectionName
                connectionReferenceLogicalName = "pmo_sharepoint"
                source = $SharePointRuntimeSource
                id = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
                displayName = "SharePoint"
                tier = "Standard"
            }
        }
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
        -SharePointRuntimeSource $SharePointRuntimeSource `
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
