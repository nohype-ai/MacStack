#!/usr/bin/env zsh

print "👻 Generating symlinks to dotfiles ..."

for filepath in "$HOME"/.[^.]*(D); do
  ln -sfh -- "$filepath" "${0:A:h}/${filepath:t}"
done
