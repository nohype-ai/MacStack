#!/usr/bin/env zsh
# Trust the Nohype AI Homebrew tap so Homebrew will load its formulae under
# require-tap-trust. Idempotent.
#
# Without this, brew cannot load nohype-ai/tap/macstack into the bundle formula
# graph, so brew bundle cleanup treats its runtime deps as undeclared and removes
# them even while the macstack keg itself remains.

set -e
set -u

brew trust nohype-ai/tap
