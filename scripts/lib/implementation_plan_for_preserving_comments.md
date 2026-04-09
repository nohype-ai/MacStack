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
2. Copy the settings file to the stack as a backup, overwriting the old backup.
3. Run `mack update` to deploy the stack (merge the backup into the target)

If comments are preserved in the target but don't transfer from the update (stack) to the target,
then comments in the stack could really be used as editable documentation since they will be replaced anyway next time the user replaces them with the backup from the actual software settings (the target), but those would then not have the changed comments from the stack. so comments effectively flow in a cycle between stack and target. they get merged into the target and then backed up to (replacing) the stack.

Comments must be first-class
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

Add `depends_on "node"` to the Homebrew formula template. This makes Node.js a
first-class dependency managed by Homebrew, installed automatically when a user runs
`brew install macstack`. No manual setup step required.

Note: the Homebrew formula lives in a **separate repository** (`homebrew-macstack`),
not in this repo. Rollout step 7 targets that repo.

The formula currently depends on `jq`, `moreutils`, and `check-jsonschema`. After
this change, `moreutils` (sponge) **cannot** be removed yet — `scripts/config/load_stack_path.sh`
calls `sponge` directly (line 31) for a purpose unrelated to `merge_json`. `jq` is
also still needed for reading `macstack.json` from the user's stack.

### comment-json (vendored)

`comment-json` is a lightweight npm package (MIT license). **Vendor it** as a single
bundled `.js` file inside `scripts/lib/vendor/`. This avoids any `npm install` step
at install time or runtime. To produce the vendored bundle:

```bash
npm install comment-json esbuild

# Create a minimal entry point
echo "module.exports = require('comment-json')" > _entry.js

npx esbuild _entry.js --bundle --platform=node \
  --outfile=scripts/lib/vendor/comment-json.bundle.js

rm _entry.js
```

The `-e` flag does not exist in esbuild; an entry point file must be passed as a
positional argument. The snippet above creates a throwaway `_entry.js` for this
purpose.

This produces a single self-contained file with `comment-json` and its
(few, small) transitive dependencies inlined. No `node_modules` directory needed
at runtime.

### Trailing commas

`comment-json`'s `parse()` **does** support trailing commas natively — they are
silently accepted and dropped on re-stringify. This replaces the trailing-comma
stripping that `strip_jsonc.pl` currently performs, with no behavioral difference.
(Confirmed in the `comment-json` README under "Special Cases about Trailing Comma".)

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
| `scripts/lib/merge_json_TEST.sh` | Update value assertions + add comment tests (TDD: add first, then implement) |
| `homebrew-macstack` repo | Add `depends_on "node"` to the formula |

### Files potentially removable

| File | Condition |
|------|-----------|
| `scripts/lib/strip_jsonc.pl` | Safe to remove once `merge_json_TEST.sh` no longer sources it for value assertions (see Testing section) |

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
   - **Objects**: iterate keys using `Object.keys()` (regular string keys only).
     For keys in both: recurse. For keys only in update: copy value and copy all
     five property-level comment Symbols (`before:k`, `after-prop:k`,
     `after-colon:k`, `after-value:k`, `after:k`).
     For keys only in target: keep as-is (value and comments untouched).
     Update wins on scalar conflicts.
   - Copy non-property container-level Symbols (`before-all`, `after-all`,
     `before`, `after`) from update to merged result.
   - **Arrays**: set-union by deep equality. When comparing elements for equality,
     compare data only (use `parse(stringify(el))` or `JSON.stringify` on a
     comment-stripped copy). Target-only entries keep their comments.
     Update-only entries bring their comments. Arrays must be built as
     `CommentArray` instances (not plain arrays) to preserve comment metadata
     through stringify.
   - **Scalars**: update wins.
4. `stringify(merged, null, 2)` → JSONC text with comments from both sides
5. Write to target file

### Symbol convention reference

`comment-json` uses nine Symbol keys to represent comment positions. The five
**property-level** ones (keyed by property name or array index) must be copied
when moving/keeping a key:

| Symbol | Meaning |
|--------|---------|
| `Symbol.for('before:k')` | Comments before the key, after the previous `,` or `{`/`[` |
| `Symbol.for('after-prop:k')` | Comments after the key, before `:` |
| `Symbol.for('after-colon:k')` | Comments after `:`, before the value |
| `Symbol.for('after-value:k')` | Comments after the value, before `,` or `}`/`]` |
| `Symbol.for('after:k')` | Comments after `,` (or after last value) |

The four **non-property** ones (container or document level):

| Symbol | Meaning |
|--------|---------|
| `Symbol.for('before-all')` | Comments before the entire document |
| `Symbol.for('after-all')` | Comments after the entire document |
| `Symbol.for('before')` | Inside an empty object/array |
| `Symbol.for('after')` | At the inner end of an object/array (stringify only) |

The library's `assign(target, source)` (called with no `keys` argument) copies all
properties **and** all Symbols in one call. It is the right tool when moving an
entire key from update into the merged object. For the recursive case (key exists
in both and values are recursed into), `assign` is not used — instead recursion
handles the value and the property-level Symbols must be copied manually from
update's object onto the result for that key.

### What happens to comments in each case

| Scenario | Comment behavior |
|----------|-----------------|
| Key exists only in target | Target's comments preserved |
| Key exists only in update | Update's comments transfer to target |
| Key exists in both (update wins on scalars) | Update's comments replace target's comments for that key |
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
jq function, and sponge dependency are no longer needed in this file.

## merge_jsonc.js sketch

```javascript
const { parse, stringify, CommentArray } = require('./vendor/comment-json.bundle.js');
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

// Property-level Symbol prefixes that comment-json attaches per key
const PROP_PREFIXES = ['before', 'after-prop', 'after-colon', 'after-value', 'after'];

function copyPropSymbols(src, dst, key) {
    for (const prefix of PROP_PREFIXES) {
        const sym = Symbol.for(`${prefix}:${key}`);
        if (src[sym] !== undefined) dst[sym] = src[sym];
    }
}

function dataEqual(a, b) {
    // Deep equality ignoring Symbol properties (compare data only)
    return JSON.stringify(parse(stringify(a), null, true)) ===
           JSON.stringify(parse(stringify(b), null, true));
}

function deepMerge(target, update) {
    if (Array.isArray(target) && Array.isArray(update)) {
        // Set-union: keep target entries, append update entries not already present
        const result = new CommentArray(...target);
        for (let i = 0; i < update.length; i++) {
            if (!target.some(t => dataEqual(t, update[i]))) {
                result.push(update[i]);
                // Copy array-item Symbols from update for the new entry
                const newIdx = result.length - 1;
                copyPropSymbols(update, result, i);
            }
        }
        return result;
    }

    if (isObject(target) && isObject(update)) {
        const result = {};
        // Copy non-property container Symbols from update (before-all, after-all, etc.)
        for (const sym of Object.getOwnPropertySymbols(update)) {
            result[sym] = update[sym];
        }
        // Merge keys: target first (preserving order), then new-from-update
        const targetKeys = Object.keys(target);
        const updateKeys = Object.keys(update);
        const allKeys = [...targetKeys, ...updateKeys.filter(k => !targetKeys.includes(k))];
        for (const key of allKeys) {
            const inTarget = Object.prototype.hasOwnProperty.call(target, key);
            const inUpdate = Object.prototype.hasOwnProperty.call(update, key);
            if (inTarget && inUpdate) {
                result[key] = deepMerge(target[key], update[key]);
                copyPropSymbols(update, result, key); // update's comments win
            } else if (inUpdate) {
                result[key] = update[key];
                copyPropSymbols(update, result, key);
            } else {
                result[key] = target[key];
                copyPropSymbols(target, result, key);
            }
        }
        return result;
    }

    // Scalar: update wins
    return update;
}

function isObject(v) {
    return v !== null && typeof v === 'object' && !Array.isArray(v);
}
```

Note: `assign` from `comment-json` is **not** used in the merge sketch above.
It is a convenience for bulk-copying all properties + Symbols from one object to
another (like `Object.assign` but Symbol-aware), which is useful for the
all-new-key case but doesn't help with the recursive per-key merge. Importing it
is harmless but unnecessary; the sketch handles Symbol copying directly with
`copyPropSymbols`.

## Testing (TDD)

### Approach

Add comment-related tests to `merge_json_TEST.sh` **before** implementing
`merge_jsonc.js`. Run the tests — they will fail against the current jq-based
implementation (confirming that comments are indeed stripped today). Then implement
the Node.js script and confirm all tests pass — both the new comment tests and all
19 existing tests.

### Impact on existing tests (tests 1–19)

The new implementation writes JSONC to the target file. Tests 1–19 all use
comment-free update files, so comments will never appear in the target for those
tests. Their `jq -c .` assertions are safe — `jq` accepts valid JSON, and a
comment-free JSONC file is valid JSON.

The one test that uses a commented update file is **test 9**, which has a
`// a comment` in the update. Under the new implementation the target will receive
that comment. Test 9 currently asserts only the array length (via `jq 'length'`),
not the raw file content, so it remains correct. No changes to tests 1–19 are
required.

### Asserting comments in new tests

Comment assertions use `grep` on the raw file content. Value assertions that need
`jq` on a file that might contain comments should pipe through `_strip_jsonc` first
(the helper remains available in `merge_json.sh` after the transition if kept, or
an inline perl one-liner can be used). In practice, new comment tests can keep
value assertions separate from comment assertions:

```zsh
# Assert a comment is present in the raw file
grep -q '// user pref' "$tmpdir/target.json"

# Assert a value (the file may have comments, so strip first)
result=$(perl -pe 's|("(?:[^"\\]|\\.)*")|$1|g; s|//[^\n]*||g' \
    < "$tmpdir/target.json" | jq -r '.fontSize')
assert_eq "fontSize is updated" "16" "$result"
```

### New test cases

All existing tests (1–19) remain and must keep passing. The new tests validate
comment handling:

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
   and its MIT license file (use the esbuild entry-point approach described above)
4. **Implement merge_jsonc.js**: the Node.js merge script (~80–100 lines)
5. **Update merge_json.sh**: replace the jq pipeline with the `node` call
6. **Confirm all tests pass** (TDD green phase): run the full suite, all 26+ pass
7. **Update the Homebrew formula** (separate repo): add `depends_on "node"`;
   leave `jq` and `moreutils` in place (both are still used elsewhere)
8. **Release**: tag a new version per the existing release process
