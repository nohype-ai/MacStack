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

  # Prompt the user if no path is saved yet (prefill with cwd), or if --prompt was passed
  if [[ -z "$STACK" ]]; then
    STACK="$PWD"
    print "📁 Set the folder that defines your stack:"
    vared -p "" STACK
  elif [[ "$force_prompt" == "--prompt" ]]; then
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
