# Mac Stack

## What?

Mac Stack allows to update/setup a developer Mac with one command.

It currently covers:
  * 🐚 Shell customizations (prompt, functions, aliases, environment variables)
  * 🐙 Global git configuration
  * 📰 Fonts
  * ⌨️ Command line tools (like `brew`, `git`, `pyenv`, `python`, `claude-code`)
  * 🍏 Graphical apps (including Mac App Store apps)
  * ⚙️ Settings and keybindings for most VS Code based IDEs
  * 🧩 Extensions for VS Code based IDEs
  
### System Configuration

The Mac's automated configuration is determined by these components:
* General variables: [`.env`](.env) file as examplified by [`.env.example`](.env.example)
* Software stack: mostly declared in [`Brewfile`](stack/homebrew/Brewfile)
* Shell customizations: scripts in [`sourced_in_zshrc/`](scripts/sourced_in_zshrc) folder
* Further software setup: [`update_other_software.sh`](scripts/update_other_software.sh)
* VSCode IDE settings: [stack/vscode/settings.json](stack/vscode/settings.json), activation in [`.env`](.env.example), see [`stack/vscode/README.md`](stack/vscode/README.md)

## How?

### 🎯 TLDR

   1. Define your system configuration once by adapting [these components](#system-configuration)
   2. Apply that configuration (repeatedly) by running [`bin/update`](bin/update) (directly or via global `update` command)
   
It's irrelevant whether you've just installed macOS and need to set up this new machine or whether you want to repeatedly update your established machine. The update script is idempotent and works for both cases.

### ✨ First Time System Setup

On a fresh system that may not even have GitHub authentication configured:

1. Make sure your [iCloud account is set up](https://support.apple.com/en-us/102314), so that Mac App Store apps can be installed automatically
2. [Download this repository](https://github.com/codeface-io/mac-stack/archive/refs/heads/master.zip)
3. Copy [`.env.example`](.env.example), name the copy `.env`, customize [`.env`](.env)
   - "dot files" like `.env.example` are hidden by default
   - show/hide them by pressing `Command + Shift + .`
4. _Technically Optional_: Customize any of the other [components listed above](#system-configuration)
   - you probably want to at least adapt or simply delete [`personalize_the_shell.sh`](scripts/sourced_in_zshrc/personalize_the_shell.sh)
5. Run [`./update.sh`](update.sh)

There may be some remaining manual steps to complete your setup:

* If Raycast is part of your setup, [import Raycast settings](stack/raycast/README.md#setup) from your `.rayconfig` file.

### 🧼 Subsequent System Updates

After you have successfully set up the system once:

1. Call this command from anywhere: `update`

## Exact Default Setup

Without customizing anything, the resulting setup will be as follows.

🧼 Note: All included software (already installed or not) will get **UPDATED TO ITS LATEST VERSION**.

1. `brew` (Homebrew itself)
2. `brew` packages that were already installed
3. [`Brewfile`](Brewfile) contents (all software it declares)
   - 🎯 this is the central and largest part of the software stack
4. `brew` system cleaned up
   - deleted old package versions and cache
5. `~/.zshrc` loads (sources) various shell customizations from three files:
   - [`setup_cli_tools.sh`](scripts/sourced_in_zshrc/setup_cli_tools.sh): Necessary setup for CLI tools like `brew` and `pyenv`
   - [`customize_the_shell.sh`](scripts/sourced_in_zshrc/customize_the_shell.sh): General setup including prompt, aliases, functions
   - [`personalize_the_shell.sh`](scripts/sourced_in_zshrc/personalize_the_shell.sh): Highly individual setup, should be adapted or deleted
6. `update`, `brewfile-clip` and `brewfile-force-adopt` commands are available system-wide
   - `update` triggers this whole update process
   - `brewfile-clip` uninstalls all Homebrew packages that are **not** (yet) in [`Brewfile`](Brewfile) as well as orphaned dependencies, caches, old package versions and cask installers.
   - `brewfile-force-adopt` forces apps to be managed by Homebrew if they currently are not
7. `~/.gitconfig` (global git config)
   - necessary parameters plus some basic best-practice ones
   - other pre-existing parameters are preserved
   - default `~/.gitignore_global` created if none existed yet
8. `python` installed via `uv`
9. `litellm` installed via `uv`
10. `markitdown` installed via `uv`
    - required by [`unveil`](scripts/sourced_in_zshrc/customize_the_shell.sh) function
11. IDE settings restored (overwritten) from backup if `VSCODE_SETTINGS_RESTORE` is set `true` in [`.env`](.env) file.

## To Do

* [Setup default SSH key](documentation/feature_plans/ssh/) (for GitHub, GitLab etc.)
* review how the commands/functions in `customize_the_shell.sh` are integrated ... what would be best practice? should we rather have separate .sh files or unix executables and add our own path to `$PATH`?
* Review whether we should rather use mise for managing dev tools that require further version management and benefit from mise features. Apparently mise also offers some declarative capabilities for global tool managament (~/.config/mise/mise.toml ...)
* The script for force adopting apps into Homebrew is essentially a PoC fix of our regular update procedure which apparently does not bring many casks properly into Homebrew if that software (mostly GUI apps) was already installed on the system outside of Homebrew. We should bring those checks into the regular update procedure.
* Flutter and Dart (via fvm or mise)
* System (and app-) settings (likely via Ansible?)
* Feature requests:
   * mechanism for translating current setup as starting point to mac stack. for initial adoption and getting started (fresh baseline based on generated brewfile and ideally mostly clean scripts/zshrc as well)
   * integrate repo based password management
* If Mac Stack is supposed to be truly open-source and easily usable for many people, we need to somehow separate Mac Stack as a universal system from user-specific setup configuration. This would probably also require separate repos ...
