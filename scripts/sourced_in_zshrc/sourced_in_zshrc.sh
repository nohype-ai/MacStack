#!/usr/bin/env zsh

# visually separate prompt/input/output. Error indication via Emoji.
export PROMPT='%(?.🍏.🍎) %F{#00ffff}%2~%f: '
zle_highlight=(default:fg=#ffff00)

# Disable shell history file (~/.zsh_history) to keep home folder clean but also for privacy and security reasons
HISTSIZE=10000  # allow in-memory history for current session
SAVEHIST=0      # don't save any commands to ~/.zsh_history
unset HISTFILE  # remove history file variable entirely

# XDG path for user-installed CLI tools
export PATH="$HOME/.local/bin:$PATH"

# Setup Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Alias for Mack Stack update process
alias update="mack update"

# print the paths in the $PATH variable as a readable list
paths() { print -l $path }

# aliases that allow omitting "git " with git commands
alias status="git status"
alias diff="git diff" # this masks /usr/bin/diff
alias restore="git restore"
alias add="git add"
alias commit="git commit"
alias push="git push"
alias branch="git branch"
alias clone="git clone"
alias merge="git merge"
alias rebase="git rebase"
alias reflog="git reflog"
alias tag="git tag"
alias switch="git switch"
alias checkout="git checkout"
alias fetch="git fetch"
alias pull="git pull"
alias revert="git revert"
alias reset="git reset" # this masks /usr/bin/reset
alias remote="git remote"
alias log="git log" # this masks /usr/bin/log
alias config="git config"
alias init="git init"

# Get script directory (in a way that works when sourced rather than executed)
export SCRIPT_DIR="$(dirname "${(%):-%x}")"

source "$SCRIPT_DIR/customize_the_shell.sh"

if [[ -f "$SCRIPT_DIR/personalize_the_shell.sh" ]]; then
    source "$SCRIPT_DIR/personalize_the_shell.sh"
fi
