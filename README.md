# MacStack

## What?

Setup and update the tech stack on a Mac with one command, based on a custom stack config:
  * 🐚 Shell customizations (prompt, paths, functions, aliases, environment)
  * 🐙 Global git configuration
  * 📰 Fonts
  * ⌨️ Command line tools (like `brew`, `git`, `pyenv`, `python`, `claude-code`)
  * 🍏 Graphical apps (including Mac App Store apps)
  * 🤖 Settings and permissions of AI agents (Gemini CLI, OpenCode, Cursor CLI)
  * ⚙️ Settings and keybindings for Zed and most VSCode based IDEs
  * 🧩 Extensions for VSCode based IDEs
  * 📂 git repositories (clone, sync, list issues)
  
## How?

1. Install and configure MacStack (also installs Homebrew if absent):
    ```bash
    curl -fsSL https://macstack.dev/install.sh | zsh
    ```
2. Configure your stack in your chosen stack folder. An example is the [Nohype AI Stack](https://github.com/nohype-ai/NohypeAIStack/tree/main/stack)
3. If your stack includes Mac App Store apps, [connect your iCloud account](https://support.apple.com/en-us/102314)
4. Apply your stack configuration by running `mack update` or simply `update`
   
> Note: Whether you've just installed macOS and need to set up this new machine or want to repeatedly update your established machine, `mack update` is idempotent and works for both cases. That means it's safe to use and only overwrites things you define in your stack. It preserves everything else – even individual pre-existing entries in dotfiles.

## The Update Process

### 1. What `mack update` Always Does
* 🐚 Ensure `~/.zshrc` loads (sources) the MacStack shell customizations
* 🍺 Update Homebrew itself
* 🍺 Update Homebrew packages that were already installed
* 🍺 Clean up Homebrew system: delete old package versions and cache
* 🐙 Ensure a `~/.gitignore_global` exists
* 🐙 Set necessary global git settings plus some basic best-practice ones in `~/.gitconfig`.
* 🍏 Make `mack` command available system-wide, offering several subcommands, including:
   - `mack update` (or just `update`): trigger this whole update process
   - `mack help` (or just `mack`): show all available `mack` commands

### 2. What `mack update` Does Based On Your Stack
* 🐚 Ensure your shell customization in `stack/zshrc.sh` gets sourced from `~/.zshrc`
* 🍺 Ensure all Homebrew packages declared in `stack/Brewfile` are installed, this is the central and largest part of your stack
* 🐙 Set personal global git settings in `~/.gitconfig` if defined in `stack/macstack.json`
* 📜 Run your custom update step: `stack/update.sh`
* ⚙️ Restore (overwrite) IDE settings and keybindings if `restore_ide_settings` is `true` in `stack/macstack.json`
    - `stack/zed`
    - `stack/vscode`: Applied to VS Code, Cursor, Antigravity, Kiro, Windsurf and VSCodium
* 🤖 Restore AI Agent configurations
    - `stack/ai/cursor`: settings, rules
    - `stack/ai/gemini`: settings, policies
    - `stack/ai/opencode`: settings
* 📁 Clone/sync git repos based on `stack/git/repos-folder-template`, then report which repos need manual attention
    - Template defines content of this folder: `git.repos_folder` defined in `macstack.json`
    - Each folder in the template may contain a `git-repos.txt` listing URLs of intended repos in that folder

## To Do

* Settings updates for Gemini CLI and OpenCode are currently not idempotent as they just overwrite the existing json settings files. We could either work with templates that get merged into the target (as we had to do for Cursor CLI) or deactivate these updates by default via flag in macstack.json (as we did for the IDE settings updates). I sense we should always merge and even remove the necessity for the IDE settings update flag ...
* Add reasonable example stack / illustrative stack template
* command for creating a new stack (`mack init`) as baseline from the current system or from template or from a mixture where the template is only used for components that cannot be retrieved from- or are not present in the current system
* At this point the basic behaviour/usage stands -> Make website viable!!!
* Integrate knowledge base from cloud folder into this repo's /documentation folder and into my stack, dissolve the external knowledge base entirely since I never tap into it anymore
* bring the other commands beyond `mack` from bin folder into `mack` and alias them, document the other commands
* explore idea of a "macstack registry" where people can register and browse and copy stacks, also any personal stack definition could be anchored in a registry stack (point to that) as the baseline default, and the personal stack itself would only define overrides, similar to how user settings in an IDE override some things but use the defaults otherwise ...
* [Setup default SSH key](documentation/feature_plans/ssh/) (for GitHub, GitLab etc.)
* Review whether we should rather use mise for managing dev tools that require further version management and benefit from mise features. Apparently mise also offers some declarative capabilities for global tool managament (~/.config/mise/mise.toml ...)
* The script for force adopting apps into Homebrew is essentially a PoC fix of our regular update procedure which apparently does not bring many casks properly into Homebrew if that software (mostly GUI apps) was already installed on the system outside of Homebrew. We should bring those checks into the regular update procedure.
* System (and app-) settings (likely via Ansible? App settings via [mackup](https://github.com/lra/mackup)?)
* Feature requests:
   * integrate repo based password management
