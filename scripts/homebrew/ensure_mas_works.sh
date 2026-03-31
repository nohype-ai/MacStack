#!/usr/bin/env zsh

set -e  # Exit on any error
set -u  # Treat unset variables as error

# Pre-flight: ensure `mas` works before installing MAS apps from Brewfile.
# On fresh macOS installs, the Apple ID session used by `mas` is sometimes
# not fully provisioned until the App Store app has been opened once.
echo "🍏 Ensuring App Store access (mas) works ..."

if ! command -v mas >/dev/null 2>&1; then
    echo "🍏 Installing mas CLI ..."
    silent /opt/homebrew/bin/brew install mas
fi

if ! mas list >/dev/null 2>&1; then
    echo "❌ mas is not ready yet (App Store session not provisioned)."
    echo "Please open the App Store app once (confirm you're signed in), then retry"
    silent open -a 'App Store' || true
    exit 1
fi
