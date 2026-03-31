#!/usr/bin/env zsh

set -e  # Exit on any error
set -u  # Treat unset variables as error

# Ensure we have the latest environment customizations
source "$MAC_STACK_ROOT/scripts/sourced_in_zshrc/customize_the_shell.sh"

# Update Python

echo "🐍 Updating Python ..."
silent uv python install --default
silent uv python upgrade

# Update LiteLLM

echo "🤖 Updating LiteLLM (https://github.com/berriai/litellm) ..."
silent uv tool install --upgrade 'litellm[proxy]'

# Update markitdown

echo "📝 Updating markitdown (https://github.com/microsoft/markitdown) ..."
silent uv tool install --upgrade markitdown

# Fix Cursor CLI Issue

echo "🩹 Fixing Cursor CLI issue ..."
xattr -rd com.apple.quarantine /opt/homebrew/Caskroom/cursor-cli
