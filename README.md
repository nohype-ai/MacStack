# MacStack

## What?

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
* 🍺 Ensure all Homebrew packages declared in `stack/Brewfile` are installed
    - 📰 Fonts
    - ⌨️ Command line tools
    - 🍏 Mac App Store apps
    - 🧩 VS Code extensions
* 🐙 Set personal global git settings in `~/.gitconfig` if defined in `stack/macstack.json`
* 📜 Run your custom update step: `stack/update.sh`
* ⚙️ Update IDE settings and keyboard shortcuts
  * Zed
    - `stack/zed/settings.json`
    - `stack/zed/keymap.json`
  * VS Code, Cursor, Antigravity, Kiro, Windsurf, VSCodium
    - `stack/vscode/settings.json`
    - `stack/vscode/keybindings.json`
* 🤖 Update AI Agent configurations
  * Cursor CLI, Cursor IDE
    - `stack/ai/coding/cursor/cli-config_template.json`
      - ⚠️ Don't simply copy your whole `~/.cursor/cli-config.json` here since that contains semi-sensitive infos
    - `stack/ai/coding/cursor/rules/*`
  * Gemini CLI
    - `stack/ai/coding/gemini/settings.json`
    - `stack/ai/coding/gemini/policies/*`
  * OpenCode, OpenCode Desktop
    - `stack/ai/coding/opencode/opencode.json`
* 📁 Clone/sync git repos based on `stack/git/repos-folder-template`, then report which repos need manual attention
    - Template defines content of this folder: `git.repos_folder` defined in `macstack.json`
    - Each folder in the template may contain a `git-repos.txt` listing URLs of intended repos in that folder

## To Do

* Create a script that does the whole release (up to step 5), given a version string.
  * The release is currently documented in `MacStack/release/release.md`.
  * put the script into `MacStack/release/`.
  * assume that the formula repo is in `MacStack/../homebrew-macstack/` (sibling folder of MacStack itself).
  * in the new script, document each step with a clear comment.
  * if you think the sha256 creation has to wait a moment so GitHub has a chance to actually create the release tarball, then let the script wait a moment.
  * How to insert the sha256 value and version string into the `macstack.rb` file: There is also a `macstack_template.rb` which contains the strings "<SHA256-PLACEHOLDER>" and "<VERSION-PLACEHOLDER>". just overwrite `macstack.rb` with a copy of the template in which the placeholders have been replaced.
* At this point the basic behaviour/usage stands -> Make website viable!!!
* command for creating a new stack (`mack init`) as baseline from the current system or from template or from a mixture where the template is only used for components that cannot be retrieved from- or are not present in the current system
  * If necessary, add reasonable example stack or illustrative stack template
* Integrate knowledge base from cloud folder into this repo's /documentation folder and into my stack, dissolve the external knowledge base entirely since I never tap into it anymore
* bring the other commands beyond `mack` from bin folder into `mack` and alias them, document the other commands
* explore idea of a "macstack registry" where people can register and browse and copy stacks, also any personal stack definition could be anchored in a registry stack (point to that) as the baseline default, and the personal stack itself would only define overrides, similar to how user settings in an IDE override some things but use the defaults otherwise ...
* [Setup default SSH key](documentation/feature_plans/ssh/) (for GitHub, GitLab etc.)
* Review whether we should rather use mise for managing dev tools that require further version management and benefit from mise features. Apparently mise also offers some declarative capabilities for global tool managament (~/.config/mise/mise.toml ...)
* The script for force adopting apps into Homebrew is essentially a PoC fix of our regular update procedure which apparently does not bring many casks properly into Homebrew if that software (mostly GUI apps) was already installed on the system outside of Homebrew. We should bring those checks into the regular update procedure.
* System (and app-) settings (likely via Ansible? App settings via [mackup](https://github.com/lra/mackup)?)
* Feature requests:
   * integrate repo based password management
