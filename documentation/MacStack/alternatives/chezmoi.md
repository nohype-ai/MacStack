# Comparison to chezmoi (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to chezmoi. What would be different (or impossible) if the user tried to do the same things with chezmoi? And what can chezmoi do that this project can not?"

---

## MacStack vs. chezmoi: A Detailed Comparison

chezmoi is the closest established competitor to MacStack — both are built around the idea that "your machine's configuration is a folder you own and version-control." The two tools agree on the philosophy and disagree on the scope. chezmoi is a dotfile manager that has grown some package-installation capability around the edges. MacStack is a Mac provisioning tool that has dotfile-merging at its core.

### What would be different (or impossible) with chezmoi

**1. Non-destructive merging into existing JSON/JSONC files**

This is the single biggest difference. chezmoi's default model is *file ownership*: a source file in `~/.local/share/chezmoi` becomes the target file in `$HOME`. When chezmoi applies, it writes the full target file. If the user has hand-edited the live file (e.g., added a new VS Code setting that isn't in the stack), `chezmoi apply` overwrites it.

chezmoi does have an escape hatch — `modify_` scripts, which receive the current target on stdin and emit the desired target on stdout. To replicate MacStack's behavior, you would write a `modify_settings.json.tmpl` script that re-implements deep JSONC merge with comment preservation, set-union arrays, and key-order preservation — i.e., re-write `merge_jsonc.js` as a chezmoi modify script. The capability exists, the implementation does not. MacStack ships this as the default behavior for every IDE/AI config it touches.

**2. Mac App Store, casks, and `--greedy` upgrades**

chezmoi can run a `Brewfile` via a `run_onchange_install-packages.sh` script, but it doesn't *do anything Brewfile-aware*. MacStack:

- Runs `brew upgrade --greedy` so casks marked `auto_updates true` (Cursor, Raycast, browsers) and `version :latest` (Apple Fonts) actually update — chezmoi has no opinion here.
- Pre-flights `mas list` (`ensure_mas_works.sh`) so Mac App Store entries in the Brewfile don't fail mid-run — chezmoi does not know `mas` exists.
- Wires in `brew bundle install --no-upgrade --file <Brewfile>` and then `brew cleanup` plus a Caskroom installer purge as part of the standard run.

In chezmoi all of this collapses to "user, please write a shell script." That works, but it isn't reproducible across stacks the way MacStack's pipeline is.

**3. IDE/editor auto-discovery**

`update_ide_settings.sh` checks `/Applications`, `~/Applications`, and `/System/Applications`, then falls back to `mdfind` (Spotlight), and only then writes settings/keybindings into the right `Library/Application Support/<App>/User/` folder. It does this for VS Code, Cursor, Antigravity, Kiro, Windsurf, and VSCodium — one source pair (`vscode/settings.json`, `vscode/keybindings.json`) fans out to every installed VS Code-derived IDE.

In chezmoi you'd have to either:

- Use a Go template with `lookPath` / `stat` calls per-app, plus duplicate target paths for every IDE (six near-identical source files), or
- Write a `run_onchange_` script that does the same `mdfind`/path checks and shells out to your own merge logic.

Either way, it's hand-rolled. MacStack treats "any installed VS Code-family IDE on this Mac" as one declarative input.

**4. AI agent configuration as a first-class category**

MacStack has `update_ai_agent_settings.sh` and a stack layout (`ai/coding/cursor/{cli-config_template.json,rules/}`, `ai/coding/gemini/{settings.json,policies/}`, `ai/coding/opencode/opencode.json`) that defines AI agents as a managed surface. The Cursor and Gemini configs go through JSONC-aware merge (so user-only fields and comments survive), while the rules/policies directories are tree-copied.

In chezmoi this isn't impossible, but it's just "more dotfiles." There is no first-class concept of an AI agent, no merge-vs-overwrite distinction enforced, and the per-tool gating ("only update if `~/.cursor` exists") would have to be written by hand in every modify script.

**5. `~/.zshrc` composition without owning the file**

MacStack does not own `~/.zshrc`. It appends a single `eval "$(mack shellenv)"` line and lets `mack shellenv` dynamically compose `content_macstack.sh` + `content_stack.sh` (which sources the user's `zshrc.sh` and adds `$STACK/bin` to `PATH`). This means the stack can change shell behavior between runs without ever touching `~/.zshrc` again.

The chezmoi-native approach is to make `~/.zshrc` a chezmoi-managed file (templated). That works, but it inverts the relationship: chezmoi now owns the file, and any tool or user that appends to `~/.zshrc` (Homebrew's own installer, conda init, asdf init, `nvm` install, etc.) will fight chezmoi on every apply. MacStack's "we only own one line, sourcing a script we regenerate" model coexists with everything else on the machine.

**6. Bidirectional git repo sync**

`update-repos.sh` walks a `git/repos-folder-template/` tree, reads each `git-repos.txt`, and for every URL it: clones if missing, *pushes if ahead*, *pulls if behind*, refuses to act on dirty or diverged repos and reports them at the end. chezmoi has no concept of "managed source repos that aren't dotfiles." You can clone things via `.chezmoiexternal.toml`, but that's a one-way pull of an archive/repo into the chezmoi source state — not "keep my dev repos in sync, push commits I made locally, and tell me which ones need attention."

**7. The `STACK` is a folder you control, not a folder chezmoi controls**

chezmoi's source state lives at a fixed path (`~/.local/share/chezmoi`) and has its own naming conventions (`dot_zshrc`, `private_`, `executable_`, `run_once_`, `.chezmoitemplates`, `.chezmoiignore`). The folder *is* chezmoi.

MacStack's stack is just a folder of plain files with obvious names: `Brewfile`, `zshrc.sh`, `vscode/settings.json`, `ai/coding/cursor/rules/*.md`. Anyone — human or LLM — can read it without learning chezmoi's filename grammar. The path is configurable (`mack config`) and the `macstack.json` schema (`scripts/stack_config/macstack.schema.json`) gives editors auto-completion. The cost is that MacStack is less expressive — chezmoi's filename DSL encodes things (permissions, executability, run-once-ness, encryption, OS gating) that MacStack would need to bake into scripts.

**8. Mac-only by design vs. cross-platform**

If the user's "stack" needs to also configure a Linux dev VM or a WSL setup, chezmoi handles that out of the box. MacStack does not. Trying to use MacStack on Linux is a non-starter — `brew --greedy`, `mas`, `mdfind`, `~/Library/Application Support/...`, `/Applications` are all Mac-specific.

---

### What chezmoi can do that MacStack cannot

**1. Templating with per-machine / per-OS / per-user variability**

chezmoi's killer feature is Go templates over source files, with rich data: `.chezmoi.os`, `.chezmoi.hostname`, `.chezmoi.arch`, `.chezmoi.username`, plus arbitrary user data in `.chezmoidata.toml`. One source file generates different outputs on a personal laptop, a work iMac, and a Linux server. MacStack has no templating — its files are static, and per-machine variation is achieved by maintaining different stacks (or, awkwardly, by branching `update.sh`).

**2. First-class secrets management**

chezmoi has built-in integrations with age, gpg, 1Password, Bitwarden, KeePassXC, LastPass, pass, HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, and Doppler. Templates can pull a secret at apply time and never write it to disk in plaintext within the source state.

MacStack explicitly tells the user *not* to put secrets in the stack (the `cli-config_template.json` warning in the README), and offers no encryption. If your stack needs to seed a `~/.netrc`, an SSH key, a `gh auth` token, or an API key into a config file, chezmoi has a story for that and MacStack does not.

**3. Bootstrap from a remote repo with one command**

`chezmoi init --apply <git-repo-url>` clones the repo, runs the prompts, and applies in one shot. MacStack's bootstrap is `curl … | zsh` followed by configuring the stack folder (`mack config` or interactive prompt on first `mack update`) — so for a *fresh* Mac, the user has to point MacStack at a stack location separately. Not a huge gap, but chezmoi's init flow is more polished for the "new machine, give me my whole environment" use case.

**4. Dry-run, diff, and verify**

- `chezmoi diff` shows exactly what would change.
- `chezmoi verify` exits non-zero if the machine has drifted from the source state.
- `chezmoi apply --dry-run` simulates without writing.
- `chezmoi status` summarizes per-file state.

MacStack has none of this. `mack update` always applies. There is no "what would this do?" mode and no drift detection. For CI and pre-flight checks ("does my stack still match this Mac?") chezmoi wins outright.

**5. Symlinks, file modes, and target-file metadata as data**

chezmoi encodes a lot in source filenames: `private_` → mode 0600, `executable_` → +x, `symlink_` → write a symlink, `encrypted_` → decrypt on apply, `run_once_`, `run_onchange_`, `modify_`, `create_` (only if missing). MacStack has none of this metadata layer; permissions and link targets are ad-hoc shell-script concerns. The only mode-aware thing MacStack does is `chmod 700 "$STACK"` on update.

**6. Managed file deletion**

chezmoi tracks which files it has applied. If you delete a source file (or add it to `.chezmoiremove`), the corresponding target is removed on next apply. MacStack only ever creates/merges — it never removes a setting it previously added. If you delete a key from your stack's `vscode/settings.json`, it stays in the live `settings.json` forever (this is a deliberate design trade-off for non-destructiveness, but it's a real limitation).

**7. External sources without scripting**

`.chezmoiexternal.toml` declaratively pulls in remote files/archives/git repos as part of the source state — e.g., zsh plugins from GitHub, a vim color scheme tarball, the latest `kubectl` completion script. In MacStack, anything beyond "what Homebrew installs" requires a hand-written step in `update.sh`.

**8. Edit workflow and conflict resolution**

`chezmoi edit <file>` opens the source-state version, `chezmoi re-add` updates the source from the live file, `chezmoi merge` opens a 3-way merge between source / target / last-applied. MacStack's editing workflow is "open the file in the stack folder in your editor." That's fine, but there's no equivalent of `re-add` to bring user-side changes back into the stack, and no merge tool when the source and target have both changed.

**9. Cross-platform and much larger ecosystem**

chezmoi runs on Linux, macOS, Windows, FreeBSD, OpenBSD, with active maintenance, ~14k GitHub stars, an ecosystem of starter repos, and shipped in every major package manager. MacStack is pre-1.0, Mac-only, and currently single-vendor. For longevity bets, chezmoi is the safer choice today.

**10. Mature, documented patterns**

chezmoi has years of accumulated docs on patterns like "multi-machine with shared base + per-host overrides," "secrets without committing them," "bootstrapping with prompts." MacStack's stack-inheritance / registry story is on the roadmap (`philosophy.md` mentions a future stack registry) but not yet built.

---

### Summary

If you only need dotfiles managed across multiple machines (possibly multiple OSes), with templating and secrets, and you're comfortable with chezmoi's filename DSL — **chezmoi is the right tool**, and MacStack would be over-scoped for the job.

If you want a Mac to be set up end-to-end (Homebrew + casks + Mac App Store apps + IDE settings *merged* with your manual tweaks + AI agent rules + git repo sync) from a folder of obviously-named files, with no templating syntax to learn and no risk of clobbering your existing config — **MacStack is the right tool**, and chezmoi would either need substantial scripting on top (`modify_` + `run_onchange_` everywhere) or would require you to hand file ownership of your IDE/AI configs over to it.

The cleanest mental model is: chezmoi is a *file replicator with escape hatches*; MacStack is a *Mac convergence engine* whose default mode is non-destructive merge. Where they overlap (a `.gitconfig`, a `.zshrc`, a Brewfile), chezmoi is more flexible and MacStack is more opinionated and less destructive. Where they don't overlap, each does things the other genuinely cannot.
