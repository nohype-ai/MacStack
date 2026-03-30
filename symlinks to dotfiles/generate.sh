#!/usr/bin/env zsh

echo "👻 Generating symlinks to dotfiles ..."

CURRENT_FOLDER="$(dirname "$(realpath "$0")")"
HOME_FOLDER="$(realpath ~)"

for filepath in "$HOME_FOLDER"/.[^.]*(D); do
  filename="${filepath:t}"
  ln -sf "$filepath" "$CURRENT_FOLDER/$filename"
done
