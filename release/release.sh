#!/usr/bin/env zsh
set -euo pipefail

# Usage: ./release.sh <major|minor|patch>
# Example: ./release.sh patch   (v0.1.2 -> v0.1.3)
#          ./release.sh minor   (v0.1.2 -> v0.2.0)
#          ./release.sh major   (v0.1.2 -> v1.0.0)
#
# Automates the MacStack release process (steps 1-6 from release.md):
#   1. Tag and push the release in the MacStack repo
#   2. Wait for GitHub to make the tarball available, then compute its sha256
#   3. Generate the Homebrew formula from the template with version and sha256
#   4. Commit the updated formula in the homebrew-macstack repo
#   5. Push the formula repo so users get the update on their next `brew upgrade`
#   6. Update local installation of MacStack to the newly released version

MACSTACK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FORMULA_REPO="$MACSTACK_DIR/../homebrew-macstack"
TEMPLATE="$FORMULA_REPO/Formula/macstack_template.rb"
FORMULA="$FORMULA_REPO/Formula/macstack.rb"

BUMP="${1:-}"
if [[ "$BUMP" != "major" && "$BUMP" != "minor" && "$BUMP" != "patch" ]]; then
    echo "Usage: $0 <major|minor|patch>"
    echo "Example: $0 patch"
    exit 1
fi

# Determine latest version from git tags
LATEST=$(git -C "$MACSTACK_DIR" tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
if [[ -z "$LATEST" ]]; then
    echo "Error: No existing version tags found."
    exit 1
fi

MAJOR=$(echo "$LATEST" | sed 's/^v//' | cut -d. -f1)
MINOR=$(echo "$LATEST" | sed 's/^v//' | cut -d. -f2)
PATCH=$(echo "$LATEST" | sed 's/^v//' | cut -d. -f3)

case "$BUMP" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
esac

VERSION="v${MAJOR}.${MINOR}.${PATCH}"
echo "Latest version: $LATEST"
echo "New version:    $VERSION"
echo ""

# Verify the formula repo exists
if [[ ! -d "$FORMULA_REPO" ]]; then
    echo "Error: Formula repo not found at $FORMULA_REPO"
    echo "Expected homebrew-macstack as a sibling folder of MacStack."
    exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
    echo "Error: Formula template not found at $TEMPLATE"
    exit 1
fi

TARBALL_URL="https://github.com/nohype-ai/MacStack/archive/refs/tags/${VERSION}.tar.gz"

echo "=== MacStack Release: $VERSION ==="
echo ""

# Step 1: Tag the release in the MacStack repo and push
echo "Step 1: Tagging $VERSION and pushing to GitHub ..."
cd "$MACSTACK_DIR"
git tag "$VERSION"
git push GitHub "$VERSION"
echo "  Tag $VERSION pushed."
echo ""

# Step 2: Wait for GitHub to create the release tarball, then compute sha256
echo "Step 2: Waiting for GitHub to make the tarball available ..."
MAX_ATTEMPTS=12
WAIT_SECONDS=5
SHA256=""

for attempt in $(seq 1 $MAX_ATTEMPTS); do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -L "$TARBALL_URL")
    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "  Tarball available (attempt $attempt). Computing sha256 ..."
        SHA256=$(curl -sL "$TARBALL_URL" | shasum -a 256 | awk '{print $1}')
        break
    fi
    echo "  Not ready yet (HTTP $HTTP_STATUS). Waiting ${WAIT_SECONDS}s ... (attempt $attempt/$MAX_ATTEMPTS)"
    sleep "$WAIT_SECONDS"
done

if [[ -z "$SHA256" ]]; then
    echo "Error: Tarball not available after $((MAX_ATTEMPTS * WAIT_SECONDS))s."
    echo "URL: $TARBALL_URL"
    echo "You may need to create the release manually on GitHub, then re-run this script."
    exit 1
fi

echo "  sha256: $SHA256"
echo ""

# Step 3: Generate macstack.rb from the template, replacing placeholders
echo "Step 3: Updating Homebrew formula from template ..."
sed -e "s|<VERSION-PLACEHOLDER>|${VERSION}|g" \
    -e "s|<SHA256-PLACEHOLDER>|${SHA256}|g" \
    "$TEMPLATE" > "$FORMULA"
echo "  Formula written to $FORMULA"
echo ""

# Step 4: Commit the updated formula in the homebrew-macstack repo
echo "Step 4: Committing formula update ..."
cd "$FORMULA_REPO"
git add Formula/macstack.rb
git commit -m "Bump macstack to $VERSION"
echo "  Committed."
echo ""

# Step 5: Push the formula repo
echo "Step 5: Pushing homebrew-macstack ..."
git push
echo "  Pushed."
echo ""

echo "=== Release $VERSION complete! ==="

# Step 6: Update local MacStack
echo ""
echo "Step 6: Updating local MacStack ..."
cd "$(brew --repository nohype-ai/macstack)" && git pull
brew upgrade macstack
echo "This version of MacStack is now installed: $(brew list --versions macstack)"
