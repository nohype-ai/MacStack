#!/usr/bin/env zsh

# Merge fields from <update_json> into <target_json>.
# Values in <update_json> take precedence over existing values in <target_json>.
# Nested objects are merged recursively (jq * operator).
# The result is written back to <target_json> in-place via sponge.
# Usage: merge_json <update_json> <target_json>
merge_json() {
    # Capture arguments
    local update_json="$1"
    local target_json="$2"

    # Create empty target json file if the target file does not exist
    if [[ ! -f "$target_json" ]]; then
        echo '{}' > "$target_json"
    fi

    jq -s '.[0] * .[1]' "$target_json" "$update_json" | sponge "$target_json"
}
