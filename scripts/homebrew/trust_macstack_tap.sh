#!/usr/bin/env zsh
# Trust the Nohype AI Homebrew tap and the MacStack formula so Homebrew will load
# them under require-tap-trust. Safe to run repeatedly (idempotent).
#
# Without this, brew bundle / upgrade / cleanup cannot load the formula graph for
# nohype-ai/tap/macstack, which causes runtime deps (check-jsonschema, node, …)
# to be treated as undeclared and removed by brew-clip.

set -e
set -u

# Whole tap (covers future formulae from the same tap).
brew trust nohype-ai/tap 2>/dev/null || true
# Belt-and-suspenders: formula-level trust (what `brew trust --help` recommends in errors).
brew trust --formula nohype-ai/tap/macstack 2>/dev/null || true
