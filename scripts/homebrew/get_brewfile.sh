#!/usr/bin/env zsh

if [[ -f "$STACK/Brewfile.rb" ]]; then
    echo "$STACK/Brewfile.rb"
else
    echo "$STACK/Brewfile"
fi
