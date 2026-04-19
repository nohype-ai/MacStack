# Comparison to Virtual Machines (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to virtual machines. What would be different (or impossible) if the user tried to do the same things with virtual machines (for example using Tart)? And what can virtual machines do that this project can not?"

---

VMs and MacStack overlap on the surface ("set up a working macOS environment") but sit on opposite sides of a fundamental boundary: a VM gives you *another* Mac, MacStack configures *your* Mac. Tart is the most relevant point of comparison because it's the modern Apple-Silicon-native VM tool (built on Apple's Virtualization framework, OCI-distributed images, popular for CI). The contrast below uses Tart as the concrete example, but most points apply to UTM, VMware Fusion, Parallels, and Apple's own `Virtualization.framework` too.

## What MacStack does that VMs (Tart) can't (or can't do well)

1. **Configure the Mac the user actually lives in.** MacStack writes to `~/.zshrc`, `~/.gitconfig`, installs fonts that Figma and Pages can use, sets up `mack`/`gitty`/`silent` in the host `PATH`, and configures Cursor/Zed/VS Code where the user opens real projects. A VM configures a *different* OS instance the user has to deliberately step into. The user's daily Terminal, Xcode, Slack, and browser don't see any of it.

2. **Apple ID / iCloud / Mac App Store.** MacStack expects the user's existing iCloud login and uses `mas` to install App Store apps under their Apple Account. macOS guest VMs are deliberately restricted by Apple here: signing in to iCloud and the Mac App Store from a Virtualization-framework guest is unreliable to outright blocked, and Tart's docs explicitly call this out. App Store apps installed in a VM are tied to whatever account you manage to sign in with, separate from the user's real one.

3. **Apple's "two VMs per host" license cap.** macOS's EULA limits Apple Silicon hosts to running two macOS guests at a time. MacStack is just configuring the host, so the cap is irrelevant. Anyone trying to replicate MacStack's "every developer gets their own configured environment" pattern via VMs runs into this limit on shared hardware.

4. **Full native hardware access — Metal, ANE, unified memory.** This is the big one for the AI-tooling angle (`ai/coding/*`, the philosophy doc's emphasis on local inference). On the host, Ollama/LM Studio/llama.cpp get unrestricted Metal and Apple Neural Engine access through unified memory. macOS guests under `Virtualization.framework` have limited GPU passthrough, no Neural Engine access, and a memory copy boundary. The exact thing MacStack is positioned to manage well — local AI inference on Apple Silicon — is what VMs degrade most.

5. **Idempotent overlay onto existing state.** From the README: "preserves everything else – even individual pre-existing entries in dotfiles." `merge_jsonc.js` exists specifically to merge into hand-tuned IDE configs without clobbering them. The VM model is the opposite: build a clean image, throw away state. Merging into a long-lived, hand-customized environment isn't what `tart clone` is for.

6. **Touch ID, Keychain, code-signing identities, notarization.** The certs and identities documented under `documentation/Apple App Code Signing` live in the user's host Keychain and are bound to the host's Secure Enclave / Touch ID. You can copy a `.p12` into a VM, but you've now duplicated a sensitive credential and lost Touch ID. MacStack assumes — correctly — that signing happens where the developer already is.

7. **System-wide CLI in the real terminal.** `mack`, `update`, `gitty`, `silent`, `backup-zed` end up on the host `PATH` and work in Apple Terminal, iTerm, Warp, and IDE-embedded terminals. The VM equivalent is `ssh user@vm …` or `tart ssh …` for every command, which breaks IDE integrations, shell history, working-directory expectations, and clipboard flow.

8. **Real on-disk repo folders the host IDE opens.** `scripts/update-repos.sh` + `git/repos-folder-template` produce a tree under `git.repos_folder` that the user opens in *their* Cursor/Zed on *their* Mac. Inside a VM that tree lives on the guest disk; using it from the host means file sharing (VirtioFS), which adds latency, breaks fsevents in subtle ways, and is read-only by default in Tart unless explicitly mounted writable.

9. **Peripherals, displays, audio, networking as the user has them.** Bluetooth devices, external displays, the Mac's microphone/camera, VPN profiles, custom DNS, corporate Wi-Fi profiles — all "just work" because MacStack runs on the host. VMs see a virtualized subset and frequently need explicit USB passthrough or bridged-network configuration that the user has to maintain.

10. **Zero runtime overhead.** MacStack runs once when invoked; afterwards the cost is zero. A VM that hosts the user's daily workflow permanently costs RAM (typically 8–32 GB), disk (50–200 GB per image), and CPU scheduling overhead, on top of the host OS the user still has to run anyway.

11. **No OS-version lag.** macOS guest support in VM tools usually trails the host by months — Apple's VM framework needs updates for each new major release, and IPSW availability + Tart-image rebuilds take time. MacStack runs on whatever macOS the user is on the moment they install it.

## What VMs (Tart) can do that MacStack can't

1. **True isolation and disposable environments.** Test untrusted software, run a sketchy installer, try a beta IDE, evaluate a destructive script — then `tart delete` and it's gone. MacStack's changes are durable on the real Mac; "undo" means manually reverting dotfiles and `brew uninstall`-ing.

2. **Snapshots and instant rollback.** `tart clone clean-base my-experiment`, break things, throw it away, clone again. MacStack has no snapshot model — its only "rollback" is whatever git history exists in the stack folder.

3. **Multiple conflicting environments side-by-side.** A VM per project with its own `node`/`python`/`postgres`/Xcode version. MacStack installs one global Homebrew toolchain (and leans on `pyenv`/`nvm` for language-version multiplicity, which it can install but doesn't itself solve).

4. **Multiple macOS versions concurrently.** Test the same app on Sonoma, Sequoia, Tahoe, and a Tahoe beta in parallel. MacStack only configures whatever single macOS the host is running.

5. **Linux guests on Apple Silicon.** Tart and friends run full Linux VMs (Ubuntu, Debian, NixOS) with proper kernels — useful for kernel-level work, systemd services, or Linux-only tooling that Docker on Mac handles awkwardly. MacStack is macOS-only by design.

6. **Beta/risky OS testing without touching the daily driver.** Install the next macOS beta in a VM, see if your stack still works, without putting your actual machine at risk. With MacStack you'd be installing the beta on the same Mac you depend on.

7. **Reproducibility down to a disk image.** A pinned Tart OCI image hash gives every teammate the *exact same bytes* — same Xcode build, same Homebrew package versions, same caches. MacStack pins the *inputs* (`Brewfile`, JSON configs) but the resolved output depends on whatever Homebrew currently serves and whatever pre-existing state the host has.

8. **OCI distribution of whole environments.** `tart pull ghcr.io/org/dev-env:latest` ships a fully-configured 80 GB environment as an addressable artifact. MacStack ships *recipes* that each Mac re-resolves; the first `mack update` on a fresh machine takes minutes-to-hours of Homebrew downloads. A VM image can be ready in the time it takes to pull layers.

9. **CI runners and ephemeral build environments.** Tart's headline use case is per-job clean macOS VMs for GitHub Actions / GitLab / Buildkite. MacStack has no concept of ephemeral runners or CI orchestration — its model is "configure this long-lived Mac."

10. **Resource limits and isolation guarantees.** Cap a VM at 4 cores and 8 GB RAM, restrict its network, mount the host filesystem read-only. MacStack does no sandboxing — it's literally configuring the host with full privileges.

11. **Multi-tenancy on shared hardware.** A team can put a Mac Studio in a closet and give each developer a VM on it (within Apple's 2-VM-per-host cap, or by clustering several Studios). MacStack assumes one human per Mac.

12. **Bit-for-bit reproducible CI of the setup itself.** Want to verify "does this stack actually produce a working machine from scratch?" — boot a fresh VM, run `mack update`, inspect, throw away. Ironically, VMs are the right tool to *test* MacStack, even though they're a poor substitute for it.

## The short version

MacStack and VMs aren't really competitors — they answer different questions.

MacStack answers: *"How do I keep the Mac I work on every day in a known, declarative, reproducible state, with full native performance and full access to my Apple-account-bound stuff?"*

A VM tool like Tart answers: *"How do I get a fresh, isolated, disposable, reproducible-down-to-the-byte macOS or Linux environment that I can clone, snapshot, ship over an OCI registry, and run in CI?"*

The native-vs-isolated split is the same axis as the Docker comparison, but with macOS guests instead of Linux containers. VMs add things containers can't (full macOS, Apple Silicon Metal — partially — proper kernels) but pay the same fundamental price: they're not the Mac the user actually lives in. MacStack's whole reason to exist is that the Mac the user actually lives in is worth managing well.

In practice the two compose nicely: MacStack configures every developer's daily Mac, and Tart provides the disposable macOS VMs the team uses for CI, OS-version testing, and risky experiments — with the same `Brewfile` and stack folder driving both, if you want consistency.
