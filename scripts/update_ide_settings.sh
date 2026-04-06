#!/usr/bin/env zsh
# This script installs/updates software outside the homebrew stack

set -e  # Exit on any error
set -u  # Treat unset variables as error

# Check if an app of a given name exists
app_exists() {
    local app_name="$1"
    # Automatically append .app if not already present
    [[ "$app_name" != *.app ]] && app_name="${app_name}.app"

    # First, check common installation directories (fast, no indexing needed)
    # This handles fresh Homebrew installs before Spotlight has indexed them
    [[ -d "/Applications/$app_name" ]] && return 0
    [[ -d "$HOME/Applications/$app_name" ]] && return 0
    [[ -d "/System/Applications/$app_name" ]] && return 0

    # Fall back to Spotlight search for apps in non-standard locations
    mdfind "kMDItemKind == 'Application' && kMDItemFSName == '$app_name'" 2>/dev/null | grep -q .
}

# Restore settings and keybindings of a VS Code type IDE
restore_ide_settings() {
    local app_name="$1"
    local app_support_folder="$2"
    local settings_file="$3"
    local keybindings_file="$4"

    if app_exists "$app_name"; then
        echo "⚙️  Restoring settings and keybindings for $app_name ..."
        local user_settings_dir="$HOME/Library/Application Support/$app_support_folder/User"
        mkdir -p "$user_settings_dir"

        if [[ -f "$settings_file" ]]; then
            cp "$settings_file" "$user_settings_dir/settings.json"
        else
            echo "⚠️  Warning: settings file is not in stack, so restoring it will be skipped:\n$settings_file"
        fi

        if [[ -f "$keybindings_file" ]]; then
            cp "$keybindings_file" "$user_settings_dir/keybindings.json"
        else
            echo "⚠️  Warning: keybindings file is not in stack, so restoring it will be skipped:\n$keybindings_file"
        fi
    fi
}

# Update IDE settings and keybindings (restoring by overwriting)
if [[ "${RESTORE_IDE_SETTINGS:-false}" == "true" ]]; then

    # 1️⃣ VSCode-based IDEs

    settings="$STACK/vscode/settings.json"
    keybindings="$STACK/vscode/keybindings.json"

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

    # 2️⃣ Zed
    #
    print "⚙️  Restoring settings and keymap for Zed ..."

    local zed_config_dir="$HOME/.config/zed"

    if [[ -f "$STACK/zed/settings.json" ]]; then
        mkdir -p "$zed_config_dir"
        cp "$STACK/zed/settings.json" "$zed_config_dir/settings.json"
    else
        echo "⚠️  Warning: settings file is not in stack, so restoring it will be skipped:\n$STACK/zed/settings.json"
    fi

    if [[ -f "$STACK/zed/keymap.json" ]]; then
        mkdir -p "$zed_config_dir"
        cp "$STACK/zed/keymap.json" "$zed_config_dir/keymap.json"
    else
        echo "⚠️  Warning: keymap file is not in stack, so restoring it will be skipped:\n$STACK/zed/keymap.json"
    fi
fi
