# Raycast

[Raycast](https://raycast.com/) has emerged as THE productivity helper for macOS, being highly customizable, extensible and covering **all imaginable conveniences** that macOS glaringly lacks, including global hot keys, a functioning emoji picker, window management, and clipboard history.

## Setup

* To set up Raycast on a new machine without a paid Raycast Pro account, the easiest way is to export/import Raycast settings.
* So whenever you changed Raycast settings, remember to export them (Raycast Settings → Advanced → Export). This creates a password protected `.rayconfig` file. Store the file somewhere independent (like in your copy/fork of this repo). And store the password somewhere secure (password manager).
* Then on a new or additional machine, import your Raycast settings from your `.rayconfig` file using the corresponding password. Before that, ensure the scripts are already in the expected location:
   1. Copy the scripts from [`scripts/`](scripts/) to `~/.config/raycast/scripts`
   2. Raycast Settings → Advanced → Import

## Global Hot Keys

* These can be set up in Raycast
* If you have apps in non-standard locations, tell Raycast about it: Raycast Settings → Extension → + → Add Application Directory → select additional directory, for example the Desktop

### My Setup

It makes sense to build global navigation hot keys around the option key. The option key does typically not interfere with the short cuts of apps (which use the command and control keys) and it already is what brings up raycast (option + space).

#### Navigate to: Apps, Web Apps, Workspaces

⌥X for navigating to destination X:

| Destination (Intent) | Shortcut | App / Website / Raycast Action |
|--------|---------|-----|
| AI Assistant | ⌥A | Grok (Safari App) |
| Calendar | ⌥C | Calendar |
| Develop | ⌥D | Zed |
| Email | ⌥E | Mail |
| Find(er) | ⌥F | Finder |
| Git Client | ⌥G | Fork |
| Hear | ⌥H | Podcasts |
| Internet | ⌥I | Safari |
| Listen | ⌥L | Music |
| Listen | ⌥⇧L | YouTube Music URL |
| Messenger | ⌥M | Telegram (Safari App) |
| News | ⌥N | X Pro |
| Outlook | ⌥O | Microsoft Outlook |
| Passwords | ⌥P | Passwords |
| Reminders | ⌥R | Reminders |
| System Settings | ⌥S | System Settings |
| Teams | ⌥T | Microsoft Teams |
| Write | ⌥W | Typora |
| Xcodes | ⌥X | Xcodes App |  
| YouTube | ⌥Y | YouTube Subscriptions (Safari App) |
| Terminal | ⌥⏎ | Terminal |
| Trash | ⌥⌫ | Open Trash |

#### In Active Finder Folder

⌥⇧X for navigation/action X in active Finder folder:

| Intent | Shortcut | Raycast Action |
|--------|---------|-----|
| Develop in folder | ⌥⇧D | Open folder in Zed |
| Create new file in folder | ⌥⇧F | Create new file in folder |
| Write in folder | ⌥⇧W | Open folder in Typora |
| Terminal in folder | ⌥⇧⏎ | Open folder in Terminal |

#### Control Settings and States

⌃X for controlling global settings/states X:

| Intent | Shortcut | Raycast Action |
|--------|---------|-----|
| Control Audio | ⌃A | Toggle SoundSource app (not via Raycast) |
| Switch Dark/Day Mode | ⌃D | Toggle System Appearance |
| Put System to Sleep | ⌃S | System -> Sleep |
| Empty the Trash | ⌃⌫ | Empty Trash |
