#!/usr/bin/env zsh

# You may use this script as a template to do necessary setup for CLI tools. Most prominently these will be exports of environment variables and similar.

# XDG path for user-installed CLI tools
export PATH="$HOME/.local/bin:$PATH"

# Setup Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Alias for Mack Stack update process
alias update="mack update"

# Setup antigravity
export PATH="$PATH:$HOME/.antigravity/antigravity/bin"
