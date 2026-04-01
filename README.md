# Mac Stack

## What?

Mac Stack allows to update/setup a developer Mac with one command, based on a config as code:
  * 🐚 Shell customizations (prompt, functions, aliases, environment variables)
  * 🐙 Global git configuration
  * 📰 Fonts
  * ⌨️ Command line tools (like `brew`, `git`, `pyenv`, `python`, `claude-code`)
  * 🍏 Graphical apps (including Mac App Store apps)
  * ⚙️ Settings and keybindings for most VS Code based IDEs
  * 🧩 Extensions for VS Code based IDEs
  
## How?

On a fresh system that may not even have GitHub authentication configured:

1. Make sure your [iCloud account is set up](https://support.apple.com/en-us/102314), so that Mac App Store apps can be installed automatically
2. [Download this repository](https://github.com/nohype-ai/MacStack/archive/refs/heads/master.zip)
3. Copy [`stack/.env.example`](stack/.env.example), name the copy `.env`, customize [`stack/.env`](stack/.env)
   - ("dotfiles" like `.env.example` are hidden by default. Show/hide them by via `Command + Shift + .`)
4. Customize any of these components in [stack/](stack/) (technically optional):
   * Software stack as declared in [`Brewfile`](stack/Brewfile)
   * Shell customization: [`custom_zshrc_content.sh`](stack/custom_zshrc_content.sh)
   * Further update script: [`custom_mack_update.sh`](stack/custom_mack_update.sh)
   * VSCode IDE settings: [settings.json](stack/vscode/settings.json)
      * (activation in [`.env`](stack/.env), see [this `README.md`](stack/vscode/README.md))
5. Apply your config by running `bin/mack update`.

After you've run `bin/mack update` once you can now trigger repeated updates via the global `mack update` command (or just `update`).
   
It's irrelevant whether you've just installed macOS and need to set up this new machine or whether you want to repeatedly update your established machine. The update script is idempotent and works for both cases. That means Mac Stack is safe to use and does not overwrite or delete things it does not define in its stack – not even any entries in pre-existing dot files.

## Exact Default Setup

Without customizing anything, the resulting setup will be as follows.

🧼 Note: All included software (already installed or not) will get **UPDATED TO ITS LATEST VERSION**.

1. `brew` (Homebrew itself)
2. `brew` packages that were already installed
3. [`Brewfile`](stack/Brewfile) contents (all software it declares)
   - 🎯 this is the central and largest part of the software stack
4. `brew` system cleaned up
   - deleted old package versions and cache
5. `~/.zshrc` loads (sources) various shell customizations.
   - [`custom_zshrc_content.sh`](stack/custom_zshrc_content.sh): Your indiviual part of the shell customization
6. `mack` is available system-wide
   - `mack update` (or just `update`): trigger this whole update process
   - `mack brew-clip` uninstalls all Homebrew packages that are **not** (yet) in [`Brewfile`](stack/Brewfile) as well as orphaned dependencies, caches, old package versions and cask installers.
   - `mack brew-force` forces apps to be managed by Homebrew if they currently are not
7. `~/.gitconfig` (global git config)
   - necessary parameters plus some basic best-practice ones
   - other pre-existing parameters are preserved
   - default `~/.gitignore_global` created if none existed yet
8. Further installations specific to your stack in [`custom_mack_update.sh`](stack/custom_mack_update.sh)
9. IDE settings restored (overwritten) from backup if `VSCODE_SETTINGS_RESTORE` is set `true` in [`.env`](stack/.env) file.

## To Do

* [Setup default SSH key](documentation/feature_plans/ssh/) (for GitHub, GitLab etc.)
* Decompose the [stack/](stack/) folder: everything that is part of the Mack Stack process and does not get customized by an individual user should go into [scripts/](scripts/)
* Review whether we should rather use mise for managing dev tools that require further version management and benefit from mise features. Apparently mise also offers some declarative capabilities for global tool managament (~/.config/mise/mise.toml ...)
* The script for force adopting apps into Homebrew is essentially a PoC fix of our regular update procedure which apparently does not bring many casks properly into Homebrew if that software (mostly GUI apps) was already installed on the system outside of Homebrew. We should bring those checks into the regular update procedure.
* Flutter and Dart (via fvm or mise)
* System (and app-) settings (likely via Ansible?)
* Feature requests:
   * mechanism for translating current setup as starting point to mac stack. for initial adoption and getting started (fresh baseline based on generated brewfile and ideally mostly clean scripts/zshrc as well)
   * integrate repo based password management
* If Mac Stack is supposed to be truly open-source and easily usable for many people, we need to somehow separate Mac Stack as a universal system from user-specific setup configuration. This would probably also require separate repos ...
