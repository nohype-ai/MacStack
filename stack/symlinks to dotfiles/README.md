# Symlinks to Dotfiles

🚨 The "dotfiles" in this directory are symlinks **to** all dotfiles in the home folder. The symlinks here exist only for reading/monitoring the real files conveniently in context of this repo. This is not to be confused with the typical setup of a "dotfile repo" where it's the other way around with the repo containing the actual files and the machine only having symlinks to them.

The reason we do it this way is simple: If we had the real dotfiles in the repo, the update process would have to copy these files from the repo to the home folder, overwriting pre-existing files. MacStack would overwrite changes to dotfiles that were made by other processes or manually, and MacStack could not be introduced to an already running and established Mac. This would break MacStack's promises of being harmless and idempotent.
