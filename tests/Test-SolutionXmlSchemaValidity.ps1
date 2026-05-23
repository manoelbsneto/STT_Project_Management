[CmdletBinding()]
param(
    [string]$Path,

    [switch]$SelfTest,

    [switch]$UseLivePacMetadata,

    [string]$PacEnvironment,

    [string]$ComponentTypeCachePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if ([string]::IsNullOrWhiteSpace($ComponentTypeCachePath)) {
    $ComponentTypeCachePath = Join-Path $PSScriptRoot "fixtures\schema_validity\official_componenttype_cache.json"
}

function Resolve-RequiredFile {
    param(
        [string]$FilePath,
        [string]$Description
    )

    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        throw "$Description path is required."
    }

    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        throw "$Description file not found: $FilePath"
    }

    (Resolve-Path -LiteralPath $FilePath).Path
}

function Remove-VerifiedTempDirectory {
    param([string]$TempPath)

    if (-not (Test-Path -LiteralPath $TempPath -PathType Container)) {
        return
    }

    $resolvedTemp = (Resolve-Path -LiteralPath $TempPath).Path
    $resolvedBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    if (-not $resolvedTemp.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove non-temp directory: $resolvedTemp"
    }

    Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
}

function Get-OfficialComponentTypeMetadata {
    param([string]$CachePath)

    $resolvedCachePath = Resolve-RequiredFile -FilePath $CachePath -Description "Official componenttype cache"
    $cache = Get-Content -LiteralPath $resolvedCachePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (($cache.globalChoiceName -ne "componenttype") -or (@($cache.values).Count -eq 0)) {
        throw "Official componenttype cache is invalid: $resolvedCachePath"
    }

    $values = [System.Collections.Generic.List[int]]::new()
    foreach ($item in @($cache.values)) {
        $values.Add([int]$item.value) | Out-Null
    }

    [pscustomobject]@{
        source = "OfficialMicrosoftCache"
        reference = [string]$cache.source
        detail = "Cached SolutionComponent.componenttype choices from Microsoft Learn."
        values = @($values | Sort-Object -Unique)
        fallbackReason = $null
    }
}

function Get-LivePacComponentTypeValues {
    param([string]$Environment)

    $pac = Get-Command pac -ErrorAction Stop
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_componenttype_model_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    try {
        $arguments = @(
            "modelbuilder",
            "build",
            "--entitynamesfilter",
            "solutioncomponent",
            "--language",
            "CS",
            "--namespace",
            "Pmo.SchemaGuard",
            "--outdirectory",
            $tempRoot,
            "--suppressINotifyPattern"
        )
        if (-not [string]::IsNullOrWhiteSpace($Environment)) {
            $arguments += @("--environment", $Environment)
        }

        $pacOutput = & $pac.Source @arguments 2>&1
        $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
        if ($exitCode -ne 0) {
            throw "pac modelbuilder build failed with exit code ${exitCode}: $($pacOutput -join "`n")"
        }

        $candidateFiles = @(
            Get-ChildItem -LiteralPath $tempRoot -Recurse -File -Filter "*.cs" |
                Where-Object { $_.Name -match "(?i)componenttype" }
        )
        if ($candidateFiles.Count -eq 0) {
            $candidateFiles = @(
                Get-ChildItem -LiteralPath $tempRoot -Recurse -File -Filter "*.cs" |
                    Where-Object { (Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue) -match "(?i)\bcomponenttype\b" }
            )
        }

        $values = [System.Collections.Generic.List[int]]::new()
        foreach ($file in $candidateFiles) {
            $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
            if ($text -notmatch "(?i)\bcomponenttype\b") {
                continue
            }

            foreach ($match in [regex]::Matches($text, "=\s*(?<value>[0-9]+)\s*(?:,|$)", [System.Text.RegularExpressions.RegexOptions]::Multiline)) {
                $values.Add([int]$match.Groups["value"].Value) | Out-Null
            }
        }

        $uniqueValues = @($values | Sort-Object -Unique)
        if (($uniqueValues.Count -eq 0) -or ($uniqueValues -notcontains 29)) {
            throw "pac modelbuilder output did not expose the componenttype values expected for SolutionComponent."
        }

        return $uniqueValues
    }
    finally {
        Remove-VerifiedTempDirectory -TempPath $tempRoot
    }
}

function Get-ComponentTypeMetadata {
    param(
        [string]$CachePath,
        [bool]$UseLivePac,
        [string]$Environment
    )

    $officialMetadata = Get-OfficialComponentTypeMetadata -CachePath $CachePath
    if (-not $UseLivePac) {
        return $officialMetadata
    }

    try {
        $liveValues = @(Get-LivePacComponentTypeValues -Environment $Environment)
        return [pscustomobject]@{
            source = "LivePacModelBuilder"
            reference = "pac modelbuilder build --entitynamesfilter solutioncomponent"
            detail = "Read-only PAC metadata generated for the active or supplied Dataverse environment."
            values = $liveValues
            fallbackReason = $null
        }
    }
    catch {
        $officialMetadata.fallbackReason = "Live PAC metadata unavailable: $($_.Exception.Message)"
        return $officialMetadata
    }
}

function Get-ZipSolutionXmlText {
    param([string]$ZipPath)

    $archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        $entries = @(
            $archive.Entries |
                Where-Object { ([System.IO.Path]::GetFileName($_.FullName)).Equals("solution.xml", [System.StringComparison]::OrdinalIgnoreCase) }
        )
        if ($entries.Count -eq 0) {
            throw "Solution ZIP does not contain solution.xml: $ZipPath"
        }

        $entry = @($entries | Where-Object { $_.FullName.Equals("solution.xml", [System.StringComparison]::OrdinalIgnoreCase) })[0]
        if ($null -eq $entry) {
            if ($entries.Count -ne 1) {
                throw "Solution ZIP has multiple non-root solution.xml entries: $ZipPath"
            }
            $entry = $entries[0]
        }

        $stream = $entry.Open()
        $reader = [System.IO.StreamReader]::new($stream, $true)
        try {
            [pscustomobject]@{
                text = $reader.ReadToEnd()
                entry = $entry.FullName
            }
        }
        finally {
            $reader.Dispose()
            $stream.Dispose()
        }
    }
    finally {
        $archive.Dispose()
    }
}

function Get-SolutionXmlPayload {
    param([string]$InputPath)

    $resolvedInputPath = Resolve-RequiredFile -FilePath $InputPath -Description "Solution XML or ZIP"
    if ([System.IO.Path]::GetExtension($resolvedInputPath).Equals(".zip", [System.StringComparison]::OrdinalIgnoreCase)) {
        $zipPayload = Get-ZipSolutionXmlText -ZipPath $resolvedInputPath
        return [pscustomobject]@{
            path = $resolvedInputPath
            kind = "Zip"
            manifest = $zipPayload.entry
            text = $zipPayload.text
        }
    }

    if (-not [System.IO.Path]::GetExtension($resolvedInputPath).Equals(".xml", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Input must be a solution.xml file or solution ZIP: $resolvedInputPath"
    }

    [pscustomobject]@{
        path = $resolvedInputPath
        kind = "Xml"
        manifest = (Split-Path -Leaf $resolvedInputPath)
        text = Get-Content -LiteralPath $resolvedInputPath -Raw -Encoding UTF8
    }
}

function Test-SolutionRootComponentTypes {
    param(
        [string]$InputPath,
        [object]$Metadata
    )

    $payload = Get-SolutionXmlPayload -InputPath $InputPath
    try {
        [xml]$solutionXml = $payload.text
    }
    catch {
        throw "Input solution.xml is not valid XML: $($payload.path). $($_.Exception.Message)"
    }

    $rootComponents = @($solutionXml.SelectNodes("//*[local-name()='RootComponent']"))
    $allowedTypes = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($value in @($Metadata.values)) {
        $allowedTypes.Add([int]$value) | Out-Null
    }

    $componentResults = [System.Collections.Generic.List[object]]::new()
    $issues = [System.Collections.Generic.List[string]]::new()
    foreach ($component in $rootComponents) {
        $rawType = [string]$component.GetAttribute("type")
        $componentId = [string]$component.GetAttribute("id")
        $componentType = 0
        $issue = $null

        if ([string]::IsNullOrWhiteSpace($rawType)) {
            $issue = "RootComponent '$componentId' has no type attribute."
        }
        elseif (($rawType -notmatch "^[0-9]+$") -or (-not [int]::TryParse($rawType, [ref]$componentType))) {
            $issue = "RootComponent '$componentId' type '$rawType' is not a Dataverse componenttype integer."
        }
        elseif (-not $allowedTypes.Contains($componentType)) {
            $issue = "RootComponent '$componentId' type '$rawType' is not in $($Metadata.source) componenttype values."
        }

        if ($null -ne $issue) {
            $issues.Add($issue) | Out-Null
        }

        $componentResults.Add([ordered]@{
            id = $componentId
            type = $rawType
            valid = ($null -eq $issue)
            issue = $issue
        }) | Out-Null
    }

    [ordered]@{
        inputPath = $payload.path
        inputKind = $payload.kind
        solutionXmlManifest = $payload.manifest
        metadataSource = $Metadata.source
        metadataReference = $Metadata.reference
        metadataDetail = $Metadata.detail
        metadataFallbackReason = $Metadata.fallbackReason
        allowedComponentTypeCount = @($Metadata.values).Count
        rootComponentCount = $rootComponents.Count
        invalidRootComponentCount = $issues.Count
        passed = ($issues.Count -eq 0)
        rootComponents = $componentResults
        issues = $issues
    }
}

function New-TempSolutionZip {
    param(
        [string]$XmlPath,
        [string]$ZipPath
    )

    $archive = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        $entry = $archive.CreateEntry("solution.xml")
        $entryStream = $entry.Open()
        $writer = [System.IO.StreamWriter]::new($entryStream, [System.Text.UTF8Encoding]::new($false))
        try {
            $writer.Write((Get-Content -LiteralPath $XmlPath -Raw -Encoding UTF8))
        }
        finally {
            $writer.Dispose()
            $entryStream.Dispose()
        }
    }
    finally {
        $archive.Dispose()
    }
}

function Invoke-SelfTest {
    param([object]$Metadata)

    $fixtureRoot = Join-Path $PSScriptRoot "fixtures\schema_validity"
    $baseFixture = Resolve-RequiredFile -FilePath (Join-Path $fixtureRoot "base_3_15_solution.xml") -Description "Base 3.15 solution fixture"
    $hotfixFixture = Resolve-RequiredFile -FilePath (Join-Path $fixtureRoot "hotfix_3_15_1_invalid_solution.xml") -Description "Hotfix 3.15.1 solution fixture"
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_solution_schema_selftest_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    $checks = [System.Collections.Generic.List[object]]::new()
    try {
        $baseZip = Join-Path $tempRoot "base_3_15.zip"
        $hotfixZip = Join-Path $tempRoot "hotfix_3_15_1.zip"
        New-TempSolutionZip -XmlPath $baseFixture -ZipPath $baseZip
        New-TempSolutionZip -XmlPath $hotfixFixture -ZipPath $hotfixZip

        $cases = @(
            [pscustomobject]@{ name = "Base 3.15 XML passes"; path = $baseFixture; expected = $true },
            [pscustomobject]@{ name = "Base 3.15 ZIP passes"; path = $baseZip; expected = $true },
            [pscustomobject]@{ name = "Hotfix 3.15.1 XML blocks string botcomponent types"; path = $hotfixFixture; expected = $false },
            [pscustomobject]@{ name = "Hotfix 3.15.1 ZIP blocks string botcomponent types"; path = $hotfixZip; expected = $false }
        )

        foreach ($case in $cases) {
            $result = Test-SolutionRootComponentTypes -InputPath $case.path -Metadata $Metadata
            $expectedIncidentSignal = $case.expected -or
                (@($result.issues | Where-Object { $_ -match "type 'botcomponent' is not a Dataverse componenttype integer" }).Count -eq 5)
            $passed = ($result.passed -eq $case.expected) -and $expectedIncidentSignal
            $checks.Add([ordered]@{
                name = $case.name
                passed = $passed
                evidence = [ordered]@{
                    path = $case.path
                    guardPassed = $result.passed
                    expectedGuardPassed = $case.expected
                    invalidRootComponentCount = $result.invalidRootComponentCount
                }
            }) | Out-Null
        }
    }
    finally {
        Remove-VerifiedTempDirectory -TempPath $tempRoot
    }

    $failed = @($checks | Where-Object { -not $_.passed })
    [ordered]@{
        mode = "SelfTest"
        metadataSource = $Metadata.source
        metadataReference = $Metadata.reference
        passed = ($failed.Count -eq 0)
        failedCheckCount = $failed.Count
        checks = $checks
    }
}

$metadata = Get-ComponentTypeMetadata -CachePath $ComponentTypeCachePath -UseLivePac ([bool]$UseLivePacMetadata) -Environment $PacEnvironment
if ($SelfTest) {
    $selfTestResult = Invoke-SelfTest -Metadata $metadata
    $selfTestResult | ConvertTo-Json -Depth 12
    if (-not $selfTestResult.passed) {
        throw "Solution XML schema validity self-test failed: $(@($selfTestResult.checks | Where-Object { -not $_.passed }).name -join '; ')"
    }
    return
}

if ([string]::IsNullOrWhiteSpace($Path)) {
    throw "Supply -Path with solution.xml or a solution ZIP, or run -SelfTest."
}

$result = Test-SolutionRootComponentTypes -InputPath $Path -Metadata $metadata
$result | ConvertTo-Json -Depth 12
if (-not $result.passed) {
    throw "Solution XML RootComponent type validation failed: $($result.issues -join '; ')"
}
