# Comparison to Workbrew (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to Workbrew (workbrew.com). What would be different (or impossible) if the user tried to do the same things with Workbrew? And what can Workbrew do that this project can not?"

---

## MacStack vs. Workbrew: A Detailed Comparison

Workbrew and MacStack both sit on top of Homebrew and both target Macs, but they live on different axes of the problem. Workbrew is a **commercial SaaS control plane** (Free / $10 per device per month Pro / custom Enterprise) that wraps Homebrew in a centrally-managed agent and pushes policies, inventory, vulnerability data, and remote commands to a fleet of Macs from a hosted Console. It is built by Mike McQuaid (Homebrew's lead maintainer) and is squarely aimed at IT/security organizations that already use an MDM (Jamf, Intune, JumpCloud, Hexnode, Kandji/iru, Fleet).

MacStack is a **local, single-user CLI** that converges one Mac toward a folder of plain config files (`Brewfile`, `zshrc.sh`, `vscode/settings.json`, `ai/coding/...`, `git/repos-folder-template/...`, `update.sh`). There is no backend, no account, no MDM, no agent, no telemetry, no policy server — the "stack" is just a directory you own and (usually) check into git.

So the comparison is less "feature for feature" and more "different categories of tool that overlap on a few square inches around `brew bundle`." The points below try to make that overlap and the gaps on either side concrete.

### What would be different (or impossible) with Workbrew

**1. Most of the MacStack surface area isn't Homebrew, and Workbrew only manages Homebrew**

Workbrew's scope, by design, is *the brew CLI and the packages it installs*. It does not touch — and has no model for — the things MacStack spends most of its code on:

- `~/.zshrc` composition via `mack shellenv` (sourcing `content_macstack.sh` + `content_stack.sh` + the user's `zshrc.sh`, plus prepending `$STACK/bin` to `PATH`)
- `~/.gitconfig` and `~/.gitignore_global` set-up (`scripts/git/update_git_config.sh`, plus the personal git settings declared in `macstack.json`)
- IDE settings and keybindings for VS Code, Cursor, Antigravity, Kiro, Windsurf, VSCodium, and Zed via JSONC-aware merge (`scripts/update_ide_settings.sh` + `scripts/json-merge/merge_jsonc.js`)
- AI agent configuration for Cursor CLI/IDE, Gemini CLI, and OpenCode — `cli-config_template.json`, `~/.cursor/rules/*`, `~/.gemini/settings.json`, `~/.gemini/policies/*`, `~/.config/opencode/opencode.json` (`scripts/update_ai_agent_settings.sh`)
- Bidirectional git repo sync of a `git/repos-folder-template/` tree (clone if missing, push if ahead, pull if behind, refuse + report on dirty/diverged) (`scripts/update-repos.sh`)
- Stack-defined custom `update.sh` hook for anything else

If you tried to put a MacStack stack into Workbrew, only the `Brewfile` would translate (as a "Default Packages" list). Everything else above is out of scope for Workbrew and would have to live in another tool — your MDM's profile payloads, an `osquery`/`munki` package, a chezmoi repo, a `defaults write` shell script in a Jamf policy, etc. There is no Workbrew equivalent of `update_ide_settings.sh` or `update_ai_agent_settings.sh`.

**2. JSONC-aware non-destructive merging into IDE / AI configs**

`merge_jsonc.js` deep-merges into existing JSONC files while preserving comments, key order, and user-only fields, and it set-unions arrays. That means the user can hand-edit `~/Library/Application Support/Cursor/User/settings.json` and `mack update` will leave their additions intact while updating the stack-managed keys.

Workbrew has no concept of merging into a non-Brewfile JSON file. The Console's "Brew Configurations" lets admins push `~/.homebrew/brew.env`-level toggles fleet-wide, but that's a different surface (Homebrew's own settings, not arbitrary JSON files an unrelated tool owns). To distribute IDE settings via Workbrew you would need to write a Brew Command that shells out to a custom script — Workbrew is the delivery channel, not the merge engine.

**3. Single-user, no account, no SaaS dependency**

MacStack runs entirely on the laptop. There is no login, no Console, no per-device fee, no telemetry sent anywhere, no agent process running between updates, and the "source of truth" for what should be on the machine is a folder you control on disk (and, if you choose, in git). If Workbrew shut down its Console tomorrow, every Workbrew-managed Mac would lose its policy plane. If `macstack.dev` disappears tomorrow, every existing MacStack install keeps working — `mack update` is just shell scripts in `$MAC_STACK_ROOT`.

This is also a privacy/sovereignty difference: Workbrew necessarily learns a complete inventory of every package, version, and license on every enrolled device (that *is* the product), and stores it in a SaaS backend. MacStack never reports anything anywhere.

**4. No MDM required — no MDM even possible**

Workbrew's deployment story is "your IT admin pushes the Workbrew installer through Jamf/Intune/JumpCloud, and the agent enrolls the device into the Console." That's zero-touch on the developer's side, and zero-touch *requires* an MDM-enrolled device. A MacStack user installs with one `curl | zsh` and answers the stack-folder prompt. You don't need to be enrolled in anything. You don't need an IT admin. You don't need a domain account. This makes MacStack usable on personal laptops, contractor machines, freelancer setups, and unmanaged Mac Studios — none of which are Workbrew's target.

Conversely, if your goal is "I have 200 Macs, I never want a developer to touch the installer," that's exactly Workbrew's pitch and not MacStack's.

**5. Mac App Store, casks, and the rest of the Brewfile pipeline behave the same — but with different ownership semantics**

Both tools resolve a Brewfile. MacStack runs `brew bundle install --no-upgrade --file <Brewfile>` after `brew upgrade --greedy` and a `mas list` pre-flight, then `brew cleanup` and a Caskroom installer purge. The user owns the Brewfile.

Workbrew's "Default Packages" feature also takes a Brewfile (and supports multiple lists per team/role, with an optional GitHub Action approval flow). But the **Console** owns the list — admins edit it server-side, and devices receive it. A developer cannot just edit the Brewfile on their laptop and have that be the source of truth; their machine will reconcile back toward what the Console says. This is the right tradeoff for an IT admin and the wrong one for a solo developer or an open-source stack like the Nohype AI Stack.

A MacStack stack can also be opinionated for a team (it's a folder in git you can require people to point at), but the convergence direction is "stack → machine" with no central authority enforcing it.

**6. AI agent rules, policies, and MCP-style configs as a managed surface**

Workbrew does not have a concept of "AI agent settings." The closest it could get is "install the `claude-code` formula via Default Packages." It cannot push `~/.cursor/rules/*.md`, `~/.gemini/policies/*`, an `opencode.json`, `cli-config.json` defaults, or (per `philosophy.md`) the future MCP server configurations as a category. Those would all have to be done via remote Brew Commands shelling out to ad-hoc scripts.

This is the largest thematic gap. MacStack's stated direction is to be an AI-native Mac provisioning tool; Workbrew's is to be a secure software delivery platform for `brew`. Even where they overlap on installing the agent CLI binary, Workbrew has nothing to say about how that agent is configured.

**7. Git repository sync (clone / push / pull / report)**

`update-repos.sh` walks `git/repos-folder-template/`, reads each `git-repos.txt`, and for every repo URL clones if missing, pushes if ahead, pulls if behind, and aggregates a "needs manual attention" report for dirty or diverged repos at the end. Workbrew has no equivalent — it is a package manager control plane, not a developer-workspace manager. You'd reconstruct this with a Brew Command pointing at a custom script, but at that point Workbrew is just a remote-execution channel, not the tool doing the work.

**8. Cost model**

MacStack is free. Workbrew is free for the "visibility + zero-touch + bootstrapping" tier and **$10/device/month** for Pro (policies, remote management, vulnerability remediation, MDM inventory sync), with custom Enterprise pricing for SSO, RBAC, automated uninstalls, private taps, data residency, and SLAs. For a 50-developer team that's $6,000/year minimum at Pro; for a solo developer or a small AI-research team, MacStack is the only one of the two that makes economic sense. For a 500-Mac regulated enterprise that needs CVE remediation and audit logs, MacStack is not even competing.

**9. "Least privilege Homebrew" / non-sudo brew on Standard accounts**

Workbrew's wrapper lets devices run as macOS Standard Account Users while still using `brew` — the Workbrew agent handles the privileged parts. That's a real security win that matters in regulated industries. MacStack assumes the user is an admin on their own Mac (the typical developer-laptop case) and shells out to plain `brew` directly. If your security posture requires "no developer is ever a local admin," MacStack is the wrong tool.

**10. Stack-as-folder vs. policies-as-database-rows**

A MacStack stack is a folder of obviously-named files. Anyone — a teammate, an LLM, a new hire — can `cat` the files and immediately understand what the machine will look like after `mack update`. Diffing two stacks is `git diff`. Forking a stack is `git clone`. Inheriting a stack from a registry (per the philosophy doc's roadmap) is straightforward.

A Workbrew workspace is a hosted database of Default Packages, Policies, Brew Commands, Brew Configurations, Device Groups, allowlists, and denylists, plus an Activity Log. Reproducible? Yes, within the Console. Portable to a different Console / vendor / fork? No — you'd export JSON/CSV via the API and re-build it elsewhere. Inspectable by a teammate without a Console login? No.

---

### What Workbrew can do that MacStack cannot

**1. Fleet-wide visibility and inventory**

The whole reason Workbrew exists. You get a Console showing every formula, cask, version, tap, and license installed across every enrolled Mac, who has what, when it was installed, and how often it's run. Per-device drill-down. Command analytics. MacStack has no notion of "the fleet" — each machine knows about its own state and nothing else. If you want to answer "how many of our laptops have OpenSSL 3.0.x?" MacStack cannot tell you and Workbrew can.

**2. Vulnerability detection (CVE-aware) and one-click remediation**

Workbrew correlates installed Homebrew packages against CVE data, surfaces affected devices in the Console, and on Pro/Enterprise will auto-upgrade vulnerable packages to a patched version (Enterprise can also auto-uninstall on policy violation). MacStack has no security model — `brew upgrade --greedy` updates everything that has an upgrade, but there is no "this CVE is critical, upgrade just this, on a schedule, fleet-wide" capability.

**3. Remote command execution and policy enforcement**

From the Console an admin can:
- Run arbitrary `brew` commands on any device or device group on demand or on a schedule (Workbrew "Brew Commands")
- Enforce allowed taps, cask allowlists, formula/license denylists with optional auto-uninstall
- Push fleet-wide Brew Configurations
- Set up CLI-driven exception requests when a developer hits a denylist (admin approves in Console)

MacStack has no remote-anything. Updates happen when the user (or a launchd job they wrote) runs `mack update` locally. There is no way to push a hotfix to all machines from a central place.

**4. MDM integration (Jamf, Intune, JumpCloud, Hexnode, Microsoft Intune, Fleet, iru, Mosyle/Kandji guidance)**

Workbrew syncs device groups and identifying metadata (serial numbers, hostnames) from the MDM, so the same groups you use to target MDM payloads target Workbrew policies. MacStack does not know what an MDM is. If your org runs on MDM-driven device targeting, Workbrew slots in; MacStack would coexist as an unmanaged additional layer.

**5. Audit log, RBAC, SSO (Enterprise tier)**

The Activity Log (workbrew 1.7) tracks create/update/destroy events for memberships, devices, Brew Commands, Default Packages, Policies, installed packages, vulnerability changes — with actor attribution, filterable, exportable to a SIEM via the API. RBAC and SSO are in the Enterprise tier. MacStack has no identity model at all (the only "auth" is whoever is logged into the Mac). If you need to demonstrate compliance ("show me who pushed which package to which device on which date"), Workbrew has it and MacStack has nothing to show.

**6. Alerting (Slack, email, webhooks)**

Workbrew can alert on any policy violation, vulnerability detection, brew event, or remote command result. MacStack prints to the terminal. The closest MacStack analog is `update-repos.sh`'s end-of-run "needs manual attention" report — and that's only visible to the person who just ran it.

**7. Private Taps cataloged in the Console for distributing internal tooling**

Workbrew 1.7 indexes formulae and casks from enabled private taps so admins can target internal packages in policies and Default Packages alongside public packages. MacStack can absolutely install from a private tap (any `brew tap` line in your Brewfile works), but there's no fleet-level "this internal CLI tool was rolled out to engineering on day one and 142/150 devices have it" visibility.

**8. REST API and bulk data export**

Workbrew exposes everything in the workspace via JSON/CSV export and a REST API for custom dashboards, SIEM integration, and trigger-from-CI workflows. MacStack has no API — it has a CLI on one machine and the filesystem.

**9. Approval workflow for Default Packages via GitHub Action**

Workbrew ships a GitHub Action that turns Default Packages into a PR-reviewed artifact, so changes to "what every new dev gets on day one" go through code review before reaching devices. A MacStack stack lives in git and gets the same benefit *if you put it in a repo*, but Workbrew bakes the workflow in and ties the approved artifact to the rollout step.

**10. Zero-touch onboarding for non-developers**

If the device's user is *not* a developer who can run a `curl | zsh` command — say, a designer, a finance hire, a contractor on a managed laptop — Workbrew (via MDM) sets up the brew environment with no user interaction at all. MacStack requires the user to run a command. For genuinely zero-touch enterprise onboarding, MacStack does not compete.

**11. Standard-Account / non-sudo `brew`**

As above — Workbrew's wrapper lets `brew` work without granting the user admin rights on their own machine. MacStack does not solve this problem; it inherits Homebrew's normal permission model.

---

### Summary

Workbrew and MacStack are not really substitutes. They share a base layer (Homebrew + Brewfile) and diverge on every axis above it.

- **Same use case:** "Install a known list of Homebrew packages on a Mac." Both do this. For the *Brewfile slice alone*, Workbrew adds fleet visibility, policies, vulnerability remediation, and remote control; MacStack adds nothing — the Brewfile pipeline is one of several things it does, not its centerpiece.

- **Where MacStack wins:** anything *not* a Homebrew package — shell composition, git config, IDE settings (with non-destructive JSONC merge across six VS Code-family IDEs and Zed), AI agent rules and policies, repo-folder sync, custom `update.sh` per stack — plus the entire "single-user, no SaaS, free, runs anywhere, the stack is a folder I own" model. This is roughly 80% of MacStack's code.

- **Where Workbrew wins:** anything *fleet-* or *security-shaped* — inventory, CVE remediation, policy enforcement with auto-uninstall, remote command execution, MDM integration, RBAC/SSO, audit logs, alerting, Console dashboards, zero-touch enrollment, Standard-account brew without sudo. This is the entire reason Workbrew is a paid product.

- **Where they could coexist:** a regulated org running Workbrew for fleet-level package governance could still let individual developers run MacStack on the same Macs to manage their personal shell, IDE, and AI agent configs. The two would not collide except on the Brewfile, and even there MacStack's `brew bundle install --no-upgrade` is additive enough to coexist with a Workbrew-managed superset (though the org would probably want to designate one of them as the source of truth for `Brewfile` content to avoid surprises).

Put bluntly: **Workbrew is "Homebrew with an enterprise control plane." MacStack is "everything on a developer's Mac as a folder."** The one piece they share is the cheapest piece of either tool's value, and outside that piece they barely overlap.

The MacStack philosophy doc imagines a future "team-wide AI configuration" and "stack registry" direction that, *if it grew a hosted layer*, would start to overlap with Workbrew's fleet plane — but only on the AI-agent / IDE / dotfile axis Workbrew explicitly does not address, not on the brew governance axis Workbrew owns. The two would still be in different aisles of the same store.
