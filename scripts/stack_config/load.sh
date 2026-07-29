#!/usr/bin/env zsh
# Source this script (do not execute) to load stack/macstack.json into the environment

print "💻 Reading stack configuration from macstack.json ..."

CONFIG="$STACK/macstack.json"

if [[ ! -f "$CONFIG" ]]; then
    echo "⚠️  Warning: Skipping basic configurations since this file does not exist:\n$CONFIG"
    return 0
fi

if ! silent jq empty "$CONFIG"; then
    echo "🛑 Error: Skipping basic configurations since macstack.json is invalid JSON:\n$CONFIG"
    return 0
fi

SCHEMA="$MAC_STACK_ROOT/scripts/stack_config/macstack.schema.json"

if ! silent check-jsonschema --schemafile "$SCHEMA" "$CONFIG"; then
    echo "🛑 Error: Skipping basic configurations since macstack.json does not match its declared schema:\n$CONFIG\nRun 'check-jsonschema --schemafile $SCHEMA $CONFIG' for details."
    return 0
fi


set -a # Automatically export all variables
GIT_USER_NAME=$(jq -r '.git.user_name // empty' "$CONFIG")
GIT_USER_EMAIL=$(jq -r '.git.user_email // empty' "$CONFIG")
GIT_CORE_EDITOR=$(jq -r '.git.core_editor // empty' "$CONFIG")
GIT_REPOS_FOLDER=$(jq -r '.repos.folder // empty' "$CONFIG")
SKIP_BREW_PACKAGE_UPDATES=$(jq -r '.flags.skip_brew_updates // empty' "$CONFIG")
set +a # Turn off auto-export
