#!/usr/bin/env zsh

# Ensure given content exists in ~/.zshrc
ensure_zshrc_content() {
    local content="$1"
    local zshrc_file="$HOME/.zshrc"

    # Create .zshrc if it does not exist yet
    if [[ ! -f "$zshrc_file" ]]; then
        touch "$zshrc_file"
    fi

    # Check if the content already exists in .zshrc (exact character match)
    local file_content="$(cat "$zshrc_file" 2>/dev/null || echo "")"

    if [[ "$file_content" == *"$content"* ]]; then
        return 0
    fi

    # Append the content with a blank line before it
    echo "" >> "$zshrc_file"
    echo "$content" >> "$zshrc_file"
    echo "📝 Added to .zshrc:"
    echo "$content"
}

# Check that a required file exists
assert_file_exists() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo "❌ Required file not found: $file_path"
        exit 1
    fi
}

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

# Restore settings and keybindings of VS Code type IDEs
restore_ide_settings() {
    local app_name="$1"
    local app_support_folder="$2"
    local settings_file="$3"
    local keybindings_file="$4"

    if app_exists "$app_name"; then
        echo "⚙️  Restoring settings and keybindings for $app_name ..."
        local user_settings_dir="$HOME/Library/Application Support/$app_support_folder/User"
        mkdir -p "$user_settings_dir"
        cp "$settings_file" "$user_settings_dir/settings.json"
        cp "$keybindings_file" "$user_settings_dir/keybindings.json"
    fi
}
