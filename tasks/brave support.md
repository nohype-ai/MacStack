# Brave Browser Support

**Task: apply Brave settings via existing MacStack JSON merge**

Use the same pattern as `scripts/json-merge/merge_json.sh`: merge a stack/source JSON **into** the live target (add missing keys, overwrite existing ones). No diff step. Brave must be quit first.

Source (backup / stack files) → target:

- `~/Library/Application Support/BraveSoftware/Brave-Browser/Default/Preferences`
- `~/Library/Application Support/BraveSoftware/Brave-Browser/Default/Secure Preferences`

Both are JSON. Merge only the settings objects we ship (Shields, content filters, appearance, startup, etc.). Do not replace the whole live files. Do not touch history, cookies, wallet, sessions, `Local State`, or `com.brave.Browser.plist`.

Reuse `merge_json <source> <target>`: recursive object merge, source wins on conflicts.

Note: `Secure Preferences` is MAC-protected. If Brave resets merged keys on launch, those keys need valid `protection.macs` (or keep them in `Preferences` only). Verify after relaunch.
