#!/usr/bin/env zsh

# Absolute path to the JSONC stripper script (sibling of this file)
_STRIP_JSONC="${0:A:h}/strip_jsonc.pl"

# Strip JSONC-style comments and trailing commas from stdin, output valid JSON.
_strip_jsonc() {
    perl "$_STRIP_JSONC"
}

# Merge fields from <update_json> into <target_json>.
# Values in <update_json> take precedence over existing values in <target_json>.
# Both files may use JSONC (comments, trailing commas).
# Object files: merged recursively (jq * operator).
# Array files: concatenated (update entries appended after target entries).
# The result is written back to <target_json> in-place via sponge.
# Usage: merge_json <update_json> <target_json>
merge_json() {
    local update_json="$1"
    local target_json="$2"

    # Determine whether update_json is an array or object
    local update_type
    update_type=$(_strip_jsonc < "$update_json" | jq -r 'type')

    local empty_value='{}'
    [[ "$update_type" == "array" ]] && empty_value='[]'

    # Create or reset target file if it is missing, empty, or not valid JSON(C)
    if [[ ! -f "$target_json" ]] || [[ ! -s "$target_json" ]] || ! _strip_jsonc < "$target_json" | jq empty 2>/dev/null; then
        echo "$empty_value" > "$target_json"
    fi

    local update_data target_data
    update_data=$(_strip_jsonc < "$update_json")
    target_data=$(_strip_jsonc < "$target_json")

    if [[ "$update_type" == "array" ]]; then
        # Arrays: concatenate (target entries first, update entries appended)
        jq -s '.[0] + .[1]' <(printf '%s' "$target_data") <(printf '%s' "$update_data") | sponge "$target_json"
    else
        # Objects: deep merge, update values win
        jq -s '.[0] * .[1]' <(printf '%s' "$target_data") <(printf '%s' "$update_data") | sponge "$target_json"
    fi
}
