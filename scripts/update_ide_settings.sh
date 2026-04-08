#!/usr/bin/env zsh

set -e  # Exit on any error
set -u  # Treat unset variables as error

source "${0:A:h}/lib/merge_json.sh"

# Check if an app of a given name exists
app_exists() {
    local app_name="$1"
    [[ "$app_name" != *.app ]] && app_name="${app_name}.app"

    # First, check common installation directories (fast, no indexing needed)
    # This handles fresh Homebrew installs before Spotlight has indexed them
    [[ -d "/Applications/$app_name" ]] && return 0
    [[ -d "$HOME/Applications/$app_name" ]] && return 0
    [[ -d "/System/Applications/$app_name" ]] && return 0

    # Fall back to Spotlight search for apps in non-standard locations
    mdfind "kMDItemKind == 'Application' && kMDItemFSName == '$app_name'" 2>/dev/null | grep -q .
}

# Merge a stack JSON file into a target JSON file (creating target if absent)
merge_ide_json() {
    local stack_file="$1"
    local target_file="$2"
    local label="$3"

    if [[ ! -f "$stack_file" ]]; then
        echo "⚠️  Warning: $label update will be skipped since file is not in stack:\n$stack_file"
        return
    fi

    if [[ ! -f "$target_file" ]]; then
        echo '{}' > "$target_file"
    fi

    merge_json "$stack_file" "$target_file"
}

# Update settings and keybindings of a VS Code based IDE
update_vscode_ide() {
    local app_name="$1"
    local app_support_folder="$2"
    local settings_file="$3"
    local keybindings_file="$4"

    if app_exists "$app_name"; then
        echo "⚙️  Updating settings and keybindings for $app_name ..."
        local user_settings_dir="$HOME/Library/Application Support/$app_support_folder/User"
        mkdir -p "$user_settings_dir"

        merge_ide_json "$settings_file" "$user_settings_dir/settings.json" "settings"
        merge_ide_json "$keybindings_file" "$user_settings_dir/keybindings.json" "keybindings"
    fi
}

# 1️⃣ VS Code based IDEs

settings="$STACK/vscode/settings.json"
keybindings="$STACK/vscode/keybindings.json"

app_names=("Visual Studio Code" "Cursor" "Antigravity" "Kiro" "Windsurf" "VSCodium")
app_support_folders=("Code" "Cursor" "Antigravity" "Kiro" "Windsurf" "VSCodium")

number_of_apps=${#app_names[@]}

for ((i=1; i<=number_of_apps; i++)); do
    update_vscode_ide \
        "${app_names[$i]}" \
        "${app_support_folders[$i]}" \
        "$settings" \
        "$keybindings"
done

# 2️⃣ Zed

zed_config_dir="$HOME/.config/zed"
mkdir -p "$zed_config_dir"

echo "⚙️  Updating settings and keymap for Zed ..."
merge_ide_json "$STACK/zed/settings.json" "$zed_config_dir/settings.json" "settings"
merge_ide_json "$STACK/zed/keymap.json" "$zed_config_dir/keymap.json" "keymap"
