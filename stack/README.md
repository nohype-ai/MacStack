# The Stack

📜 This folder defines your actual stack. It holds everything you may want to customize. This includes code (like scripts and JSON) as well as "infrastructure as documentation".

## Inputs
🎯 Some of the files here can be direct inputs to the Mac Stack update process that you run via `mack update` or `update`. But all of them are optional:

| Input | Description |
|------|-------------|
| [macstack.json](macstack.json) | Basic configuration options |
| [zshrc.sh](zshrc.sh) | `mack update` makes this sourced from `~./zshrc` |
| [Brewfile](Brewfile) | `mack update` updates/installs listed packages |
| [update.sh](update.sh) | `mack update` executes it |
| [git/repos-folder-template/](git/repos-folder-template/) | A template for the content of the `git.repos_folder` defined in [macstack.json](macstack.json). Each folder in the template may contain a `git-repos.txt` listing URLs of intended repos in that folder. `mack update` will attempt to clone/sync your repos based on the template. |
| [zed/](zed/) and [vscode/](vscode/) | Contain json files that will be restored during `mack update` if `"restore_ide_settings": true` in [macstack.json](macstack.json) |
