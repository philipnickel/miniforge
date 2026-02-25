$ErrorActionPreference = "Stop"

Write-Host "=== DTU VS Code Installation (Windows) ===" -ForegroundColor Cyan
Write-Host ""

function Install-VSCode {
    $paths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
        "$env:ProgramFiles\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Host "Found existing VS Code at: $path" -ForegroundColor Green
            return
        }
    }

    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq "ARM64") {
        $url = "https://update.code.visualstudio.com/latest/win32-arm64-user/stable"
        $installer = Join-Path $env:TEMP "VSCodeUserSetup-arm64.exe"
    }
    else {
        $url = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
        $installer = Join-Path $env:TEMP "VSCodeUserSetup-x64.exe"
    }

    Write-Host "Downloading VS Code installer..."
    Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing

    Write-Host "Installing VS Code..."
    $proc = Start-Process -FilePath $installer -ArgumentList "/VERYSILENT /NORESTART /TASKS=addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "VS Code installer exited with code $($proc.ExitCode)"
    }

    Remove-Item -Path $installer -Force -ErrorAction SilentlyContinue
    $env:PATH = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin;$env:PATH"
}

function Install-Extensions {
    Write-Host ""
    Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan
    try {
        & code --version > $null 2>&1
    }
    catch {
        Write-Host "code CLI not available; skipping extensions." -ForegroundColor Yellow
        return
    }

    $extensions = @(
        "ms-python.python",
        "ms-toolsai.jupyter"
    )

    foreach ($ext in $extensions) {
        Write-Host "  Installing $ext..."
        & code --install-extension $ext --force
    }
}

Install-VSCode
Install-Extensions

Write-Host ""
Write-Host "=== VS Code installation complete ===" -ForegroundColor Cyan
