#!/usr/bin/env bash

set -euo pipefail

echo "=== DTU VS Code Installation (macOS) ==="
echo

install_vscode() {
    if command -v code >/dev/null 2>&1; then
        echo "VS Code CLI already available at: $(command -v code)"
        return 0
    fi

    if [[ -d "/Applications/Visual Studio Code.app" ]]; then
        echo "VS Code app found; setting up CLI symlink..."
        create_code_symlink
        return 0
    fi

    local arch url
    arch="$(uname -m)"
    if [[ "$arch" == "arm64" ]]; then
        url="https://update.code.visualstudio.com/latest/darwin-arm64/stable"
    else
        url="https://update.code.visualstudio.com/latest/darwin/stable"
    fi

    echo "Downloading VS Code ($arch)..."
    curl -fsSL "$url" -o /tmp/VSCode.zip
    unzip -qq /tmp/VSCode.zip -d /tmp/
    rm -rf "/Applications/Visual Studio Code.app"
    mv "/tmp/Visual Studio Code.app" "/Applications/"
    rm -f /tmp/VSCode.zip

}


install_extensions() {
    local code_cli
    if command -v code >/dev/null 2>&1; then
        code_cli="code"
    elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
        code_cli="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    else
        echo "VS Code CLI not found; skipping extension install."
        return 0
    fi

    echo
    echo "Installing VS Code extensions..."
    "$code_cli" --install-extension ms-python.python --force
    "$code_cli" --install-extension ms-toolsai.jupyter --force
}

install_vscode
hash -r
install_extensions

echo
echo "=== VS Code installation complete ==="
