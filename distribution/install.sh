#!/usr/bin/env zsh

# MacStack install script
# Installs Homebrew if needed, then installs mack and runs first-time configuration.

set -e  # Exit on any error
set -u  # Treat unset variables as error

echo "🍏 Installing MacStack ..."

# Install Homebrew if not present
if ! command -v brew >/dev/null 2>&1; then
    echo "🍺 Installing Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "🍺 Homebrew already installed, skipping."
fi

# Ensure Homebrew is in PATH (required when Homebrew was just installed)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Install mack via Homebrew
echo "🍏 Installing mack ..."
brew install macstack

echo ""
echo "✅ MacStack installed. Let's configure it."
echo ""

# Run first-time configuration to set the stack folder
mack config
