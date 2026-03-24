# Informal Stack ("Infrastructure as Documentation")

The part of the stack that can not be declared as code is documented in this folder.

## Helper Apps

- [MagicMouseTap](https://www.magicmousetap.com/): "tap to click" on magic mouse
  * (stored as "MagicMouseMenuApp.dmg" in iCloud (and not in repo) since it's neither available via Homebrew nor free ...)
- [SoundSource](https://rogueamoeba.com/soundsource/): Volume control (in particular for pro audio interfaces)
- [MWeb](https://www.mweb.im/onemarkdown-help): iOS/macOS markdown editor/renderer with iCloud Drive integration

## Essential System Settings

### Battery
* Low Power Mode: Only on Battery
* Charging → Charge Limit: 80%
  - (protects battery life when laptop is plugged in most of the time)

### General
* Software Update → Automatic Updates
  - Download new updates when available: Off
  - Install macOS updates: Off

### Accessibility
* Zoom → Use scroll gesture with modifier keys to zoom: On

### Appearance
* Theme → Icon & widget style: Dark, Auto
* Theme → Folder colour: Graphite
* Windows → Show scroll bars: Always
* Windows → Click in the scroll bar to: Jump to the spot that's clicked

### Desktop & Dock
* Dock position on screen: Left
* Show indicators for open applications: Off
* Show suggested and ./recent apps in Dock: Off
* Mission Control → Automatically rearrange Spaces based on most recent use: Off

### Displays
* Automatically adjust brightness: Off
* Night Shift → Schedule: Custom, 17:00 - 05:00, max warmth

### Menu Bar
* Automatically Hide and Show the Menu Bar: Never

### Spotlight
* Show Related Content: Off
* Results from Apps: Enable only essential apps like Mail
* Results from System: Activate only Apps, iPhone Apps and Menu Items
* Search Privacy...: (this saves main memory, but do not list /Applications or /System here so `mas` and Spotlight can find all apps)
  - iCloud Drive
  - Desktop
  - Movies
  - Music
  - Pictures

### Wallpaper
* Screen Saver... → Start Screen Saver...: Never

### Lock Screen
* Turn display off on battery when inactive: Never
* Turn display off on power adapter when inactive: Never
* Require password after screen saver begins or display is turned off: After 15 minutes

### Privacy & Security
* Full Disk Access: Enable Terminal, IDEs etc.

### Keyboard
* Adjust keyboard brightness in low light: Off
* Keyboard navigation: On
* Keyboard Shortcuts... → Windows → Arrange
  - Arrange Left and Right: ⌃⌘→
  - Arrange Right and Left: ⌃⌘←
  - Arrange Top and Bottom: ⌃⌘↑
  - Arrange Bottom and Top: ⌃⌘↓
* Keyboard Shortcuts... → App Shortcuts
  - All Applications: Show Next Tab: ⌥⌘→
  - All Applications: Show Previous Tab: ⌥⌘←
* Dictation: On
* Languages: English (US), German (Germany)
* Shortcut: Press Either Command Key Twice

### Trackpad
* Point & Click → Tracking Speed: Fastest
* Point & Click → Tap to Click: On