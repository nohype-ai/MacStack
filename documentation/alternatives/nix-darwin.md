# Comparison to nix-darwin + Home Manager (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to nix-darwin + Home Manager (with `nix-homebrew`). What would be different (or impossible) if the user tried to do the same things with nix-darwin + Home Manager? And what can nix-darwin + Home Manager do that this project can not?"

---

## MacStack vs. nix-darwin + Home Manager: A Detailed Comparison

nix-darwin + Home Manager (+ `nix-homebrew`) and MacStack live on opposite ends of the "how invasive is your config tool allowed to be?" spectrum. Both want a Mac to converge to a declared state. Nix achieves this by owning the world: a `/nix` APFS volume, a multi-user daemon, an immutable `/nix/store`, and a configuration written in the Nix language whose evaluation produces every file the system points at. MacStack achieves it by writing plain files to `~/`, appending one line to `~/.zshrc`, and merging JSONC into the targets the user already cares about.

Everything below follows from that core difference.

### What would be different (or impossible) with nix-darwin + Home Manager

**1. Non-destructive merge into existing JSON/JSONC config files**

This is the largest delta, and it is structural — not just "Nix doesn't ship the feature."

Home Manager's standard pattern is that user configuration files (`~/.config/...`, `~/Library/Application Support/.../settings.json`, etc.) are symlinks into `/nix/store/<hash>-<name>`. The store is read-only. So:

- The settings file the IDE opens cannot be hand-edited live — the symlink target is read-only, and an in-place save by the IDE will fail or be silently dropped. Some IDEs respond by writing a sibling file or refusing to save.
- The *only* way to change a setting is to change the Nix expression that generates it and run `darwin-rebuild switch`.
- There is no notion of "merge my declared keys into whatever the user/app has accumulated and preserve everything else." Nix-rendered files are the truth; everything else is drift.

You can escape this with `home.file."Library/Application Support/Cursor/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink ./settings.json;` (writable, but you've now lost reproducibility and given up declarative ownership), or by writing a Home Manager activation script that re-implements MacStack's `merge_jsonc.js` (deep merge, comment preservation, set-union arrays). The second option is possible; nobody does it because it fights the Nix model.

MacStack ships JSONC-aware merging as the default for every IDE and AI agent target it touches (`scripts/json-merge/merge_jsonc.js`). Comments and user-added keys survive every `mack update`. In Nix, comments cannot survive at all — the source is a Nix expression, not a JSONC file, so comments in the target are an output-time concern that Home Manager has no representation for.

**2. JSONC as the user-facing format**

The MacStack stack is files the user already knows: `Brewfile`, `vscode/settings.json` (with `//` comments), `ai/coding/cursor/cli-config_template.json`, `zshrc.sh`. The schema for `macstack.json` is a normal JSON Schema (`scripts/stack_config/macstack.schema.json`) that any editor will autocomplete.

The nix-darwin stack is `flake.nix` + a tree of `.nix` files written in the Nix language. Editing them requires learning Nix's lazy functional syntax, the module system (`mkOption`, `mkMerge`, `mkIf`, `lib.mkForce`), and per-program option names (`programs.git.userName`, not `git config user.name`). The payoff is real — but the floor is high, and the configs are no longer "the file the app reads," they are "an expression that, when evaluated, produces the file the app reads."

**3. Auto-discovery of installed VS Code-family IDEs**

`update_ide_settings.sh` checks `/Applications`, `~/Applications`, `/System/Applications`, then falls back to `mdfind` (Spotlight), and writes one source pair (`vscode/settings.json`, `vscode/keybindings.json`) into every installed VS Code-derived IDE: VS Code, Cursor, Antigravity, Kiro, Windsurf, VSCodium. New IDE installs on the next run get the same settings automatically.

Home Manager has `programs.vscode`, with extension lists, settings, and keybindings — but it manages *one* `package` per program instance. To cover six IDEs you would either:

- Declare six instances (often via custom modules, since most of these aren't upstreamed), each with the same settings duplicated or factored out, *and* you must declare which IDEs exist on this Mac in the Nix expression itself (Nix doesn't probe the running system at evaluation time; Spotlight queries are foreign to it), or
- Write Home Manager activation scripts that do the `mdfind` checks and the file writing — bypassing the whole `programs.*` model.

Either way, "any installed VS Code-family IDE on this Mac" as a single declarative input doesn't exist in the Nix model. Discovery from the live filesystem isn't how Nix thinks.

**4. `brew upgrade --greedy` and the cask auto-update problem**

nix-homebrew's design point is the *opposite* of greedy upgrades: it pins the Homebrew tap revisions in the flake (`flake.lock`) so two machines on the same lock see the same cask definitions. The default activation runs `brew bundle install --no-upgrade` (or equivalents), which intentionally ignores casks marked `auto_updates true` (Cursor, Raycast, browsers) and `version :latest` (Apple Fonts).

MacStack's `update_user_stack.sh` does the opposite: it explicitly runs `brew upgrade --greedy` so those casks actually update, then `brew bundle install --no-upgrade` for the missing ones. To replicate this in nix-darwin you'd add a custom activation script that runs `brew upgrade --greedy` after nix-homebrew has done its declarative bundle — but you've now introduced non-reproducibility on purpose, which defeats nix-homebrew's main reason to exist.

The two tools are answering different questions: nix-homebrew asks "how do I make Homebrew reproducible across machines?", MacStack asks "how do I make sure the user's Mac is actually running the latest cask versions?". Both are legitimate; they are not the same question.

**5. Mac App Store pre-flight (`ensure_mas_works.sh`)**

Both nix-homebrew and MacStack support `mas` entries in a Brewfile. MacStack additionally pre-flights `mas list` so a not-signed-in-iCloud failure is detected before `brew bundle install` is half-done. nix-homebrew has no equivalent — a `masApps` activation that fails mid-run leaves you debugging from the middle of a `darwin-rebuild` activation, with the previous generation still active but the App Store apps in an inconsistent state.

This is small, but it's representative: MacStack has been built around the actual quirks of the macOS surfaces it touches (Spotlight indexing latency, `mas` sign-in state, casks that auto-update outside Homebrew), in shell scripts that can be read and changed in five minutes. nix-darwin's equivalent quirk-handling lives behind module options and would require either upstream PRs or local module overrides.

**6. `~/.zshrc` composition without owning the file**

MacStack appends exactly one line to `~/.zshrc`:

```bash
# MacStack shell customization
eval "$(mack shellenv)"
```

`mack shellenv` then dynamically composes `content_macstack.sh` (PATH, prompt, history disable, git aliases, helper functions) and `content_stack.sh` (sources `$STACK/zshrc.sh`, prepends `$STACK/bin` to `PATH`). The user's `~/.zshrc` is otherwise theirs, and other tools that append to it (Homebrew installer, conda init, `nvm` install, asdf init, `gh completion`, language-server installs, etc.) coexist without conflict.

Home Manager's `programs.zsh` is whole-file ownership: it generates `~/.zshrc` from Nix options (`programs.zsh.shellAliases`, `programs.zsh.initExtra`, `programs.zsh.envExtra`, plugin lists). You can opt out (`programs.zsh.enable = false;`) and write activation scripts that append a sourced line, replicating MacStack — but the moment you opt back in to use Home Manager's nice plugin/completion handling, the file is generated and any other tool that tries to append to it will be blown away on the next switch. There is no middle ground built in.

**7. Bidirectional git repo sync (`update-repos.sh`)**

`update-repos.sh` walks `git/repos-folder-template/`, reads each `git-repos.txt`, and for every URL: clones if missing, *pushes if ahead*, *pulls if behind*, refuses to act on dirty or diverged repos and reports them at the end. Plain shell, plain git.

Nix has no concept of "managed dev repos that you can push from." Flake inputs are read-only pulls of revisions pinned in `flake.lock` — they exist in `/nix/store` and are not where you do work. To replicate `update-repos.sh` you would write a `system.activationScripts.cloneRepos.text = ''…''` — i.e., the same shell script, called from a Nix-evaluated string. It works, but it is *outside* the declarative model: nothing about that activation script benefits from Nix's atomicity, rollback, or evaluation purity.

**8. AI agent configuration as a first-class category**

MacStack has `update_ai_agent_settings.sh` and a stack layout (`ai/coding/cursor/{cli-config_template.json,rules/}`, `ai/coding/gemini/{settings.json,policies/}`, `ai/coding/opencode/opencode.json`). It uses JSONC merge for the settings files (so user-only fields and comments survive) and tree-copies the rules/policies directories. Each tool is gated on its presence (`if [[ -d ~/.cursor ]]`).

Home Manager has no modules for Cursor CLI, Gemini CLI, or OpenCode. You write `home.file."./.cursor/cli-config.json".text = builtins.toJSON { … };` — which means rendering Nix attribute sets to JSON, losing comments, and writing the *whole* file (overwriting any user keys). Or you `mkOutOfStoreSymlink` to a writable copy in your flake repo, which gets you back to "this is just a file" but at the cost of reproducibility.

The merge-vs-overwrite-vs-tree-copy distinctions MacStack makes per file type don't exist as primitives in Home Manager — they would have to be modeled per file, by hand.

**9. `brew-force`: adopting unmanaged apps into Homebrew**

`mack brew-force` finds apps in `/Applications` that exist on disk but are not registered with Homebrew (e.g., user double-clicked a `.dmg` six months ago, then later added the cask to the Brewfile), removes the unmanaged bundle (preserving `~/Library` user data), and `brew install --cask --force`s it cleanly so Homebrew can manage updates from then on.

This is a Homebrew-specific impedance-match step. nix-darwin's strict declarative model assumes the system is already in spec — there is no "your `/Applications` accumulated this app outside the system, let's bring it under management" workflow because Nix wouldn't let it accumulate in the first place. The closest equivalent (`homebrew.onActivation.cleanup = "zap"` plus a re-install) is more aggressive and zaps user data the brew-force flow preserves.

**10. Bootstrap cost and footprint**

MacStack's bootstrap is `curl -fsSL https://macstack.dev/setup.sh | zsh`, which installs Homebrew if absent and the `mack` script. No system volume created, no daemon, no `/etc/synthetic.conf` edit, no APFS volume mount, no PAM modifications. Nothing in `/`. Reversal is `rm -rf` of two folders.

nix-darwin requires a Nix install first: multi-user daemon (`nix-daemon`), a dedicated `/nix` APFS volume mounted into `/`, build users (`_nixbld1..32`), modifications to `/etc/zshrc`, `/etc/bashrc`, and `/etc/profile`, and on recent macOS versions a synthesized firmlink. Then the nix-darwin install adds `darwin-rebuild`, `org.nixos.activate-system` launchd agent, etc. Reversal is famously the [Determinate Systems uninstaller](https://github.com/DeterminateSystems/nix-installer) or a multi-page manual procedure. None of this is wrong — it's the cost of what Nix delivers — but for a user whose only goal is "set up my Mac the same way every time," it is a large up-front commitment.

**11. iCloud + AppleID dependent installs**

Both tools route Mac App Store apps through `mas`, so the iCloud account requirement is the same. But MacStack's surface area beyond MAS (cask installs, IDE settings into `~/Library/Application Support`, Spotlight discovery) is all just shell on top of the user's normal Mac account. nix-darwin's activation runs as `root` (with helper hops back to user-space for Home Manager), which is fine, but introduces sudo prompts for things MacStack does without escalation.

**12. Mac-only by design vs. cross-platform-curious**

MacStack is unapologetically Mac-only: `/opt/homebrew`, `mdfind`, `~/Library/Application Support`, `mas`, `/Applications`. You cannot use it on Linux. nix-darwin is also Mac-only by name, but the Nix language and Home Manager modules transfer to NixOS, so the same skill set scales cross-OS. If your "stack" might also need to configure a Linux dev VM or a remote build server, Nix wins outright.

---

### What nix-darwin + Home Manager can do that MacStack cannot

**1. Atomic generations and instant rollback**

Every `darwin-rebuild switch` produces a new *generation* — a fully-built, hash-identified system configuration in `/nix/store`. Activation atomically swaps the symlinks that point at the current generation. If something breaks, `darwin-rebuild switch --rollback` (or selecting an older generation at boot) instantly returns to the previous good state.

MacStack has no generations. `mack update` runs scripts in sequence; if one fails midway, the system is left in whatever partial state it reached. A bad change to `vscode/settings.json` in the stack is corrected by editing the stack again and re-running, not by rolling back. There is no "previous known-good system" to return to.

**2. Pinned, reproducible package closures (within Nix-managed packages)**

`flake.lock` pins every input — nixpkgs revision, the `nix-homebrew` revision, the Homebrew tap revisions — so two machines on the same lock build the *same* derivations bit-for-bit. For Nix-managed packages this means identical binaries from identical source trees with identical patches. Even for nix-homebrew managed casks this means the cask *definitions* are pinned, so what `brew install` resolves to is deterministic across machines on the same lock.

MacStack's Brewfile pins package names, not versions: two machines `mack update`-ing a week apart will get whatever Homebrew currently ships for `cursor` and `python@3.13`. Sometimes that is what you want (greedy upgrades, see point 4 above), sometimes it is exactly the bug you are trying to avoid.

**3. macOS system defaults as first-class declarative options**

nix-darwin exposes hundreds of `system.defaults.*` options: `system.defaults.dock.autohide`, `system.defaults.NSGlobalDomain.AppleICUForce24HourTime`, `system.defaults.finder.AppleShowAllExtensions`, `system.defaults.trackpad.Clicking`, `system.keyboard.enableKeyMapping`, sudo TouchID, firewall settings, software-update channel, etc. These are real `defaults write` calls and PAM edits, surfaced as typed options.

MacStack manages zero macOS system defaults. The user's Dock, Finder, trackpad, keyboard, login items, and sudo configuration are all unmanaged. That's a deliberate "lightweight, blends into any machine" choice (see `philosophy.md`) but it is a real capability gap for someone who wants their *whole* Mac, including system preferences, defined as code.

**4. launchd services as code**

`launchd.user.agents.foo = { command = "/path/bin"; serviceConfig = { … }; };` and the equivalent system-level form. Home Manager handles user agents; nix-darwin handles system daemons. Both manage installation, plist generation, loading, and unloading.

MacStack offers nothing for launchd. If your stack wants a periodic background job, a login agent, or a system daemon, you write the plist by hand and `launchctl` it, outside MacStack.

**5. Secrets management (sops-nix, agenix)**

Encrypted secrets committed to the same git repo as the rest of the config, decrypted at activation time using age or GPG keys present on the machine. Secrets land at the right path with the right mode, without ever existing in plaintext in the source tree.

MacStack explicitly excludes secrets from the stack (the README warns *not* to put `~/.cursor/cli-config.json` directly in the stack precisely for this reason). There is no encryption layer. If your stack needs to seed an SSH key, a `~/.netrc`, an API token in a config file, or a `gh auth` credential, Nix has well-trodden patterns for this and MacStack has none.

**6. Vast package universe beyond Homebrew**

nixpkgs has on the order of 100k packages — many development tools that Homebrew either lacks or carries in stale versions. Overlays let you patch any of them locally. You can build IDEs and AI tools from source with custom options.

MacStack relies on Homebrew (cask, formula) and the Mac App Store. If something isn't in any tap and isn't on MAS, you write a custom step in `update.sh` to fetch and install it manually. The same is true for nix-darwin if it's not in nixpkgs, but nixpkgs is enormous and very actively maintained.

**7. Multi-host fleet from one repo**

A single flake can declare `darwinConfigurations.mymac`, `darwinConfigurations.work-imac`, `darwinConfigurations.studio` — each importing shared modules and per-host overrides. `darwin-rebuild switch --flake .#mymac` evaluates only the right host's config. With remote build / `--target-host`, a single command applies to a remote Mac.

MacStack's per-machine variation today is "use a different stack" or branch the stack — there is no first-class "shared base + host overrides" mechanism (the philosophy doc lists a stack registry / inheritance as a roadmap item). For a fleet of Macs that are *almost* identical with a few per-host knobs, Nix's module system is far ahead.

**8. Dry-run, diff, and drift detection**

- `darwin-rebuild build --flake .` builds the new system without activating.
- `nvd diff /run/current-system result` (or `nix store diff-closures`) shows exactly which packages and versions changed.
- `nix flake check` verifies the configuration evaluates and type-checks.
- A `darwin-rebuild switch` that finds the current generation already matches does nothing — drift is detectable by definition.

MacStack has no dry-run, no diff, no drift detection. `mack update` always applies. There is no "what would this change?" mode and no way to ask "is this Mac still in spec?" short of re-running and reading the output.

**9. Generation-level package GC**

Old generations are kept until you `nix-collect-garbage`, and each generation's full closure is browsable. You can boot an old generation, copy a binary out of it, or diff its contents against the current one.

MacStack's only "previous state" tools are git on the stack folder (which is good and real) and `brew autoremove`. Nothing analogous to "boot last week's system to debug today's regression" is possible.

**10. Type-checked configuration with module composition**

The Nix module system has typed options, default values, conditional imports, override priorities (`mkDefault`, `mkOverride`, `mkForce`), and assertions. If you set `programs.git.userEmail` to an integer, evaluation fails before activation. Modules from different sources merge with documented precedence rules.

MacStack validates `macstack.json` against a JSON Schema (`scripts/stack_config/macstack.schema.json`) but everything else in the stack is shell scripts and raw JSON — no module composition, no override priorities, no per-key types.

**11. Pin Homebrew taps via nix-homebrew**

Even staying inside the Homebrew side of the world, nix-homebrew's killer feature is that it makes the *Homebrew tap* itself a flake input. So `homebrew/homebrew-cask` is at a specific revision in `flake.lock`, and the cask definitions don't drift between machines on the same lock. Two engineers on the same flake commit get the same `cursor` cask file.

MacStack's Brewfile gets whatever the current state of `homebrew/cask` says today.

**12. Remote Mac deployment**

nix-darwin's `--target-host` and tools like `deploy-rs` / `colmena` (with darwin support) let one operator switch the configurations of many Macs over SSH. MacStack assumes you're running `mack update` interactively on the machine being updated.

**13. Manage user shell environment as typed options**

`programs.zsh.shellAliases`, `programs.zsh.history.size`, `programs.zsh.oh-my-zsh.enable`, `programs.starship.enable`, `programs.direnv.enable`, plugin sets with declarative initialization order, completion generation. Everything composable across modules.

MacStack's shell config is one shell script (`zshrc.sh` in the stack) plus the `content_macstack.sh` defaults shipped with the tool. No typed options, no plugin manager integration, no composition — but also no Nix to learn, and the file is read top-to-bottom by zsh exactly as written.

---

### Summary

If you want a Mac (and possibly a Linux box, and possibly a fleet of them) to be *bit-for-bit reproducible*, *atomically updatable*, *rollback-able*, with *system defaults*, *launchd*, *secrets*, and *the entire nixpkgs universe* as managed surfaces, and you are willing to commit to the Nix language, the `/nix` volume, and a steeper learning curve — **nix-darwin + Home Manager + nix-homebrew is the right tool**, and MacStack is a toy by comparison on those axes.

If you want a Mac (this one Mac) set up end-to-end from a folder of plain JSON/JSONC, shell, and a Brewfile — with *non-destructive merging into the configs you already have*, *latest casks installed on every run* (not pinned), *Spotlight-aware IDE auto-discovery*, *pre-flight checks for `mas`*, *AI agent settings as a first-class category*, *bidirectional git repo sync*, and *no daemon, no APFS volume, no Nix language to learn* — **MacStack is the right tool**, and nix-darwin would either fight you on these things by design (no merging, no greedy upgrades, no Spotlight probing during evaluation) or require extensive activation-script escape hatches that defeat its own model.

The cleanest mental model: **nix-darwin is a system replacement that pretends macOS is a Nix target**; **MacStack is a thin convergence layer that pretends macOS is exactly itself**. nix-darwin treats the Mac as the substrate for a declarative ideal and is willing to replace large parts of it (the `/nix` volume, the symlink farm, the daemon) to make that ideal work. MacStack treats the Mac as a first-class operating system and only writes files the Mac itself was already going to read, with merging instead of replacement wherever possible.

Where they overlap (a Brewfile, a `~/.gitconfig`, a `~/.zshrc`, a VS Code `settings.json`), nix-darwin is more reproducible and MacStack is more forgiving. Where they don't overlap, each does things the other cannot — nix-darwin manages system defaults, launchd, secrets, and rollbacks that MacStack does not even attempt; MacStack auto-discovers IDEs, merges JSONC with comments preserved, syncs dev repos bidirectionally, and updates auto-updating casks greedily, none of which fits the Nix model.
