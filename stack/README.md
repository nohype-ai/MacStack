# The Stack

* 📜 This folder defines your actual stack. It holds everything you may want to customize. This includes code (like scripts and JSON) as well as "infrastructure as documentation".
* 🎯 Some of the files here are direct inputs to the Mac Stack update process:
  * REQUIRED:
    * [macstack.json](macstack.json): Entry point and basic configuration
    * [Brewfile](Brewfile): Updated/installed during `mack update`
    * [custom_zshrc_content.sh](custom_zshrc_content.sh): Sourced from ~./zshrc
    * [custom_mack_update.sh](custom_mack_update.sh): Executed during `mack update`
  * OPTIONAL:
    * [git/repos-folder-template/](git/repos-folder-template/): A template for the content of the `git.repos_folder` defined in [macstack.json](macstack.json). Each folder in the template may contain a `git-repos.txt` listing URLs of intended repos in that folder. `mack update` will attempt to clone/sync your repos based on the template.
    * [zed/](zed/) and [vscode/](vscode/): Contain json files that will be restored during `mack update` if `"restore_ide_settings": true` in [macstack.json](macstack.json)
