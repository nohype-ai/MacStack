# Comparison to MDM (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to MDM (Mobile Device Management). What would be different (or impossible) if the user tried to do the same things with MDM? And what can MDM do that this project can not?"

---

MDM (Jamf Pro, Mosyle, Kandji, Microsoft Intune, Apple Business Manager + a vendor of choice, etc.) and MacStack both end up "configuring Macs", but they sit on opposite ends of the control spectrum. MDM is a fleet-management framework Apple built for *organizations to enforce policy on devices they own*. MacStack is a CLI a *user runs on their own Mac to converge it toward a stack they author themselves*. The philosophy doc is explicit about this: "MacStack is not MDM. It does not fight the user, does not require IT approval, and does not lock things down."

The contrast below uses Apple's MDM protocol and typical commercial MDM vendors as the reference point.

## What MacStack does that MDM can't (or can't do well)

1. **Configure shell, dotfiles, and the user's home directory.** MacStack writes to `~/.zshrc`, `~/.gitconfig`, `~/.gitignore_global`, `~/.config/...`, IDE user settings under `~/Library/Application Support/...`, and AI agent configs under `~/.cursor`, `~/.gemini`, `~/.config/opencode`. Apple's MDM protocol has **no commands for any of this**. MDM speaks in Configuration Profiles (`.mobileconfig`), Declarative Device Management declarations, and a fixed set of MDM commands (InstallApplication, InstallProfile, EraseDevice, etc.). None of those touch a user's dotfiles. Vendors work around this by shipping a per-device agent that runs scripts as root or as the logged-in user (Jamf Composer/Policies, Mosyle's Custom Commands, Kandji's Custom Scripts, Munki, etc.) — but at that point you're writing the same kind of shell scripts MacStack already gives you, just wrapped in a vendor's UI and queued through APNs.

2. **Idempotent, *non-destructive* merging into existing files.** The README emphasizes: "preserves everything else – even individual pre-existing entries in dotfiles." `merge_jsonc.js` does deep, comment-preserving JSONC merges into VS Code / Cursor / Zed settings. MDM's mental model is the opposite: a Configuration Profile is *installed* and *removed* as a unit — when removed, every key it set is reverted. Profiles overwrite, they don't merge into a user's hand-tuned JSONC. For files MDM doesn't natively understand (which is most of what MacStack manages), the only path is "run a script", which loses MDM's profile lifecycle entirely.

3. **Homebrew, Brewfile, and the cask ecosystem as the source of truth.** MacStack leans on `brew bundle`, including casks and `mas` for Mac App Store apps. MDM has `InstallApplication` (for VPP/App Store apps assigned via Apple Business Manager) and `InstallEnterpriseApplication` (for signed `.pkg`s), but no native concept of Homebrew. Vendors bolt on "patch management catalogs" (Jamf App Catalog, Kandji Auto Apps, Mosyle's catalog) to install GUI apps from curated `.pkg`s — useful, but a parallel universe to Homebrew. Installing a Homebrew CLI tool like `pyenv`, `claude-code`, `gh`, or a font cask via MDM means shipping a script that runs `brew install` as the user, which is exactly what MacStack already does — natively and without the MDM round trip.

4. **AI agent configuration as a first-class concern.** MacStack manages Cursor CLI/IDE rules, Gemini CLI policies, OpenCode configs, MCP servers (planned). No MDM vendor models any of this. The best MDM can do is push a script that drops files into the right spots — which is, again, what MacStack already does, plus schema-aware merging.

5. **Git repository management.** `update-repos.sh` clones missing repos, syncs clean ones, and reports diverged/dirty ones for manual attention. MDM has no concept of "the user's working repos." A script-based workaround would have to deal with credentials (SSH keys, GitHub tokens) per-user, which is exactly the kind of user-context problem MDM is awkward at.

6. **No vendor lock-in, no server, no enrollment.** MacStack is a folder you own, version-control, and copy. There's no MDM server to license, no APNs round trips, no enrollment profile, no Apple Business Manager tenant, no DEP/ADE token. `curl … | zsh` and you're set up. For a solo developer or a small team that just wants reproducible Macs, MDM is enormous overhead.

7. **Works on personal machines without surrendering control.** MDM enrollment grants the operator (typically IT/employer) extensive powers: remote wipe, supervised mode, restrictions, payload installation, location queries (on supervised devices). Putting MDM on a personal Mac to get reproducible setup means accepting that whole governance model. MacStack is just a script the user runs — no remote actor has any standing authority over the machine.

8. **Live in the user's `PATH` next to the user's other tools.** `mack`, `gitty`, `silent`, plus everything in the stack's `bin/`, are added to `PATH` so they coexist with everything the user has. MDM doesn't have an equivalent — it ships files and runs commands, but it doesn't *belong* to the user's interactive shell environment.

9. **Author-the-stack workflow.** A MacStack stack is a folder of human-readable, hand-edited files (`Brewfile`, `zshrc.sh`, `vscode/settings.json`, `ai/coding/cursor/rules/*.md`). The author iterates locally and re-runs `mack update`. MDM's authoring loop is "edit profile or script in vendor UI → assign to scope → wait for check-in / push → debug from logs in the console." Iteration latency and friction are dramatically higher.

10. **Open, scriptable, and inspectable.** Every step of `mack update` is a shell or JS script you can read in this repo. MDM behavior is a mix of Apple's MDM protocol (mostly opaque to the end user), the vendor's agent (often closed-source), and configuration profiles (XML, but with vendor-specific UI on top).

## What MDM can do that MacStack can't (or doesn't try to)

1. **Remote, unattended fleet management at scale.** This is MDM's reason for existing. Push a profile to 5,000 Macs, watch compliance roll in, scope by department/site/OS version, retire a device, remote-wipe a lost laptop. MacStack runs locally on one Mac at a time — driving it across a fleet is a "wrap it in your own automation" problem (Ansible, SSH, image, …).

2. **Enforce policy the user can't bypass.** Configuration profiles signed by the MDM and installed under supervision are not removable by the user. MacStack is opt-in; the user runs `mack update`, can stop running it, can edit the resulting files freely. For compliance scenarios (SOC 2, HIPAA, ISO 27001, government / regulated industries) where you need *enforced* settings, only MDM qualifies.

3. **Restrictions payloads.** Disable iCloud, disable AirDrop, force FileVault, require a passcode of certain complexity, block specific apps, restrict USB media, enforce screen-lock timing, configure software-update deferral, lock the firmware, disable Touch ID for unlock — all standard MDM payloads. None of this is in MacStack's scope, and most of it can *only* be done via MDM (Apple gates many restrictions behind supervision + MDM).

4. **Apple-supervised features.** Activation Lock bypass, automated DEP/ADE enrollment out of the box, Setup Assistant skip-pane configuration, Lost Mode, remote restart/shutdown, Bootstrap Tokens, Managed Apple IDs, and Volume Purchase Program (VPP) app assignment all require MDM + Apple Business/School Manager. MacStack has no Apple-side privileged channel — it's just a tool a user runs after they've finished Setup Assistant themselves.

5. **Device inventory and reporting.** MDM continuously collects hardware inventory, installed-app inventory, OS version, FileVault status, security posture, geolocation (on supervised devices), and reports it to a central console. MacStack doesn't report anything anywhere; there's no central view of "which Macs ran which version of the stack."

6. **OS update orchestration and deferral.** MDM can defer macOS updates by N days, force install updates by a deadline, and (with Declarative Device Management) report rich update state. MacStack updates Homebrew packages but does not manage macOS updates themselves.

7. **Certificate, Wi-Fi, VPN, and 802.1X provisioning.** MDM payloads can push enterprise root CAs into the system Keychain, pre-configure Wi-Fi SSIDs with certificate auth, deploy VPN profiles, configure email/Calendar/Exchange accounts, and provision SCEP/ACME-issued client certs. MacStack doesn't touch any of this.

8. **FileVault key escrow.** MDM can enable FileVault and escrow the recovery key to the MDM server so IT can recover an encrypted disk if the user is locked out. MacStack has no analogue — disk encryption and recovery keys remain entirely the user's responsibility.

9. **Run as root with privileged-helper context, on schedule, without the user's involvement.** MDM agents run as root and can execute scripts on a schedule, on check-in, on enrollment, or on demand. MacStack runs when the user types `update`. Background, scheduled, or "on first login" execution is something the user would have to set up themselves (e.g., a launchd job calling `mack update`).

10. **Managed Apple Account and identity provisioning.** MDM (with ABM/ASM) can provision Managed Apple Accounts, federate them to Google Workspace or Entra ID, and bind devices to a corporate identity. MacStack expects a personal Apple ID the user already signed into.

11. **Lost / stolen device response.** Lock, locate, sound an alarm, remote-wipe — only MDM (with supervision) can do this end-to-end. MacStack has no remote channel at all.

12. **Audit, compliance evidence, and chain-of-custody.** MDM consoles produce reports auditors can consume: who is enrolled, what policies are applied, when they were applied, FileVault posture per device, etc. MacStack produces git history of the stack repo, and that's it — fine for a personal setup, insufficient for regulated environments.

## Summary

MDM and MacStack don't really compete; they answer different questions. MDM answers *"how does an organization remotely enforce, monitor, and recover devices it is responsible for?"* MacStack answers *"how does a developer (or a small team) keep a Mac configured the way they want, declaratively and reproducibly, without giving up control?"* The closest they come to overlapping is when an MDM vendor's "run this script as the user" capability is used to do MacStack-style provisioning — and even then, MacStack does the actual provisioning *better* (idempotent JSONC merges, Brewfile-native, AI-agent-aware, no APNs round trip), while MDM provides the *delivery and policy framework* MacStack deliberately has no opinion about. In practice, the two can complement each other: an organization could use MDM for security posture, FileVault escrow, OS update policy, and certificate provisioning — and let MacStack own the developer-experience layer on top.
