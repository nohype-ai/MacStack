# Comparison to Mackup (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to Mackup. What would be different (or impossible) if the user tried to do the same things with Mackup? And what can Mackup do that this project can not?"

---

## MacStack vs. Mackup: A Detailed Comparison

Mackup and MacStack share one sentence of pitch — "make your Mac's configuration portable" — and almost nothing else underneath. Mackup is a *symlink mover*: it relocates application preference files from `~` into a cloud-synced folder (iCloud, Dropbox, Google Drive, a git repo, ...) and replaces the originals with symlinks, so the *exact same bytes* appear on every Mac connected to that storage. MacStack is a *Mac convergence engine*: it installs software, merges settings into existing files, and configures IDEs, AI agents, and git repos from a folder of declarative inputs. The two tools answer different questions — "how do I keep the settings I already have in sync?" vs. "how do I describe a Mac and converge any Mac toward that description?" — and the gap shows up almost everywhere.

### What would be different (or impossible) with Mackup

**1. No software installation at all**

This is the headline difference. Mackup never runs `brew install`, `brew upgrade`, `mas install`, downloads a font, or fetches a binary. It only relocates files that *already exist*. Everything MacStack does in `scripts/homebrew/` — `update_user_stack.sh` (Brewfile install + `--greedy` cask upgrade), `ensure_mas_works.sh` (pre-flighting Mac App Store availability), `brew-clip.sh` (cleanup), `brew-force.sh` (forcing existing `/Applications` apps under Homebrew management) — has no analog in Mackup. To set up a new Mac with Mackup you first install Homebrew by hand, install every package and cask by hand, install every Mac App Store app by hand, install every font by hand, and *then* run `mackup restore` to symlink the preference files back. MacStack's `curl … | zsh` → `mack update` covers all of it from one folder.

**2. No merging — symlinks are whole-file by definition**

Mackup's unit of work is the file, not the key. When it "syncs" `~/Library/Application Support/Code/User/settings.json`, it moves that whole file into the storage folder and symlinks it back. There is no concept of "I want to enforce these five settings and leave the rest alone." If two Macs disagree on a setting, whichever one wrote last wins (and the other Mac silently inherits it on next sync). MacStack's `merge_jsonc.js` (137 lines wrapped by `merge_json.sh`) does deep, comment-preserving, key-order-preserving JSONC merge with set-union arrays — exactly so the user's hand-edits and Mackup-style "everything I ever set" survive each `mack update`. With Mackup, the only way to express "I care about these keys" is to not use Mackup for that file.

**3. No first-class casks, MAS apps, fonts, or VS Code extensions**

Mackup's worldview is "files in `~`." Casks (`brew install --cask cursor`), Mac App Store apps (`mas install <id>`), Apple Fonts (`brew install --cask font-sf-pro`), and VS Code extensions (`code --install-extension ...`, also driven via Brewfile in MacStack) are all *software*, not config files, so they are simply outside Mackup's model. MacStack treats all of these as one declarative input — a `Brewfile` lines like `cask "cursor"`, `mas "Xcode", id: 497799835`, `vscode "ms-python.python"` — and the same `brew bundle install` pass installs them all.

**4. No IDE auto-discovery, no JSONC, no fan-out**

`scripts/update_ide_settings.sh` (81 lines) checks `/Applications`, `~/Applications`, `/System/Applications`, then falls back to `mdfind`, and writes one source pair (`vscode/settings.json`, `vscode/keybindings.json`) into the User folder of every installed VS Code-family IDE — VS Code, Cursor, Antigravity, Kiro, Windsurf, VSCodium. With Mackup you'd register six separate "applications" (in `~/.mackup/*.cfg` files), each pointing at a different `Library/Application Support/<App>/User/` path, and you'd be syncing six independent copies of the same settings via the cloud. Worse: those copies are JSON-with-comments (JSONC), and Mackup doesn't know that. If one machine's editor decides to rewrite the file without comments, every other machine inherits the comment-stripped version on next sync.

**5. No AI agent configuration as a category**

`scripts/update_ai_agent_settings.sh` (62 lines) reads `ai/coding/cursor/{cli-config_template.json,rules/}`, `ai/coding/gemini/{settings.json,policies/}`, `ai/coding/opencode/opencode.json` and applies them with the merge-vs-tree-copy distinction the README documents (e.g., the Cursor CLI config gets merged so user-only fields and semi-sensitive locals survive, while the rules directories are tree-copied). Mackup has no concept of an AI agent. You could write a custom `~/.mackup/cursor.cfg` listing `~/.cursor/cli-config.json` for symlinking, but then Mackup would (a) sync the *full file including any local secrets* across all your Macs, and (b) overwrite, not merge — defeating MacStack's explicit warning that `cli-config.json` "contains semi-sensitive infos" and shouldn't be copied wholesale.

**6. No `~/.zshrc` composition without owning the file**

MacStack appends one line — `eval "$(mack shellenv)"` — to `~/.zshrc` and lets `mack shellenv` dynamically compose `content_macstack.sh` + `content_stack.sh` (which sources the user's `zshrc.sh` and adds `$STACK/bin` to `PATH`). `~/.zshrc` itself is left alone, so Homebrew's installer, `conda init`, `nvm` install, `pyenv init`, etc. can all keep appending to it without conflict. Mackup's only mode is "symlink `~/.zshrc` into the sync folder." Now Mackup *owns* `~/.zshrc`. Anything that appends to it on Mac A immediately appears on Mac B via the sync — including things that shouldn't be there (Mac-A-specific paths, conda environments that don't exist on Mac B). MacStack's "we own one line, sourcing scripts we regenerate" model is precisely what Mackup cannot do.

**7. No git repo sync**

`scripts/update-repos.sh` (148 lines) walks `git/repos-folder-template/`, reads each `git-repos.txt`, and for every URL it: clones if missing, pushes if ahead, pulls if behind, refuses to act on dirty/diverged repos and reports them at the end. Mackup has no concept of "managed source repos." It only sees files in `~`.

**8. No idempotent "describe a Mac, then converge any Mac"**

Mackup is a *backup/restore* tool. The flow is: on Mac A, `mackup backup` → all files move to storage; on Mac B, `mackup restore` → symlinks pull them in. There is no "current state vs. desired state" reasoning, no convergence loop, no `mack update` that you re-run weekly to keep the machine fresh. Mackup is event-driven (you sync when you change something) and storage-mediated (the truth lives in iCloud/Dropbox/your git repo's working tree, not in a versionable description).

**9. Sandboxed Mac App Store apps will not cooperate**

Sandboxed apps — which is most modern MAS apps and a growing share of notarized apps — refuse to follow symlinks out of their container. Mackup's symlink approach silently fails or causes apps to recreate the original file on next launch, breaking the sync. This is a long-standing, well-known limitation of Mackup that gets worse with each macOS release as Apple tightens sandboxing. MacStack sidesteps the issue by not using symlinks for app data at all — it merges into the real files in place.

**10. iCloud-as-storage has historically corrupted data**

Mackup's most popular storage backend is iCloud Drive. It has a documented history of issues where iCloud's own sync semantics fight with Mackup's symlinks, leading to lost preferences or duplicated "(2)" copies of config files. MacStack's stack folder is just a regular folder you put wherever you want; the tool reads it but doesn't symlink anything live into it.

**11. Maintenance status**

Mackup (~15k stars on GitHub) has been effectively stagnant for years — the last meaningful releases predate several macOS versions, many bundled "application" definitions point at paths that no longer exist or have moved under newer macOS sandboxing, and long-standing PRs sit unmerged. MacStack is pre-1.0 and actively developed against current macOS (Sequoia / Tahoe-era assumptions throughout the scripts).

---

### What Mackup can do that MacStack cannot

**1. Whole-file, two-way, real-time sync of app preferences across machines**

Mackup's defining feature: change a setting in BetterTouchTool on Mac A, and within seconds (via iCloud/Dropbox) the change is on Mac B. No "edit the stack, commit, run `mack update`" loop — the live preference file *is* the synced file. For users whose problem is "I want my Macs to be identical, all the time, without thinking about it," Mackup answers that and MacStack does not. MacStack's deliberate review/commit moment (edit the stack folder → `mack update`) is the opposite trade-off.

**2. ~150 supported apps out of the box, with zero per-app work**

Mackup ships an internal database of application definitions covering Alfred, BetterTouchTool, iTerm2, Karabiner-Elements, Sublime Text, MacVim, Bartender, Hammerspoon, Hazel, Keyboard Maestro, Moom, TextExpander, Transmission, Tower, Tunnelblick, and many more — each one a small INI file telling Mackup which paths to relocate. To add a new Mac to your fleet you `pip install mackup && mackup restore` and ~150 apps' preferences appear correctly. MacStack only knows about the categories its scripts target (Homebrew packages, git config, VS Code-family IDEs, Zed, three AI agents). Anything else — your Alfred workflows, your Karabiner key remappings, your iTerm2 profiles, your Hammerspoon config — has to be handled by you in the stack's optional `update.sh` or by adding files under `bin/` / `zshrc.sh`. Mackup just works.

**3. Sync of secret-bearing dotfiles**

Because Mackup blindly relocates whatever the application writes, it transparently syncs files that contain secrets (`~/.ssh/`, `~/.aws/credentials`, `~/.netrc`, `~/.gitconfig` with tokens, `~/.gnupg/`) — the security model is "your storage backend is private." MacStack explicitly tells the user *not* to put secrets in the stack and offers no encryption. If your goal is "I want my SSH keys, AWS creds, and GPG keyring on every Mac without manually copying them," Mackup does it (with all the security caveats that implies); MacStack will not.

**4. Symmetric multi-machine workflow without git knowledge**

Mackup users can run a multi-Mac sync with no version control involved at all — just point all Macs at the same iCloud/Dropbox folder. For non-developers (designers, writers, executives with multiple Macs) this is meaningfully simpler than maintaining a git-versioned stack folder. MacStack assumes you're comfortable with at minimum a folder of files (and ideally a git repo) describing your machine.

**5. Cross-platform (Linux) for the subset that overlaps**

Mackup runs on Linux too — the app database is much smaller there, but the core symlink mechanic works for cross-platform dotfiles (`.zshrc`, `.gitconfig`, `.vimrc`, `.tmux.conf`). MacStack is Mac-only by design (`brew --greedy`, `mas`, `mdfind`, `~/Library/Application Support/...`, `/Applications` are all Mac-specific) and has no Linux story.

**6. No surface area to learn**

`mackup backup`, `mackup restore`, `mackup uninstall`, `mackup list`. That's effectively the whole API. There is no schema, no `macstack.json`, no `Brewfile` to write, no `update.sh` hook, no AI-agent folder layout, no IDE settings discovery to reason about. For a user whose entire need is "sync my dotfiles to iCloud," Mackup is one `pip install` and one command.

**7. Restoring an *existing* configuration, not specifying a new one**

Mackup excels at the "I already have a Mac configured exactly how I like it, I just got a new Mac, make the new one match" use case — `mackup backup` on the old Mac, `mackup restore` on the new one, done (assuming the new Mac already has the apps installed). MacStack's model assumes you have *described* the machine in a stack folder; if your description is incomplete, the new Mac will be missing whatever you forgot to put in the stack. Mackup doesn't require you to know what you have — it just copies whatever the supported apps wrote to disk.

---

### Summary

Mackup and MacStack are not really competitors in any concrete workflow. They overlap on one sentence — "make your Mac portable" — and diverge on what "portable" means.

Mackup answers: **"How do I make the preference files my apps already wrote sync across all my Macs?"** Answer: symlink them into iCloud/Dropbox/git, blind-copy to every machine.

MacStack answers: **"How do I describe a Mac (software, shell, IDEs, AI agents, repos) in a folder and have any Mac converge to that description without clobbering whatever else is on it?"** Answer: install via Homebrew, merge into existing config files key-by-key, fan IDE settings out across all VS Code-family editors, manage AI agent configuration as a first-class category, and sync git repos.

Where they nominally overlap (`~/.zshrc`, `~/.gitconfig`, IDE `settings.json`), Mackup wins on simplicity-of-sync and loses on safety: it owns the whole file, ships its content as-is to every other machine, and silently breaks under sandboxed apps and modern iCloud semantics. MacStack wins on safety and loses on automatic two-way sync: it merges only the keys it owns, but it doesn't know about a setting you toggled in the live app until you put it in the stack.

The honest summary is:
- If your problem is **"keep my Macs' app preferences identical with no effort,"** and you accept symlinks-into-cloud-storage as a sync mechanism, **Mackup** does that and MacStack does not.
- If your problem is **"set up and keep current a Mac (software included) from a folder I version,"** Mackup cannot install anything, cannot merge, cannot fan settings out across IDEs, and has no AI/repo concept — **MacStack** is doing a different and larger job.

A real user could plausibly use both: Mackup for a long tail of small-app preference files that MacStack doesn't model (Alfred, Karabiner, iTerm2 profiles), and MacStack for everything that needs installation, merging, or AI/IDE/repo awareness. They don't conflict, because Mackup operates in `~` and MacStack operates on the stack folder plus a small number of well-known config files.
