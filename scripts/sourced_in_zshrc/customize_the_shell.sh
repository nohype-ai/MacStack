#!/usr/bin/env zsh

# list folder content with useful options
alias l="ls -Fahl"

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
