# Comparison to Docker Containers (by Claude Opus 4.7, 2026_04_19)

> Prompt: "Look at this whole project and compare it to Docker containers. What would be different (or impossible) if the user tried to do the same things with Docker containers? And what can Docker containers do that this project can not?"

---

These are fundamentally different tools, but the comparison is interesting because they both "set up an environment."

## What MacStack does that Docker can't (or can't do well)

1. **Configure the real macOS host.** MacStack writes to `~/.zshrc`, `~/.gitconfig`, installs Homebrew, fonts, CLI tools, and GUI apps **on the user's actual Mac**. Docker containers are sealed from the host — they can't change your shell prompt, install a font that Figma will see, or set up your `git config --global`.

2. **Install and configure native macOS GUI apps.** Cask apps and Mac App Store apps via `mas`, plus IDE configs for Zed, Cursor, VS Code, Antigravity, Kiro, Windsurf, VSCodium (`scripts/update_ide_settings.sh`). Docker on Mac runs Linux containers; it can't install or launch a `.app` bundle on macOS, and it certainly can't sign in to your iCloud account to fetch App Store purchases.

3. **Configure AI coding agents where they're actually used.** Cursor CLI/IDE rules, Gemini CLI policies, OpenCode settings (`ai/coding/*`) need to live in the user's home dir so the agents pick them up while editing the user's real projects. A container would isolate them from those projects (and from the Mac IDEs entirely).

4. **Idempotent overlay onto existing state.** From the README: "preserves everything else – even individual pre-existing entries in dotfiles." Containers take the opposite philosophy — wipe and rebuild from a clean base image. Merging into a user's hand-tuned `.zshrc` isn't really a Docker pattern.

5. **Use the user's identity & hardware.** Apple ID, iCloud, Keychain, code-signing identities (see `documentation/Apple App Code Signing`), Touch ID, peripherals, system fonts available to every native app. A container gets none of that natively.

6. **Manage real on-disk repo folders** (`scripts/update-repos.sh`, `git/repos-folder-template`). The point is that *you* open them in *your* IDE on *your* Mac. In Docker you'd have to bind-mount, and now you've broken the isolation that made Docker interesting.

7. **System-wide CLI commands.** `mack`, `update`, `gitty`, `silent`, `backup-zed` from `bin/` end up on the user's `PATH` for use in any terminal, including Apple Terminal, iTerm, Warp, IDE terminals. A containerized command requires `docker run …` wrapping.

## What Docker can do that MacStack can't

1. **OS isolation / non-macOS workloads.** Run Ubuntu, Alpine, Debian, specific glibc versions, old Pythons, GPU CUDA stacks. MacStack only configures whatever runs natively on macOS.

2. **Reproducibility down to the byte.** A pinned image hash gives every teammate the *exact* same filesystem. MacStack pins via `Brewfile` but still relies on whatever Homebrew currently resolves and whatever pre-existing state your Mac has.

3. **Multiple conflicting stacks side-by-side.** Two projects needing different `node`, `python`, or `postgres` versions coexist trivially in containers. On MacStack you get one global Homebrew-installed version (you'd lean on `pyenv`/`nvm`, which MacStack can install but doesn't itself solve).

4. **Disposable / instant rollback.** `docker rm` and you're back to zero. MacStack changes are applied to your real Mac; undoing them means manually reverting dotfiles and `brew uninstall`-ing.

5. **Resource limits & sandboxing.** CPU/memory caps, seccomp, read-only FS, network namespaces. MacStack doesn't sandbox anything — it's literally configuring your machine.

6. **Servers and long-running services.** Postgres, Redis, Kafka, a microservice mesh — Docker's bread and butter. MacStack has no concept of running services.

7. **Portable artifacts.** A built image is a single shippable thing that runs identically on a colleague's laptop, CI, and production. MacStack's "artifact" is a stack repo of declarative inputs that still has to be re-resolved on each Mac.

8. **Cross-host portability.** Same image on macOS dev, Linux CI, Linux prod, ARM cloud. MacStack is macOS-only by design.

9. **Layered caching of builds.** Dockerfile layer cache speeds up rebuilds. MacStack reruns Homebrew/script logic each time and relies on Homebrew's own idempotency.

10. **Network topology between components.** Custom bridges, compose stacks, service discovery. Out of scope for MacStack entirely.

## The short version

MacStack is a **declarative configurator for the host Mac you actually live in** — shell, GUI apps, IDE settings, AI agents, fonts, repos. Docker is a **sealed runtime for software that should not touch the host**. There's almost no overlap: MacStack's whole value proposition (changing your real Mac, including GUI apps and Apple-account-bound App Store installs) is precisely what Docker is designed *not* to do, and Docker's whole value proposition (isolated, reproducible, portable Linux runtimes) is something MacStack doesn't attempt.

In practice they're complementary — `Brewfile` could install Docker Desktop, and then containers handle services while MacStack handles the human's workstation.
