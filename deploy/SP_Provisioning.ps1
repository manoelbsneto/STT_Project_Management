# PMO Hub — SharePoint Provisioning Script (PnP PowerShell)
# Site: Grp_T_DN_Transformacao_Digital
# Ref: AGENT_CONTRACT.md + PRD v1.3

param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [switch]$SkipConnection,
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
if (-not $SkipConnection) {
    Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
}
if (-not (Get-Module SharePointPnPPowerShellOnline)) {
    Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
}

function Add-DateOnlyField {
    param(
        [Parameter(Mandatory)]
        [string]$List,
        [Parameter(Mandatory)]
        [string]$DisplayName,
        [Parameter(Mandatory)]
        [string]$InternalName,
        [switch]$Required
    )

    $requiredValue = if ($Required) { "TRUE" } else { "FALSE" }
    $fieldXml = "<Field Type='DateTime' DisplayName='$DisplayName' Name='$InternalName' StaticName='$InternalName' Format='DateOnly' Required='$requiredValue' />"
    Add-PnPFieldFromXml -List $List -FieldXml $fieldXml
}

# --- Connection ---
if (-not $SkipConnection) {
    Write-Host "Connecting to $SiteUrl..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

# =============================================================================
# LIST 1: Projetos
# =============================================================================
Write-Host "Creating list: Projetos..." -ForegroundColor Yellow
New-PnPList -Title "Projetos" -Template GenericList -OnQuickLaunch

# Columns
Add-PnPField -List "Projetos" -DisplayName "ProjectID"          -InternalName "ProjectID"          -Type Text     -Required
Add-PnPField -List "Projetos" -DisplayName "Nome"               -InternalName "NomeProjeto"        -Type Text     -Required
Add-PnPField -List "Projetos" -DisplayName "PM"                 -InternalName "PM"                 -Type User     -Required
Add-PnPField -List "Projetos" -DisplayName "Sponsor"            -InternalName "Sponsor"            -Type User
Add-PnPField -List "Projetos" -DisplayName "StatusRAG"          -InternalName "StatusRAG"          -Type Choice   -Required -Choices "Verde","Amarelo","Vermelho"
Add-PnPField -List "Projetos" -DisplayName "Percentual"         -InternalName "Percentual"         -Type Number
Add-DateOnlyField -List "Projetos" -DisplayName "DataAlvo" -InternalName "DataAlvo"
Add-PnPField -List "Projetos" -DisplayName "UltimaAtualizacao"  -InternalName "UltimaAtualizacao"  -Type DateTime
Add-PnPField -List "Projetos" -DisplayName "Ativo"              -InternalName "Ativo"              -Type Boolean
Add-PnPField -List "Projetos" -DisplayName "Unidade"            -InternalName "Unidade"            -Type Choice   -Choices "TI","Digital","Dados","Infra","Seguranca"
Add-PnPField -List "Projetos" -DisplayName "Prioridade"         -InternalName "Prioridade"         -Type Choice   -Choices "Alta","Media","Baixa"
Add-PnPField -List "Projetos" -DisplayName "PlannerGroupId"     -InternalName "PlannerGroupId"     -Type Text
Add-PnPField -List "Projetos" -DisplayName "PlannerPlanId"      -InternalName "PlannerPlanId"      -Type Text
Add-PnPField -List "Projetos" -DisplayName "LinkPlanner"        -InternalName "LinkPlanner"        -Type URL
Add-PnPField -List "Projetos" -DisplayName "TarefasTotal"       -InternalName "TarefasTotal"       -Type Number
Add-PnPField -List "Projetos" -DisplayName "TarefasAbertas"     -InternalName "TarefasAbertas"     -Type Number
Add-PnPField -List "Projetos" -DisplayName "TarefasConcluidas"  -InternalName "TarefasConcluidas"  -Type Number
Add-PnPField -List "Projetos" -DisplayName "TarefasAtrasadas"   -InternalName "TarefasAtrasadas"   -Type Number
Add-PnPField -List "Projetos" -DisplayName "PlannerLastSyncAt"  -InternalName "PlannerLastSyncAt"  -Type DateTime
Add-PnPField -List "Projetos" -DisplayName "PlannerSyncStatus"  -InternalName "PlannerSyncStatus"  -Type Choice   -Choices "OK","Erro","Pendente"
Add-PnPField -List "Projetos" -DisplayName "ResumoExecutivo"    -InternalName "ResumoExecutivo"    -Type Note
Add-PnPField -List "Projetos" -DisplayName "DiasSemUpdate"      -InternalName "DiasSemUpdate"      -Type Number

# Indexes
Write-Host "Creating indexes on Projetos..." -ForegroundColor Green
Set-PnPField -List "Projetos" -Identity "ProjectID"         -Values @{Indexed=$true}
Set-PnPField -List "Projetos" -Identity "StatusRAG"          -Values @{Indexed=$true}
Set-PnPField -List "Projetos" -Identity "PM"                 -Values @{Indexed=$true}
Set-PnPField -List "Projetos" -Identity "Sponsor"            -Values @{Indexed=$true}
Set-PnPField -List "Projetos" -Identity "UltimaAtualizacao"  -Values @{Indexed=$true}
Set-PnPField -List "Projetos" -Identity "Ativo"              -Values @{Indexed=$true}

# Views
Add-PnPView -List "Projetos" -Title "Board RAG"    -Fields "ProjectID","NomeProjeto","PM","StatusRAG","Percentual","DataAlvo","UltimaAtualizacao" -Query "<GroupBy Collapse='TRUE'><FieldRef Name='StatusRAG'/></GroupBy><Where><Eq><FieldRef Name='Ativo'/><Value Type='Boolean'>1</Value></Eq></Where>"
Add-PnPView -List "Projetos" -Title "Gallery"      -Fields "ProjectID","NomeProjeto","PM","StatusRAG","Percentual" -Query "<Where><Eq><FieldRef Name='Ativo'/><Value Type='Boolean'>1</Value></Eq></Where>"
Add-PnPView -List "Projetos" -Title "Todos"         -Fields "ProjectID","NomeProjeto","PM","Sponsor","StatusRAG","Percentual","DataAlvo","UltimaAtualizacao","Prioridade","Ativo"

Write-Host "Projetos created." -ForegroundColor Green

# =============================================================================
# LIST 2: Status Diário
# =============================================================================
Write-Host "Creating list: Status Diario..." -ForegroundColor Yellow
New-PnPList -Title "Status Diario" -Template GenericList -OnQuickLaunch

Add-PnPField -List "Status Diario" -DisplayName "StatusID"       -InternalName "StatusID"       -Type Text     -Required
Add-PnPField -List "Status Diario" -DisplayName "ProjectID"      -InternalName "ProjectID"      -Type Text     -Required
Add-PnPField -List "Status Diario" -DisplayName "DataRegistro"   -InternalName "DataRegistro"   -Type DateTime -Required
Add-PnPField -List "Status Diario" -DisplayName "PM"             -InternalName "PM"             -Type User
Add-PnPField -List "Status Diario" -DisplayName "RAG"            -InternalName "RAG"            -Type Choice   -Required -Choices "Verde","Amarelo","Vermelho"
Add-PnPField -List "Status Diario" -DisplayName "Resumo"         -InternalName "Resumo"         -Type Note     -Required
Add-PnPField -List "Status Diario" -DisplayName "Risco"          -InternalName "Risco"          -Type Note
Add-PnPField -List "Status Diario" -DisplayName "Bloqueio"       -InternalName "Bloqueio"       -Type Note
Add-PnPField -List "Status Diario" -DisplayName "ProximaAcao"    -InternalName "ProximaAcao"    -Type Note
Add-PnPField -List "Status Diario" -DisplayName "Percentual"     -InternalName "Percentual"     -Type Number
Add-PnPField -List "Status Diario" -DisplayName "OrigemEntrada"  -InternalName "OrigemEntrada"  -Type Choice   -Required -Choices "AdaptiveCard","CopilotStudio","FormsFallback","ManualPMO","ImportacaoInicial"
Add-PnPField -List "Status Diario" -DisplayName "ResumoTarefas"  -InternalName "ResumoTarefas"  -Type Note
Add-PnPField -List "Status Diario" -DisplayName "CardVersion"    -InternalName "CardVersion"    -Type Text

Set-PnPField -List "Status Diario" -Identity "StatusID"      -Values @{Indexed=$true}
Set-PnPField -List "Status Diario" -Identity "ProjectID"     -Values @{Indexed=$true}
Set-PnPField -List "Status Diario" -Identity "DataRegistro"  -Values @{Indexed=$true}
Set-PnPField -List "Status Diario" -Identity "PM"            -Values @{Indexed=$true}

Add-PnPView -List "Status Diario" -Title "Por Projeto" -Fields "StatusID","ProjectID","DataRegistro","PM","RAG","Resumo","Percentual" -Query "<OrderBy><FieldRef Name='DataRegistro' Ascending='FALSE'/></OrderBy>"

Write-Host "Status Diario created." -ForegroundColor Green

# =============================================================================
# LIST 3: Riscos e Bloqueios
# =============================================================================
Write-Host "Creating list: Riscos e Bloqueios..." -ForegroundColor Yellow
New-PnPList -Title "Riscos e Bloqueios" -Template GenericList -OnQuickLaunch

Add-PnPField -List "Riscos e Bloqueios" -DisplayName "RiskID"           -InternalName "RiskID"           -Type Text     -Required
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "ProjectID"        -InternalName "ProjectID"        -Type Text     -Required
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "Tipo"             -InternalName "Tipo"             -Type Choice   -Required -Choices "Risco","Bloqueio"
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "Severidade"       -InternalName "Severidade"       -Type Choice   -Required -Choices "Baixa","Media","Alta","Critica"
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "Descricao"        -InternalName "Descricao"        -Type Note     -Required
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "Impacto"          -InternalName "Impacto"          -Type Choice   -Choices "Baixo","Medio","Alto","Critico"
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "Probabilidade"    -InternalName "Probabilidade"    -Type Choice   -Choices "Baixa","Media","Alta"
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "Owner"            -InternalName "Owner"            -Type User
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "DataCriacao"      -InternalName "DataCriacao"      -Type DateTime -Required
Add-DateOnlyField -List "Riscos e Bloqueios" -DisplayName "SLA" -InternalName "SLA"
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "Status"           -InternalName "StatusRisco"      -Type Choice   -Required -Choices "Aberto","Em Mitigacao","Escalado","Resolvido","Aceito"
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "PlanoMitigacao"   -InternalName "PlanoMitigacao"   -Type Note
Add-PnPField -List "Riscos e Bloqueios" -DisplayName "EscaladoPara"     -InternalName "EscaladoPara"     -Type User

Set-PnPField -List "Riscos e Bloqueios" -Identity "RiskID"       -Values @{Indexed=$true}
Set-PnPField -List "Riscos e Bloqueios" -Identity "ProjectID"    -Values @{Indexed=$true}
Set-PnPField -List "Riscos e Bloqueios" -Identity "Severidade"   -Values @{Indexed=$true}
Set-PnPField -List "Riscos e Bloqueios" -Identity "StatusRisco"  -Values @{Indexed=$true}

Add-PnPView -List "Riscos e Bloqueios" -Title "Abertos" -Fields "RiskID","ProjectID","Tipo","Severidade","Descricao","Owner","DataCriacao","StatusRisco" -Query "<Where><Eq><FieldRef Name='StatusRisco'/><Value Type='Choice'>Aberto</Value></Eq></Where><OrderBy><FieldRef Name='Severidade' Ascending='FALSE'/></OrderBy>"

Write-Host "Riscos e Bloqueios created." -ForegroundColor Green

# =============================================================================
# LIST 4: Decisões do Board
# =============================================================================
Write-Host "Creating list: Decisoes do Board..." -ForegroundColor Yellow
New-PnPList -Title "Decisoes do Board" -Template GenericList -OnQuickLaunch

Add-PnPField -List "Decisoes do Board" -DisplayName "DecisionID"      -InternalName "DecisionID"      -Type Text     -Required
Add-PnPField -List "Decisoes do Board" -DisplayName "ProjectID"       -InternalName "ProjectID"       -Type Text     -Required
Add-PnPField -List "Decisoes do Board" -DisplayName "Descricao"       -InternalName "Descricao"       -Type Note     -Required
Add-PnPField -List "Decisoes do Board" -DisplayName "Solicitante"     -InternalName "Solicitante"     -Type User     -Required
Add-PnPField -List "Decisoes do Board" -DisplayName "Aprovador"       -InternalName "Aprovador"       -Type User     -Required
Add-DateOnlyField -List "Decisoes do Board" -DisplayName "Prazo" -InternalName "Prazo"
Add-PnPField -List "Decisoes do Board" -DisplayName "Status"          -InternalName "StatusDecisao"   -Type Choice   -Required -Choices "Pendente","Aprovada","Rejeitada","Adiada","Cancelada"
Add-PnPField -List "Decisoes do Board" -DisplayName "Resposta"        -InternalName "Resposta"        -Type Note
Add-PnPField -List "Decisoes do Board" -DisplayName "DataResposta"    -InternalName "DataResposta"    -Type DateTime
Add-PnPField -List "Decisoes do Board" -DisplayName "Impacto"         -InternalName "Impacto"         -Type Choice   -Choices "Baixo","Medio","Alto","Critico"
Add-PnPField -List "Decisoes do Board" -DisplayName "Justificativa"   -InternalName "Justificativa"   -Type Note
Add-PnPField -List "Decisoes do Board" -DisplayName "ApproverUPN"     -InternalName "ApproverUPN"     -Type Text
Add-PnPField -List "Decisoes do Board" -DisplayName "CardVersion"     -InternalName "CardVersion"     -Type Text
Add-PnPField -List "Decisoes do Board" -DisplayName "ResponseSource"  -InternalName "ResponseSource"  -Type Choice   -Choices "AdaptiveCard","CopilotStudio","Manual"

Set-PnPField -List "Decisoes do Board" -Identity "DecisionID"     -Values @{Indexed=$true}
Set-PnPField -List "Decisoes do Board" -Identity "ProjectID"      -Values @{Indexed=$true}
Set-PnPField -List "Decisoes do Board" -Identity "StatusDecisao"  -Values @{Indexed=$true}

Add-PnPView -List "Decisoes do Board" -Title "Pendentes" -Fields "DecisionID","ProjectID","Descricao","Solicitante","Aprovador","Prazo","StatusDecisao","Impacto" -Query "<Where><Eq><FieldRef Name='StatusDecisao'/><Value Type='Choice'>Pendente</Value></Eq></Where>"

Write-Host "Decisoes do Board created." -ForegroundColor Green

# =============================================================================
# PILOT DATA — 5 Projetos
# =============================================================================
Write-Host "Inserting pilot data..." -ForegroundColor Yellow

$pilotProjects = @(
    @{ProjectID="PRJ-001"; NomeProjeto="Mobile App Corporativo"; StatusRAG="Verde"; Percentual=65; Prioridade="Alta"; Ativo=$true},
    @{ProjectID="PRJ-002"; NomeProjeto="Migração Cloud Azure"; StatusRAG="Amarelo"; Percentual=40; Prioridade="Alta"; Ativo=$true},
    @{ProjectID="PRJ-003"; NomeProjeto="Portal do Colaborador"; StatusRAG="Vermelho"; Percentual=25; Prioridade="Media"; Ativo=$true},
    @{ProjectID="PRJ-004"; NomeProjeto="Data Lake Analytics"; StatusRAG="Verde"; Percentual=80; Prioridade="Media"; Ativo=$true},
    @{ProjectID="PRJ-005"; NomeProjeto="Automação RPA Financeiro"; StatusRAG="Amarelo"; Percentual=55; Prioridade="Alta"; Ativo=$true}
)

foreach ($proj in $pilotProjects) {
    Add-PnPListItem -List "Projetos" -Values $proj
    Write-Host "  $($proj.NomeProjeto) inserted." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "SharePoint Provisioning COMPLETE!" -ForegroundColor Green
Write-Host "   4 lists created | indexes applied | views configured | 5 pilot projects inserted" -ForegroundColor DarkGreen

Disconnect-PnPOnline
