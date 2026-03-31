#!/usr/bin/env zsh

# Ensure given content exists in ~/.zshrc
ensure_zshrc_content() {
    local content="$1"
    local zshrc_file="$HOME/.zshrc"

    # Create .zshrc if it does not exist yet
    if [[ ! -f "$zshrc_file" ]]; then
        touch "$zshrc_file"
    fi

    # Check if the content already exists in .zshrc (exact character match)
    local file_content="$(cat "$zshrc_file" 2>/dev/null || echo "")"

    if [[ "$file_content" == *"$content"* ]]; then
        return 0
    fi

    # Append the content with a blank line before it
    echo "" >> "$zshrc_file"
    echo "$content" >> "$zshrc_file"
    echo "📝 Added to .zshrc:"
    echo "$content"
}
