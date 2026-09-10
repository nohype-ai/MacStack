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

# Update Grok Build settings
# Copy each stack item that exists. Files overwrite; directory contents are copied
# (no merge). Stack-only docs like README.md are not copied. `.gitkeep` is skipped.
if [[ -d ~/.grok ]]; then
  echo "🤖 Updating Grok Build settings ..."

  grok_stack="$STACK/ai/coding/grok"
  if [[ ! -d "$grok_stack" ]]; then
    echo "⚠️ Warning: Skipping update of ~/.grok/*, since template directory does not exist in stack:\n$grok_stack"
  else
    copy_grok_stack_item() {
      local name="$1"
      local src="$grok_stack/$name"
      local dest="$HOME/.grok/$name"
      if [[ -f "$src" ]]; then
        cp "$src" "$dest"
      elif [[ -d "$src" ]]; then
        mkdir -p "$dest"
        cp -R "$src/." "$dest/"
        rm -f "$dest/.gitkeep"
      fi
    }

    for grok_item in \
      AGENTS.md config.toml pager.toml sandbox.toml \
      rules hooks skills commands plugins workflows agents personas
    do
      copy_grok_stack_item "$grok_item"
    done
    unset -f copy_grok_stack_item
    unset grok_item
  fi
fi
