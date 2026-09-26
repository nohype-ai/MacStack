## System Settings

(the app formerly known as "System Preferences") stores its settings across:

1. **`~/Library/Preferences/.GlobalPreferences.plist`** — Appearance, language, keyboard behavior, trackpad/mouse scaling, text substitutions

2. **`~/Library/Preferences/com.apple.dock.plist`** — Dock & Desktop settings (part of System Settings)

3. **`~/Library/Preferences/com.apple.controlcenter.plist`** — Control Center settings

4. **`~/Library/Preferences/com.apple.Accessibility.plist`** — Accessibility settings

5. **`~/Library/Preferences/com.apple.HIToolbox.plist`** — Keyboard input sources

6. **`/Library/Preferences/` (system-wide, requires sudo)** — Login window, time zone, network settings

7. **Various `com.apple.*` plists** — Each System Settings pane often maps to a specific domain (e.g., `com.apple.screensaver`, `com.apple.spaces`, `com.apple.AppleMultitouchTrackpad`)

So there's no single "System Settings" plist—Apple splits it by functional area. The `.GlobalPreferences.plist` handles the most common cross-cutting settings (appearance, input, locale), but each System Settings pane typically writes to its own `com.apple.*` domain.

## Verified Plist Files

All files below exist in `~/Library/Preferences/`:

| System Settings Pane | Plist File(s) |
|---------------------|---------------|
| Appearance, Language, Input | `.GlobalPreferences.plist` |
| Accessibility | `com.apple.Accessibility.plist`, `com.apple.universalaccess.plist` |
| Control Center | `com.apple.controlcenter.plist` |
| Siri | `com.apple.Siri.plist`, `com.apple.assistant.plist` |
| Spotlight | `com.apple.Spotlight.plist` |
| Desktop & Dock | `com.apple.dock.plist`, `com.apple.spaces.plist` |
| Displays | `com.apple.CoreGraphics.plist` |
| Wallpaper | `com.apple.wallpaper.plist` |
| Screen Saver | `com.apple.screensaver.plist` |
| Lock Screen | `com.apple.loginwindow.plist` |
| Keyboard | `com.apple.HIToolbox.plist` |
| Keyboard Shortcuts | `com.apple.symbolichotkeys.plist` |
| Trackpad | `com.apple.AppleMultitouchTrackpad.plist`, `com.apple.driver.AppleBluetoothMultitouch.trackpad.plist` |
| Mouse | `com.apple.AppleMultitouchMouse.plist`, `com.apple.driver.AppleBluetoothMultitouch.mouse.plist` |
| Printers | `com.apple.print.custompresets.plist` |
| Focus | `com.apple.donotdisturbd.plist` |
| Notifications | `com.apple.ncprefs.plist` |
| Sharing | `com.apple.sharingd.plist` |
| Bluetooth | `com.apple.bluetooth.plist` |
| Software Update | `com.apple.SoftwareUpdate.plist` |
| Date & Time (menu bar clock) | `com.apple.menuextra.clock.plist` |
| Finder | `com.apple.finder.plist` |

**Note:** Sound settings don't have a dedicated plist in `~/Library/Preferences/`.

## Example of more difficult setting in Application Support

wallpaper set to solid black color is actually stored in `/Users/seb/Library/Application Support/com.apple.wallpaper/Store/Index.plist`

in that file under both paths:
- AllSpacesAndDisplays.Desktop.Content.Choices[0].Configuration
- SystemDefault.Desktop.Content.Choices[0].Configuration

The value in `Configuration` is not a simple hex value—Apple uses a serialized object format. The value is a base64-encoded bplist (binary plist) containing the color "black" as a named system color. 

runnning this:
```
echo "YnBsaXN0MDDSAQICA1R0eXBlW3N5c3RlbUNvbG9y0QQFVWJsYWNr0AgNEh4hJwAAAAAAAAEBAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAo" | base64 -d | plutil -p - 
```
... outputs this:
```
{
  "systemColor" => {
    "black" => {
    }
  }
  "type" => "systemColor"
}
```

that actual base64 value can be read via plutil: `plutil -extract SystemDefault xml1 -o - ~/Library/Application\ Support/com.apple.wallpaper/Store/Index.plist`

potential script to set this programmatically:

```bash
#!/bin/bash

# 1. Create the color config as binary plist
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>type</key>
    <string>systemColor</string>
    <key>systemColor</key>
    <dict>
        <key>black</key>
        <dict/>
    </dict>
</dict>
</plist>' | plutil -convert binary1 -o /tmp/color_config.bplist -

# 2. Import into wallpaper plist
PLIST=~/Library/Application\ Support/com.apple.wallpaper/Store/Index.plist

/usr/libexec/PlistBuddy -c "Import :SystemDefault:Desktop:Content:Choices:0:Configuration /tmp/color_config.bplist" "$PLIST"

/usr/libexec/PlistBuddy -c "Import :AllSpacesAndDisplays:Desktop:Content:Choices:0:Configuration /tmp/color_config.bplist" "$PLIST"

# 3. Clean up
rm /tmp/color_config.bplist

# 4. Restart wallpaper service (may be needed)
killall WallpaperAgent 2>/dev/null
```

## CLI Tools for Setting System Settings

There aren't many lightweight solutions like CLI tools that give unified access to system settings across the involved plist files:
* https://github.com/dsully/macos-defaults
