#!/bin/bash
# git-status.sh
# Usage: ./git-status.sh [root-folder]
#        ./git-status.sh ~/Desktop/Repos

root="${1:-.}"   # use argument or default to current folder

echo "🔍 Scanning for git repositories in: $root"

find "$root" -name .git -type d -prune | sort | while read -r gitdir; do
    repo=$(dirname "$gitdir")
    
    echo -e "\n📁 $repo"
    
    # 1. Local changes (unstaged/staged/untracked)
    if git -C "$repo" status --porcelain | grep -q .; then
        echo "   ⚠️  Has local changes"
    else
        echo "   ✅ Clean (no local changes)"
    fi
    
    # 2. Ahead of remote
    if git -C "$repo" status -sb 2>/dev/null | grep -q "ahead"; then
        ahead=$(git -C "$repo" status -sb | grep -o 'ahead [0-9]*' | cut -d' ' -f2)
        branch=$(git -C "$repo" branch --show-current 2>/dev/null || echo "detached")
        echo "   ↑  Ahead by $ahead commit(s) on $branch → needs push"
    else
        echo "   ✓  Up to date with remote"
    fi
done

echo -e "\n✅ Scan finished."