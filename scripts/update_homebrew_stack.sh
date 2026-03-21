#!/usr/bin/env zsh
# This script installs/updates Homebrew and everything in Brewfile

# Prepare

set -e  # Exit on any error
set -u  # Treat unset variables as error
source "$MAC_STACK_ROOT/scripts/helpers.sh" # Load helpers

# Install/update Homebrew

if ! command -v brew >/dev/null 2>&1; then
    echo "🍺 Installing Homebrew ..."
    silent /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    # side stepping the install script avoids entering password and other interactive hand holding
    # that means when brew is already installed, the whole script can run unattended 
    echo "🍺 Updating Homebrew ..."
    silent brew update
fi

# Update pre-existing Homebrew packages (even outside Brewfile)
# We use --greedy to force updates for casks with 'auto_updates true' (like Browsers, Cursor, Raycast) or 'version :latest' (like Apple Fonts). Without this flag, Homebrew ignores them. This ensures our stack actually stays up to date. While it may periodically trigger re-installs for 'latest' casks, it is efficient for versioned apps as they only download when a new numeric version is detected.
if [[ "$SKIP_BREW_PACKAGE_UPDATES" == "false" ]]; then
    echo "🍺 Updating installed Homebrew packages ..."
    /opt/homebrew/bin/brew upgrade --greedy
fi

# Install additional packages declared in Brewfile

echo "🍺 Installing missing Homebrew packages listed in Brewfile ..."
brewfile="$MAC_STACK_ROOT/Brewfile"
assert_file_exists "$brewfile"
/opt/homebrew/bin/brew bundle install --no-upgrade --file "$brewfile"

# Clean up Homebrew: cache, old package versions, cask installers

echo "🍺 Cleaning up Homebrew cache, old package versions and cask installers ..."
silent /opt/homebrew/bin/brew cleanup
silent find /opt/homebrew/Caskroom -type f \( -name "*.dmg" -o -name "*.pkg" -o -name "*.zip" \) -delete