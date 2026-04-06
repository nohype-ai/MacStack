#!/usr/bin/env zsh

MACSTACK_SETTINGS="$HOME/.config/macstack/settings.json"

# Loads the stack folder path from settings into MACSTACK_STACK_ROOT, prompting the user if not set.
# Pass --prompt to always show the prompt (e.g. for mack config to allow changing the path).
# Saves the (confirmed or newly entered) path back to settings.
load_stack_path() {
  local force_prompt=${1:-false}
  MACSTACK_STACK_ROOT=""

  if [[ -f "$MACSTACK_SETTINGS" ]]; then
    MACSTACK_STACK_ROOT=$(jq -r '.stack_path // empty' "$MACSTACK_SETTINGS")
  fi

  if [[ -z "$MACSTACK_STACK_ROOT" ]]; then
    echo "No stack folder configured yet."
    MACSTACK_STACK_ROOT="$PWD"
  fi

  if [[ -z "$MACSTACK_STACK_ROOT" || "$force_prompt" == "--prompt" ]]; then
    vared -p "Stack folder path: " MACSTACK_STACK_ROOT
  fi

  mkdir -p "${MACSTACK_SETTINGS:h}"
  [[ -f "$MACSTACK_SETTINGS" ]] || echo '{}' > "$MACSTACK_SETTINGS"

  jq --arg p "$MACSTACK_STACK_ROOT" '. + {stack_path: $p}' "$MACSTACK_SETTINGS" | sponge "$MACSTACK_SETTINGS"

  typeset -gx MACSTACK_STACK_ROOT
}
