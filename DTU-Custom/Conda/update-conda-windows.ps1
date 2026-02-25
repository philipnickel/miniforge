$ErrorActionPreference = "Stop"

param(
    [switch]$RestoreEnvs
)

$releaseBaseUrl = if ($env:DTU_RELEASE_BASE_URL) { $env:DTU_RELEASE_BASE_URL } else { "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download" }
$uninstallScript = Join-Path $PSScriptRoot "uninstall-conda-windows.ps1"
$downloadedUninstall = $false

if (-not (Test-Path $uninstallScript)) {
    Write-Host "Local uninstall script not found; downloading from release assets..."
    $uninstallScript = Join-Path $env:TEMP ("uninstall-conda-" + [guid]::NewGuid().ToString() + ".ps1")
    Invoke-RestMethod "$releaseBaseUrl/uninstall-conda-windows.ps1" -OutFile $uninstallScript
    $downloadedUninstall = $true
}

try {
    $backupRoot = $null

    if ($RestoreEnvs) {
        Write-Host "==> Step 1/4: Backing up environments and uninstalling conda installation..."
        $uninstallOutput = & powershell -ExecutionPolicy Bypass -File $uninstallScript -PreserveEnvironments 2>&1
        $uninstallOutput | ForEach-Object { Write-Host $_ }

        $backupLine = $uninstallOutput | Where-Object { $_ -match "^Environment exports:\s+" } | Select-Object -Last 1
        if ($backupLine) {
            $backupRoot = ($backupLine -replace "^Environment exports:\s+", "").Trim()
        }

        if (-not $backupRoot -or -not (Test-Path $backupRoot)) {
            throw "Could not find environment backup directory from uninstaller output."
        }
    }
    else {
        Write-Host "==> Step 1/3: Uninstalling conda installation..."
        & powershell -ExecutionPolicy Bypass -File $uninstallScript
    }

    if ($RestoreEnvs) {
        Write-Host "==> Step 2/4: Installing latest Miniforge3..."
    }
    else {
        Write-Host "==> Step 2/3: Installing latest Miniforge3..."
    }

    $installerExe = Join-Path $env:TEMP "Miniforge3.exe"
    Invoke-RestMethod "$releaseBaseUrl/Miniforge3-Windows-x86_64.exe" -OutFile $installerExe
    Start-Process -FilePath $installerExe -ArgumentList "/S" -NoNewWindow -Wait
    Remove-Item -Path $installerExe -Force -ErrorAction SilentlyContinue

    $prefixCandidates = @(
        "$env:USERPROFILE\miniforge3-DTU",
        "$env:USERPROFILE\miniforge3",
        "$env:USERPROFILE\miniconda3",
        "$env:USERPROFILE\anaconda3",
        "$env:ProgramData\miniforge3",
        "$env:ProgramData\miniconda3",
        "$env:ProgramData\anaconda3"
    )

    $prefix = $null
    foreach ($candidate in $prefixCandidates) {
        $condaExeCandidate = Join-Path $candidate "Scripts\conda.exe"
        if (Test-Path $condaExeCandidate) {
            $prefix = $candidate
            break
        }
    }

    if (-not $prefix) {
        throw "Could not detect the newly installed conda prefix automatically."
    }

    Write-Host "==> Detected new prefix: $prefix"

    $condaExe = Join-Path $prefix "Scripts\conda.exe"
    $mambaExe = Join-Path $prefix "Scripts\mamba.exe"
    $envTool = $condaExe
    if (Test-Path $mambaExe) {
        $envTool = $mambaExe
    }
    Write-Host "==> Using '$([System.IO.Path]::GetFileNameWithoutExtension($envTool))' for environment restore operations"

    function Normalize-EnvName([string]$name) {
        switch ($name) {
            "miniforge3" { return "base" }
            "miniforge3-DTU" { return "base" }
            "miniconda3" { return "base" }
            "anaconda3" { return "base" }
            "mambaforge" { return "base" }
            default { return $name }
        }
    }

    function Get-ExistingEnvNames([string]$condaExecutable) {
        $json = & $condaExecutable env list --json | ConvertFrom-Json
        $names = @{}
        foreach ($p in $json.envs) {
            if (-not $p) { continue }
            $leaf = Split-Path -Leaf $p
            if ($p -eq $prefix) {
                $leaf = "base"
            }
            $names[$leaf] = $true
        }
        return $names
    }

    if ($RestoreEnvs) {
        Write-Host "==> Step 3/4: Restoring backed-up environments from: $backupRoot"

        $yamlFiles = Get-ChildItem -Path $backupRoot -Filter *.yaml -File -Recurse | Sort-Object FullName
        if (-not $yamlFiles) {
            Write-Host "No environment backup YAML files were found under: $backupRoot"
        }

        $restored = @{}
        foreach ($yaml in $yamlFiles) {
            $envName = Normalize-EnvName $yaml.BaseName
            if ($restored.ContainsKey($envName)) {
                continue
            }

            $tmpDir = Join-Path $env:TEMP ("conda-env-" + [guid]::NewGuid().ToString())
            New-Item -ItemType Directory -Path $tmpDir | Out-Null
            $tmpYaml = Join-Path $tmpDir "environment.yml"

            Get-Content $yaml.FullName | Where-Object { $_ -notmatch '^prefix:' } | Set-Content $tmpYaml

            $existing = Get-ExistingEnvNames $condaExe
            if ($envName -eq "base") {
                $cmdArgs = @("env", "update", "-n", "base", "-f", $tmpYaml, "--yes")
                Write-Host "    - Updating base from $($yaml.Name)"
            }
            elseif ($existing.ContainsKey($envName)) {
                $cmdArgs = @("env", "update", "-n", $envName, "-f", $tmpYaml, "--yes")
                Write-Host "    - Updating env '$envName'"
            }
            else {
                $cmdArgs = @("env", "create", "-n", $envName, "-f", $tmpYaml, "--yes")
                Write-Host "    - Creating env '$envName'"
            }

            Write-Host "      Running: $envTool $($cmdArgs -join ' ')"
            & $envTool @cmdArgs

            Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
            $restored[$envName] = $true
        }

        Write-Host "==> Step 4/4: Done"
        Write-Host "Backups remain at: $backupRoot"
    }
    else {
        Write-Host "==> Step 3/3: Done"
    }

    Write-Host "Restart your terminal."
}
finally {
    if ($downloadedUninstall -and (Test-Path $uninstallScript)) {
        Remove-Item -Path $uninstallScript -Force -ErrorAction SilentlyContinue
    }
}
