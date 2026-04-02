#!/usr/bin/env zsh
# Mac Stack (`mack update`) runs this script
# This script allow you to customize/extend the update process

# Prepare
set -e  # Exit on any error
set -u  # Treat unset variables as error

# Update Python
echo "🐍 Updating Python ..."
silent uv python install --default
silent uv python upgrade

# Update LiteLLM
echo "🤖 Updating LiteLLM ..."
silent uv tool install --upgrade 'litellm[proxy]'

# Update markitdown
echo "📝 Updating markitdown ..."
silent uv tool install --upgrade --force 'markitdown[all]'

# Fix Cursor CLI Issue
echo "🩹 Fixing Cursor CLI issue ..."
xattr -rd com.apple.quarantine /opt/homebrew/Caskroom/cursor-cli
