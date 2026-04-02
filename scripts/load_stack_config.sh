#!/usr/bin/env zsh
# Source this script (do not execute) to load stack/macstack.json into the environment

CONFIG="$MAC_STACK_ROOT/stack/macstack.json"

if [[ ! -f "$CONFIG" ]]; then
    echo "⚠️  No macstack.json found at $CONFIG"
    exit 1
fi

JQ='/opt/homebrew/bin/jq'

if ! $JQ empty "$CONFIG" 2>/dev/null; then
    echo "🛑 macstack.json is invalid JSON"
    exit 1
fi

set -a # Automatically export all variables
GIT_USER_NAME=$($JQ -r '.git.user_name' "$CONFIG")
GIT_USER_EMAIL=$($JQ -r '.git.user_email' "$CONFIG")
GIT_CORE_EDITOR=$($JQ -r '.git.core_editor' "$CONFIG")
GIT_REPOS_FOLDER=$($JQ -r '.repos.folder' "$CONFIG")
GIT_REPOS_FOLDER_TEMPLATE=$($JQ -r '.repos.folder_template' "$CONFIG")
SKIP_BREW_PACKAGE_UPDATES=$($JQ -r '.flags.skip_brew_updates' "$CONFIG")
VSCODE_SETTINGS_RESTORE=$($JQ -r '.flags.vscode_settings_restore' "$CONFIG")
set +a # Turn off auto-export
