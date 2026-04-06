#!/usr/bin/env zsh
# This script installs/updates Homebrew and what MacStack needs

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

# Update `jq` and `check-jsonschema` for reading json files
echo "🍺 Updating \`jq\` and \`check-jsonschema\` for reading json files ..."
silent zsh -c 'brew upgrade jq || brew install jq'
silent zsh -c 'brew upgrade check-jsonschema || brew install check-jsonschema'

# Update `moreutils` to get `sponge` for merging json files
echo "🍺 Updating \`moreutils\` to get \`sponge\` for merging json files ..."
silent zsh -c 'brew upgrade moreutils || brew install moreutils'
