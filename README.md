# MacStack

Setup and update the tech stack on your Mac with one command, based on your stack configuration:
  * 🐚 Shell customizations (prompt, paths, functions, aliases, environment)
  * 🐙 Global git configuration
  * 📰 Fonts
  * ⌨️ Command line tools (like `brew`, `git`, `pyenv`, `python`, `claude-code`)
  * 🍏 Graphical apps (including Mac App Store apps)
  * 🤖 Settings and permissions of AI agents (Gemini CLI, OpenCode, Cursor CLI)
  * ⚙️ Settings and keybindings for Zed and most VS Code based IDEs
  * 🧩 Extensions for VS Code based IDEs
  * 📂 git repositories (clone, sync, list issues)
  
## Get Started

1. Install and configure MacStack (also installs Homebrew if absent):
    ```bash
    curl -fsSL https://macstack.dev/install.sh | zsh
    ```
2. Configure your stack in your chosen stack folder. An example is the [Nohype AI Stack](https://github.com/nohype-ai/NohypeAIStack/tree/main/stack)
3. If your stack includes Mac App Store apps, [connect your iCloud account](https://support.apple.com/en-us/102314)
4. Apply your stack configuration by running `mack update` or simply `update`
   
> Note: Whether you want to set up a fresh Mac or want to repeatedly update your established Mac, `mack update` is idempotent and works for both cases. That means it's safe to use and only overwrites things you define in your stack. It preserves everything else – even individual pre-existing entries in dotfiles.

## What Does `mack update` Do?

### Generally
* 🐚 Ensure `~/.zshrc` loads (sources) the MacStack shell customizations
* 🍺 Update Homebrew itself
* 🍺 Update Homebrew packages that were already installed
* 🍺 Clean up Homebrew system: delete old package versions and cache
* 🐙 Ensure a `~/.gitignore_global` exists
* 🐙 Set necessary global git settings plus some basic best-practice ones in `~/.gitconfig`.
* 🍏 Make `mack` command available system-wide, offering several subcommands, including:
   - `mack update` (or just `update`): trigger this whole update process
   - `mack help` (or just `mack`): show all available `mack` commands

### Based On Your Stack
Here is what `mack update` does wherever it finds the respective inputs in your stack configuration folder.

**All these configuration files and folders in your stack are optional**. You can add what you want when you want it:
* ⚙️ `macstack.json`: Load the contained basic configuration options, based on [this JSON schema](scripts/stack_config/macstack.schema.json)
* 🐚 `bin/`: Add it to `PATH` so you can place your custom commands there (scripts, binaries)
* 🐚 `zshrc.sh`: Ensure it gets sourced from `~/.zshrc` to apply your shell customizations
* 🍺 `Brewfile`: Ensure all declared Homebrew packages are installed
    - 📰 Fonts
    - ⌨️ Command line tools
    - 🍏 Mac App Store apps
    - 🧩 VS Code extensions
* 🐙 `macstack.json`: Apply the contained personal global git settings to `~/.gitconfig`
* 📜 `update.sh`: Run this custom update step
* ⚙️ `zed/*`: Update configuration of Zed
  * `zed/settings.json`
  * `zed/keymap.json`
* ⚙️ `vscode/*`: Update configuration of VS Code, Cursor, Antigravity, Kiro, Windsurf, VSCodium
  * `vscode/settings.json`
  * `vscode/keybindings.json`
* 🤖 `ai/coding/*`: Update AI coding agent configurations
  * Cursor CLI, Cursor IDE
    - `ai/coding/cursor/cli-config_template.json`
      - ⚠️ Don't simply copy your whole `~/.cursor/cli-config.json` here since that contains semi-sensitive infos
    - `ai/coding/cursor/rules/*`
  * Gemini CLI
    - `ai/coding/gemini/settings.json`
    - `ai/coding/gemini/policies/*`
  * OpenCode, OpenCode Desktop
    - `ai/coding/opencode/opencode.json`
* 📁 `git/repos-folder-template`: Clone/sync git repos based on this template, then report which repos need manual attention
    - Template defines content of this folder: `git.repos_folder` defined in `macstack.json`
    - Each folder in the template may contain a `git-repos.txt` listing URLs of intended repos in that folder

## To Do

* MacStack itself must be excluded from brew-clip
* At this point the basic behaviour/usage stands -> Make website viable!!!
* command for creating a new stack (`mack init`) as baseline from the current system or from template or from a mixture where the template is only used for components that cannot be retrieved from- or are not present in the current system
  * If necessary, add reasonable example stack or illustrative stack template
* Integrate knowledge base from cloud folder into this repo's /documentation folder and into my stack, dissolve the external knowledge base entirely since I never tap into it anymore
* Review what should move from Nohype AI stack into MacStack itself. For example right now, macstack is an entry in the Nohype AI Brewfile, shouldn't macstack keep itself alive? there are also other elements in the Nohype AI stack that are general enough or even essential to MacStack.
* bring the other commands beyond `mack` from bin folder into `mack` and alias them, document the other commands
* explore idea of a "macstack registry" where people can register and browse and copy stacks, also any personal stack definition could be anchored in a registry stack (point to that) as the baseline default, and the personal stack itself would only define overrides, similar to how user settings in an IDE override some things but use the defaults otherwise ...
* [Setup default SSH key](documentation/feature_plans/ssh/) (for GitHub, GitLab etc.)
* Review whether we should rather use mise for managing dev tools that require further version management and benefit from mise features. Apparently mise also offers some declarative capabilities for global tool managament (~/.config/mise/mise.toml ...)
* The script for force adopting apps into Homebrew is essentially a PoC fix of our regular update procedure which apparently does not bring many casks properly into Homebrew if that software (mostly GUI apps) was already installed on the system outside of Homebrew. We should bring those checks into the regular update procedure.
* System (and app-) settings (likely via Ansible? App settings via [mackup](https://github.com/lra/mackup)?)
* Feature requests:
   * integrate repo based password management
