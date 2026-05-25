param(
    [Parameter(Mandatory=$true)]
    [string]$ZipPath
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $entry = $zip.GetEntry('solution.xml')
    if ($null -eq $entry) {
        Write-Error "solution.xml not found in $ZipPath"
        exit 1
    }
    $reader = New-Object System.IO.StreamReader($entry.Open())
    $content = $reader.ReadToEnd()
    $reader.Close()
    Write-Host "=== solution.xml from $ZipPath ==="
    $content | Select-String -Pattern '<Version>|<UniqueName>|<Managed>|<LocalizedName' | ForEach-Object { $_.Line.Trim() }
}
finally {
    $zip.Dispose()
}
