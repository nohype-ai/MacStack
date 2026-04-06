# MacStack

## What?

Setup and update the tech stack on a Mac with one command, based on config as code:
  * 🐚 Shell customizations (prompt, paths, functions, aliases, environment)
  * 🐙 Global git configuration
  * 📰 Fonts
  * ⌨️ Command line tools (like `brew`, `git`, `pyenv`, `python`, `claude-code`)
  * 🍏 Graphical apps (including Mac App Store apps)
  * ⚙️ Settings of coding agents (Gemini CLI, OpenCode, Cursor CLI)
  * ⚙️ Settings and keybindings for Zed and most VSCode based IDEs
  * 🧩 Extensions for VSCode based IDEs
  * 📂 git repositories (clone, sync, list issues)
  
## How?

On a fresh system that may not even have GitHub authentication configured:

1. Make sure your [iCloud account is set up](https://support.apple.com/en-us/102314), so that Mac App Store apps can be installed automatically
2. [Download this repository](https://github.com/nohype-ai/MacStack/archive/refs/heads/master.zip)
3. Customize any of the components in of your [stack/](stack/)
4. Apply your config by running `bin/mack update`.

After you've run `bin/mack update` once you can now trigger repeated updates via the global `mack update` command (or just `update`).
   
It's irrelevant whether you've just installed macOS and need to set up this new machine or whether you want to repeatedly update your established machine. The update script is idempotent and works for both cases. That means MacStack is safe to use and does not overwrite or delete things it does not define in its stack – not even any entries in pre-existing dot files.

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
   - [`zshrc.sh`](stack/zshrc.sh): Your indiviual part of the shell customization
6. `mack` is available system-wide, offering several commands, including:
   - `mack update` (or just `update`): trigger this whole update process
   - `mack help` (or just `mack`): show all available `mack` commands 
7. `~/.gitconfig` (global git config)
   - necessary parameters plus some basic best-practice ones
   - other pre-existing parameters are preserved
   - default `~/.gitignore_global` created if none existed yet
8. Further installations specific to your stack in [`update.sh`](stack/update.sh)
9. IDE settings restored (overwritten) from backup if `restore_ide_settings` is set `true` in [`macstack.json`](stack/macstack.json) file.

## To Do

* Settings updates for Gemini CLI and OpenCode are currently not idempotent as they just overwrite the existing json settings files. We could either work with templates that get merged into the target (as we had to do for Cursor CLI) or deactivate these updates by default via flag in macstack.json (as we did for the IDE settings updates). I sense we should always merge and even remove the necessity for the IDE settings update flag ...
* Integrate knowledge base from cloud folder into this repo's /documentation folder and into my stack, dissolve the external knowledge base entirely since I never tap into it anymore
* Separate MacStack as a universal system from user-specific setup configuration
  * let the mack command dynamically retrieve the actual path to the stack (~/.config/macstack ?, ask user?, look for example stack? allow pointing to stack repo on github? etc ...)
  * move stack definition to distinct repo
  * turn stack in this repo into reasonable example stack / illustrative stack template
  * install script (+ curl command on website)
  * distribute via Homebrew
  * command for creating a new stack as baseline from the current system
* bring the other commands beyond `mack` from bin folder into `mack` and alias them, document the other commands
* explore idea of a "macstack registry" where people can register and browse and copy stacks, also any personal stack definition could be anchored in a registry stack (point to that) as the baseline default, and the personal stack itself would only define overrides, similar to how user settings in an IDE override some things but use the defaults otherwise ...
* [Setup default SSH key](documentation/feature_plans/ssh/) (for GitHub, GitLab etc.)
* Review whether we should rather use mise for managing dev tools that require further version management and benefit from mise features. Apparently mise also offers some declarative capabilities for global tool managament (~/.config/mise/mise.toml ...)
* The script for force adopting apps into Homebrew is essentially a PoC fix of our regular update procedure which apparently does not bring many casks properly into Homebrew if that software (mostly GUI apps) was already installed on the system outside of Homebrew. We should bring those checks into the regular update procedure.
* Flutter and Dart (via fvm or mise)
* System (and app-) settings (likely via Ansible?)
* Feature requests:
   * integrate repo based password management
