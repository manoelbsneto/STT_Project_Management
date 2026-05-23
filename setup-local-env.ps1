# setup-local-env.ps1
# Run this in your local PowerShell terminal to load .env.local variables
# Usage: . .\setup-local-env.ps1

function Load-EnvLocal {
    $envPath = ".env.local"

    if (-not (Test-Path $envPath)) {
        Write-Warning ".env.local not found. Please create it from .env.local.example"
        return
    }

    Write-Host "Loading environment from $envPath..." -ForegroundColor Green

    Get-Content $envPath | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#")) {
            $parts = $line -split '=', 2
            if ($parts.Count -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim('"')
                [System.Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Process)
                Write-Host "  → $key set" -ForegroundColor DarkGray
            }
        }
    }

    Write-Host "Done! Environment variables loaded for this session." -ForegroundColor Green
    Write-Host "GitHub CLI auth will use these tokens." -ForegroundColor Cyan
}

Load-EnvLocal
