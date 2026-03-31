#!/usr/bin/env zsh
# This script installs/updates software outside the homebrew stack

set -e  # Exit on any error
set -u  # Treat unset variables as error

# Ensure we have the latest environment customizations
source "$MAC_STACK_ROOT/scripts/helpers.sh"
source "$MAC_STACK_ROOT/scripts/sourced_in_zshrc/setup_cli_tools.sh"
source "$MAC_STACK_ROOT/scripts/sourced_in_zshrc/customize_the_shell.sh"

# Update IDE settings and keybindings

if [[ "$VSCODE_SETTINGS_RESTORE" == "true" ]]; then
    settings="$MAC_STACK_ROOT/stack/vscode/settings.json"
    assert_file_exists "$settings"

    keybindings="$MAC_STACK_ROOT/stack/vscode/keybindings.json"
    assert_file_exists "$keybindings"

    app_names=("Visual Studio Code" "Cursor" "Antigravity" "Kiro" "Windsurf" "VSCodium")
    app_support_folders=("Code" "Cursor" "Antigravity" "Kiro" "Windsurf" "VSCodium")

    number_of_apps=${#app_names[@]}

    for ((i=1; i<=number_of_apps; i++)); do
        restore_ide_settings \
            "${app_names[$i]}" \
            "${app_support_folders[$i]}" \
            "$settings" \
            "$keybindings"
    done
fi
