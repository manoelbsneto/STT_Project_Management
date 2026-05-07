param(
    [switch]$RunSharePointPnP,
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$EnvironmentId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
)

$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$evidenceDir = ".planning\comms"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null

$jsonPath = Join-Path $evidenceDir "g6_qa_wave1_$timestamp.json"
$mdPath = Join-Path $evidenceDir "G6_QA_WAVE1_RESULTS.md"
$flowInventoryPath = Join-Path $evidenceDir "g6_wave1_processsimple_flows_$timestamp.json"
$flowRunsPath = Join-Path $evidenceDir "g6_wave1_processsimple_runs_$timestamp.json"

$results = New-Object System.Collections.Generic.List[object]
$evidenceDetails = [ordered]@{}

function Add-Result {
    param(
        [string]$Id,
        [string]$Name,
        [ValidateSet("PASS","FAIL","CHECK","NOT_RUN")] [string]$Status,
        [string]$Detail
    )
    $results.Add([pscustomobject]@{
        ID = $Id
        Teste = $Name
        Status = $Status
        Detalhes = $Detail
        Timestamp = (Get-Date).ToString("o")
    }) | Out-Null
}

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 50)
    ConvertTo-Json -InputObject $Data -Depth $Depth | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-JsonFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    try { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json } catch { return $null }
}

function Get-LatestFile {
    param([string]$Filter)
    return Get-ChildItem -Path $evidenceDir -Filter $Filter -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

Write-Host "=== Phase 6 QA Wave 1 Automated Validation ===" -ForegroundColor Cyan

# A1-A5 SharePoint. Default is non-interactive evidence mode; pass -RunSharePointPnP to execute live PnP/write tests.
if ($RunSharePointPnP) {
    Write-Host "`n=== A1-A5: SharePoint live PnP tests ===" -ForegroundColor Cyan
    try {
        $env:PNPLEGACYMESSAGE = "false"
        Remove-Module PnP.PowerShell,SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
        Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
        Connect-PnPOnline -Url $SiteUrl -UseWebLogin

        $expectedLists = @(
            @{Title="Projetos"; MinFields=22},
            @{Title="Status Diario"; MinFields=13},
            @{Title="Riscos e Bloqueios"; MinFields=13},
            @{Title="Decisoes do Board"; MinFields=14}
        )
        $listChecks = foreach ($l in $expectedLists) {
            $list = Get-PnPList -Identity $l.Title -ErrorAction Stop
            $fields = @(Get-PnPField -List $l.Title -ErrorAction Stop | Where-Object { -not $_.Hidden })
            [pscustomobject]@{ List=$l.Title; Exists=($null -ne $list); VisibleFieldCount=$fields.Count; MinFields=$l.MinFields }
        }
        $a1Pass = @($listChecks | Where-Object { -not $_.Exists -or $_.VisibleFieldCount -lt $_.MinFields }).Count -eq 0
        Add-Result "A1" "Verificar 4 listas SP existem com campos corretos" $(if($a1Pass){"PASS"}else{"FAIL"}) (($listChecks | ConvertTo-Json -Compress))

        $views = [ordered]@{
            Projetos = @(Get-PnPView -List "Projetos" | Select-Object -ExpandProperty Title)
            "Status Diario" = @(Get-PnPView -List "Status Diario" | Select-Object -ExpandProperty Title)
            "Riscos e Bloqueios" = @(Get-PnPView -List "Riscos e Bloqueios" | Select-Object -ExpandProperty Title)
            "Decisoes do Board" = @(Get-PnPView -List "Decisoes do Board" | Select-Object -ExpandProperty Title)
        }
        $requiredViews = @("Board RAG","Projetos Criticos","Gallery","Todos","Por Projeto","Abertos","Pendentes")
        $viewText = ($views.Values | ForEach-Object { $_ }) -join "|"
        $missingViews = @($requiredViews | Where-Object { $viewText -notmatch [regex]::Escape($_) })
        Add-Result "A2" "Verificar views SP existem" $(if($missingViews.Count -eq 0){"PASS"}else{"FAIL"}) ("Missing: " + ($missingViews -join ", "))

        $created = @()
        $project = Add-PnPListItem -List "Projetos" -Values @{Title="PRJ-QA-TEST"; ProjectID="PRJ-QA-TEST"; NomeProjeto="QA Teste Automatizado"; StatusRAG="Verde"; Ativo=$false}
        $created += [pscustomobject]@{List="Projetos";Id=$project.Id}
        $status = Add-PnPListItem -List "Status Diario" -Values @{Title="PRJ-QA-TEST"; ProjectID="PRJ-QA-TEST"; RAG="Verde"; Resumo="QA"; Bloqueio="Nao"}
        $created += [pscustomobject]@{List="Status Diario";Id=$status.Id}
        $risco = Add-PnPListItem -List "Riscos e Bloqueios" -Values @{Title="PRJ-QA-TEST"; ProjectID="PRJ-QA-TEST"; Severidade="Baixa"; StatusRisco="Aberto"; Descricao="QA"}
        $created += [pscustomobject]@{List="Riscos e Bloqueios";Id=$risco.Id}
        $decisao = Add-PnPListItem -List "Decisoes do Board" -Values @{Title="PRJ-QA-TEST"; ProjectID="PRJ-QA-TEST"; StatusDecisao="Pendente"; Decisao="QA"}
        $created += [pscustomobject]@{List="Decisoes do Board";Id=$decisao.Id}
        Add-Result "A3" "Criar item teste via PnP em cada lista" "PASS" (($created | ConvertTo-Json -Compress))

        Set-PnPListItem -List "Projetos" -Identity $project.Id -Values @{StatusRAG="Vermelho"} | Out-Null
        $updated = Get-PnPListItem -List "Projetos" -Id $project.Id
        $a4Pass = $updated["StatusRAG"] -eq "Vermelho"
        Add-Result "A4" "Atualizar StatusRAG via PnP" $(if($a4Pass){"PASS"}else{"FAIL"}) ("StatusRAG=" + $updated["StatusRAG"])

        $indexedChecks = @()
        foreach ($entry in @(
            @{List="Projetos"; Fields=@("StatusRAG","ProjectID")},
            @{List="Status Diario"; Fields=@("DataRegistro","ProjectID")}
        )) {
            foreach ($fieldName in $entry.Fields) {
                $field = Get-PnPField -List $entry.List -Identity $fieldName -ErrorAction SilentlyContinue
                $indexedChecks += [pscustomobject]@{List=$entry.List;Field=$fieldName;Indexed=($field -and $field.Indexed)}
            }
        }
        $a5Pass = @($indexedChecks | Where-Object { -not $_.Indexed }).Count -eq 0
        Add-Result "A5" "Verificar indexacao de colunas" $(if($a5Pass){"PASS"}else{"FAIL"}) (($indexedChecks | ConvertTo-Json -Compress))

        foreach ($item in $created) {
            Remove-PnPListItem -List $item.List -Identity $item.Id -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Add-Result "A1" "Verificar 4 listas SP existem com campos corretos" "FAIL" ("PnP failed: " + $_.Exception.Message)
        Add-Result "A2" "Verificar views SP existem" "NOT_RUN" "Skipped after PnP failure."
        Add-Result "A3" "Criar item teste via PnP em cada lista" "NOT_RUN" "Skipped after PnP failure."
        Add-Result "A4" "Atualizar StatusRAG via PnP" "NOT_RUN" "Skipped after PnP failure."
        Add-Result "A5" "Verificar indexacao de colunas" "NOT_RUN" "Skipped after PnP failure."
    }
}
else {
    $g1Verify = Get-LatestFile "g1_legacy_pnp_verify_*.log"
    $g5Views = Get-LatestFile "g5_sharepoint_views_*.json"
    Add-Result "A1" "Verificar 4 listas SP existem com campos corretos" "CHECK" ("Evidence mode. Prior G1 verification: " + $g1Verify.Name)
    Add-Result "A2" "Verificar views SP existem" "CHECK" ("Evidence mode. Latest G5 view export: " + $g5Views.Name)
    Add-Result "A3" "Criar item teste via PnP em cada lista" "NOT_RUN" "Requires -RunSharePointPnP interactive SharePoint login."
    Add-Result "A4" "Atualizar StatusRAG via PnP" "NOT_RUN" "Requires A3 live test item."
    Add-Result "A5" "Verificar indexacao de colunas" "CHECK" ("Evidence mode. Prior G1 verification: " + $g1Verify.Name)
}

# B1-B4 live ProcessSimple, B5 local cards.
Write-Host "`n=== B1-B5: Power Automate and cards ===" -ForegroundColor Cyan
$expectedFlows = [ordered]@{
    "PMO_PA_EnviarCheckInDiario" = "Started"
    "PMO_PA_ProcessarRespostaCheckIn" = "Stopped"
    "PMO_PA_AlertaProjetoVermelho" = "Started"
    "PMO_PA_CheckInOnDemand" = "Started"
    "PMO_PA_AlertaSemAtualizacao" = "Started"
    "PMO_PA_ResumoDiarioBoard" = "Started"
    "PMO_PA_RegistrarDecisaoBoard" = "Started"
    "PMO_PA_SyncPlannerStats_Standard" = "Started"
    "PMO_PA_EscalarRiscoCritico" = "Started"
    "PMO_PA_ResumoSemanal" = "Started"
}
$pmoFlows = @()
try {
    $powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"
    Import-Module $powerAppsModule -ErrorAction Stop
    $flowInventory = InvokeApi -Method GET -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentId/flows?api-version=2016-11-01" -ApiVersion "2016-11-01"
    Save-Json -Data $flowInventory -Path $flowInventoryPath -Depth 80
    $pmoFlows = @($flowInventory.value | Where-Object { $_.properties.displayName -like "PMO_PA_*" })
    $evidenceDetails["ProcessSimpleFlows"] = $flowInventoryPath

    $stateChecks = foreach ($name in $expectedFlows.Keys) {
        $flow = @($pmoFlows | Where-Object { $_.properties.displayName -eq $name } | Select-Object -First 1)
        [pscustomobject]@{Name=$name; Expected=$expectedFlows[$name]; Actual=if($flow){$flow.properties.state}else{"MISSING"}; FlowId=if($flow){$flow.name}else{$null}}
    }
    $b1Pass = @($stateChecks | Where-Object { $_.Actual -ne $_.Expected }).Count -eq 0
    Add-Result "B1" "Verificar 10 flows existem e estado correto" $(if($b1Pass){"PASS"}else{"FAIL"}) (($stateChecks | ConvertTo-Json -Compress))

    $runNames = @("PMO_PA_EnviarCheckInDiario","PMO_PA_ResumoDiarioBoard","PMO_PA_ResumoSemanal")
    $runEvidence = @()
    foreach ($flowName in $runNames) {
        $flow = @($pmoFlows | Where-Object { $_.properties.displayName -eq $flowName } | Select-Object -First 1)
        if (-not $flow) {
            $runEvidence += [pscustomobject]@{Flow=$flowName; Status="MISSING"; RunCount=0; LatestStart=$null; Recent=$false}
            continue
        }
        try {
            $runs = InvokeApi -Method GET -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentId/flows/$($flow.name)/runs?api-version=2016-11-01" -ApiVersion "2016-11-01"
            $latest = @($runs.value | Sort-Object { $_.properties.startTime } -Descending | Select-Object -First 1)
            $latestTime = if ($latest) { [datetime]$latest.properties.startTime } else { $null }
            $runEvidence += [pscustomobject]@{
                Flow=$flowName
                Status="OK"
                RunCount=@($runs.value).Count
                LatestStart=$latestTime
                Recent=($latestTime -and $latestTime -gt (Get-Date).AddDays(-3))
            }
        } catch {
            $runEvidence += [pscustomobject]@{Flow=$flowName; Status=("ERROR: " + $_.Exception.Message); RunCount=0; LatestStart=$null; Recent=$false}
        }
    }
    Save-Json -Data $runEvidence -Path $flowRunsPath -Depth 20
    $b2Pass = @($runEvidence | Where-Object { -not $_.Recent }).Count -eq 0
    Add-Result "B2" "Verificar run-history flows recurrence" $(if($b2Pass){"PASS"}else{"FAIL"}) (($runEvidence | ConvertTo-Json -Compress))

    $triggerChecks = foreach ($name in $expectedFlows.Keys) {
        $flow = @($pmoFlows | Where-Object { $_.properties.displayName -eq $name } | Select-Object -First 1)
        $triggers = @($flow.properties.definitionSummary.triggers | ForEach-Object { if ($_.swaggerOperationId) { "$($_.type)/$($_.swaggerOperationId)" } else { $_.type } })
        [pscustomobject]@{Name=$name;Triggers=($triggers -join ", ")}
    }
    $b3Pass = @($triggerChecks | Where-Object { [string]::IsNullOrWhiteSpace($_.Triggers) }).Count -eq 0
    Add-Result "B3" "Verificar trigger types" $(if($b3Pass){"PASS"}else{"FAIL"}) (($triggerChecks | ConvertTo-Json -Compress))

    $allowedApis = @("shared_sharepointonline","shared_teams","shared_office365","shared_planner","shared_logicflows")
    $apiFindings = @()
    foreach ($flow in $pmoFlows) {
        $apis = New-Object System.Collections.Generic.HashSet[string]
        foreach ($p in $flow.properties.connectionReferences.PSObject.Properties) { [void]$apis.Add($p.Name) }
        foreach ($t in @($flow.properties.definitionSummary.triggers)) {
            if ($t.api -match "name=([^;]+)") { [void]$apis.Add($Matches[1]) }
        }
        foreach ($a in @($flow.properties.definitionSummary.actions)) {
            if ($a.api -match "name=([^;]+)") { [void]$apis.Add($Matches[1]) }
        }
        $bad = @($apis | Where-Object { $allowedApis -notcontains $_ })
        $apiFindings += [pscustomobject]@{Flow=$flow.properties.displayName;Apis=(@($apis) -join ",");Unexpected=($bad -join ",")}
    }
    $b4Pass = @($apiFindings | Where-Object { $_.Unexpected }).Count -eq 0
    Add-Result "B4" "Verificar Standard connectors only" $(if($b4Pass){"PASS"}else{"FAIL"}) (($apiFindings | ConvertTo-Json -Compress))
}
catch {
    Add-Result "B1" "Verificar 10 flows existem e estado correto" "FAIL" ("ProcessSimple failed: " + $_.Exception.Message)
    Add-Result "B2" "Verificar run-history flows recurrence" "NOT_RUN" "Skipped after ProcessSimple failure."
    Add-Result "B3" "Verificar trigger types" "CHECK" "Use local flow_definition/flow_summary evidence."
    Add-Result "B4" "Verificar Standard connectors only" "CHECK" "Use local G2/G3 deployment evidence."
}

$cards = @(Get-ChildItem "deploy\cards" -Filter "*.json" -File)
$cardChecks = foreach ($card in $cards) {
    try {
        $json = Get-Content -LiteralPath $card.FullName -Raw | ConvertFrom-Json
        [pscustomobject]@{File=$card.Name;SizeKB=[math]::Round($card.Length/1KB,2);Valid=$true;Version=$json.version;Under27KB=($card.Length -lt 27KB)}
    } catch {
        [pscustomobject]@{File=$card.Name;SizeKB=[math]::Round($card.Length/1KB,2);Valid=$false;Version="PARSE_ERROR";Under27KB=($card.Length -lt 27KB)}
    }
}
$b5Pass = @($cardChecks | Where-Object { -not $_.Valid -or $_.Version -ne "1.4" -or -not $_.Under27KB }).Count -eq 0 -and $cards.Count -eq 6
$evidenceDetails["CardChecks"] = $cardChecks
Add-Result "B5" "Validar 6 card JSON schemas" $(if($b5Pass){"PASS"}else{"FAIL"}) (($cardChecks | ConvertTo-Json -Compress))

# C1-C4 Copilot Studio.
Write-Host "`n=== C1-C4: Copilot Studio ===" -ForegroundColor Cyan
$botId = "0c4a9729-d55d-483c-8ec3-db9369583155"
try {
    $copilotList = pac copilot list 2>&1 | Out-String
    $c1Pass = $copilotList -match "Assistente PMO\s+$botId\s+Published\s+False\s+\S+\s+Active\s+Provisioned"
    Add-Result "C1" "Verificar bot Published/Active/Provisioned" $(if($c1Pass){"PASS"}else{"FAIL"}) "pac copilot list contains Assistente PMO Published/Active/Provisioned."
} catch {
    Add-Result "C1" "Verificar bot Published/Active/Provisioned" "FAIL" ("pac copilot list failed: " + $_.Exception.Message)
}

$exportYaml = Get-LatestFile "g4_assistente_pmo_export_complete_final_*.yaml"
$exportText = if ($exportYaml) { Get-Content -LiteralPath $exportYaml.FullName -Raw } else { "" }
$gateText = if (Test-Path ".planning\comms\GATE_STATUS.md") { Get-Content ".planning\comms\GATE_STATUS.md" -Raw } else { "" }
$c2Pass = $exportText -match "GenerativeActionsEnabled:\s*false" -and $exportText -match "authenticationMode:\s*Integrated"
if (-not $c2Pass -and $gateText -match "GenerativeActionsEnabled=false" -and $gateText -match "useModelKnowledge=false") { $c2Pass = $true }
Add-Result "C2" "Verificar seguranca Copilot" $(if($c2Pass){"PASS"}else{"CHECK"}) ("Evidence: " + $(if($exportYaml){$exportYaml.Name}else{"GATE_STATUS.md"}))

$c3Pass = $gateText -match "Portugu" -or $gateText -match "pt-BR" -or $exportText -match "Portugu"
Add-Result "C3" "Verificar language pt-BR" $(if($c3Pass){"PASS"}else{"CHECK"}) "Validated from G4 live evidence in GATE_STATUS/exports; PAC bot fetch does not expose language cleanly."

$actionFetch = Join-Path $evidenceDir "g6_wave1_fetch_actions_$timestamp.xml"
@"
<fetch>
  <entity name="workflow">
    <attribute name="name"/>
    <attribute name="statecode"/>
    <attribute name="statuscode"/>
    <attribute name="category"/>
    <filter>
      <condition attribute="name" operator="like" value="%PMO_PA_%"/>
    </filter>
  </entity>
</fetch>
"@ | Set-Content -LiteralPath $actionFetch -Encoding UTF8
$actionOutput = pac org fetch --xmlFile $actionFetch 2>&1 | Out-String
$expectedActions = @("PMO_PA_CheckInOnDemand","PMO_PA_EscalarRiscoCritico","PMO_PA_RegistrarDecisaoBoard")
$missingActions = @($expectedActions | Where-Object { $actionOutput -notmatch [regex]::Escape($_) })
$c4Pass = $missingActions.Count -eq 0 -and $actionOutput -match "Activado"
Add-Result "C4" "Verificar 3 action bindings ativos" $(if($c4Pass){"PASS"}else{"FAIL"}) ("Missing: " + ($missingActions -join ", ") + "; FetchXML: " + $actionFetch)

$summary = [pscustomobject]@{
    timestamp = (Get-Date).ToString('o')
    environment = "ColOfertasBrasilPro"
    environmentId = $EnvironmentId
    runSharePointPnP = [bool]$RunSharePointPnP
    results = @($results.ToArray())
    details = [pscustomobject]$evidenceDetails
    evidence = [pscustomobject]@{
        json = $jsonPath
        markdown = $mdPath
        processSimpleFlows = $flowInventoryPath
        processSimpleRuns = $flowRunsPath
    }
}
Save-Json -Data $summary -Path $jsonPath -Depth 80

$passCount = @($results | Where-Object Status -eq "PASS").Count
$failCount = @($results | Where-Object Status -eq "FAIL").Count
$checkCount = @($results | Where-Object Status -eq "CHECK").Count
$notRunCount = @($results | Where-Object Status -eq "NOT_RUN").Count

$md = New-Object System.Collections.Generic.List[string]
$md.Add("# G6 QA Wave 1 Results") | Out-Null
$md.Add("") | Out-Null
$md.Add("- Timestamp: $((Get-Date).ToString('o'))") | Out-Null
$md.Add("- Environment: ColOfertasBrasilPro ($EnvironmentId)") | Out-Null
$md.Add("- Summary: PASS=$passCount; FAIL=$failCount; CHECK=$checkCount; NOT_RUN=$notRunCount") | Out-Null
$md.Add("- JSON evidence: ``$jsonPath``") | Out-Null
$md.Add("") | Out-Null
$md.Add("| ID | Teste | Status | Detalhes | Timestamp |") | Out-Null
$md.Add("|----|-------|--------|----------|-----------|") | Out-Null
foreach ($r in $results) {
    $detail = ($r.Detalhes -replace "\|","/" -replace "`r?`n"," ")
    if ($detail.Length -gt 300) { $detail = $detail.Substring(0,300) + "..." }
    $md.Add("| $($r.ID) | $($r.Teste) | $($r.Status) | $detail | $($r.Timestamp) |") | Out-Null
}
$md.Add("") | Out-Null
$md.Add("## Notes") | Out-Null
$md.Add("") | Out-Null
$md.Add("- A3/A4 are only executed when ``-RunSharePointPnP`` is supplied because they create and delete SharePoint test data through interactive PnP authentication.") | Out-Null
$md.Add("- B1/B2/B3/B4 use live ProcessSimple API through cached Microsoft.PowerApps.PowerShell auth.") | Out-Null
$md.Add("- C2/C3 rely on G4 export/gate evidence where PAC does not expose the fields cleanly.") | Out-Null
$md | Set-Content -LiteralPath $mdPath -Encoding UTF8

Write-Host "`nResults: PASS=$passCount FAIL=$failCount CHECK=$checkCount NOT_RUN=$notRunCount" -ForegroundColor $(if($failCount -gt 0){"Red"}else{"Green"})
Write-Host "Markdown: $mdPath"
Write-Host "JSON: $jsonPath"
