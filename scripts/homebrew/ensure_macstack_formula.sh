#!/usr/bin/env zsh
# Ensure the macstack formula is installed *with* its runtime dependencies.
#
# The Cellar keg can remain after brew-clip while deps like check-jsonschema and
# node are gone (bundle cleanup cannot resolve deps of an untrusted formula).
#
# Note: `brew install macstack` is a no-op when the keg already exists — it does
# *not* reinstall missing runtime deps. Use `brew missing` + install, or reinstall.

set -e
set -u

if ! brew list --formula macstack &>/dev/null; then
    echo "🍺 Installing MacStack formula ..."
    if ! brew install nohype-ai/tap/macstack; then
        echo "⚠️  Warning: Could not install nohype-ai/tap/macstack."
    fi
    exit 0
fi

# Runtime deps recorded for this keg but not present on disk.
# Split on whitespace/newlines into an array (brew missing prints space-separated names).
missing=()
missing_raw="$(brew missing macstack 2>/dev/null || true)"
if [[ -n "$missing_raw" ]]; then
    # shellcheck disable=SC2206
    missing=(${=missing_raw})
fi

if (( ${#missing[@]} > 0 )); then
    echo "🍺 Restoring ${#missing[@]} missing MacStack dependency(ies): ${missing[*]}"
    if ! brew install "${missing[@]}"; then
        echo "⚠️  Warning: Could not restore all missing MacStack dependencies."
        echo "   You can try: brew reinstall nohype-ai/tap/macstack"
    fi
    exit 0
fi

# Fallback: keg claims complete but tools we need are still not on PATH
if ! command -v check-jsonschema &>/dev/null || ! command -v node &>/dev/null; then
    echo "🍺 MacStack tools missing from PATH; reinstalling formula ..."
    if ! brew reinstall nohype-ai/tap/macstack; then
        echo "⚠️  Warning: Could not reinstall nohype-ai/tap/macstack."
    fi
fi
