#!/usr/bin/env zsh

# You may use this script as a template to personalize your shell. It may reference and set up personal- and user-specific stuff.

# access frequently used folders
export cloud="$HOME/Library/Mobile Documents/com~apple~CloudDocs/iCloud"
alias cdc="cd '$cloud'"

export repos="$HOME/Desktop/Repos"
alias cdr="cd '$repos'"

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