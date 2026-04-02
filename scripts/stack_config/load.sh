#!/usr/bin/env zsh
# Source this script (do not execute) to load stack/macstack.json into the environment

print "💻 Reading stack configuration from macstack.json ..."

CONFIG="$MAC_STACK_ROOT/stack/macstack.json"

if [[ ! -f "$CONFIG" ]]; then
    echo "⚠️  Warning: Skipping basic configurations since this file does not exist:\n$CONFIG"
    return 0
fi

JQ='/opt/homebrew/bin/jq'

if ! silent $JQ empty "$CONFIG"; then
    echo "🛑 Error: Skipping basic configurations since macstack.json is invalid JSON:\n$CONFIG"
    return 0
fi

CHECK_SCHEMA='/opt/homebrew/bin/check-jsonschema'
SCHEMA="$MAC_STACK_ROOT/scripts/stack_config/macstack.schema.json"

if ! silent $CHECK_SCHEMA --schemafile "$SCHEMA" "$CONFIG"; then
    echo "🛑 Error: Skipping basic configurations since macstack.json does not match its declared schema:\n$CONFIG\nRun 'check-jsonschema --schemafile $SCHEMA $CONFIG' for details."
    return 0
fi

set -a # Automatically export all variables
GIT_USER_NAME=$($JQ -r '.git.user_name // empty' "$CONFIG")
GIT_USER_EMAIL=$($JQ -r '.git.user_email // empty' "$CONFIG")
GIT_CORE_EDITOR=$($JQ -r '.git.core_editor // empty' "$CONFIG")
GIT_REPOS_FOLDER=$($JQ -r '.repos.folder // empty' "$CONFIG")
SKIP_BREW_PACKAGE_UPDATES=$($JQ -r '.flags.skip_brew_updates // empty' "$CONFIG")
RESTORE_IDE_SETTINGS=$($JQ -r '.flags.restore_ide_settings // empty' "$CONFIG")
set +a # Turn off auto-export
