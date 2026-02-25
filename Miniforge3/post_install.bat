@echo off
REM Post-installation script to add PEP 668 EXTERNALLY-MANAGED marker
REM This prevents pip/uv/poetry from modifying the base environment

echo Creating PEP 668 marker file...

REM Get Python version dynamically
for /f "delims=" %%i in ('%PREFIX%\python.exe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"') do set PYTHON_VERSION=%%i

set MARKER_FILE=%PREFIX%\Lib\EXTERNALLY-MANAGED

echo Marker file location: %MARKER_FILE%

REM Create the EXTERNALLY-MANAGED marker file
(
echo [externally-managed]
echo Error=This DTU Python base environment is frozen and cannot be modified.
echo.
echo To install additional packages, create a new environment:
echo   conda create -n myproject python=3.12
echo   conda activate myproject
echo   conda install ^<packages^>   
echo.
echo This protection applies to both conda/mamba AND pip/uv/poetry.
echo.
echo For more information about frozen environments:
echo   - conda/mamba: https://conda.org/learn/ceps/cep-0022
echo   - pip: https://peps.python.org/pep-0668/
) > "%MARKER_FILE%"

echo PEP 668 protection installed successfully
