# Comparison to Strap (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to Strap ([github.com/MikeMcQuaid/strap](https://github.com/MikeMcQuaid/strap). What would be different (or impossible) if the user tried to do the same things with Strap? And what can Strap do that this project can not?"

---

## MacStack vs. Strap: A Detailed Comparison

Strap and MacStack come from very different traditions. Strap is GitHub's "hand a new hire a Mac and let them be productive in 20 minutes" bootstrapper — a single ~440-line bash script (`bin/strap.sh`) plus a small Sinatra web app that personalizes the script per user via GitHub OAuth. It is run **once**, on **day one**, against a **fresh Mac**, and its contract with the user ends shortly after Homebrew is on disk and a `dotfiles` repo has been cloned. MacStack is the opposite shape: a CLI (`mack`) you run **continuously**, against an **established Mac**, that converges the machine toward a declarative `STACK` folder you own.

That difference in shape — one-shot bootstrap vs. continuous convergence — is the source of almost every concrete difference below.

### What would be different (or impossible) with Strap

**1. No declarative, versionable stack folder**

The Strap model has exactly two configurable surfaces:

- A `dotfiles` repo at `https://github.com/<user>/dotfiles` (cloned to `~/.dotfiles`), with up to three optional executable hooks: `script/setup`, `script/bootstrap`, and `script/strap-after-setup`.
- A `homebrew-brewfile` repo at `https://github.com/<user>/homebrew-brewfile` (or a `~/.Brewfile`), passed to `brew bundle --global`.

Everything beyond that is *your shell scripts inside the dotfiles repo*. There is no MacStack-style `STACK` folder with named slots like `vscode/settings.json`, `zed/keymap.json`, `ai/coding/cursor/rules/`, `git/repos-folder-template/`, or `macstack.json`. To get the same effect with Strap, you'd put all of that logic into `script/setup` as hand-written bash, and the "schema" of your stack would be implicit in that script. MacStack's `scripts/stack_config/macstack.schema.json` (which gives editors auto-completion for the stack config) has no Strap equivalent.

**2. Continuous, idempotent updates as a first-class workflow**

Strap calls itself idempotent and it technically is — you can re-run `bin/strap.sh` and most steps will skip. But the *intent* is one-shot. There's no `strap update`, no `strap update-repos`, no `strap brew-clip`, no subcommand structure at all. `mack update`, by contrast, is the daily-driver operation:

- `brew upgrade --greedy` so casks marked `auto_updates true` (Cursor, Raycast, browsers) and `version :latest` (Apple Fonts) actually receive updates.
- `brew bundle install --no-upgrade --file <Brewfile>` to install only what's missing, rather than upgrading everything in the bundle.
- `brew cleanup` plus a Caskroom installer purge to reclaim disk.
- `mack brew-clip` to remove packages that are no longer in the stack's Brewfile.
- `mack brew-force` to re-adopt manually-installed apps into Homebrew management.

Strap's Brewfile step is just `brew bundle check --global &>/dev/null || brew bundle --global` — a one-liner. There's no greedy flag, no cleanup pass, no removal of packages no longer wanted, no `mas` pre-flight (`scripts/homebrew/ensure_mas_works.sh`). You'd have to write all of that into `script/strap-after-setup` and remember to re-run Strap.

**3. Non-destructive merging into existing JSON/JSONC**

This entire category does not exist in Strap. MacStack's `scripts/json-merge/` (with `merge_json.sh`, `merge_jsonc.js`, `strip_jsonc.pl`) deep-merges a stack template into a live `settings.json` / `keybindings.json` / `cli-config.json` while preserving comments, key order, and user-only fields. The IDE/AI updaters (`update_ide_settings.sh`, `update_ai_agent_settings.sh`) all funnel through it, so a stack can declare *only* the keys it cares about and leave the user's hand-edits untouched.

In Strap, you have whatever your dotfiles' `script/setup` decides to do. The path of least resistance is `cp` (clobber) or `ln -s` (replace), which is why most Strap-adjacent dotfile repos *own* the whole settings.json. Doing what MacStack does requires re-implementing the JSONC merger inside your dotfiles.

**4. IDE/editor auto-discovery and fan-out**

`update_ide_settings.sh` checks `/Applications`, `~/Applications`, and `/System/Applications`, falls back to Spotlight (`mdfind`), then writes settings/keybindings into `~/Library/Application Support/<App>/User/` for Visual Studio Code, Cursor, Antigravity, Kiro, Windsurf, and VSCodium — from one source pair. It does the same for Zed at `~/.config/zed/`.

Strap has no concept of an IDE. The closest analog is `script/setup` doing per-app `cp` calls, with hard-coded application names. Auto-discovery, the fan-out from one source to six destinations, the merge semantics — all of it is on you.

**5. AI agent configuration as a managed surface**

MacStack's `update_ai_agent_settings.sh` and stack layout (`ai/coding/cursor/{cli-config_template.json,rules/}`, `ai/coding/gemini/{settings.json,policies/}`, `ai/coding/opencode/opencode.json`) treat Cursor, Gemini CLI, and OpenCode as a first-class category, with merge-vs-tree-copy distinctions and per-tool gates ("only update if `~/.cursor` exists"). Strap pre-dates this entire ecosystem and has nothing for it. To replicate, you'd add it to your dotfiles' `script/strap-after-setup`. Possible, but again, hand-rolled per user.

**6. Bidirectional git repo sync**

`scripts/update-repos.sh` walks `git/repos-folder-template/`, reads each `git-repos.txt`, and for every URL it:

- clones if missing,
- *pushes if ahead*,
- *pulls if behind*,
- refuses to act on dirty or diverged repos and reports them at the end.

Strap clones exactly two well-known repos (`dotfiles`, `homebrew-brewfile`) by convention and does a `git pull --rebase --autostash` on the dotfiles one. There is no general "keep N working repos in sync" facility, no template-driven layout, no push side. You'd write all of it.

**7. Stack-driven `~/.zshrc` composition without owning the file**

MacStack appends *one* line to `~/.zshrc`: `eval "$(mack shellenv)"`. `mack shellenv` then dynamically composes `content_macstack.sh` (PATH for `~/.local/bin` and Homebrew, prompt, history-off, git aliases) plus `content_stack.sh` (sources the stack's `zshrc.sh` and adds `$STACK/bin` to `PATH`). Changing shell behavior between runs touches the stack, never `~/.zshrc`.

Strap doesn't manage shell config at all. Whatever your `script/setup` writes to `~/.zshrc` is what's there, and re-runs of Strap won't reconverge it. Tools downstream (Homebrew installer, conda init, asdf, nvm) will append to `~/.zshrc` and your dotfile setup script either fights them or ignores them.

**8. Per-tool gating and the "blend in" property**

Almost every MacStack updater is gated on the tool actually being present: `[[ -d ~/.cursor ]]`, `app_exists "Cursor"`, `[[ -d "$zed_config_dir" ]]`, `[[ -d ~/.gemini ]]`. The same stack file (`vscode/settings.json`) does the right thing on a Mac that has only VS Code, only Cursor, all six VS Code-family IDEs, or none. Nothing is forced on a machine that doesn't already have the target tool.

Strap doesn't have this property because it doesn't manage these tools at all. The closest equivalent in dotfile-script land is `command -v cursor && cp …`, which works but has to be written per-tool, every time.

**9. Stable CLI surface vs. one shell script**

MacStack ships a real CLI (`bin/mack`) with subcommands: `update`, `update-repos`, `brew-clip`, `brew-force`, `backup-zed`, `shellenv`, `config`, `help`. There's also `bin/gitty` and `bin/silent`. The user's stack can drop more commands into its own `bin/` (which MacStack auto-adds to `PATH`).

Strap is a single bash file you invoke as `bash bin/strap.sh`. Anything beyond running it end-to-end requires you to write your own wrapper.

**10. Pre-1.0 and Mac-only, but not narrower than Strap**

Both tools are Mac-only by construction. The relevant difference is that *Strap is narrower in scope by design* (its README explicitly lists "Out of Scope Features"), where MacStack's scope deliberately covers Homebrew + casks + MAS + IDE settings + AI agent settings + git repo sync + shell + global git config. If your needs are inside Strap's scope you're fine; the moment they aren't, Strap routes you into "write more bash in `script/setup`."

---

### What Strap can do that MacStack cannot

**1. macOS security hardening as a built-in step**

This is Strap's signature move and MacStack has nothing equivalent. In one run, Strap:

- Configures **TouchID for `sudo`** by editing `/etc/pam.d/sudo_local` (or `/etc/pam.d/sudo` on older macOS) to add `pam_tid.so`.
- Sets the **screensaver password requirement** (`com.apple.screensaver askForPassword=1`, `askForPasswordDelay=0`).
- Enables the **macOS application firewall** (`com.apple.alf globalstate=1`) and loads the `alf` LaunchDaemon.
- Sets a **"Found this computer?" login window message** with the user's name + email (`/Library/Preferences/com.apple.loginwindow LoginwindowText`).
- Enables **FileVault full-disk encryption** (`fdesetup enable -user "$USER"`) and saves the recovery key to `~/Desktop/FileVault Recovery Key.txt`.

MacStack does none of this. It is, by philosophy, "lightweight, not locked down" — security posture is left to the user. If you want a Mac to come up hardened on day one, Strap does that and MacStack does not.

**2. Xcode Command Line Tools installation + license agreement**

Strap installs CLT non-interactively by writing the `/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress` placeholder, parsing `softwareupdate -l`, and `softwareupdate -i`-ing the right CLT package. It then runs `xcodebuild -license` to accept the license. MacStack assumes Homebrew is or will be installable (and the official Homebrew installer prompts for CLT itself), but does not own this step or accept the license. On a truly fresh Mac, Strap is more autonomous here.

**3. Homebrew install via the raw `git init` + `reset --hard origin/master` path**

Strap installs Homebrew without invoking the official installer — it `mkdir`s `Cellar Caskroom Frameworks bin etc include lib opt sbin share var`, `chown`s them, then `git init` + `git fetch` + `git reset --hard origin/master` against `https://github.com/Homebrew/brew`. This avoids the `curl … | bash` pattern entirely and works without internet-fetched scripts. MacStack's `setup.sh` (per the README, distributed via `https://macstack.dev/setup.sh | zsh`) bootstraps Homebrew the conventional way.

**4. macOS software updates**

Strap runs `softwareupdate --install --all` (gated by `STRAP_NO_SOFTWAREUPDATE`/`STRAP_CI`). MacStack does not invoke `softwareupdate` at all — the user is expected to handle macOS updates via the system UI.

**5. A web app that personalizes the script via GitHub OAuth**

Strap's defining UX feature is the Sinatra web app at `https://strap.mikemcquaid.com/`. The user signs in with GitHub, the server fills in `STRAP_GIT_NAME`, `STRAP_GIT_EMAIL`, `STRAP_GITHUB_USER` (and optional `CUSTOM_HOMEBREW_TAP`, `CUSTOM_BREW_COMMAND`) into the script, and hands them a personalized `strap.sh` to download and run. For *organizations*, the env vars `STRAP_BEFORE_INSTALL`, `STRAP_ISSUES_URL`, etc. let the company host their own Strap server with their own pre-install instructions.

MacStack's bootstrap is the much simpler `curl -fsSL https://macstack.dev/setup.sh | zsh`, then `mack config` to point at a stack folder. There is no per-user OAuth flow, no server-side personalization, no organizational Strap-portal equivalent. (The roadmap mentions a "stack registry" with inheritance — that's the closest direction MacStack is heading, but it's not built.)

**6. `gh auth login` as a built-in step**

If `gh` is installed and not authenticated, Strap runs `gh auth login --git-protocol https --hostname github.com --web`. MacStack does not touch `gh` auth at all — partly because it explicitly avoids handling secrets/credentials.

**7. `caffeinate` to prevent sleep during setup**

Strap runs `caffeinate -s -w $$ &` so the machine doesn't sleep mid-install. MacStack does not — generally fine because `mack update` is shorter and re-runnable, but on a long fresh-install run the lack of `caffeinate` is a real difference.

**8. Sudo handling with `--askpass` and TouchID detection**

Strap has a careful sudo flow: if `pam_tid.so` is configured, it skips the password prompt; otherwise it builds a `mktemp`'d askpass script and re-validates sudo at every log step (`sudo_refresh`) so long-running operations don't hit a stale credential. MacStack avoids needing sudo for almost everything (Homebrew at `/opt/homebrew` is user-owned on Apple Silicon), so it doesn't have or need this machinery — but the corollary is that anything actually needing root (the security hardening above, MAS-installed system extensions, etc.) is out of scope.

**9. `STRAP_CI` and structured failure reporting**

Strap has a `STRAP_CI` env var that skips destructive/long steps (FileVault, software updates) and a `STRAP_DEBUG` mode with `set -x`. Failures print `!!! $STRAP_STEP FAILED` with the step name and an issue-tracker URL via the `STRAP_ISSUES_URL` env var. MacStack uses `set -e -u` and lets failures bubble up; there's no step-name reporting or CI mode.

**10. Used by GitHub at scale and battle-tested**

Strap has been GitHub's onboarding tool for years (it explicitly replaced Boxen). It's been hammered by thousands of new-hire setups across many macOS versions. MacStack is pre-1.0 and single-vendor. For the narrow job of "set up a fresh Mac with security defaults, Xcode CLT, Homebrew, dotfiles, and a Brewfile, in one shot, on day one," Strap is the more proven tool.

---

### Summary

If you want the **first 30 minutes after a Mac comes out of the box** — TouchID for sudo, FileVault on, firewall up, Xcode CLT installed, Homebrew bootstrapped, Brewfile applied, dotfiles cloned, `gh` authenticated — and you don't expect to re-run the tool weekly: **Strap is the right tool**. MacStack offers nothing for the security/Xcode/`softwareupdate`/OAuth-personalization layer.

If you want the **next two years of that Mac** — adding/removing Homebrew packages, keeping casks updated with `--greedy`, merging IDE and AI-agent settings non-destructively across six VS Code-family editors and three AI CLIs, syncing a pile of dev repos, evolving your shell environment, and doing all of the above from a folder of plain files you can read at a glance: **MacStack is the right tool**. Strap has nothing for any of that beyond "write more bash in your dotfiles repo."

The cleanest mental model is: **Strap is a one-shot Mac onboarder; MacStack is a continuous Mac convergence engine.** They overlap on Homebrew bootstrap, Brewfile install, and basic git config, and that's about it. The two could plausibly be used together — Strap on day one for security + Xcode + Homebrew, MacStack from day two onward for everything else — and they would not step on each other.
