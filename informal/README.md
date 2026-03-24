# Informal Stack ("Infrastructure as Documentation")

The part of the stack that can not be declared as code is documented in this folder.

## Helper Apps

- [MagicMouseTap](https://www.magicmousetap.com/): "tap to click" on magic mouse
  * (stored as "MagicMouseMenuApp.dmg" in iCloud (and not in repo) since it's neither available via Homebrew nor free ...)
- [SoundSource](https://rogueamoeba.com/soundsource/): Volume control (in particular for pro audio interfaces)
- [MWeb](https://www.mweb.im/onemarkdown-help): iOS/macOS markdown editor/renderer with iCloud Drive integration

## Essential System Settings

### Battery

| Option | Value | Comment |
| :--- | :--- | :--- |
| Low Power Mode | Only on Battery | |
| Charging → Charge Limit | 80% | protects battery life when laptop is plugged in most of the time |

### General

| Option | Value | Comment |
| :--- | :--- | :--- |
| Software Update → Automatic Updates → Download new updates when available | Off | |
| Software Update → Automatic Updates → Install macOS updates | Off | |

### Accessibility

| Option | Value | Comment |
| :--- | :--- | :--- |
| Zoom → Use scroll gesture with modifier keys to zoom | On | |

### Appearance

| Option | Value | Comment |
| :--- | :--- | :--- |
| Theme → Icon & widget style | Dark, Auto | |
| Theme → Folder colour | Graphite | |
| Windows → Show scroll bars | Always | because mouse scrolling is not so smooth |
| Windows → Click in the scroll bar to | Jump to the spot that's clicked | |

### Desktop & Dock

| Option | Value | Comment |
| :--- | :--- | :--- |
| Dock position on screen | Left | |
| Show indicators for open applications | Off | I only let open apps remain in Dock |
| Show suggested and ./recent apps in Dock | Off | |
| Mission Control → Automatically rearrange Spaces based on most recent use | Off | |

### Displays

| Option | Value | Comment |
| :--- | :--- | :--- |
| Automatically adjust brightness | Off | |
| Night Shift → Schedule | Custom, 17:00 - 05:00, max warmth | |

### Menu Bar

| Option | Value | Comment |
| :--- | :--- | :--- |
| Automatically Hide and Show the Menu Bar | Never | Quickest interaction |

### Spotlight

| Option | Value | Comment |
| :--- | :--- | :--- |
| Show Related Content | Off | Removes web clutter from search results |
| Results from Apps | Only essential apps like Mail | |
| Results from System | Only Apps, iPhone Apps and Menu Items | |
| Search Privacy... | iCloud Drive, Desktop, Movies, Music, Pictures | Saves main memory, but do not list /Applications or /System here so `mas` and Spotlight can find all apps |

### Wallpaper

| Option | Value | Comment |
| :--- | :--- | :--- |
| Screen Saver... → Start Screen Saver... | Never | |

### Lock Screen

| Option | Value | Comment |
| :--- | :--- | :--- |
| Turn display off on battery when inactive | Never | |
| Turn display off on power adapter when inactive | Never | |
| Require password after screen saver begins or display is turned off | After 15 minutes | |

### Privacy & Security

| Option | Value | Comment |
| :--- | :--- | :--- |
| Full Disk Access | Enable Terminal, IDEs etc. | |

### Keyboard

| Option | Value | Comment |
| :--- | :--- | :--- |
| Adjust keyboard brightness in low light | Off | |
| Keyboard navigation | On | |
| Keyboard Shortcuts... → Windows → Arrange → Arrange Left and Right | ⌃⌘→ | |
| Keyboard Shortcuts... → Windows → Arrange → Arrange Right and Left | ⌃⌘← | |
| Keyboard Shortcuts... → Windows → Arrange → Arrange Top and Bottom | ⌃⌘↑ | |
| Keyboard Shortcuts... → Windows → Arrange → Arrange Bottom and Top | ⌃⌘↓ | |
| Keyboard Shortcuts... → App Shortcuts → All Applications | Show Next Tab, ⌥⌘→ | |
| Keyboard Shortcuts... → App Shortcuts → All Applications | Show Previous Tab, ⌥⌘← | |
| Dictation | On | |
| Languages | English (US), German (Germany) | Because these are supported, it will download models for local dictation inference |
| Shortcut | Press Either Command Key Twice | |

### Trackpad

| Option | Value | Comment |
| :--- | :--- | :--- |
| Point & Click → Tracking Speed | Fastest | |
| Point & Click → Tap to Click | On | |