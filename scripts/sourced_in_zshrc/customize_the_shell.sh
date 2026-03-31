#!/usr/bin/env zsh

# You may use this script as a template to customize the shell in general. It should not reference or set up anything personal or user-specific.

# visually separate prompt/input/output. Error indication via Emoji.
export PROMPT='%(?.🍏.🍎) %F{#00ffff}%2~%f: '
zle_highlight=(default:fg=#ffff00)

# Disable shell history file (~/.zsh_history) to keep home folder clean but also for privacy and security reasons
HISTSIZE=10000  # allow in-memory history for current session
SAVEHIST=0      # don't save any commands to ~/.zsh_history
unset HISTFILE  # remove history file variable entirely

# list folder content with useful options
alias l="ls -Fahl"

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

# gitty: A "Save & Sync" Command for git. It commits and pushes all changes.
#
# USAGE:
# `gitty "Your commit message here"`
# or even without a commit message:
# `gitty`
#
# This script automates the most common Git workflow: adding all changes,
# committing them with a message, and pushing them to the remote repository.
# If no commit message is provided, a generic message is generated based on
# the number of changed files.
#
# WHY IT'S USEFUL:
# It's designed for a rapid development cycle where you commit frequently
# and push immediately for backup and collaboration. This streamlines the
# 98% of Git usage that is "add all -> commit -> push", removing repetitive
# steps while still requiring a thoughtful commit message.
#
# For the 2% of cases requiring more granular control (like selective
# staging or complex branch operations), the standard Git commands can
# still be used directly.
gitty () {
    changes=$(status --porcelain)

    if [ -z "$changes" ]; then
        echo "🛑 No changes to commit"
    else
        if [ -z "$1" ]; then
            # Generate commit message since none was provided
            file_count=$(echo "$changes" | wc -l)

            if [ "$file_count" -eq 1 ]; then
                filepath=$(echo "$changes" | sed 's/^...//')
                filename=$(basename "$filepath")
                commit_msg="Edit file: $filename"
            else
                commit_msg="Edit $file_count files"
            fi
        else
            # Use provided commit message
            commit_msg="$1"
        fi

        # Stage, commit and push changes
        add .
        commit -m "$commit_msg"
        push

        # Give feedback
        echo "🤪 https://www.urbandictionary.com/define.php?term=gitty"

        remote_url=$(git remote get-url origin 2>/dev/null)
        if [ -n "$remote_url" ]; then
            echo "🐙 $remote_url"
        fi

        lastCommit=$(log --oneline -1)
        echo "✅ Pushed $lastCommit"
    fi
}

# unveil: Turns all PDFs in the current folder into Markdown files, using markitdown (https://github.com/microsoft/markitdown). Super useful for working with AI on local context.
unveil() {
    if ! command -v markitdown &> /dev/null; then
        echo "markitdown not found (yet)."
        echo "markitdown (by Microsoft) helps making all kinds of content readable to AI."
        echo "Install it with: pipx install 'markitdown'"
        echo "Or visit: https://github.com/microsoft/markitdown"
        return 1
    fi

    for pdf in *.pdf; do
        base="${pdf%.pdf}"
        PYTHONWARNINGS=ignore markitdown "$pdf" -o "$base.md" > /dev/null
        echo "✅ $base.md"
    done
}

# d: Opens folder in IDE, opens current folder if none is provided
# "d" stands for: Development environment, Develop, Debug, Display, Dive into, Dig into, Discuss (with AI)
d() {
    local target_dir="${1:-$(pwd)}"

    if [[ -d "$target_dir" ]]; then
        zed "$target_dir"
    else
        echo "🛑 Directory '$target_dir' does not exist"
        return 1
    fi
}

# hide-extensions: Hide all file extensions in the current directory
hide-extensions() {
  for file in *; do
    if [ -f "$file" ]; then
      SetFile -a E "$file"
    fi
  done
}

# show-extensions: Show all file extensions in the current directory
show-extensions() {
  for file in *; do
    if [ -f "$file" ]; then
      SetFile -a e "$file"
    fi
  done
}

# Install the latest Xcode version
alias xcode-update="xcodes install --latest"

# md2pdf: Converts Markdown to PDF using Pandoc and WeasyPrint.
#
# USAGE:
# `md2pdf <markdown_file>`
#
# This function converts a specified Markdown file into a PDF document.
# It leverages Pandoc for the conversion and WeasyPrint as the PDF engine,
# allowing for high-quality PDF generation with custom styling.
#
# It automatically applies a CSS file (`pdf_style.css`) located in the same
# directory as this script to style the generated PDF, ensuring a consistent
# and professional appearance.
#
# WHY IT'S USEFUL:
# Ideal for creating shareable, print-ready documents from Markdown sources.
# It streamlines the process of generating reports, documentation, or any
# text-based content that benefits from a polished PDF format, making it
# easy to transform plain text into a beautifully formatted document.
md2pdf() {
    if [ -z "$1" ]; then
        echo "Usage: md2pdf <markdown_file>"
        return 1
    fi

    local input_file="$1"

    if [ ! -f "$input_file" ]; then
        echo "Error: File '$input_file' not found."
        return 1
    fi

    local output_file="${input_file%.*}.pdf"
    # Use the CSS file located in the same directory as this script
    local css_file="$SCRIPT_DIR/pdf_style.css"

    if [ ! -f "$css_file" ]; then
        echo "Error: CSS file not found at '$css_file'"
        return 1
    fi

    echo "Converting '$input_file' to PDF..."
    # We use grep to filter out harmless warnings from WeasyPrint about unsupported CSS properties
    # that Pandoc injects by default (gap with min(), overflow-x).
    pandoc "$input_file" \
        -o "$output_file" \
        --pdf-engine=weasyprint \
        --css="$css_file" \
        2> >(grep -v -E "Ignored .*(gap|overflow-x)" >&2)

    if [ $? -eq 0 ]; then
        echo "✅ PDF created at: $output_file"
    else
        echo "🛑 Conversion failed."
        return 1
    fi
}
