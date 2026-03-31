#!/usr/bin/env zsh

# Get script directory (in a way that works when sourced rather than executed)
export SCRIPT_DIR="$(dirname "${(%):-%x}")"

source "$SCRIPT_DIR/customize_the_shell.sh"

if [[ -f "$SCRIPT_DIR/personalize_the_shell.sh" ]]; then
    source "$SCRIPT_DIR/personalize_the_shell.sh"
fi

# XDG path for user-installed CLI tools
export PATH="$HOME/.local/bin:$PATH"

# Setup Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Alias for Mack Stack update process
alias update="mack update"
