#!/usr/bin/env zsh
# This script backs up Zed settings.json and keymap.json to zed/ in your stack

# Prepare
set -e  # Exit on any error
set -u  # Treat unset variables as error

ZED_CONFIG_DIR="$HOME/.config/zed"
ZED_BACKUP="$STACK/zed"

if [[ ! -d "$ZED_CONFIG_DIR" ]]; then
    print "⚠️  No Zed config directory found at $ZED_CONFIG_DIR"
    print "   Nothing to back up."
    exit 0
fi

backed_up_count=0

if [[ -f "$ZED_CONFIG_DIR/settings.json" ]]; then
    mkdir -p "$ZED_BACKUP"
    cp -f "$ZED_CONFIG_DIR/settings.json" "$ZED_BACKUP/settings.json"
    (( backed_up_count += 1 ))
fi

if [[ -f "$ZED_CONFIG_DIR/keymap.json" ]]; then
    mkdir -p "$ZED_BACKUP"
    cp -f "$ZED_CONFIG_DIR/keymap.json" "$ZED_BACKUP/keymap.json"
    (( backed_up_count += 1 ))
fi

if (( backed_up_count > 0 )); then
    print "✅ Backed up Zed settings and keymap to:\n$ZED_BACKUP"
else
    print "⚠️  No Zed settings or keymap found in $ZED_CONFIG_DIR"
fi
