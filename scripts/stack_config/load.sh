#!/usr/bin/env zsh
# Source this script (do not execute) to load stack/macstack.json into the environment

print "💻 Reading stack configuration from stack/macstack.json"

CONFIG="$MAC_STACK_ROOT/stack/macstack.json"

if [[ ! -f "$CONFIG" ]]; then
    echo "🛑 macstack.json not found at $CONFIG"
    exit 1
fi

JQ='/opt/homebrew/bin/jq'

if ! silent $JQ empty "$CONFIG"; then
    echo "🛑 macstack.json is invalid JSON"
    exit 1
fi

CHECK_SCHEMA='/opt/homebrew/bin/check-jsonschema'
SCHEMA="$MAC_STACK_ROOT/scripts/stack_config/macstack.schema.json"

if ! silent $CHECK_SCHEMA --schemafile "$SCHEMA" "$CONFIG"; then
    echo "🛑 macstack.json does not match the expected schema. Run 'check-jsonschema --schemafile $SCHEMA $CONFIG' for details."
    exit 1
fi

set -a # Automatically export all variables
GIT_USER_NAME=$($JQ -r '.git.user_name' "$CONFIG")
GIT_USER_EMAIL=$($JQ -r '.git.user_email' "$CONFIG")
GIT_CORE_EDITOR=$($JQ -r '.git.core_editor' "$CONFIG")
GIT_REPOS_FOLDER=$($JQ -r '.repos.folder' "$CONFIG")
GIT_REPOS_FOLDER_TEMPLATE=$($JQ -r '.repos.folder_template' "$CONFIG")
SKIP_BREW_PACKAGE_UPDATES=$($JQ -r '.flags.skip_brew_updates' "$CONFIG")
RESTORE_IDE_SETTINGS=$($JQ -r '.flags.restore_ide_settings' "$CONFIG")
set +a # Turn off auto-export
