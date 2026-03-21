#!/usr/bin/env zsh

echo "👻 Generating symlinks to dotfiles ..."

CURRENT_FOLDER="$(dirname "$(realpath "$0")")"

ln -sf "$(realpath ~/.ssh)" "$CURRENT_FOLDER/.ssh"
ln -sf "$(realpath ~/.gitconfig)" "$CURRENT_FOLDER/.gitconfig"
ln -sf "$(realpath ~/.zprofile)" "$CURRENT_FOLDER/.zprofile"
ln -sf "$(realpath ~/.zshenv)" "$CURRENT_FOLDER/.zshenv"
ln -sf "$(realpath ~/.zshrc)" "$CURRENT_FOLDER/.zshrc"