#!/usr/bin/env zsh

echo "🐙 Checking git repos ..."

# Ensure repos folder exists
REPOS_FOLDER="$HOME/Desktop/Repos/nohype-ai"
mkdir -p "$REPOS_FOLDER"

# Define repos to check: "subfolder;repo"
SUBFOLDERS_REPOS=(
    # Apps
    "apps;aiOS"
    "apps;Codeface"
    "apps;Flowlist"
    "apps;iMember"
    "apps;Moovees"
    "apps;Paretospeak"
    "apps;Portfolio"
    "apps;PortfolioOLD"
    "apps;xHale"
    
    # Libraries
    "libraries;CloudKid"
    "libraries;FoundationToolz"
    "libraries;GetLaid"
    "libraries;LSPService"
    "libraries;LSPServiceKit"
    "libraries;SwiftAI"
    "libraries;SwiftLSP"
    "libraries;SwiftNodes"
    "libraries;SwiftObserver"
    "libraries;SwiftUINodes"
    "libraries;SwiftUIToolz"
    "libraries;SwiftUIToolzOLD"
    "libraries;SwiftyToolz"

    # Tools
    "tools;CheatSheets"
    "tools;MacStack"

    # Websites
    "websites;codeface-io.github.io"
    "websites;flowlistapp-com.github.io"
    "websites;FlowtoolzWebsiteOLD"
    "websites;github"
    "websites;nohype-ai.github.io"
    "websites;sebastian-cv"
)

for SUBFOLDER_REPO in "${SUBFOLDERS_REPOS[@]}"; do
    # Explicitly split by semicolon into variables
    IFS=";" read -r SUBFOLDER REPO <<< "$SUBFOLDER_REPO"

    # Ensure repo folder exists
    REPO_FOLDER="$REPOS_FOLDER/$SUBFOLDER/$REPO"
    mkdir -p "$REPO_FOLDER"

    # If the repo is not cloned yet
    if [[ ! -d "$REPO_FOLDER/.git" ]]; then
        # Clone the repo
        REPO_URL="https://github.com/nohype-ai/$REPO.git"
        git clone "$REPO_URL" "$REPO_FOLDER"
    fi
done