#!/usr/bin/env zsh
# MacStack (`mack update`) runs this script
# This script allow you to customize/extend the update process

# Prepare
set -e  # Exit on any error
set -u  # Treat unset variables as error

# Update Rust (needed to compile some Python package dependencies)
echo "🦀 Updating Rust ..."
silent zsh -c 'brew upgrade rust || brew install rust'

# Update Python
echo "🐍 Updating Python ..."
silent uv python install --default
silent uv python upgrade

# Update LiteLLM (pinned to Python 3.13 until orjson ships 3.14 wheels)
echo "🤖 Updating LiteLLM ..."
silent uv tool install --python 3.13 --upgrade 'litellm[proxy]'

# Update markitdown
echo "📝 Updating markitdown ..."
silent uv tool install --upgrade --force 'markitdown[pptx,docx,xlsx,xls,pdf,outlook]'

# Fix Cursor CLI Issue
echo "🩹 Fixing Cursor CLI issue ..."
xattr -rd com.apple.quarantine /opt/homebrew/Caskroom/cursor-cli
