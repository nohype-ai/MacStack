#!/usr/bin/env zsh
# This script installs/updates Homebrew and what Mac Stack needs

# Prepare

set -e  # Exit on any error
set -u  # Treat unset variables as error

# Install/update Homebrew

if ! command -v brew >/dev/null 2>&1; then
    echo "🍺 Installing Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    # side stepping the install script avoids entering password and other interactive hand holding
    # that means when brew is already installed, the whole script can run unattended
    echo "🍺 Updating Homebrew ..."
    silent brew update
fi

# Pre-flight `mas list` gate so Brewfile MAS installs don't fail mid-run.
"$MAC_STACK_ROOT/scripts/homebrew/ensure_mas_works.sh"

# Update `jq` for reading configurations from json files
echo "🍺 Updating \`jq\` for reading configurations from json files ..."
silent zsh -c '/opt/homebrew/bin/brew upgrade jq || /opt/homebrew/bin/brew install jq'
