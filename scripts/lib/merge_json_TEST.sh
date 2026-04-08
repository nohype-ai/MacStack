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

echo ""
echo "Results: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
