#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
UNINSTALL_SCRIPT="$SCRIPT_DIR/uninstall-conda.sh"
RELEASE_BASE_URL="${DTU_RELEASE_BASE_URL:-https://github.com/PN-CourseWork/miniforge-DTU-PIS/releases/latest/download}"
UNINSTALL_URL="$RELEASE_BASE_URL/uninstall-conda.sh"
INSTALLER_URL="$RELEASE_BASE_URL/Miniforge3-$(uname -s)-$(uname -m).sh"
RESTORE_ENVS=0
DOWNLOADED_UNINSTALL=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --restore-envs)
            RESTORE_ENVS=1
            shift
            ;;
        -h|--help)
            cat <<'EOF'
Usage: update-conda.sh [--restore-envs]

Modes:
  (default)       Purge all conda installations and reinstall Miniforge
  --restore-envs  Also back up and restore environments across reinstall
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage."
            exit 1
            ;;
    esac
done

if [[ ! -x "$UNINSTALL_SCRIPT" ]]; then
    echo "Local uninstall script not found; downloading from release assets..."
    UNINSTALL_SCRIPT="$(mktemp "${TMPDIR:-/tmp}/uninstall-conda-XXXXXX.sh")"
    curl -fsSL "$UNINSTALL_URL" -o "$UNINSTALL_SCRIPT"
    chmod +x "$UNINSTALL_SCRIPT"
    DOWNLOADED_UNINSTALL=1
fi

cleanup() {
    if [[ "$DOWNLOADED_UNINSTALL" -eq 1 && -f "$UNINSTALL_SCRIPT" ]]; then
        rm -f "$UNINSTALL_SCRIPT"
    fi
}
trap cleanup EXIT

BACKUP_ROOT=""
if [[ "$RESTORE_ENVS" -eq 1 ]]; then
    echo "==> Step 1/4: Backing up environments and uninstalling conda installations..."
    UNINSTALL_LOG="$(mktemp)"
    bash "$UNINSTALL_SCRIPT" --preserve-environments | tee "$UNINSTALL_LOG"

    BACKUP_ROOT="$(awk -F': ' '/^Environment exports: /{print $2}' "$UNINSTALL_LOG" | tail -n 1)"
    rm -f "$UNINSTALL_LOG"

    if [[ -z "${BACKUP_ROOT:-}" || ! -d "$BACKUP_ROOT" ]]; then
        echo "Could not find environment backup directory from uninstaller output."
        exit 1
    fi
else
    echo "==> Step 1/3: Uninstalling conda installations..."
    bash "$UNINSTALL_SCRIPT"
fi

if [[ "$RESTORE_ENVS" -eq 1 ]]; then
    echo "==> Step 2/4: Installing latest Miniforge3..."
else
    echo "==> Step 2/3: Installing latest Miniforge3..."
fi
INSTALL_START_TS="$(date +%s)"
echo "==> Downloading Miniforge3..."
curl -fLo Miniforge3.sh "$INSTALLER_URL"
echo "==> Installing Miniforge3..."
bash Miniforge3.sh -b
echo "==> Cleaning up installer artifact..."
rm -f Miniforge3.sh

detect_installed_prefix() {
    local start_ts="$1"
    local p
    local -a candidates=(
        "$HOME/miniforge3-DTU"
        "$HOME/miniforge3"
        "$HOME/mambaforge"
        "$HOME/miniconda3"
        "$HOME/anaconda3"
    )

    for p in "${candidates[@]}"; do
        if [[ -x "$p/bin/conda" ]]; then
            if [[ "$(stat -f %m "$p")" -ge "$start_ts" ]]; then
                printf '%s\n' "$p"
                return 0
            fi
        fi
    done

    while IFS= read -r p; do
        [[ -n "$p" ]] || continue
        printf '%s\n' "$p"
        return 0
    done < <(find "$HOME" -maxdepth 3 -type f -name conda -path "*/bin/conda" -newermt "@${start_ts}" 2>/dev/null | while IFS= read -r exe; do dirname "$(dirname "$exe")"; done)

    return 1
}

PREFIX="$(detect_installed_prefix "$INSTALL_START_TS" || true)"
if [[ -z "${PREFIX:-}" || ! -x "$PREFIX/bin/conda" ]]; then
    echo "Could not detect the newly installed conda prefix automatically."
    if [[ "$RESTORE_ENVS" -eq 1 ]]; then
        echo "Backups are still available at: $BACKUP_ROOT"
    fi
    exit 1
fi

echo "==> Detected new prefix: $PREFIX"

# shellcheck disable=SC1091
source "$PREFIX/etc/profile.d/conda.sh"
conda activate base >/dev/null 2>&1 || true

ENV_TOOL="conda"
if command -v mamba >/dev/null 2>&1; then
    ENV_TOOL="mamba"
fi
echo "==> Using '$ENV_TOOL' for environment restore operations"

restore_environment() {
    local yaml_path="$1"
    local env_name tmp_yaml tmp_dir
    local -a cmd

    env_name="$(basename "$yaml_path" .yaml)"

    case "$env_name" in
        miniforge3|miniforge3-DTU|miniconda3|anaconda3|mambaforge)
            env_name="base"
            ;;
    esac

    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/conda-env-XXXXXX")"
    tmp_yaml="$tmp_dir/environment.yml"
    sed '/^prefix:/d' "$yaml_path" > "$tmp_yaml"

    if [[ "$env_name" == "base" ]]; then
        echo "    - Updating base from $(basename "$yaml_path")"
        cmd=("$ENV_TOOL" env update -n base -f "$tmp_yaml" --yes)
        echo "      Running: ${cmd[*]}"
        "${cmd[@]}"
    else
        if conda env list | awk '{print $1}' | grep -Fxq "$env_name"; then
            echo "    - Updating env '$env_name'"
            cmd=("$ENV_TOOL" env update -n "$env_name" -f "$tmp_yaml" --yes)
            echo "      Running: ${cmd[*]}"
            "${cmd[@]}"
        else
            echo "    - Creating env '$env_name'"
            cmd=("$ENV_TOOL" env create -n "$env_name" -f "$tmp_yaml" --yes)
            echo "      Running: ${cmd[*]}"
            "${cmd[@]}"
        fi
    fi

    rm -rf "$tmp_dir"
}

if [[ "$RESTORE_ENVS" -eq 1 ]]; then
    echo "==> Step 3/4: Restoring backed-up environments from: $BACKUP_ROOT"
fi
ENV_FILES_FOUND=0
RESTORED_ENVS=""

already_restored() {
    local env_name="$1"
    case ",$RESTORED_ENVS," in
        *",$env_name,"*) return 0 ;;
        *) return 1 ;;
    esac
}

while [[ "$RESTORE_ENVS" -eq 1 ]] && IFS= read -r yaml_file; do
    local_name="$(basename "$yaml_file" .yaml)"
    case "$local_name" in
        miniforge3|miniforge3-DTU|miniconda3|anaconda3|mambaforge)
            local_name="base"
            ;;
    esac

    if already_restored "$local_name"; then
        continue
    fi

    [[ -n "$yaml_file" ]] || continue
    ENV_FILES_FOUND=1
    restore_environment "$yaml_file"
    RESTORED_ENVS="${RESTORED_ENVS},${local_name}"
done < <(find "$BACKUP_ROOT" -type f -name "*.yaml" | sort)

if [[ "$RESTORE_ENVS" -eq 1 && "$ENV_FILES_FOUND" -eq 0 ]]; then
    echo "No environment backup YAML files were found under: $BACKUP_ROOT"
fi

if [[ "$RESTORE_ENVS" -eq 1 ]]; then
    echo "==> Step 4/4: Done"
    echo "Backups remain at: $BACKUP_ROOT"
else
    echo "==> Step 3/3: Done"
fi
echo "Restart your terminal to begin using python and conda."
