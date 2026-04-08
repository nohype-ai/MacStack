#!/usr/bin/env zsh

source "${0:A:h}/lib/merge_json.sh"

# Update Cursor CLI settings
if [[ -f ~/.cursor/cli-config.json ]]; then
  echo "🤖 Updating Cursor CLI settings ..."

  template="$STACK/ai/coding/cursor/cli-config_template.json"

  if [[ ! -f "$template" ]]; then
    echo "⚠️ Warning: Skipping Cursor CLI settings update, since template file does not exist in stack:\n$template"
  else
    merge_json "$template" ~/.cursor/cli-config.json
  fi

  rules_dir="$STACK/ai/coding/cursor/rules"
  if [[ -d "$rules_dir" ]]; then
    cp -r "$rules_dir/." ~/.cursor/rules/
  fi
fi

# Update Gemini CLI settings
if [[ -d ~/.gemini ]]; then
  echo "🤖 Updating Gemini CLI settings ..."
  cp -r "$STACK/ai/coding/gemini/policies" ~/.gemini/

  settings_template="$STACK/ai/coding/gemini/settings.json"
  if [[ ! -f "$settings_template" ]]; then
    echo "⚠️ Warning: Skipping Gemini CLI settings update, since template file does not exist in stack:\n$settings_template"
  else
    if [[ ! -f ~/.gemini/settings.json ]]; then
      echo '{}' > ~/.gemini/settings.json
    fi
    merge_json "$settings_template" ~/.gemini/settings.json
  fi
fi

# Update OpenCode settings
if [[ -d ~/.config/opencode ]]; then
  echo "🤖 Updating OpenCode settings ..."

  settings_template="$STACK/ai/coding/opencode/opencode.json"
  if [[ ! -f "$settings_template" ]]; then
    echo "⚠️ Warning: Skipping OpenCode settings update, since template file does not exist in stack:\n$settings_template"
  else
    if [[ ! -f ~/.config/opencode/opencode.json ]]; then
      echo '{}' > ~/.config/opencode/opencode.json
    fi
    merge_json "$settings_template" ~/.config/opencode/opencode.json
  fi
fi
