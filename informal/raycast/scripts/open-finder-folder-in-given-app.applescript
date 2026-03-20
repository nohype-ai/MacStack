#!/usr/bin/osascript
on run argv
    set appName to item 1 of argv
    tell application "Finder"
        set folderPath to POSIX path of (target of front window as alias)
    end tell
    do shell script "open -a " & quoted form of appName & " " & quoted form of folderPath
end run