# Informal Stack ("Infrastructure as Documentation")

The part of the stack that can not be declared as code is documented in this folder.

## Accounts

* IDE: [dashboard.zed.dev](https://dashboard.zed.dev) (via GitHub)
  - login unlocks tab completion
* Provider: [opencode.ai/zen](https://opencode.ai/zen) (via GitHub)
  - model variety without markup
  - can be used in any tool/agent, not just in OpenCode
  - not quite as cheap as DeepInfra
* Provider: [deepinfra.com](https://deepinfra.com)
  - cheap and fast inference provider for open models
* Provider: [console.x.ai](https://console.x.ai) (via X)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)
* Provider: [openrouter.ai](https://openrouter.ai/workspaces/default) (via GitHub)
  - does absolutely not work reliably with OpenCode in Zed, only outside Zed (Terminal)
  - usable rate limits on free models when funded with 10$
  - 5.5% markup on paid models

## Helper Apps

- [MagicMouseTap](https://www.magicmousetap.com/): "tap to click" on magic mouse
  * (stored as "MagicMouseMenuApp.dmg" in iCloud (and not in repo) since it's neither available via Homebrew nor free ...)
- [SoundSource](https://rogueamoeba.com/soundsource/): Volume control (in particular for pro audio interfaces)
- [MWeb](https://www.mweb.im/onemarkdown-help): iOS/macOS markdown editor/renderer with iCloud Drive integration

## Essential System Settings

| Category | Option | Value(s) | Comment |
| :--- | :--- | :--- | :--- |
| Battery | Low Power Mode | Only on Battery | |
|  | Charging → Charge Limit | 80% | protects battery life when laptop is plugged in most of the time |
| General | Software Update → Automatic Updates → Download new updates when available | Off | |
|  | Software Update → Automatic Updates → Install macOS updates | Off | |
| Accessibility | Zoom → Use scroll gesture with modifier keys to zoom | On | |
| Appearance | Theme → Icon & widget style | Dark, Auto | |
|  | Theme → Folder colour | Graphite | |
|  | Windows → Show scroll bars | Always | because mouse scrolling is not so smooth |
|  | Windows → Click in the scroll bar to | Jump to the spot that's clicked | |
| Desktop & Dock | Dock position on screen | Left | |
|  | Show indicators for open applications | Off | I only let open apps remain in Dock |
|  | Show suggested and ./recent apps in Dock | Off | |
|  | Mission Control → Automatically rearrange Spaces based on most recent use | Off | |
|  | Hot Corners... | Disable all | |
| Displays | Automatically adjust brightness | Off | |
|  | Night Shift → Schedule | Custom, 17:00 - 05:00, max warmth | |
| Menu Bar | Automatically Hide and Show the Menu Bar | Never | Quickest interaction |
| Spotlight | Show Related Content | Off | Removes web clutter from search results |
|  | Results from Apps | Only essential apps like Mail | |
|  | Results from System | Only Apps, iPhone Apps and Menu Items | |
|  | Search Privacy... | iCloud Drive, Desktop, Movies, Music, Pictures | Saves main memory, but do not list /Applications or /System here so `mas` and Spotlight can find all apps |
| Wallpaper | Screen Saver... → Start Screen Saver... | Never | |
| Screen Time | Share across devices | Off | iPhone and Mac have different needs for restriction |
| Lock Screen | Turn display off on battery when inactive | Never | |
|  | Turn display off on power adapter when inactive | Never | |
|  | Require password after screen saver begins or display is turned off | After 15 minutes | |
| Privacy & Security | Full Disk Access | Enable Terminal, IDEs etc. | |
| Keyboard | Adjust keyboard brightness in low light | Off | |
|  | Keyboard navigation | On | |
|  | Keyboard Shortcuts... → Windows → Arrange → Arrange Left and Right | ⌃⌘→ | |
|  | Keyboard Shortcuts... → Windows → Arrange → Arrange Right and Left | ⌃⌘← | |
|  | Keyboard Shortcuts... → Windows → Arrange → Arrange Top and Bottom | ⌃⌘↑ | |
|  | Keyboard Shortcuts... → Windows → Arrange → Arrange Bottom and Top | ⌃⌘↓ | |
|  | Keyboard Shortcuts... → App Shortcuts → All Applications | Show Next Tab, ⌥⌘→ | |
|  | Keyboard Shortcuts... → App Shortcuts → All Applications | Show Previous Tab, ⌥⌘← | |
|  | Dictation | On | |
|  | Languages | English (US), German (Germany) | Because these are supported, it will download models for local dictation inference |
|  | Shortcut | Press Either Command Key Twice | |
| Trackpad | Point & Click → Tracking Speed | Fastest | |
|  | Point & Click → Tap to Click | On | |
