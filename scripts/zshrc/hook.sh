#!/usr/bin/env zsh
# MacStack zsh customization hook

# Get zshrc script folder
DIR="${${(%):-%x}:A:h}"

# Get root folder (up two levels)
ROOT="${DIR:h:h}"

# Source the MacStack shell customization
source "$ROOT/scripts/zshrc/content.sh"

# Read the stack path from settings (requires jq; skip silently if unavailable or not configured)
_macstack_settings="$HOME/.config/macstack/settings.json"
if command -v jq &>/dev/null && [[ -f "$_macstack_settings" ]]; then
  STACK=$(jq -r '.stack_path // empty' "$_macstack_settings")
fi
unset _macstack_settings

# Source the user's custom shell customization from their stack
if [[ -n "${STACK:-}" && -f "$STACK/zshrc.sh" ]]; then
  source "$STACK/zshrc.sh"
fi
