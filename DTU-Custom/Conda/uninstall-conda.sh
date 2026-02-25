#!/usr/bin/env bash

set -euo pipefail

# Uninstall conda using the official single-install flow, with optional
# environment backups.

if [[ "$(uname)" == MINGW* || "$(uname)" == CYGWIN* || "$(uname)" == MSYS* ]]; then
    echo "This script targets macOS/Linux shells."
    echo "On Windows, use each installation's Uninstall-*.exe."
    exit 1
fi

if ! command -v conda >/dev/null 2>&1; then
    echo "conda command not found in PATH."
    echo "Activate your conda installation first, then rerun this script."
    exit 1
fi

PRESERVE_ENVIRONMENTS=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--preserve-environments)
            PRESERVE_ENVIRONMENTS=1
            shift
            ;;
        -h|--help)
            cat <<'EOF'
Usage: uninstall-conda.sh [options]

Options:
  -p, --preserve-environments  Export environments to YAML before uninstall
  -h, --help                   Show this help message
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

BASE_PREFIX="$(conda info --base)"

if [[ -z "$BASE_PREFIX" || ! -d "$BASE_PREFIX" ]]; then
    echo "Could not resolve a valid conda base prefix from 'conda info --base'."
    exit 1
fi

BACKUP_ROOT=""
if [[ "$PRESERVE_ENVIRONMENTS" -eq 1 ]]; then
    BACKUP_ROOT="${TMPDIR:-/tmp}/conda-env-backups-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_ROOT"

    if command -v python3 >/dev/null 2>&1; then
        PARSER_PYTHON="$(command -v python3)"
    else
        PARSER_PYTHON="$BASE_PREFIX/bin/python"
    fi

    echo "Exporting environments to: $BACKUP_ROOT"
    while IFS= read -r env_prefix; do
        [[ -n "$env_prefix" ]] || continue
        if [[ "$env_prefix" == "$BASE_PREFIX" ]]; then
            env_name="base"
        else
            env_name="$(basename "$env_prefix")"
        fi

        if ! conda env export -p "$env_prefix" --no-builds > "$BACKUP_ROOT/${env_name}.yaml" 2>/dev/null; then
            echo "WARNING: Failed to export env at $env_prefix"
            rm -f "$BACKUP_ROOT/${env_name}.yaml"
        fi
    done < <(conda env list --json | "$PARSER_PYTHON" -c 'import json,sys; print("\n".join(json.load(sys.stdin).get("envs", [])))')
fi

echo
echo "Running: conda init --reverse --dry-run"
conda init --reverse --dry-run || true

echo
echo "Running: conda init --reverse"
conda init --reverse || true

CONDA_BASE_ENVIRONMENT="$BASE_PREFIX"
echo
echo "The next command will delete all files in ${CONDA_BASE_ENVIRONMENT}"

case "$CONDA_BASE_ENVIRONMENT" in
    ""|"/"|"$HOME")
        echo "Refusing to delete unsafe path: $CONDA_BASE_ENVIRONMENT"
        exit 1
        ;;
esac

rm -rf "$CONDA_BASE_ENVIRONMENT"

echo "${HOME}/.condarc will be removed if it exists"
rm -f "${HOME}/.condarc"

echo "${HOME}/.conda and underlying files will be removed if they exist"
rm -rf "${HOME}/.conda"

echo
echo "Uninstall complete."
if [[ "$PRESERVE_ENVIRONMENTS" -eq 1 ]]; then
    echo "Environment exports: $BACKUP_ROOT"
fi
echo "Restart your terminal."
