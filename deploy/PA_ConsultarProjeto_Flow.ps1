[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$EnvironmentDisplayName = "ColOfertasBrasilPro",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [string]$EvidenceDir = ".planning\comms",
    [switch]$ForceCreate,
    [switch]$BuildOnly
)

$argsForFactory = @{
    FlowKind = "ConsultarProjeto"
    EnvironmentName = $EnvironmentName
    EnvironmentDisplayName = $EnvironmentDisplayName
    SiteUrl = $SiteUrl
    SharePointConnectionName = $SharePointConnectionName
    EvidenceDir = $EvidenceDir
    ForceCreate = $ForceCreate
    BuildOnly = $BuildOnly
}

& (Join-Path $PSScriptRoot "PA_BotTopicFlows.Factory.ps1") @argsForFactory
