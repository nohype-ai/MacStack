#!/usr/bin/env zsh

# Capture this script's directory at source time so function bodies can use it
# regardless of what $0 refers to when the function is later called.
_MERGE_JSON_DIR="${0:A:h}"

# Absolute path to the JSONC stripper script (sibling of this file).
# Still used by merge_json_TEST.sh for stripping comments in value assertions.
_STRIP_JSONC="${_MERGE_JSON_DIR}/strip_jsonc.pl"

# Strip JSONC-style comments and trailing commas from stdin, output valid JSON.
_strip_jsonc() {
    perl "$_STRIP_JSONC"
}

# Merge fields from <update_json> into <target_json>.
# Values in <update_json> take precedence over existing values in <target_json>.
# Both files may use JSONC (comments, trailing commas).
# Objects: merged recursively; update values win on scalar conflicts.
# Arrays:  set-union by deep equality — duplicates removed, update entries last.
# Comments are preserved and transferred as first-class data.
# Usage: merge_json <update_json> <target_json>
merge_json() {
    local update_json="$1"
    local target_json="$2"
    node "${_MERGE_JSON_DIR}/merge_jsonc.js" "$update_json" "$target_json"
}
