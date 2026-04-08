# Implementation Plan: Comment-Preserving JSON Merge

## Background

`merge_json.sh` is MacStack's core function for idempotently merging stack template
JSON files into user configuration files (IDE settings, keymaps, AI agent configs).

The current implementation uses `strip_jsonc.pl` to remove comments and trailing
commas, then `jq` to perform a recursive deep merge. This works correctly for values
but **permanently strips comments from both files**. Many config files (Zed settings,
OpenCode config, VS Code settings) use JSONC comments for inline documentation —
placed there by software vendors or by the user. Users back up their tweaked settings
(comments included) to their stack, and expect those comments to arrive in the
deployed config on the next `mack update`.

### Why comments must transfer, not just survive

The stack is the source of truth. The typical user workflow is:

1. Tweak settings in an app (which may have vendor comments)
2. Copy the settings file to the stack as a backup
3. Run `mack update` to deploy the stack

If comments only survive in the target but don't transfer from the update (stack),
then comments in the stack become dead documentation — they exist in the repo but
never appear where the user actually reads the file. Comments must be first-class
data that flows through the merge like any other element.

## Key Insight: `comment-json`

The npm package `comment-json` (by kaelzhang) solves this by treating comments as
**properties on the parsed JavaScript objects**, stored under Symbol keys.

### How it works

JavaScript Symbols (an ES2015 language feature) are a special type of property key
that is **invisible to normal object operations**. `Object.keys()` won't list them,
`JSON.stringify()` won't emit them, `for...in` loops won't see them. But code that
explicitly looks for them can read and copy them. This makes Symbols ideal for
attaching metadata (like comments) to objects without interfering with the data.

`comment-json` uses this by attaching comments as Symbol-keyed properties on the
parsed objects. For example:

```javascript
const { parse, stringify } = require('comment-json');

const obj = parse('{\n  // user pref\n  "theme": "dark"\n}');
// Regular property:
//   obj.theme === "dark"
// Symbol property (invisible to normal operations):
//   obj[Symbol.for('before:theme')] → [{ type: 'LineComment', value: ' user pref' }]

stringify(obj, null, 2);
// outputs the JSONC with the comment intact
```

There is no special data structure or format — it's a regular JavaScript object
with standard Symbol-keyed properties. The *convention* of which Symbol names to
use (`before:key`, `after:key`, etc.) is specific to `comment-json`, but the
mechanism is plain JavaScript.

### Why this matters for the merge

Because comments are just properties, the merge algorithm stays **conceptually
identical** to the current jq implementation. Comments flow through the recursive
deep merge like any other property — no heuristics, no comment association, no
surgical text editing. The only adjustment: when copying a key from one object to
another, also copy its associated Symbol properties.

## Dependencies

### Node.js (new brew dependency)

Add `depends_on "node"` to the Homebrew formula template
(`homebrew-macstack/Formula/macstack_template.rb`). This makes Node.js a first-class
dependency managed by Homebrew, installed automatically when a user runs
`brew install macstack`. No manual setup step required.

The formula currently depends on `jq`, `moreutils`, and `check-jsonschema`. After
this change, the `jq` and `moreutils` (sponge) dependencies can be **removed** if
no other scripts use them, since the Node.js script replaces both.

### comment-json (vendored)

`comment-json` is a lightweight npm package (MIT license). **Vendor it** as a single
bundled `.js` file inside `scripts/lib/vendor/`. This avoids any `npm install` step
at install time or runtime. To produce the vendored bundle:

```bash
npm install comment-json
npx esbuild --bundle --platform=node \
  --outfile=scripts/lib/vendor/comment-json.bundle.js \
  -e "module.exports = require('comment-json')"
```

This produces a single self-contained file with `comment-json` and its
(few, small) transitive dependencies inlined. No `node_modules` directory needed
at runtime.

### License compliance

`comment-json` uses the MIT License. Include the license text at
`scripts/lib/vendor/comment-json.LICENSE`. MIT requires only that the copyright
notice and license text are preserved alongside the vendored code. Check transitive
dependencies for their licenses as well (expected to also be MIT) and include them
in the same file.

## Architecture

### Files to add

| File | Purpose |
|------|---------|
| `scripts/lib/merge_jsonc.js` | Node.js script: deep merge with comment preservation |
| `scripts/lib/vendor/comment-json.bundle.js` | Vendored comment-json library (single file) |
| `scripts/lib/vendor/comment-json.LICENSE` | MIT license(s) for comment-json and its dependencies |

### Files to modify

| File | Change |
|------|--------|
| `scripts/lib/merge_json.sh` | Replace jq pipeline with call to `node merge_jsonc.js` |
| `scripts/lib/merge_json_TEST.sh` | Add comment tests (TDD: add first, then implement) |
| `homebrew-macstack/Formula/macstack_template.rb` | Add `depends_on "node"` |

### Files potentially removable

| File | Condition |
|------|-----------|
| `scripts/lib/strip_jsonc.pl` | If no other script uses it; Node.js handles JSONC natively |

### Callers (unchanged interface)

These files call `merge_json` and require **no changes** — the function signature
(`merge_json <update_file> <target_file>`) stays the same:

- `scripts/update_ide_settings.sh`
- `scripts/update_ai_agent_settings.sh`

## Algorithm

### Current approach (jq — comments stripped)

1. Strip JSONC from both files via `strip_jsonc.pl` → valid JSON (comments lost)
2. Parse both into data structures
3. Deep merge (objects: recursive key merge; arrays: set-union by deep equality)
4. Serialize back to JSON → write to target (comments gone from both sides)

### New approach (comment-json — comments are data)

1. `parse(targetText)` → JavaScript object with comments as Symbol properties
2. `parse(updateText)` → JavaScript object with comments as Symbol properties
3. Deep merge the two objects:
   - **Objects**: iterate keys (including Symbol-keyed comment properties).
     For keys in both: recurse. For keys only in update: copy (with comments).
     For keys only in target: keep (with comments). Update wins on scalar conflicts.
   - **Arrays**: set-union by deep equality. When comparing elements for equality,
     strip Symbol properties (compare data only, not comments). Target-only entries
     keep their comments. Update-only entries bring their comments.
   - **Scalars**: update wins.
4. `stringify(merged, null, 2)` → JSONC text with comments from both sides
5. Write to target file

### What happens to comments in each case

| Scenario | Comment behavior |
|----------|-----------------|
| Key exists only in target | Target's comments preserved |
| Key exists only in update | Update's comments transfer to target |
| Key exists in both (update wins) | Update's comments replace target's comments |
| Array element only in target | Target's comments preserved |
| Array element only in update | Update's comments transfer |
| Array element is duplicate | Deduplicated; existing copy's comments kept |
| Target file is missing/empty | Update content written directly (comments included) |
| Update file is empty | No-op, target untouched |

### Key properties

- **Idempotency**: merging the same update twice produces the same result.
  Guaranteed by set-union for arrays and "update wins" for object scalars — same as
  before, now including comments.
- **Key ordering**: target keys keep their original order; new keys from update
  are appended at the end of the containing object.
- **Comment transfer**: comments flow from update to target as first-class data.
  The stack's inline documentation arrives in the deployed config.
- **Comment preservation**: target-only keys retain their comments undisturbed.
- **Formatting**: `stringify(obj, null, 2)` produces consistent 2-space indentation.
  Original target formatting (tabs, irregular spacing) is normalized. This is an
  acceptable tradeoff — consistent formatting is better than preserved quirks, and
  is far better than lost comments.

## merge_json.sh changes

The shell function becomes a thin wrapper:

```zsh
merge_json() {
    local update_json="$1"
    local target_json="$2"
    node "${0:A:h}/merge_jsonc.js" "$update_json" "$target_json"
}
```

All merge logic, JSONC parsing, empty/missing file handling, and the deep merge
algorithm move into `merge_jsonc.js`. The `_strip_jsonc` helper, `_JQ_DEEP_MERGE`
jq function, and sponge dependency are no longer needed.

## merge_jsonc.js sketch

```javascript
const { parse, stringify, assign } = require('./vendor/comment-json.bundle.js');
const fs = require('fs');

const updateFile = process.argv[2];
const targetFile = process.argv[3];

const updateText = fs.readFileSync(updateFile, 'utf8');

// Empty or invalid update → no-op
let updateObj;
try { updateObj = parse(updateText); } catch { process.exit(0); }
if (updateObj == null) process.exit(0);

// Missing or empty target → write update directly
let targetObj;
try { targetObj = parse(fs.readFileSync(targetFile, 'utf8')); } catch { targetObj = null; }
if (targetObj == null) {
    fs.writeFileSync(targetFile, stringify(updateObj, null, 2) + '\n');
    process.exit(0);
}

const merged = deepMerge(targetObj, updateObj);
fs.writeFileSync(targetFile, stringify(merged, null, 2) + '\n');

function deepMerge(target, update) {
    // Both objects → recursive key merge with Symbol (comment) preservation
    // Both arrays → set-union by deep data equality
    // Otherwise → update wins
    // ... (~40–60 lines implementing the same logic as _JQ_DEEP_MERGE)
}
```

The deep merge function mirrors the current jq `deep_merge` exactly, with the
addition of copying Symbol-keyed properties (comments) alongside regular keys.

## Testing (TDD)

### Approach

Add comment-related tests to `merge_json_TEST.sh` **before** implementing
`merge_jsonc.js`. Run the tests — they will fail against the current jq-based
implementation (confirming that comments are indeed stripped today). Then implement
the Node.js script and confirm all tests pass — both the new comment tests and all
19 existing tests.

### Asserting comments in tests

Since the target file now contains JSONC (not clean JSON), value assertions need
to strip comments before piping to `jq`. The existing `_strip_jsonc` helper (or an
inline perl one-liner) can be used for this. Comment assertions use `grep` on the
raw file content:

```zsh
# Assert a comment is present
grep -q '// User preference' "$tmpdir/target.json"

# Assert a value (strip comments first, then use jq)
result=$(_strip_jsonc < "$tmpdir/target.json" | jq -r '.fontSize')
assert_eq "fontSize is updated" "16" "$result"
```

### New test cases

All existing tests (1–19) remain and must keep passing. They validate merge
correctness. The new tests validate comment handling:

**Test 20: Comments in target are preserved when merging new values**

Target: `{ // user pref\n "theme": "dark", "fontSize": 14 }`
Update: `{"fontSize": 16}`
Assert: output contains `// user pref`, fontSize is 16, theme is "dark".

**Test 21: Comments in target survive idempotent re-merge**

Same as test 20, run merge 3 times. Assert comments still present, values stable.

**Test 22: Comments in target array file are preserved**

Target: `[ // Markdown binding\n {"context":"Editor","bindings":{"cmd-p":"preview"}} ]`
Update: `[{"context":"Terminal","bindings":{"cmd-k":"clear"}}]`
Assert: `// Markdown binding` is in output, both entries exist.

**Test 23: Inline comments on the same line as a value are preserved**

Target: `{ "timeout": 30, // seconds\n "retries": 3 }`
Update: `{"retries": 5}`
Assert: `// seconds` present, retries is 5.

**Test 24: Comments from update transfer to target**

Target: `{"a": 1}` (no comments)
Update: `{ // important note\n "b": 2 }`
Assert: target contains both keys AND contains `// important note`.

**Test 25: Comments from update replace target comments on conflict**

Target: `{ // old note\n "key": "old" }`
Update: `{ // new note\n "key": "new" }`
Assert: target contains `// new note`, does NOT contain `// old note`, value is "new".

**Test 26: Comments on target-only keys are undisturbed**

Target: `{ // keep this\n "a": 1, "b": 2 }`
Update: `{"b": 99}`
Assert: `// keep this` is present (it's on "a", which update doesn't touch), b is 99.

## Rollout

1. **Add tests** (TDD red phase): add tests 20–26 to `merge_json_TEST.sh`
2. **Confirm they fail**: run the test suite, verify tests 1–19 pass and 20–26 fail
3. **Vendor comment-json**: create `scripts/lib/vendor/` with the bundled library
   and its MIT license file
4. **Implement merge_jsonc.js**: the Node.js merge script (~60–80 lines)
5. **Update merge_json.sh**: replace the jq pipeline with the `node` call
6. **Confirm all tests pass** (TDD green phase): run the full suite, all 26+ pass
7. **Update the Homebrew formula**: add `depends_on "node"`, evaluate whether `jq`
   and `moreutils` can be removed
8. **Release**: tag a new version per the existing release process
