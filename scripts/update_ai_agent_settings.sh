#!/usr/bin/env zsh

# Update Cursor CLI settings
echo "⚙️ Updating Cursor CLI settings ..."

local template="$MAC_STACK_ROOT/stack/ai/cursor/cli-config_template.json"

if [[ ! -f ~/.cursor/cli-config.json ]] || [[ ! -f "$template" ]]; then
  echo "🛑 Error: cli-config.json or template not found"
else
    jq -s '.[0] * .[1]' \
      ~/.cursor/cli-config.json \
      "$template" | sponge ~/.cursor/cli-config.json
fi
