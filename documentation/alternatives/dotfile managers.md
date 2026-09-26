# Comparison to dotfile managers (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to dotfile managers (like GNU Stow, YADM, rcm and Dotbot). What would be different (or impossible) if the user tried to do the same things with dotfile managers? And what can dotfile managers do that this project can not?"

---

## MacStack vs. the dotfile-manager category: A Detailed Comparison

- **GNU Stow** — the classic symlink-farm manager; still widely used.
- **YADM** — git-native dotfiles manager, very popular alternative to chezmoi.
- **rcm** (thoughtbot) — predates chezmoi, still in use.
- **Dotbot** — Python-based, large user base.

The four tools above are sometimes grouped with chezmoi, but they sit one tier below it in scope. chezmoi is a dotfile manager with templating, secrets, scripting, and external sources baked in; Stow / YADM / rcm / Dotbot are **strictly file-placement tools**. They each answer one tightly-scoped question:

- **Stow:** "How do I symlink a directory of files into `$HOME` and trivially undo it?"
- **YADM:** "How do I treat `$HOME` itself as a git working tree?"
- **rcm:** "How do I symlink a `dotfiles/` repo into `$HOME` with per-host tags and hook scripts?"
- **Dotbot:** "How do I declare in YAML which files get linked, which get cleaned, and which shell commands run to bootstrap?"

MacStack is not in this category. It is a Mac convergence engine that installs software (Homebrew + casks + Mac App Store + fonts + VS Code extensions), merges into existing config files key-by-key, fans IDE settings out across every installed VS Code-family editor, manages AI-agent configuration as a first-class category, and bidirectionally syncs git repositories. The overlap with the four dotfile managers is "both touch files in `$HOME`" — and that's roughly the entire overlap.

The four tools differ enough among themselves that a one-to-one comparison would be repetitive, so what follows treats them as a category with per-tool callouts where the differences matter.

### What would be different (or impossible) with these dotfile managers

**1. No software installation — at all, by any of them**

None of Stow, YADM, rcm, or Dotbot installs software. They have no concept of Homebrew, casks, Mac App Store, fonts, or VS Code extensions. To set up a fresh Mac with any of them you would first install Homebrew by hand, install every package and cask by hand, install every Mac App Store app by hand, install every font by hand, install every VS Code extension by hand, and *then* run the dotfile manager to place the config files.

Dotbot is the only one of the four with even a partial workaround: its `shell:` directive runs arbitrary commands, so you can write `shell: [["brew bundle --file=~/Brewfile", "Installing brew packages"]]`. That works, but it's not Brewfile-aware in any sense — it's just "shell out, hope it works, surface stdout." MacStack's `scripts/homebrew/` does the actual job: `update_user_stack.sh` runs `brew bundle install --no-upgrade` *and* `brew upgrade --greedy` (so casks marked `auto_updates true` and `version :latest` actually update); `ensure_mas_works.sh` pre-flights `mas list` so Mac App Store entries don't fail mid-run; `brew-clip.sh` cleans up old versions and the Caskroom; `brew-force.sh` brings already-installed `/Applications` apps under Homebrew management. That's ~5 scripts of Mac-specific Brewfile knowledge that a Dotbot `shell:` line cannot replicate.

YADM has a `bootstrap` hook (`~/.config/yadm/bootstrap`) that runs once after `yadm clone` — same situation: it's "run a script the user wrote," not built-in package awareness. Stow and rcm have no bootstrap hook at all (rcm has `pre-up`/`post-up` hooks, but they're per-rc-file lifecycle hooks, not "set up the machine first").

**2. No merging — every one of them is whole-file**

This is the second headline difference and arguably the more dangerous one. All four tools either symlink or copy whole files:

- **Stow** symlinks. The unit is the file (or a folder of files). If `~/.gitconfig` already exists with content the user wants to keep, `stow git` errors out ("existing target is not a symlink") and refuses to proceed unless you delete or `--adopt` the existing file. There is no merge; there is barely a way to coexist with hand-edits.
- **YADM** uses git. The unit is the file. Hand-edits show up as `yadm status` modifications you have to commit, stash, or discard. There's no concept of "I own these five keys, leave the rest alone."
- **rcm** symlinks (or copies, with `-C`). Same as Stow: whole-file ownership, no merge.
- **Dotbot** has `link:` (symlink), `create:`, and `clean:`. Same model: it owns the file or it doesn't.

MacStack's `scripts/json-merge/merge_jsonc.js` (137 lines, wrapped by `merge_json.sh`) does deep, comment-preserving, key-order-preserving JSONC merge with set-union arrays — exactly so the user's hand-edits in IDE/AI settings survive each `mack update`. None of these four tools has anything comparable. The closest workaround in any of them would be a Dotbot `shell:` step or a YADM `bootstrap` step that calls out to a custom merge script the user writes — i.e., re-invent `merge_jsonc.js` and call it from the dotfile manager.

**3. No JSONC awareness, period**

VS Code, Cursor, Zed, Gemini CLI, OpenCode, and Cursor CLI all use JSON-with-comments (JSONC) for their config files. None of the four dotfile managers knows what JSONC is. Symlinking a JSONC file via Stow/rcm/YADM/Dotbot works (it's just a file to them), but the moment two machines disagree on the content — or the moment the live editor decides to rewrite the file without comments — the comments are gone. There is no merge layer to put them back. MacStack's merge engine treats comment preservation as a default behavior.

**4. No IDE auto-discovery, no fan-out**

`scripts/update_ide_settings.sh` (81 lines) checks `/Applications`, `~/Applications`, `/System/Applications`, then falls back to `mdfind` (Spotlight), and writes one source pair (`vscode/settings.json`, `vscode/keybindings.json`) into the User folder of every installed VS Code-family IDE: VS Code, Cursor, Antigravity, Kiro, Windsurf, VSCodium.

To replicate this in a dotfile manager you'd need:
- **Stow:** six "packages" (`stow vscode`, `stow cursor`, `stow antigravity`, …), each containing a copy of the same files at the right path. No discovery — every package gets symlinked whether the IDE is installed or not. Symlinks into `~/Library/Application Support/<App>/User/` will fight any sandboxing the editor applies to its container. And if you uninstall an IDE, the dangling symlinks just sit there.
- **rcm:** tag-based per-IDE configs, but again, no "is it installed?" check. You'd hand-maintain six near-identical files.
- **YADM:** `yadm alt` lets you have file variants per-OS / per-class / per-host, but not "per installed application." The closest you'd get is a bootstrap script that conditionally `cp`s files into place — at which point YADM is no longer doing the work, your script is.
- **Dotbot:** YAML can declare six `link:` entries (one per IDE's User folder), and `if:` conditions can gate each on `[ -d /Applications/Cursor.app ]`. Workable, but still hand-maintained per IDE, and you've now got `mdfind` logic to write yourself if you want `~/Applications` and Spotlight fallback.

In all four cases, "any installed VS Code-family IDE on this Mac" is not a primitive. In MacStack, it is.

**5. No AI agent configuration as a category**

`scripts/update_ai_agent_settings.sh` (62 lines) reads `ai/coding/cursor/{cli-config_template.json,rules/}`, `ai/coding/gemini/{settings.json,policies/}`, `ai/coding/opencode/opencode.json` and applies them with the merge-vs-tree-copy distinction the README documents — Cursor CLI config gets *merged* (so user-only fields and semi-sensitive locals survive the README warning), while the rules/policies directories get *tree-copied*.

In Stow/YADM/rcm/Dotbot, AI agent configs are just more dotfiles. Worse, the merge-vs-overwrite distinction MacStack makes for `cli-config.json` cannot be expressed: any of these tools would copy or symlink the whole file, blowing away the local secret-bearing fields the README explicitly tells you not to commit.

**6. `~/.zshrc` composition without owning the file**

MacStack appends one line — `eval "$(mack shellenv)"` — to `~/.zshrc` and lets `mack shellenv` dynamically compose `scripts/zshrc/content_macstack.sh` + `content_stack.sh` (which sources the user's `zshrc.sh` and adds `$STACK/bin` to `PATH`). `~/.zshrc` itself is left alone, so Homebrew's installer, `conda init`, `pyenv init`, `nvm` install, etc. can all keep appending to it without conflict.

In dotfile-manager land:
- **Stow / rcm / Dotbot** symlink `~/.zshrc` → your repo's copy. They now own the file. Anything that appends to `~/.zshrc` (Homebrew installer, conda init, …) is appending into your symlinked source — and on the next machine that symlink resolves to *the same source file*, so Mac-A-only paths and conda envs that don't exist on Mac B end up sourced on Mac B.
- **YADM** treats `~/.zshrc` as a tracked file in `$HOME`. Same problem: anything that appends shows as a YADM modification you must commit, stash, or revert. The "we only own one line, sourcing scripts we regenerate" model that MacStack uses is not expressible.

**7. No git repo sync**

`scripts/update-repos.sh` (148 lines) walks `git/repos-folder-template/`, reads each `git-repos.txt`, and for every URL it: clones if missing, pushes if ahead, pulls if behind, refuses to act on dirty/diverged repos and reports them at the end.

None of the four dotfile managers has a "managed source repos" concept. YADM is itself a git wrapper but its scope is `$HOME` as one repo, not "manage these N other repos." Dotbot has `link:` for git submodules within the dotfiles repo, but submodules are pinned snapshots, not "keep my dev repos in sync, push commits I made locally."

**8. No declarative cross-cutting schema**

MacStack's `macstack.json` (validated by `scripts/stack_config/macstack.schema.json`) is one place to declare global git config (`git.user.name`, `git.user.email`, `git.user.signingkey`), the repos folder location (`git.repos_folder`), and other cross-cutting settings. Editors get auto-completion via the JSON Schema.

Stow/rcm/YADM/Dotbot have no schema at all. Stow has flags, rcm has `~/.rcrc`, YADM has `yadm config` (delegating to git config), Dotbot has YAML keys per directive. None of them models "global git user identity + signing key + repos location" as one declarative input — it's all hand-rolled.

**9. None know about Mac App Store, casks, fonts, or VS Code extensions as software categories**

Even if you bolt a `brew bundle` shell-out onto Dotbot or YADM, you still don't get the surrounding logic MacStack has: `mas` pre-flight, `--greedy` cask upgrade, font cask treatment, VS Code extensions installed via `brew bundle`'s `vscode "..."` lines. These are Mac-specific concerns no general-purpose dotfile manager has any reason to know about.

**10. Mac-specific paths and tools as primitives**

`mdfind`, `/Applications`, `~/Applications`, `/System/Applications`, `~/Library/Application Support/...`, `mas`, `osascript` — MacStack's scripts use these as load-bearing primitives. The four dotfile managers were built cross-platform (Stow originated on GNU/Linux for `/usr/local`; Dotbot, rcm, YADM all support Linux as primary targets too). They have no native concept of "the Mac app's User folder" — to them, it's just another path you symlink into.

**11. Idempotent convergence vs. one-shot link/copy**

`mack update` is designed to be re-run on a cadence — it updates Homebrew itself, upgrades installed packages, cleans up cache, and re-applies the stack. The four dotfile managers have an *initial-link* model: you `stow`, `rcup`, `yadm clone && yadm bootstrap`, or `dotbot -c install.conf.yaml` once on a new machine. Subsequent runs only re-link if the source changed. There's no "every Tuesday I run the same command and the machine stays current with software updates and stack changes" loop.

**12. No notion of a portable, schema-validated *stack folder***

A MacStack stack is a folder with obvious file names — `Brewfile`, `zshrc.sh`, `vscode/settings.json`, `ai/coding/cursor/rules/*.md`, `git/repos-folder-template/` — readable by any human or LLM at a glance. The four dotfile managers each impose conventions:

- **Stow:** the source is a parent dir of "package" subdirs whose internal layout must mirror the target hierarchy from `$HOME` down. `~/.gitconfig` ↔ `git/.gitconfig`. Once you understand the trick it's elegant; it's also the only thing Stow does.
- **rcm:** files in the source dir prefixed `.` map to `~/.foo`. Tag-based subdirs (`tag-host-laptop/...`) override.
- **YADM:** `.yadm/repo.git` lives separately; `$HOME` itself is the working tree. Filenames can carry suffixes for `alt` variants (`.zshrc##os.Darwin`, `.zshrc##class.work`).
- **Dotbot:** `install.conf.yaml` is the source of truth; the layout of the rest of the repo is whatever the YAML says.

None of these conventions makes "this folder describes my whole Mac" obvious the way MacStack's stack folder does. They each encode "this folder is dotfiles for `$HOME`."

---

### What dotfile managers can do that MacStack cannot

These tools have been around long enough — some 30+ years, in Stow's case — to do specific things very well that MacStack does not attempt.

**1. Stow: symlink-farm trivially reversible, useful far beyond dotfiles**

`stow -D <package>` cleanly removes every symlink Stow created. No state file, no manifest — Stow just walks the package dir and removes symlinks pointing into it. This makes Stow uniquely good for the original use case (managing `/usr/local` overlays, multiple parallel versions of CLI tools under `~/local/`) and for dotfiles where you genuinely want "all-or-nothing per package." MacStack has no clean uninstall — once it merges keys into `~/.gitconfig` or an IDE settings file, those keys stay (deliberately, for non-destructiveness, but it's an asymmetry).

Stow also has zero dependencies beyond Perl (which ships with macOS), which makes it ideal for environments where you can't install much.

**2. YADM: per-host / per-OS / per-class file variants without templating**

YADM's `alt` feature lets you maintain `~/.gitconfig##os.Darwin`, `~/.gitconfig##os.Linux`, `~/.gitconfig##class.work`, `~/.gitconfig##hostname.laptop` side by side, and `yadm alt` picks the right one on `yadm clone`. This solves the "same dotfile, different machines" problem without writing a template. MacStack has no per-machine variation story — the closest is "maintain different stacks" or "branch on hostname inside `update.sh`."

**3. YADM: encryption of secret-bearing dotfiles via gpg**

`yadm encrypt` reads a list of files (`~/.config/yadm/encrypt`) and stores their gpg-encrypted contents in the YADM repo. On `yadm clone`, you `yadm decrypt` to materialize the live files. SSH keys, AWS credentials, GPG keyring — YADM can ship them across machines safely. MacStack explicitly tells the user *not* to put secrets in the stack (the `cli-config_template.json` warning) and offers no encryption.

**4. YADM: templating with envtpl / ESH / Jinja2 and J2CLI**

YADM supports four template engines for generating dotfiles based on host/OS/user data. MacStack has no templating at all — its files are static.

**5. YADM: `$HOME` itself is a git repo**

`yadm status`, `yadm diff`, `yadm log`, `yadm push` — all act on dotfiles in-place. There is no "edit the source folder, then apply" indirection. For users who want their dotfiles to be a single `git push` away from being on every other machine, this is the most direct workflow. MacStack's deliberate edit-stack-then-`mack update` round trip is the opposite trade-off.

**6. rcm: tag-based per-machine overrides**

`rcup -t laptop -t work` materializes only the `tag-laptop/` and `tag-work/` overlays on top of the base dotfiles. Lightweight, no template syntax, very fast to reason about. MacStack has no equivalent ("apply only these subsets of the stack").

**7. rcm: pre-up / post-up hooks per rc-file**

`~/.zshrc` can have a `pre-up.zshrc` and `post-up.zshrc` that run before and after rcm processes that file. Useful for "regenerate `~/.ssh/known_hosts` after symlinking my SSH config." MacStack has one global `update.sh` hook, not per-file lifecycle hooks.

**8. Dotbot: pure-declarative YAML, no shell needed for the basics**

A 30-line `install.conf.yaml` can describe link-this, clean-that, create-this-dir, run-this-shell-command, all in YAML with no scripting. For a user whose entire need is "symlink these 12 dotfiles into `$HOME`," Dotbot is the most readable, smallest-surface tool of any in this comparison. MacStack's shell-script-driven model is less readable for the trivial case.

**9. Dotbot: plugin ecosystem**

Dotbot has community plugins for git submodule management, brew, npm, vundle, asdf, and a long tail of other tools. None of these match MacStack's depth (e.g., the brew plugin is "shell out to brew install"), but the *ecosystem* exists in a way MacStack's does not yet.

**10. All four: cross-platform**

Stow runs anywhere Perl runs. YADM is a Bash script — Linux, macOS, BSD, Windows via WSL. rcm is Ruby + sh. Dotbot is Python 3. MacStack is Mac-only by design (`brew --greedy`, `mas`, `mdfind`, `~/Library/Application Support/...`, `/Applications`).

**11. All four: maturity, ubiquity, package-manager availability**

Stow is in every Linux distribution and `brew install stow`. rcm, dotbot, yadm are all in Homebrew. They have years of accumulated patterns, starter repos on GitHub, and Stack Overflow answers. MacStack is pre-1.0 and currently single-vendor.

**12. Stow specifically: "managed dirs of binaries under `~/local`"**

Stow's original purpose — managing parallel installations of software under `/usr/local` or `~/local` — has no analog in MacStack. If you compile multiple versions of the same tool from source and want to swap between them by `stow -D oldver && stow newver`, Stow is the right tool and MacStack will not help.

**13. None of them require the user to "describe a Mac"**

If your problem is "I already have my dotfiles, I just want them on another machine," Stow/YADM/rcm/Dotbot all let you `git clone` and `<tool> apply` to materialize them — no schema, no Brewfile, no IDE-discovery setup, no AI-agent layout. MacStack assumes you're willing to *describe* the machine in a stack folder. For a user whose entire need is "sync my 8 dotfiles across Macs," any of the four dotfile managers is faster to set up than MacStack.

---

### Summary

The four dotfile managers and MacStack are not competitors so much as tools at different layers of the stack. Stow/YADM/rcm/Dotbot are *file placers* — they move config files into `$HOME` (by symlink, copy, or git-checkout) and stop there. MacStack is a *Mac convergence engine* — it installs software, merges configs, fans IDE settings out, manages AI agents, syncs repos.

A useful one-line summary for each:

- **GNU Stow:** the right tool when you want symlinks, want them trivially reversible, and don't need any other capability — including not needing to install software. Doesn't merge, doesn't install, doesn't know about Macs.
- **YADM:** the right tool when your model is "`$HOME` is a git repo with per-host variants and gpg-encrypted secrets," and you'll handle software installation in a `bootstrap` script you write. Closest of the four to chezmoi in expressiveness; still no merging, no IDE/AI/repo awareness.
- **rcm:** the right tool when you want the simplest possible "tagged dotfiles repo → `$HOME` symlinks" with per-file lifecycle hooks. Same caveats as Stow for everything outside that scope.
- **Dotbot:** the right tool when you want pure-declarative YAML for a small, well-understood set of links and a few bootstrap shell commands. Best readability of the four for trivial cases; not built to scale to MacStack-sized scope.

Where they overlap with MacStack (a `.gitconfig`, a `.zshrc`, an IDE `settings.json`), the four dotfile managers are simpler-and-more-destructive: they own the file, they don't merge, and they don't know about JSONC comments. Where they don't overlap (Brewfile install with `--greedy`, Mac App Store pre-flighting, IDE auto-discovery and fan-out, AI-agent merge-vs-tree-copy, bidirectional repo sync), MacStack is doing a different and larger job that none of the four was designed for.

The honest summary is:

- If your problem is **"symlink (or git-track) my dotfiles into `$HOME` across machines, possibly cross-platform, possibly with per-host variants or gpg-encrypted secrets,"** one of these four tools is the right answer (YADM if you want the most features in this category, Stow if you want the least surface area, rcm for tag-based overrides, Dotbot for declarative YAML). MacStack would be over-scoped — and would force you onto Mac-only.

- If your problem is **"set up and keep current a Mac end-to-end (software included, IDE-merged, AI-aware, repos in sync) from a folder I version,"** none of these four can do it. They were never trying to. Stow has no install layer; YADM has a hand-written `bootstrap` you'd have to fully author; rcm has hooks but no software model; Dotbot has `shell:` shell-outs but no Mac-specific awareness, no merge engine, no IDE discovery, no AI-agent category. MacStack is in a different problem space.

A real user could plausibly use Stow or Dotbot *alongside* MacStack — Stow for managing parallel `~/local` toolchain installs, Dotbot for a long tail of small dotfiles MacStack doesn't model — without any conflict, because the four dotfile managers operate in `$HOME` on files MacStack doesn't touch. They live happily one layer below MacStack's concerns.
