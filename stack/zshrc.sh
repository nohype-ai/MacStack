# MacStack (`mack update`) ensures this script is sourced in ~/.zshrc
# This script allows you to further customize your shell environment

# list folder content with useful options
alias l="ls -Fahl"

# access frequently used folders
export cloud="$HOME/Library/Mobile Documents/com~apple~CloudDocs/iCloud"
alias cdc="cd '$cloud'"

export repos="$HOME/Desktop/Repos"
alias cdr="cd '$repos'"

# Install the latest Xcode version
alias xcode-update="xcodes install --latest"

# Setup antigravity
export PATH="$PATH:$HOME/.antigravity/antigravity/bin"

# d: Opens folder in IDE, opens current folder if none is provided
# "d" stands for: Development environment, Develop, Debug, Display, Dive into, Dig into, Discuss (with AI)
d() {
    local target_dir="${1:-$(pwd)}"

    if [[ -d "$target_dir" ]]; then
        zed "$target_dir"
    else
        echo "🛑 Directory '$target_dir' does not exist"
        return 1
    fi
}

# backup and restore Flowlist (http://www.flowlistapp.com)
bfl() {
    # define what to backup
    sourceFolder="$HOME/Library/Containers/com.flowtoolz.flowlist/Data/Documents/Flowlist-Beta/"

    # define where to store the backup
    destinationFolder="$cloud/FLOWLIST BACKUP/Flowlist-Beta/"

    # update the destination folder, deleting files that aren't anymore in the source folder
    rsync -a --delete $sourceFolder $destinationFolder
}

rfl() {
    # define where the backup is stored
    sourceFolder="$cloud/FLOWLIST BACKUP/Flowlist-Beta/"

    # define what to restore
    destinationFolder="$HOME/Library/Containers/com.flowtoolz.flowlist/Data/Documents/Flowlist-Beta/"

    # update the destination folder, deleting files that aren't anymore in the source folder
    rsync -a --delete $sourceFolder $destinationFolder
}

find-flowlist-duplicates() {
    flowlistItemsFolder="$HOME/Library/Containers/com.flowtoolz.flowlist/Data/Documents/Flowlist-Beta/Items"
    find $flowlistItemsFolder -name "* *.json"
}

delete-flowlist-duplicates() {
    flowlistItemsFolder="$HOME/Library/Containers/com.flowtoolz.flowlist/Data/Documents/Flowlist-Beta/Items"
    find $flowlistItemsFolder -name "* *.json" -delete
}
