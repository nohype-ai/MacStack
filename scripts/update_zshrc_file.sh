#!/usr/bin/env zsh
# This script updates the ~/.zshrc file with necessary configurations

# Prepare
set -e  # Exit on any error
set -u  # Treat unset variables as error
source "$MAC_STACK_ROOT/scripts/helpers.sh" # Load helpers

# Ensure the .zshrc customization is sourced in ~/.zshrc
echo "🐚 Ensuring the .zshrc customization is loaded in ~/.zshrc ..."
zshrc_setup_script="$MAC_STACK_ROOT/scripts/sourced_in_zshrc/sourced_in_zshrc.sh"
assert-file "$zshrc_setup_script"
script_call="# Mac Stack .zshrc customization
source \"$zshrc_setup_script\""
ensure_zshrc_content "$script_call"

# Ensure the Mac Stack binary path is in PATH
echo "🐚 Ensuring the Mac Stack binary path is in PATH ..."
path_export="# Mac Stack binary path
export PATH=\"$MAC_STACK_ROOT/bin:\$PATH\""
ensure_zshrc_content "$path_export"
