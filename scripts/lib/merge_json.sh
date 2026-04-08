#!/usr/bin/env zsh

# Absolute path to the JSONC stripper script (sibling of this file)
_STRIP_JSONC="${0:A:h}/strip_jsonc.pl"

# Strip JSONC-style comments and trailing commas from stdin, output valid JSON.
_strip_jsonc() {
    perl "$_STRIP_JSONC"
}

# jq function: recursive deep-merge of two JSON values.
#   Objects  → merge keys recursively; update wins on scalar conflicts.
#   Arrays   → set-union by deep equality (target-only entries first, then update).
#   Scalars  → update wins.
# Idempotent: merging the same update twice produces the same result.
_JQ_DEEP_MERGE='
def unique_ordered:
    reduce .[] as $k ([]; if IN(.[]; $k) then . else . + [$k] end);
def deep_merge:
    if (.[0] | type) == "object" and (.[1] | type) == "object" then
        .[0] as $t | .[1] as $u |
        reduce (($t | keys_unsorted) + ($u | keys_unsorted) | unique_ordered)[] as $k (
            {};
            if ($t | has($k)) and ($u | has($k)) then
                . + {($k): ([$t[$k], $u[$k]] | deep_merge)}
            elif ($u | has($k)) then
                . + {($k): $u[$k]}
            else
                . + {($k): $t[$k]}
            end
        )
    elif (.[0] | type) == "array" and (.[1] | type) == "array" then
        (.[1] as $u | .[0] | map(select(. as $t | $u | map(. == $t) | any | not))) + .[1]
    else
        .[1]
    end;
'

# Merge fields from <update_json> into <target_json>.
# Values in <update_json> take precedence over existing values in <target_json>.
# Both files may use JSONC (comments, trailing commas).
# Objects: merged recursively; update values win on scalar conflicts.
# Arrays:  set-union by deep equality — duplicates removed, update entries last.
# This applies at every nesting level, so array-valued properties inside objects
# are also set-unioned rather than replaced.
# The result is written back to <target_json> in-place via sponge.
# Usage: merge_json <update_json> <target_json>
merge_json() {
    local update_json="$1"
    local target_json="$2"

    local update_data
    update_data=$(_strip_jsonc < "$update_json")

    # Nothing to merge if the update file is empty or not valid JSON(C)
    if [[ -z "$update_data" ]] || ! printf '%s' "$update_data" | jq empty 2>/dev/null; then
        return
    fi

    # Create or reset target file if it is missing, empty, or not valid JSON(C)
    if [[ ! -f "$target_json" ]] || [[ ! -s "$target_json" ]] || ! _strip_jsonc < "$target_json" | jq empty 2>/dev/null; then
        # Seed with a type-matching empty value so deep_merge sees compatible types
        printf '%s' "$update_data" | jq 'if type == "array" then [] else {} end' > "$target_json"
    fi

    local target_data
    target_data=$(_strip_jsonc < "$target_json")

    jq -s "${_JQ_DEEP_MERGE}"'[.[0], .[1]] | deep_merge' \
        <(printf '%s' "$target_data") <(printf '%s' "$update_data") | sponge "$target_json"
}
