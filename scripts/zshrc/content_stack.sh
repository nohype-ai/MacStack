# Read path of user stack from MacStack settings
_macstack_settings="$HOME/.config/macstack/settings.json"
if command -v jq &>/dev/null && [[ -f "$_macstack_settings" ]]; then
  STACK=$(jq -r '.stack_path // empty' "$_macstack_settings")
fi
unset _macstack_settings

# Source user's shell customization from their stack
if [[ -n "${STACK:-}" && -f "$STACK/zshrc.sh" ]]; then
  source "$STACK/zshrc.sh"
fi
