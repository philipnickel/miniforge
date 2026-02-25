@echo off

REM Initialize conda for all supported shells on this machine.
call "%PREFIX%\Scripts\activate.bat"
conda init --all

REM Create PEP 668 EXTERNALLY-MANAGED marker to block pip/uv/poetry in base
set MARKER_FILE=%PREFIX%\Lib\EXTERNALLY-MANAGED

(
echo [externally-managed]
echo Error=This base environment is frozen and should not be modified.
echo   Bypassing this protection can break your installation. Do so at your own risk.
echo.
echo   Instead, create a new environment:
echo     conda create -n myproject python=3.12
echo     conda activate myproject
echo     conda install ^<packages^>
echo.
echo   Only use pip if the package is not available on conda-forge:
echo     pip install ^<packages^>
) > "%MARKER_FILE%"
