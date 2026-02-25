$ErrorActionPreference = "Stop"

param(
    [switch]$PreserveEnvironments
)

function Get-CondaBase {
    try {
        $base = (& conda info --base 2>$null).Trim()
        if ($base -and (Test-Path $base)) {
            return $base
        }
    }
    catch {
    }
    return $null
}

$basePrefix = Get-CondaBase
if (-not $basePrefix) {
    Write-Host "conda command not found or base prefix is unavailable." -ForegroundColor Red
    Write-Host "Activate/open a conda shell first, then rerun this script." -ForegroundColor Yellow
    exit 1
}

$backupRoot = $null
if ($PreserveEnvironments) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupRoot = Join-Path $env:TEMP "conda-env-backups-$timestamp"
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Write-Host "Exporting environments to: $backupRoot"

    $envList = (& conda env list --json | ConvertFrom-Json).envs
    foreach ($envPrefix in $envList) {
        if (-not $envPrefix) { continue }

        if ($envPrefix -eq $basePrefix) {
            $envName = "base"
        }
        else {
            $envName = Split-Path -Leaf $envPrefix
        }

        $yamlPath = Join-Path $backupRoot "$envName.yaml"
        try {
            & conda env export -p $envPrefix --no-builds *> $yamlPath
        }
        catch {
            Write-Host "WARNING: Failed to export env at $envPrefix" -ForegroundColor Yellow
            Remove-Item -Path $yamlPath -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host ""
Write-Host "Running: conda init --reverse --dry-run"
try {
    & conda init --reverse --dry-run
}
catch {
}

Write-Host ""
Write-Host "Running: conda init --reverse"
try {
    & conda init --reverse
}
catch {
}

Write-Host ""
Write-Host "The next action will delete all files in $basePrefix"

$unsafe = @("", "C:\", $env:USERPROFILE)
if ($unsafe -contains $basePrefix) {
    Write-Host "Refusing to delete unsafe path: $basePrefix" -ForegroundColor Red
    exit 1
}

if (Test-Path $basePrefix) {
    Remove-Item -Path $basePrefix -Recurse -Force
}

$condarc = Join-Path $env:USERPROFILE ".condarc"
$condaDir = Join-Path $env:USERPROFILE ".conda"

Write-Host "$condarc will be removed if it exists"
if (Test-Path $condarc) {
    Remove-Item -Path $condarc -Force
}

Write-Host "$condaDir and underlying files will be removed if they exist"
if (Test-Path $condaDir) {
    Remove-Item -Path $condaDir -Recurse -Force
}

Write-Host ""
Write-Host "Uninstall complete." -ForegroundColor Green
if ($PreserveEnvironments -and $backupRoot) {
    Write-Host "Environment exports: $backupRoot"
}
Write-Host "Restart your terminal."
