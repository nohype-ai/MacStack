#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create New File in Finder Folder
# @raycast.mode silent

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "new_file.md" }

# Documentation:
# @raycast.author nohype.ai
# @raycast.authorURL nohype.ai

on run argv
	tell application "Finder"
		set currentFolder to target of front window
		set newFile to make new file at currentFolder with properties {name:(item 1 of argv)}
		select newFile
	end tell
end run

