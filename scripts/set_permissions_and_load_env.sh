#!/usr/bin/env zsh
# This script sets safe file permissions and loads the .env file

# Set safe permissions for project directory
echo "🔒 Setting safe permissions for project directory ..."
chmod 700 "$MAC_STACK_ROOT" # Only owner can access project

# Set safe permissions for .env file and load it
echo "🔒 Setting safe permissions for .env file and loading it ..."

env_file="$MAC_STACK_ROOT/stack/.env"

if [[ -f "$env_file" ]]; then
    chmod 600 "$env_file" # Only owner can read/write .env file
    set -a                # Automatically export all variables
    source "$env_file"    # Load environment variables from .env file
    set +a                # Turn off auto-export
else
    echo "⚠️  No .env file found. Copy .env.example to .env and customize it."
    exit 1
fi
