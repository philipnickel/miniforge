# DTU Miniforge3

[![Build DTU Miniforge3](https://github.com/PN-CourseWork/miniforge-DTU-PIS/actions/workflows/ci.yml/badge.svg)](https://github.com/PN-CourseWork/miniforge-DTU-PIS/actions/workflows/ci.yml)
[![GitHub downloads](https://img.shields.io/github/downloads/PN-CourseWork/miniforge-DTU-PIS/total.svg)](https://tooomm.github.io/github-release-stats/?username=PN-CourseWork&repository=miniforge-DTU-PIS)
![Latest release downloads](https://img.shields.io/github/downloads/PN-CourseWork/miniforge-DTU-PIS/latest/total?label=latest%20release)

Customized [Miniforge3](https://github.com/conda-forge/miniforge) installers for DTU courses.

## Quick Links

- [Install](#install) — Miniforge3 and VS Code
- [Uninstall](#uninstall) — Remove Miniforge3 and/or VS Code
- [Update](#update) — Reinstall and restore environments

---

# Install

### macOS / Linux

**Miniforge3**

```sh
curl -fLo Miniforge3.sh "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/Miniforge3-$(uname -s)-$(uname -m).sh" && bash Miniforge3.sh -bc && rm -f Miniforge3.sh 
```

**VS Code**

```sh
curl -fsSL "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/install-vscode-macos.sh" -o /tmp/install-vscode-macos.sh && bash /tmp/install-vscode-macos.sh && rm /tmp/install-vscode-macos.sh
```

### Windows (PowerShell)

**Miniforge3**

```powershell
$BASE_URL = "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download"; irm "$BASE_URL/Miniforge3-Windows-x86_64.exe" -OutFile "$env:TEMP\Miniforge3.exe"; Start-Process "$env:TEMP\Miniforge3.exe" "/S" -NoNewWindow -Wait; Remove-Item "$env:TEMP\Miniforge3.exe" -Force
```

**VS Code**

```powershell
$BASE_URL = "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download"; irm "$BASE_URL/install-vscode-windows.ps1" -OutFile "$env:TEMP\install-vscode-windows.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\install-vscode-windows.ps1"
```

---

# Uninstall

### macOS / Linux

**Miniforge3**

```sh
curl -fsSL "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/uninstall-conda.sh" -o /tmp/uninstall-conda.sh && bash /tmp/uninstall-conda.sh && rm /tmp/uninstall-conda.sh
```

**VS Code**

```sh
curl -fsSL "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/uninstall-vscode-macos.sh" -o /tmp/uninstall-vscode-macos.sh && bash /tmp/uninstall-vscode-macos.sh && rm /tmp/uninstall-vscode-macos.sh
```

### Windows (PowerShell)

**Miniforge3**

```powershell
$BASE_URL = "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download"; irm "$BASE_URL/uninstall-conda-windows.ps1" -OutFile "$env:TEMP\uninstall-conda-windows.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\uninstall-conda-windows.ps1"
```

**VS Code**

```powershell
$BASE_URL = "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download"; irm "$BASE_URL/uninstall-vscode-windows.ps1" -OutFile "$env:TEMP\uninstall-vscode-windows.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\uninstall-vscode-windows.ps1" -Force
```

---

# Update/Reinstall 

### macOS / Linux

**Reinstall + restore environments**

```sh
curl -fsSL "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/update-conda.sh" -o /tmp/update-conda.sh && bash /tmp/update-conda.sh --restore-envs && rm /tmp/update-conda.sh
```

**Reinstall without restoring environments**

```sh
curl -fsSL "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/update-conda.sh" -o /tmp/update-conda.sh && bash /tmp/update-conda.sh && rm /tmp/update-conda.sh
```

**Update VS Code (uninstall + reinstall)**

```sh
curl -fsSL "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/uninstall-vscode-macos.sh" -o /tmp/uninstall-vscode-macos.sh && bash /tmp/uninstall-vscode-macos.sh && rm /tmp/uninstall-vscode-macos.sh && curl -fsSL "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download/install-vscode-macos.sh" -o /tmp/install-vscode-macos.sh && bash /tmp/install-vscode-macos.sh && rm /tmp/install-vscode-macos.sh
```

### Windows (PowerShell)

**Reinstall + restore environments**

```powershell
$BASE_URL = "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download"; irm "$BASE_URL/update-conda-windows.ps1" -OutFile "$env:TEMP\update-conda-windows.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\update-conda-windows.ps1" -RestoreEnvs
```

**Reinstall without restoring environments**

```powershell
$BASE_URL = "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download"; irm "$BASE_URL/update-conda-windows.ps1" -OutFile "$env:TEMP\update-conda-windows.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\update-conda-windows.ps1"
```

**VS Code (uninstall + reinstall)**

```powershell
$BASE_URL = "https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download"; irm "$BASE_URL/uninstall-vscode-windows.ps1" -OutFile "$env:TEMP\uninstall-vscode-windows.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\uninstall-vscode-windows.ps1" -Force; irm "$BASE_URL/install-vscode-windows.ps1" -OutFile "$env:TEMP\install-vscode-windows.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\install-vscode-windows.ps1"
```

---

