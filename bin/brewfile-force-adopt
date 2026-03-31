#!/usr/bin/env zsh

# This script forces apps into Homebrew management that were initially installed by other means and thereby were not properly and fully brought into Homebrew. It batch removes unmanaged binaries (preserving user data) and then force re-installs the apps.

# We identify "incomplete/incorrect" installations by checking if `brew list --cask --versions <cask_name>` returns an exit code of 1. This indicates that while the app might exist on disk (e.g. in /Applications), Homebrew does not have a registered receipt or version metadata for it, meaning it cannot manage updates or uninstalls.

# Prepare
set -e  # Exit on any error
BREWFILE="$(realpath "$(dirname "$0")")/Brewfile"

# Check if Brewfile exists
if [ ! -f "$BREWFILE" ]; then
    echo "❌ Error: Brewfile not found at $BREWFILE"
    exit 1
fi

echo "🍺 Scanning Brewfile for unmanaged Casks..."

# Arrays to hold data
declare -a unmanaged_casks
declare -a paths_to_delete

# 1. IDENTIFY STEP
# Loop sequentially to find what needs to be done
while read -r cask_name; do
    # Skip empty lines
    [ -z "$cask_name" ] && continue

    if ! brew list --cask --versions "$cask_name" >/dev/null 2>&1; then
        # It is unmanaged
        unmanaged_casks+=("$cask_name")
        
        # Use a heuristic via brew info to find the artifact name
        # We need to handle spaces in app names (e.g. "Visual Studio Code.app")
        # brew info output format: "Name.app (App)"
        app_name=$(brew info --cask "$cask_name" | grep "(App)" | head -n 1 | sed 's/ (App)//g' | xargs)
        
        # Fallback if grep fails
        if [ -z "$app_name" ]; then
             # Try standard naming (most common fallback)
             # This is risky if we guess wrong, so we only delete if we are SURE it exists
             # and looks like an app.
             true
        else
            target_path="/Applications/$app_name"
            if [ -d "$target_path" ]; then
                paths_to_delete+=("$target_path")
            fi
        fi
    fi
done < <(grep '^\s*cask "' "$BREWFILE" | cut -d '"' -f 2)

# Check if we have work to do
if [ ${#unmanaged_casks[@]} -eq 0 ]; then
    echo "✅ All casks are already managed!"
    exit 0
fi

echo "⚠️  Found ${#unmanaged_casks[@]} unmanaged casks."

# 1.5 CHECK FOR RUNNING PROCESSES
# It is critical to ensure apps are closed before we try to delete them.
echo "🔍 Checking for running applications..."
running_apps=()
for path in "${paths_to_delete[@]}"; do
    # Extract just the App Name without .app extension (e.g. "Visual Studio Code")
    app_name_only=$(basename "$path" .app)
    
    # Check if a process with this name is running (looking for .app path to avoid false positives like system services)
    if pgrep -f "${app_name_only}.app" >/dev/null; then
        running_apps+=("$app_name_only")
    fi
done

if [ ${#running_apps[@]} -gt 0 ]; then
    echo "❌ Error: The following applications are currently running:"
    printf "   - %s\n" "${running_apps[@]}"
    echo "Please QUIT these applications fully (Cmd+Q) and run this script again."
    exit 1
fi

# 2. DELETE STEP (Batch)
if [ ${#paths_to_delete[@]} -gt 0 ]; then
    echo "---------------------------------------------------"
    echo "🗑️  The following unmanaged applications will be removed to allow Homebrew adoption:"
    printf "   - %s\n" "${paths_to_delete[@]}"
    echo "   (Your user data/preferences in ~/Library are PRESERVED)"
    echo "---------------------------------------------------"
    
    echo "🔐 Asking for sudo permission once to remove these old bundles..."
    # We use "${paths_to_delete[@]}" to pass the array elements as separate arguments
    sudo rm -rf "${paths_to_delete[@]}"
    
    if [ $? -eq 0 ]; then
        echo "✅ Cleanup complete."
    else
        echo "❌ Failed to remove files. Aborting."
        exit 1
    fi
else
    echo "ℹ️  No conflicting App bundles found in /Applications. Proceeding to install."
fi

# 3. INSTALL STEP
echo "---------------------------------------------------"
echo "🚀 Starting sequential installation..."

# Turn off exit-on-error for the loop so we can try all of them
set +e
failed_casks=()

for cask in "${unmanaged_casks[@]}"; do
    echo "   👉 Installing $cask (force overwriting leftovers)..."
    if ! brew install --cask --force "$cask"; then
        echo "   ❌ Failed to install $cask"
        failed_casks+=("$cask")
    fi
done

echo "---------------------------------------------------"
if [ ${#failed_casks[@]} -eq 0 ]; then
    echo "🎉 Adoption sequence complete! All apps successfully processed."
else
    echo "⚠️  Adoption complete, but the following apps failed to install:"
    printf "   - %s\n" "${failed_casks[@]}"
    echo "Check the errors above for details."
    exit 1
fi
