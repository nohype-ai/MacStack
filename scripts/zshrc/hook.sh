#!/usr/bin/env zsh
# Mac Stack zsh customization hook

# Get zshrc script folder
DIR="${${(%):-%x}:A:h}"

# Get root folder (up two levels)
ROOT="${DIR:h:h}"

# Source the Mac Stack shell customization
source "$ROOT/scripts/zshrc/content.sh"

# Source the user's custom shell customization
if [[ -f "$ROOT/stack/zshrc.sh" ]]; then
  source "$ROOT/stack/zshrc.sh"
else
  echo "⚠️  Warning: Skipping stack-specific shell customization since script does not exist in stack:\n$ROOT/stack/zshrc.sh"
fi
