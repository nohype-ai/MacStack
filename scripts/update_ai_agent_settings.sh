#!/usr/bin/env zsh

# Update Cursor CLI settings
if [[ -f ~/.cursor/cli-config.json ]]; then
  echo "⚙️  Updating Cursor CLI settings ..."

  template="$STACK/ai/cursor/cli-config_template.json"

  if [[ ! -f "$template" ]]; then
    echo "⚠️ Warning: Skipping Cursor CLI settings update, since template file does not exist in stack:\n$template"
  else
    jq -s '.[0] * .[1]' \
      ~/.cursor/cli-config.json \
      "$template" | sponge ~/.cursor/cli-config.json
  fi

  # Copy rules
  rules_dir="$STACK/ai/cursor/rules"
  if [[ -d "$rules_dir" ]]; then
    cp -r "$rules_dir/." ~/.cursor/rules/
  fi
fi

# Update Gemini CLI settings
if [[ -d ~/.gemini ]]; then
  echo "⚙️  Updating Gemini CLI settings ..."
  cp -r "$STACK/ai/gemini/policies" ~/.gemini/
  cp "$STACK/ai/gemini/settings.json" ~/.gemini/
fi

# Update OpenCode settings
if [[ -d ~/.config/opencode ]]; then
  echo "⚙️  Updating OpenCode settings ..."
  cp "$STACK/ai/opencode/opencode.json" ~/.config/opencode/
fi
