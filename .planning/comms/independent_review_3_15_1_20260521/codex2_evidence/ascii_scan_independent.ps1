[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath,

    [Parameter(Mandatory)]
    [string]$OutPath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$topicEntries = @(
    "botcomponents/pmo_AssistentePMO_V2.topic.AtualizarStatus/data",
    "botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data",
    "botcomponents/pmo_AssistentePMO_V2.topic.ConsultarPortfolio/data",
    "botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa/data",
    "botcomponents/pmo_AssistentePMO_V2.topic.ListarTarefas/data"
)

$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedPackagePath)
$lines = [System.Collections.Generic.List[string]]::new()
$violations = [System.Collections.Generic.List[string]]::new()

try {
    $lines.Add("Independent ASCII scan") | Out-Null
    $lines.Add("Package: $resolvedPackagePath") | Out-Null
    $lines.Add("Entries expected: $($topicEntries.Count)") | Out-Null
    $lines.Add("") | Out-Null

    foreach ($entryName in $topicEntries) {
        $entry = $archive.GetEntry($entryName)
        if ($null -eq $entry) {
            $violations.Add("$entryName,MISSING,,") | Out-Null
            $lines.Add("FAIL $entryName missing") | Out-Null
            continue
        }

        $stream = $entry.Open()
        $bytes = New-Object byte[] $entry.Length
        try {
            $offset = 0
            while ($offset -lt $bytes.Length) {
                $read = $stream.Read($bytes, $offset, $bytes.Length - $offset)
                if ($read -le 0) { break }
                $offset += $read
            }
        }
        finally {
            $stream.Dispose()
        }

        $entryViolations = 0
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -gt 0x7F) {
                $entryViolations++
                $violations.Add(("{0},NON_ASCII,{1},0x{2:X2}" -f $entryName, $i, $bytes[$i])) | Out-Null
            }
        }

        if ($entryViolations -eq 0) {
            $lines.Add("PASS $entryName bytes=$($bytes.Length) nonAscii=0") | Out-Null
        }
        else {
            $lines.Add("FAIL $entryName bytes=$($bytes.Length) nonAscii=$entryViolations") | Out-Null
        }
    }
}
finally {
    $archive.Dispose()
}

$lines.Add("") | Out-Null
$lines.Add("ViolationCount: $($violations.Count)") | Out-Null
if ($violations.Count -gt 0) {
    $lines.Add("Violations:") | Out-Null
    foreach ($violation in $violations) {
        $lines.Add($violation) | Out-Null
    }
}

$outDir = Split-Path -Parent $OutPath
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$lines | Set-Content -LiteralPath $OutPath -Encoding ascii

if ($violations.Count -gt 0) {
    exit 1
}

exit 0
