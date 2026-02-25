#!/usr/bin/env bash

set -euo pipefail

echo "=== DTU VS Code Uninstall (macOS) ==="
echo

remove_vscode_app() {
    local app_path="/Applications/Visual Studio Code.app"
    if [[ ! -d "$app_path" ]]; then
        echo "VS Code app not found at $app_path; skipping."
        return 0
    fi

    echo "Removing VS Code app (requires admin privileges)..."
    if [[ "$EUID" -eq 0 ]]; then
        rm -rf "$app_path"
    else
        sudo rm -rf "$app_path"
    fi
    echo "Removed: $app_path"
}

remove_user_data() {
    echo "Removing VS Code user data..."
    rm -rf "$HOME/Library/Application Support/Code"
    rm -rf "$HOME/.vscode"
    echo "Removed: ~/.vscode and ~/Library/Application Support/Code"
}

remove_symlink() {
    if [[ -L "/usr/local/bin/code" ]]; then
        echo "Removing VS Code CLI symlink..."
        if [[ "$EUID" -eq 0 ]]; then
            rm -f /usr/local/bin/code
        else
            sudo rm -f /usr/local/bin/code
        fi
    fi
    if [[ -L "$HOME/bin/code" ]]; then
        rm -f "$HOME/bin/code"
    fi
}

remove_vscode_app
remove_user_data
remove_symlink

echo
echo "=== VS Code uninstall complete ==="
