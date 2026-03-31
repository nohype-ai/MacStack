#!/usr/bin/env zsh

set -e  # Exit on any error
set -u  # Treat unset variables as error

# Update Python
echo "🐍 Updating Python ..."
silent uv python install --default
silent uv python upgrade

# Update LiteLLM
echo "🤖 Updating LiteLLM (https://github.com/berriai/litellm) ..."
silent uv tool install --upgrade 'litellm[proxy]'

# Update markitdown
echo "📝 Updating markitdown (https://github.com/microsoft/markitdown) ..."
silent uv tool install --upgrade --force 'markitdown[all]'

# Fix Cursor CLI Issue
echo "🩹 Fixing Cursor CLI issue ..."
xattr -rd com.apple.quarantine /opt/homebrew/Caskroom/cursor-cli
