@echo off
setlocal

if "%PREFIX%"=="" (
    echo PREFIX is not set; skipping conda initialization
    exit /b 0
)

set "CONDA_EXE=%PREFIX%\Scripts\conda.exe"
if not exist "%CONDA_EXE%" (
    echo conda.exe not found at %CONDA_EXE%; skipping conda initialization
    exit /b 0
)

rem Relax PowerShell script policy for current user to allow conda hook loading.
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop } catch { Write-Host 'Set-ExecutionPolicy skipped:' $_.Exception.Message }"

rem Initialize conda for PowerShell and CMD shells.
"%CONDA_EXE%" init powershell cmd.exe

exit /b 0
