#!/usr/bin/env zsh

# Add basic binary paths to PATH
export PATH="$HOME/.local/bin:$PATH" # XDG path for user-installed CLIs

export PATH="$ROOT/bin:$PATH" # MacStack binary path
# Setup Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Alias for Mack Stack update process
alias update="mack update"

# visually separate prompt/input/output. Error indication via Emoji.
export PROMPT='%(?.🍏.🍎) %F{#00ffff}%2~%f: '
zle_highlight=(default:fg=#ffff00)

# Disable shell history file (~/.zsh_history) to keep home folder clean but also for privacy and security reasons
HISTSIZE=10000  # allow in-memory history for current session
SAVEHIST=0      # don't save any commands to ~/.zsh_history
unset HISTFILE  # remove history file variable entirely

# prints paths in $PATH variable as readable list
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

# Hide all file extensions in the current directory
hide-extensions() {
  for file in *; do
    if [ -f "$file" ]; then
      SetFile -a E "$file"
    fi
  done
}

# Show all file extensions in the current directory
show-extensions() {
  for file in *; do
    if [ -f "$file" ]; then
      SetFile -a e "$file"
    fi
  done
}
