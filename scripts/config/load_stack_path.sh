#!/usr/bin/env zsh

MACSTACK_SETTINGS="$HOME/.config/macstack/settings.json"

# Loads the stack folder path from settings into STACK, prompting the user if not set.
# Pass --prompt to always show the prompt (e.g. for mack config to allow changing the path).
# Saves the (confirmed or newly entered) path back to settings.
load_stack_path() {
  local force_prompt=${1:-false}
  STACK=""

  # Read the saved stack path from settings if available
  if [[ -f "$MACSTACK_SETTINGS" ]]; then
    STACK=$(jq -r '.stack_path // empty' "$MACSTACK_SETTINGS")
  fi

  # Fall back to the current directory if no path is saved yet
  if [[ -z "$STACK" ]]; then
    echo "No stack folder configured yet."
    STACK="$PWD"
  fi

  # Prompt the user to confirm or edit the path (always when --prompt, otherwise only when unset)
  if [[ -z "$STACK" || "$force_prompt" == "--prompt" ]]; then
    vared -p "Stack folder path: " STACK
  fi

  # Create the settings file if it does not exist yet
  mkdir -p "${MACSTACK_SETTINGS:h}"
  [[ -f "$MACSTACK_SETTINGS" ]] || echo '{}' > "$MACSTACK_SETTINGS"

  # Persist the path into settings without overwriting other entries
  jq --arg p "$STACK" '. + {stack_path: $p}' "$MACSTACK_SETTINGS" | sponge "$MACSTACK_SETTINGS"

  # Export so all child processes inherit the value
  typeset -gx STACK
}
