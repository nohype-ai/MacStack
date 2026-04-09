#!/usr/bin/env zsh

set -e  # Exit on any error
set -u  # Treat unset variables as error

# Load merge_json function
source "${0:A:h}/json-merge/merge_json.sh"

# Update Cursor CLI settings and rules
if [[ -d ~/.cursor ]]; then
  echo "🤖 Updating Cursor CLI settings and rules ..."

  # Update ~/.cursor/cli-config.json
  settings_template="$STACK/ai/coding/cursor/cli-config_template.json"
  if [[ ! -f "$settings_template" ]]; then
    echo "⚠️ Warning: Skipping update of ~/.cursor/cli-config.json, since template file does not exist in stack:\n$settings_template"
  else
    merge_json "$settings_template" ~/.cursor/cli-config.json
  fi

  # Update files in ~/.cursor/rules
  rules_template="$STACK/ai/coding/cursor/rules"
  if [[ ! -d "$rules_template" ]]; then
    echo "⚠️ Warning: Skipping update of ~/.cursor/rules/*, since template directory does not exist in stack:\n$rules_template"
  else
    cp -r "$rules_template/." ~/.cursor/rules/
  fi
fi

# Update Gemini CLI settings and policies
if [[ -d ~/.gemini ]]; then
  echo "🤖 Updating Gemini CLI settings and policies ..."

  # Update ~/.gemini/settings.json
  settings_template="$STACK/ai/coding/gemini/settings.json"
  if [[ ! -f "$settings_template" ]]; then
    echo "⚠️ Warning: Skipping update of ~/.gemini/settings.json, since template file does not exist in stack:\n$settings_template"
  else
    merge_json "$settings_template" ~/.gemini/settings.json
  fi

  # Update files in ~/.gemini/policies
  policies_template="$STACK/ai/coding/gemini/policies"
  if [[ ! -d "$policies_template" ]]; then
    echo "⚠️ Warning: Skipping update of ~/.gemini/policies/*, since policies directory does not exist in stack:\n$policies_template"
  else
    cp -r "$policies_template/." ~/.gemini/policies/
  fi
fi

# Update OpenCode settings
if [[ -d ~/.config/opencode ]]; then
  echo "🤖 Updating OpenCode settings ..."

  # Update ~/.config/opencode/opencode.json
  settings_template="$STACK/ai/coding/opencode/opencode.json"
  if [[ ! -f "$settings_template" ]]; then
    echo "⚠️ Warning: Skipping update of ~/.config/opencode/opencode.json since template file does not exist in stack:\n$settings_template"
  else
    merge_json "$settings_template" ~/.config/opencode/opencode.json
  fi
fi
