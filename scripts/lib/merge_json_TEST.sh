#!/usr/bin/env zsh

# Tests for the merge_json function defined in scripts/lib/json_utils.sh.
# Requires: jq, sponge (moreutils)

source "${0:A:h}/merge_json.sh"

pass=0
fail=0

assert_eq() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo "  ✅ $description"
    (( pass++ ))
  else
    echo "  ❌ $description"
    echo "     expected: $expected"
    echo "     actual:   $actual"
    (( fail++ ))
  fi
}

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

# Test 1: Keys from update_json are added to target_json
echo "Test 1: update_json keys are merged into target_json"
echo '{"a": 1}' > "$tmpdir/target.json"
echo '{"b": 2}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq -c . "$tmpdir/target.json")
assert_eq "merged result contains both keys" '{"a":1,"b":2}' "$result"

# Test 2: update_json values override conflicting keys in target_json
echo "Test 2: update_json values win on conflict"
echo '{"key": "old", "other": "keep"}' > "$tmpdir/target.json"
echo '{"key": "new"}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result_key=$(jq -r '.key' "$tmpdir/target.json")
result_other=$(jq -r '.other' "$tmpdir/target.json")
assert_eq "conflicting key takes update value" "new" "$result_key"
assert_eq "non-conflicting key is preserved" "keep" "$result_other"

# Test 3: Nested objects are merged recursively
echo "Test 3: nested objects are merged, not replaced"
echo '{"settings": {"theme": "dark", "fontSize": 14}}' > "$tmpdir/target.json"
echo '{"settings": {"fontSize": 16}}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result_theme=$(jq -r '.settings.theme' "$tmpdir/target.json")
result_size=$(jq -r '.settings.fontSize' "$tmpdir/target.json")
assert_eq "nested key not in update is preserved" "dark" "$result_theme"
assert_eq "nested key in update overrides target" "16" "$result_size"

# Test 4: Array files — exact duplicates are deduplicated (idempotent merge)
echo "Test 4: array merge deduplicates exact duplicates"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' > "$tmpdir/target.json"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq -c . "$tmpdir/target.json")
assert_eq "identical entry appears exactly once" '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' "$result"

# Test 5: Array files — merge is idempotent (running twice gives same result)
echo "Test 5: array merge is idempotent (running twice = running once)"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' > "$tmpdir/target.json"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq 'length' "$tmpdir/target.json")
assert_eq "array length is 1 after two merges" "1" "$result"

# Test 6: Array files — new entries from update are appended
echo "Test 6: new entries in update are appended to target"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' > "$tmpdir/target.json"
printf '[{"context":"Terminal","bindings":{"cmd-k":"bar"}}]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result_len=$(jq 'length' "$tmpdir/target.json")
result_ctx0=$(jq -r '.[0].context' "$tmpdir/target.json")
result_ctx1=$(jq -r '.[1].context' "$tmpdir/target.json")
assert_eq "array has 2 entries after merging distinct entries" "2" "$result_len"
assert_eq "target entry is first" "Editor" "$result_ctx0"
assert_eq "update entry is appended" "Terminal" "$result_ctx1"

# Test 7: Array files — target starts empty, update entries are added
echo "Test 7: array merge into empty target populates all update entries"
printf '[]' > "$tmpdir/target.json"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}},{"context":"Terminal","bindings":{"cmd-k":"bar"}}]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq 'length' "$tmpdir/target.json")
assert_eq "empty target gets all update entries" "2" "$result"

# Test 8: Array files — missing target is created and populated
echo "Test 8: array merge creates missing target file"
rm -f "$tmpdir/target.json"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq -c . "$tmpdir/target.json")
assert_eq "missing target is created with update contents" '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' "$result"

# Test 9: JSONC trailing commas / comments don't cause false mismatches
echo "Test 9: JSONC update with trailing commas deduplicates against clean target"
printf '[{"context":"Editor","bindings":{"cmd-k":"foo"}}]' > "$tmpdir/target.json"
printf '[
  // a comment
  {"context":"Editor","bindings":{"cmd-k":"foo"},},
]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq 'length' "$tmpdir/target.json")
assert_eq "JSONC update still deduplicates against clean target" "1" "$result"

# Test 10: VS Code keybindings — exact duplicate is not repeated
echo "Test 10: VS Code keybindings exact duplicate is deduplicated"
printf '[{"key":"cmd-k","command":"foo","when":"editorFocus"}]' > "$tmpdir/target.json"
printf '[{"key":"cmd-k","command":"foo","when":"editorFocus"}]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq 'length' "$tmpdir/target.json")
assert_eq "duplicate keybinding appears only once" "1" "$result"

# Test 11: Object with nested array property — set-union, not replacement
echo "Test 11: nested array property in object is merged (set-union)"
echo '{"rules": ["A", "B", "C"], "other": "keep"}' > "$tmpdir/target.json"
echo '{"rules": ["C", "D"]}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result_rules=$(jq -c '.rules' "$tmpdir/target.json")
result_other=$(jq -r '.other' "$tmpdir/target.json")
assert_eq "nested array is set-union (target-only + update)" '["A","B","C","D"]' "$result_rules"
assert_eq "sibling key is preserved" "keep" "$result_other"

# Test 12: Object with nested array — idempotent across repeated merges
echo "Test 12: nested array property stays stable across repeated merges"
echo '{"font_fallbacks": ["Menlo", "Monaco"], "theme": "dark"}' > "$tmpdir/target.json"
echo '{"font_fallbacks": ["SF Mono", "Menlo"]}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result_fonts=$(jq -c '.font_fallbacks' "$tmpdir/target.json")
result_theme=$(jq -r '.theme' "$tmpdir/target.json")
assert_eq "nested array unchanged after 3 merges" '["Monaco","SF Mono","Menlo"]' "$result_fonts"
assert_eq "sibling key still preserved" "dark" "$result_theme"

# Test 13: Deeply nested object with array property
echo "Test 13: deeply nested array in object is set-union merged"
echo '{"settings": {"editor": {"rulers": [80, 120], "font": "mono"}}}' > "$tmpdir/target.json"
echo '{"settings": {"editor": {"rulers": [100]}}}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result_rulers=$(jq -c '.settings.editor.rulers' "$tmpdir/target.json")
result_font=$(jq -r '.settings.editor.font' "$tmpdir/target.json")
assert_eq "deeply nested array is set-union" "[80,120,100]" "$result_rulers"
assert_eq "deeply nested sibling key preserved" "mono" "$result_font"

# Test 14: Empty update file is a no-op
echo "Test 14: empty update file leaves target unchanged"
echo '{"a": 1}' > "$tmpdir/target.json"
: > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq -c . "$tmpdir/target.json")
assert_eq "target unchanged after empty update" '{"a":1}' "$result"

# Test 15: Empty object update is a no-op
echo "Test 15: empty object update leaves target unchanged"
echo '{"a": 1, "b": 2}' > "$tmpdir/target.json"
echo '{}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq -c . "$tmpdir/target.json")
assert_eq "target unchanged after empty object update" '{"a":1,"b":2}' "$result"

# Test 16: Empty array update is a no-op
echo "Test 16: empty array update leaves target unchanged"
printf '["A", "B"]' > "$tmpdir/target.json"
printf '[]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq -c . "$tmpdir/target.json")
assert_eq "target unchanged after empty array update" '["A","B"]' "$result"

# Test 17: Object key ordering is preserved (target-first, then new update keys)
echo "Test 17: key order preserved (target-first, update-new appended)"
printf '{"z": 1, "a": 2}' > "$tmpdir/target.json"
printf '{"a": 99, "m": 3}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result=$(jq -c 'keys_unsorted' "$tmpdir/target.json")
assert_eq "key order is z, a (from target), m (new from update)" '["z","a","m"]' "$result"

# Test 18: Object merge is idempotent
echo "Test 18: object merge is idempotent (running twice = running once)"
echo '{"a": 1, "b": 2}' > "$tmpdir/target.json"
echo '{"b": 99, "c": 3}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
first_run=$(jq -c . "$tmpdir/target.json")
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
second_run=$(jq -c . "$tmpdir/target.json")
assert_eq "object merge is idempotent" "$first_run" "$second_run"

# Test 19: Null value in update overrides target
echo "Test 19: null in update overrides target value"
echo '{"a": 1, "b": 2}' > "$tmpdir/target.json"
echo '{"a": null}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
result_a=$(jq '.a' "$tmpdir/target.json")
result_b=$(jq '.b' "$tmpdir/target.json")
assert_eq "null from update wins" "null" "$result_a"
assert_eq "other key preserved" "2" "$result_b"

# Helper: strip JSONC comments and trailing commas so jq can parse the output.
# Used in comment tests where the target file may contain JSONC after merging.
_strip_comments_for_jq() {
    perl "$_STRIP_JSONC"
}

assert_contains() {
    local description="$1"
    local needle="$2"
    local haystack="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "  ✅ $description"
        (( pass++ ))
    else
        echo "  ❌ $description"
        echo "     expected to contain: $needle"
        echo "     actual content:      $haystack"
        (( fail++ ))
    fi
}

assert_not_contains() {
    local description="$1"
    local needle="$2"
    local haystack="$3"
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "  ✅ $description"
        (( pass++ ))
    else
        echo "  ❌ $description"
        echo "     expected NOT to contain: $needle"
        echo "     actual content:          $haystack"
        (( fail++ ))
    fi
}

# Test 20: Comments in target are preserved when merging new values
echo "Test 20: target comments are preserved when update adds/changes values"
printf '{\n  // user pref\n  "theme": "dark",\n  "fontSize": 14\n}' > "$tmpdir/target.json"
printf '{"fontSize": 16}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_theme=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.theme')
result_size=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.fontSize')
assert_contains "target comment is preserved" "// user pref" "$raw"
assert_eq "theme (target-only key) is preserved" "dark" "$result_theme"
assert_eq "fontSize (conflicting key) is updated" "16" "$result_size"

# Test 21: Comments in target survive idempotent re-merge
echo "Test 21: target comments survive repeated merges"
printf '{\n  // user pref\n  "theme": "dark",\n  "fontSize": 14\n}' > "$tmpdir/target.json"
printf '{"fontSize": 16}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_size=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.fontSize')
assert_contains "target comment survives 3 merges" "// user pref" "$raw"
assert_eq "fontSize is stable after 3 merges" "16" "$result_size"

# Test 22: Comments in target array file are preserved
echo "Test 22: comments in target array file are preserved"
printf '[\n  // Markdown binding\n  {"context":"Editor","bindings":{"cmd-p":"preview"}}\n]' > "$tmpdir/target.json"
printf '[{"context":"Terminal","bindings":{"cmd-k":"clear"}}]' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_len=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq 'length')
assert_contains "array comment is preserved" "// Markdown binding" "$raw"
assert_eq "both array entries are present" "2" "$result_len"

# Test 23: Inline comments on the same line as a value are preserved
echo "Test 23: inline end-of-line comments are preserved"
printf '{\n  "timeout": 30, // seconds\n  "retries": 3\n}' > "$tmpdir/target.json"
printf '{"retries": 5}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_retries=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.retries')
assert_contains "inline comment is preserved" "// seconds" "$raw"
assert_eq "retries is updated" "5" "$result_retries"

# Test 24: Comments from update transfer to target
echo "Test 24: comments from update transfer to target"
printf '{"a": 1}' > "$tmpdir/target.json"
printf '{\n  // important note\n  "b": 2\n}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_a=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.a')
result_b=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.b')
assert_contains "update comment transfers to target" "// important note" "$raw"
assert_eq "original target key is preserved" "1" "$result_a"
assert_eq "update key is added" "2" "$result_b"

# Test 25: Comments from update replace target comments on conflicting keys
echo "Test 25: update comments replace target comments on conflicting keys"
printf '{\n  // old note\n  "key": "old"\n}' > "$tmpdir/target.json"
printf '{\n  // new note\n  "key": "new"\n}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_key=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.key')
assert_contains "update comment is present" "// new note" "$raw"
assert_not_contains "old target comment is gone" "// old note" "$raw"
assert_eq "update value wins" "new" "$result_key"

# Test 26: Comments on target-only keys are undisturbed when update touches other keys
echo "Test 26: comments on target-only keys are undisturbed"
printf '{\n  // keep this\n  "a": 1,\n  "b": 2\n}' > "$tmpdir/target.json"
printf '{"b": 99}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_b=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.b')
assert_contains "comment on target-only key is undisturbed" "// keep this" "$raw"
assert_eq "updated key has new value" "99" "$result_b"

# Test 27: Comments from both target and update survive when on different keys
echo "Test 27: comments from both sides survive when on different keys"
printf '{\n  // target note\n  "a": 1,\n  "b": 2\n}' > "$tmpdir/target.json"
printf '{\n  // update note\n  "c": 3\n}' > "$tmpdir/update.json"
merge_json "$tmpdir/update.json" "$tmpdir/target.json"
raw=$(cat "$tmpdir/target.json")
result_a=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.a')
result_c=$(_strip_comments_for_jq < "$tmpdir/target.json" | jq -r '.c')
assert_contains "target comment survives alongside update comment" "// target note" "$raw"
assert_contains "update comment transfers alongside target comment" "// update note" "$raw"
assert_eq "target key a is preserved" "1" "$result_a"
assert_eq "update key c is added" "3" "$result_c"

echo ""
echo "Results: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
