#!/usr/bin/env zsh

# Update Cursor CLI settings
if [[ -f ~/.cursor/cli-config.json ]]; then
  echo "⚙️  Updating Cursor CLI settings ..."

  template="$MAC_STACK_ROOT/stack/ai/cursor/cli-config_template.json"

  if [[ ! -f "$template" ]]; then
    echo "⚠️ Warning: Skipping Cursor CLI settings update, since template file does not exist in stack:\n$template"
  else
    jq -s '.[0] * .[1]' \
      ~/.cursor/cli-config.json \
      "$template" | sponge ~/.cursor/cli-config.json
  fi
fi
