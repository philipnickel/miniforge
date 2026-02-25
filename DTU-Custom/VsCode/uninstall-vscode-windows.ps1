param(
    [switch]$Force
)

$ErrorActionPreference = "Continue"

Write-Host "=== DTU VS Code Uninstall (Windows) ===" -ForegroundColor Cyan
Write-Host ""

$vscodePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code",
    "$env:ProgramFiles\Microsoft VS Code",
    "${env:ProgramFiles(x86)}\Microsoft VS Code"
) | Where-Object { Test-Path $_ }

if ($vscodePaths.Count -eq 0) {
    Write-Host "No VS Code installations found." -ForegroundColor Green
    exit 0
}

if (-not $Force) {
    $response = Read-Host "Remove VS Code and user data? (y/N)"
    if ($response -notin @("y", "Y")) {
        Write-Host "Cancelled."
        exit 0
    }
}

foreach ($path in $vscodePaths) {
    try {
        $uninstaller = Join-Path $path "unins000.exe"
        if (Test-Path $uninstaller) {
            Start-Process -FilePath $uninstaller -ArgumentList "/SILENT" -Wait
        }
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
        }
        Write-Host "Removed: $path" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to remove ${path}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$cleanup = @(
    "$env:APPDATA\Code",
    "$env:USERPROFILE\.vscode"
)
foreach ($path in $cleanup) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

try {
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath) {
        $cleanPath = ($userPath -split ';' | Where-Object { $_ -notmatch 'Microsoft VS Code' }) -join ';'
        [Environment]::SetEnvironmentVariable("PATH", $cleanPath, "User")
    }
}
catch {
}

Write-Host ""
Write-Host "=== VS Code uninstall complete ===" -ForegroundColor Cyan
