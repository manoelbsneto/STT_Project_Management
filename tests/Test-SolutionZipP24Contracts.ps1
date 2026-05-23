[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath,

    [string]$ExpectedVersion = "3.3"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_zip_p24_contracts_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

function Invoke-SubTest {
    param([string]$Script)
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -PackagePath $resolvedPackagePath 2>&1
        if ($LASTEXITCODE -ne 0) {
            Add-Check "$Script output" $false ($output -join "`n")
            return $false
        }
        return $true
    }
    catch {
        Add-Check "$Script output" $false $_.Exception.Message
        return $false
    }
}

function Get-ZipUtf8BomEntries {
    param([string]$ZipPath)

    $bomEntries = [System.Collections.Generic.List[string]]::new()
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        foreach ($entry in $archive.Entries) {
            $isClientData = ($entry.FullName -like "Workflows/*.json") -or ($entry.FullName -like "botcomponents/*/data")
            if ((-not $isClientData) -or ($entry.Length -lt 3)) {
                continue
            }

            $stream = $entry.Open()
            try {
                $buffer = New-Object byte[] 3
                $read = $stream.Read($buffer, 0, 3)
                if (($read -eq 3) -and ($buffer[0] -eq 0xEF) -and ($buffer[1] -eq 0xBB) -and ($buffer[2] -eq 0xBF)) {
                    $bomEntries.Add($entry.FullName) | Out-Null
                }
            }
            finally {
                $stream.Dispose()
            }
        }
    }
    finally {
        $archive.Dispose()
    }

    return @($bomEntries)
}

try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($resolvedPackagePath)
    try {
        $entryNames = @($zip.Entries | ForEach-Object { $_.FullName })
    }
    finally {
        $zip.Dispose()
    }

    Add-Check "Zip entries use Dataverse path separators" (-not [bool]($entryNames | Where-Object { $_ -match "\\" })) "Dataverse import resolves manifest paths with /, not Windows backslashes."
    Add-Check "Zip contains AtualizarStatus workflow at manifest path" ($entryNames -contains "Workflows/PMO_PA_AtualizarStatus-C11A165B-C64C-F111-BEC7-7CED8D9559C1.json") "Import log failed when /Workflows/... was not present as a ZIP entry."
    $bomEntries = @(Get-ZipUtf8BomEntries -ZipPath $resolvedPackagePath)
    Add-Check "No UTF-8 BOM in workflow/clientdata files" ($bomEntries.Count -eq 0) $(if ($bomEntries.Count -eq 0) { "Checked Workflows/*.json and botcomponents/*/data entries." } else { $bomEntries -join "; " })

    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $allText = (Get-ChildItem -LiteralPath $tempRoot -Recurse -File | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue }) -join "`n"
    $customizationsText = Get-Content -LiteralPath (Join-Path $tempRoot "customizations.xml") -Raw
    $manifestWorkflowPaths = @(
        [regex]::Matches($customizationsText, "<JsonFileName>/([^<]+)</JsonFileName>") |
            ForEach-Object { $_.Groups[1].Value }
    )
    $missingManifestPaths = @($manifestWorkflowPaths | Where-Object { $entryNames -notcontains $_ })

    Add-Check "Zip has solution.xml" (Test-Path -LiteralPath (Join-Path $tempRoot "solution.xml")) "Required Dataverse solution manifest."
    Add-Check "Zip has customizations.xml" (Test-Path -LiteralPath (Join-Path $tempRoot "customizations.xml")) "Required customizations manifest."
    Add-Check "Zip has [Content_Types].xml" (Test-Path -LiteralPath (Join-Path $tempRoot "[Content_Types].xml")) "Required package content type manifest."
    Add-Check "All workflow JsonFileName manifest paths exist in ZIP" ($missingManifestPaths.Count -eq 0) (($missingManifestPaths -join "; "))
    Add-Check "Package version is $ExpectedVersion" ($allText -match "<Version>$([regex]::Escape($ExpectedVersion))</Version>") "Solution version must match the active release candidate."
    Add-Check "No runtimeSource invoker" ($allText -notmatch '"runtimeSource"\s*:\s*"invoker"') "No per-user invoker connection source."
    Add-Check "No raw APIM token auth" ($allText -notmatch "X-MS-APIM-Tokens|ConnectionKey") "No unsupported raw connection token auth."
    Add-Check "No physical SharePoint delete operation" ($allText -notmatch '"operationId"\s*:\s*"DeleteItem"') "Logical delete only."
    Add-Check "No Premium/Graph/HTTP connector markers" ($allText -notmatch "shared_graph|shared_azuread|shared_http|/providers/Microsoft.PowerApps/apis/shared_http") "Standard-only package."
    Add-Check "No solution missing dependencies" ($allText -notmatch "<MissingDependency>") "Release package must not ship unresolved solution dependencies."
    $hasPm0TeamsCardReference = (
        ($allText -match "PM0_PA_Card_AtualizarStatus") -and
        ($allText -match "cat_sharedteams_1ef7e") -and
        ($customizationsText -match '<connectionreference connectionreferencelogicalname="cat_sharedteams_1ef7e"')
    )
    Add-Check "No unresolved Teams/Outlook kit references" ((($allText -notmatch "cat_sharedteams_1ef7e|cat_CopilotStudioKitOutlook") -or $hasPm0TeamsCardReference) -and ($allText -notmatch "cat_CopilotStudioKitOutlook")) "Teams/Outlook adaptive-card flows must stay dependency-clean; PM0 AtualizarStatus may include the Teams card connector when declared."
    Add-Check "No unused gstf SharePoint reference" ($allText -notmatch "gstf_sharepoint") "Release package must not include unused legacy connection references."
    Add-Check "No unsupported padLeft expression" ($allText -notmatch "padLeft") "Power Automate template language in this tenant does not support padLeft."
    Add-Check "No legacy DataAlvo eq Compose_DataAlvo filter" ($allText -notmatch "DataAlvo\s+eq\s+'@\{outputs\('Compose_DataAlvo'\)\}'") "SharePoint DateTime filters must use day ranges, not string equality."

    $criarProjetoTopic = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarProjeto\data"
    $criarTarefaTopic = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarTarefa\data"
    $batchTopic = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos\data"
    $projectTopicText = if (Test-Path -LiteralPath $criarProjetoTopic) { Get-Content -LiteralPath $criarProjetoTopic -Raw } else { "" }
    $taskTopicText = if (Test-Path -LiteralPath $criarTarefaTopic) { Get-Content -LiteralPath $criarTarefaTopic -Raw } else { "" }
    $batchTopicText = if (Test-Path -LiteralPath $batchTopic) { Get-Content -LiteralPath $batchTopic -Raw } else { "" }

    Add-Check "CriarProjeto topic exists" (Test-Path -LiteralPath $criarProjetoTopic) "Project creation must have its own topic."
    Add-Check "CriarProjeto excludes task trigger phrases" ($projectTopicText -notmatch "criar tarefa|nova tarefa|adicionar tarefa|cadastrar tarefa") "Project topic cannot own task intent."
    Add-Check "CriarProjeto prompt requires Brazilian date" ($projectTopicText -match "dd/MM/aaaa") "User-facing project prazo prompt must use Brazilian date format."
    Add-Check "CriarTarefa topic exists" (Test-Path -LiteralPath $criarTarefaTopic) "Task creation must have its own topic."
    Add-Check "CriarTarefa excludes project trigger phrases" ($taskTopicText -notmatch "criar projeto|novo projeto|abrir projeto|registrar projeto") "Task topic cannot own project intent."
    Add-Check "CriarTarefa title parser ignores command prefix" (($taskTopicText -match [regex]::Escape('t.tulo\s*[:=]')) -and ($taskTopicText -notmatch [regex]::Escape('(?:titulo|tarefa)\s*[:=]'))) "The parser must not capture 'criar tarefa:' as the task title."
    Add-Check "CriarTarefa prompt requires Brazilian date" ($taskTopicText -match "dd/MM/aaaa") "User-facing prazo prompt must use Brazilian date format."
    Add-Check "CriarTarefa parses full one-shot command" (($taskTopicText -match "parse_responsavel") -and ($taskTopicText -match "parse_prazo") -and ($taskTopicText -match "parse_horas") -and ($taskTopicText -match "parse_prioridade")) "One-line command must not re-ask fields already present."
    Add-Check "Gerar_Multiplos_Projetos topic exists" (Test-Path -LiteralPath $batchTopic) "Batch topic required."
    Add-Check "Gerar_Multiplos_Projetos topic routes batch phrases" (($batchTopicText -match "gerar multiplos projetos") -and ($batchTopicText -match "criar varios projetos") -and ($batchTopicText -match "criar projetos em lote")) "Batch phrases required."

    $criarProjetoOk = [bool](Invoke-SubTest ".\tests\Test-CriarProjetoFlowDefinition.ps1")
    $criarProjetoParserOk = [bool](Invoke-SubTest ".\tests\Test-CriarProjetoTopicParser.ps1")
    $criarProjetoPublishOk = [bool](Invoke-SubTest ".\tests\Test-CriarProjetoPublishBinding.ps1")
    $criarTarefaOk = [bool](Invoke-SubTest ".\tests\Test-CriarTarefaCreatesTarefas.ps1")
    $criarTarefaParserOk = [bool](Invoke-SubTest ".\tests\Test-CriarTarefaTopicParser.ps1")
    $criarTarefaPublishOk = [bool](Invoke-SubTest ".\tests\Test-CriarTarefaPublishBinding.ps1")
    $listarContentSafeOk = [bool](Invoke-SubTest ".\tests\Test-ListarTarefasContentSafeContract.ps1")
    $batchOk = [bool](Invoke-SubTest ".\tests\Test-GerarMultiplosProjetosDefinition.ps1")
    $criarProjetoOutputSafeOk = [bool](Invoke-SubTest ".\tests\Test-CriarProjetoContentSafeOutput.ps1")
    $routingInstructionsOk = [bool](Invoke-SubTest ".\tests\Test-CopilotRoutingInstructions.ps1")
    $pedirDecisaoTopicOk = [bool](Invoke-SubTest ".\tests\Test-PedirDecisaoTopicValidation.ps1")
    $powerFxRegexSafetyOk = [bool](Invoke-SubTest ".\tests\Test-CopilotPowerFxRegexSafety.ps1")
    $atualizarTarefaSkipOk = [bool](Invoke-SubTest ".\tests\Test-AtualizarTarefaSkipSemantics.ps1")
    Add-Check "CriarProjeto flow subtest" $criarProjetoOk "Project flow contract."
    Add-Check "CriarProjeto parser subtest" $criarProjetoParserOk "Project topic parser contract."
    Add-Check "CriarProjeto publish binding subtest" $criarProjetoPublishOk "Project topic must call an action component, not direct CloudFlow."
    Add-Check "CriarTarefa flow subtest" $criarTarefaOk "Task flow contract."
    Add-Check "CriarTarefa parser subtest" $criarTarefaParserOk "Task topic parser contract."
    Add-Check "CriarTarefa publish binding subtest" $criarTarefaPublishOk "Topic must call an action component, not direct CloudFlow."
    Add-Check "ListarTarefas content-safe response subtest" $listarContentSafeOk "Blocks Markdown-heavy/untrusted flow output that can trigger Copilot ContentFiltered."
    Add-Check "Gerar_Multiplos_Projetos subtest" $batchOk "Batch flow/topic contract."
    Add-Check "CriarProjeto content-safe output subtest" $criarProjetoOutputSafeOk "Project action output must be mapped to static bot text."
    Add-Check "Copilot routing instructions subtest" $routingInstructionsOk "Project creation must route to CriarProjeto in GPT and fallback instructions."
    Add-Check "PedirDecisao topic validation subtest" $pedirDecisaoTopicOk "Decision topic must block invalid approver UPN before invoking Power Automate."
    Add-Check "Power Fx regex safety subtest" $powerFxRegexSafetyOk "Package must not contain Copilot Studio-invalid regex character classes."
    Add-Check "AtualizarTarefa skip semantics subtest" $atualizarTarefaSkipOk "Updating optional task fields with skip tokens must preserve current SharePoint values."
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = (Resolve-Path -LiteralPath $tempRoot).Path
        $resolvedBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
        if ($resolvedTemp.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
        }
    }
}

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    packagePath = $resolvedPackagePath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10
if ($failed.Count -gt 0) {
    throw "Solution ZIP P24 contract test failed: $($failed.name -join '; ')"
}
