# VS Code based IDEs

* The [settings.json](settings.json) and [keybindings.json](keybindings.json) files in this folder are backups for VS Code based IDEs. They normally locate at `~/Library/Application Support/<IDE>/User/*.json`.
* So whenever you change your user settings or user keybindings in a VS Code based IDE, remember to back them up to [settings.json](settings.json) or [keybindings.json](keybindings.json).
* The `update` command of MacStack will restore (overwrite) your IDE user settings and keybindings from the backup if `restore_ide_settings` is set `true` in the [macstack.json](../macstack.json) file.
* Supported IDEs: VS Code, Cursor, Antigravity, VSCodium, Windsurf, Kiro
