#!/usr/bin/env zsh
# This script installs/updates everything in the user's Brewfile

# Prepare
set -e  # Exit on any error
set -u  # Treat unset variables as error

# Auto-confirm Homebrew's "Do you want to proceed?" upgrade prompt
# Equivalent to passing `--no-ask` / `-y` to `brew upgrade`.
# See `man brew` (Environment section) → HOMEBREW_NO_ASK.
export HOMEBREW_NO_ASK=1

# Update pre-existing Homebrew packages (even outside Brewfile)
# We use --greedy to force updates for casks with 'auto_updates true' (like Browsers, Cursor, Raycast) or 'version :latest' (like Apple Fonts). Without this flag, Homebrew ignores them. This ensures our stack actually stays up to date. While it may periodically trigger re-installs for 'latest' casks, it is efficient for versioned apps as they only download when a new numeric version is detected.
if [[ "${SKIP_BREW_PACKAGE_UPDATES:-false}" != "true" ]]; then
    echo "🍺 Updating installed Homebrew packages ..."
    brew upgrade --greedy
fi

# Pre-flight `mas list` gate so Brewfile MAS installs don't fail mid-run.
"$MAC_STACK_ROOT/scripts/homebrew/ensure_mas_works.sh"

# Install additional packages declared in Brewfile
echo "🍺 Installing missing Homebrew packages listed in Brewfile ..."
brewfile="$(${0:h}/get_brewfile.sh)"
if [[ -f "$brewfile" ]]; then
    brew bundle install --no-upgrade --file "$brewfile"
else
    echo "⚠️  Warning: Skipping Brewfile installs since file does not exist in stack:\n$brewfile"
fi

# Clean up Homebrew: cache, old package versions, cask installers
echo "🍺 Cleaning up Homebrew cache, old package versions, installers ..."
silent brew cleanup
silent find /opt/homebrew/Caskroom -type f \( -name "*.dmg" -o -name "*.pkg" -o -name "*.zip" \) -delete
