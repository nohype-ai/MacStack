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

echo ""
echo "Results: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
