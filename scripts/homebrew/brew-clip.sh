#!/usr/bin/env zsh

# This script enforces the philosophy that every Homebrew package used must be declared explicitly in the Brewfile.

# It uninstalls:
# 1) brew packages that are not (yet) declared in the Brewfile, does proper deep uninstalls for casks (apps) beyond just deleting them from Applications folder
# 2) brew packages that are orphaned dependencies (Orphaned means they were once installed as dependencies but are not depended upon anymore. Brew intentionally tracks and keeps such orphans.)
# 3) unused old package versions, caches
# 4) Cask installers. This disables offline reinstalls (virtually never needed) but frees up a lot of disk space.

# Prepare
BREWFILE_PATH="$MAC_STACK_ROOT/stack/Brewfile"

# Ask for confirmation
echo "⚠️  This will uninstall all brew packages that are not declared in this Brewfile:\n   file://${BREWFILE_PATH// /%20}"
read "response?❓ Continue? (y/N): "
if [[ "$response" != [yY] ]]; then
    exit 0
fi

# Proceed with uninstallations
echo "🧹 Uninstalling ..."
brew bundle cleanup --force --zap --file "$BREWFILE_PATH" # (1)
brew autoremove # (2)
brew cleanup # (3)
find /opt/homebrew/Caskroom -type f \( -name "*.dmg" -o -name "*.pkg" -o -name "*.zip" \) -delete # (4)
echo "✅ Did uninstall all brew packages that are not declared in the Brewfile"
