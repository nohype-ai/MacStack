1. **Create the Homebrew formula** — a Ruby file (`macstack.rb`) that declares the source URL, version, dependencies (`jq`, `moreutils`), and install instructions (copy scripts, symlink `mack` into `bin`).

2. **Have a versioned release to point at** — Homebrew formulas reference a specific tagged release tarball on GitHub (e.g. `https://github.com/nohype-ai/MacStack/archive/refs/tags/v1.0.0.tar.gz`), so you'd need to start tagging releases.

3. **Host the formula** — two options:
   - Submit to the official Homebrew core tap (`homebrew/core`) — high bar, they require the tool to be notable/popular
   - Create your own tap (`homebrew/homebrew-macstack`) — a separate GitHub repo named `homebrew-macstack`, much easier, users install via `brew tap nohype-ai/macstack && brew install macstack`

4. **Make the install script self-contained** — right now `bin/mack` derives `MAC_STACK_ROOT` from its own location in the repo. When installed via Homebrew, that path changes to something like `/opt/homebrew/opt/macstack/`. The scripts need to find themselves correctly regardless of where Homebrew puts them.

4 is the most immediate code change needed and probably the most fiddly. Everything else is relatively straightforward setup.
