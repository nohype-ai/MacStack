#!/usr/bin/env zsh
# Mac Stack zsh customization hook

# Get zshrc script folder
DIR="${${(%):-%x}:A:h}"

# Get root folder (up two levels)
ROOT="${DIR:h:h}"

# Source the Mac Stack shell customization
source "$ROOT/scripts/zshrc/content.sh"

# Source the user's custom shell customization
source "$ROOT/stack/zshrc.sh"
