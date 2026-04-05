## Amp Customization — Deep Research by Sonnet 4.6 (April 5, 2026)

Source: [ampcode.com/manual](https://ampcode.com/manual), [ampcode.com/agent.md](https://ampcode.com/agent.md), [Enterprise Managed Settings](https://ampcode.com/news/enterprise-managed-settings), [Workspace Settings](https://ampcode.com/news/cli-workspace-settings), [Appendix / Permissions](https://ampcode.com/manual/appendix).

### Customization Philosophy

Amp's approach is notably richer and more composable than most peers. Rather than a single "rules file" pattern, it layers several distinct mechanisms:

1. **AGENTS.md** — the universal text-context layer (instructions/conventions)
2. **Skills** — reusable, on-demand instruction packages with optional bundled MCP servers
3. **Toolboxes** — custom tools as executable scripts (no MCP server needed)
4. **Permissions** — fine-grained allow/reject/ask/delegate rules on every tool call
5. **Settings (JSON)** — structured config (MCP servers, permissions, etc.) at user/project/enterprise level
6. **Checks** — per-directory code-review criteria run as subagents

### Level-by-Level Breakdown

#### Level 1 — Team (Enterprise only)
- **Enterprise Managed Settings** stored at OS system paths (not user home):
  - macOS: `/Library/Application Support/ampcode/managed-settings.json`
  - Linux: `/etc/ampcode/managed-settings.json`
  - Windows: `C:\ProgramData\ampcode\managed-settings.json`
- Same schema as user settings (`amp.mcpServers`, `amp.permissions`, etc.)
- Overrides all individual user settings — functions as an unbreakable guardrail
- Separate from AGENTS.md hierarchy; purely structural/security-focused
- **MCP Registry Allowlist** (Enterprise): workspace admins set an MCP registry URL; only listed MCP servers are allowed. If unreachable, all MCP servers are blocked.

#### Level 2 — User
- `~/.config/amp/AGENTS.md` — personal preferences, device-specific commands, local experiments before committing to a repo
- `~/.config/AGENTS.md` — generic fallback also picked up by Amp
- `~/.config/amp/skills/` and `~/.config/agents/skills/` — user-wide skills (take precedence over project skills of same name)
- `~/.config/amp/checks/` and `~/.config/agents/checks/` — global code review checks applied to all projects
- User settings JSON (managed via `amp permissions edit`, VS Code settings, or CLI flags)

#### Level 3 — Project (root)
- `AGENTS.md` — primary. Falls back to `AGENT.md` (no S) or `CLAUDE.md` if not found.
- `.amp/settings.json` — project-scoped structured settings (MCP servers, permissions). Workspace MCP servers require explicit user approval before running (trust prompt).
- `.agents/skills/` — project-specific skills; committed to git for team sharing
- `.agents/checks/` — project-wide code review checks

#### Level 4 — Folder/Subtree
- `AGENTS.md` files in any subdirectory — **loaded on demand**: only included when the agent reads a file within that subtree (not preloaded at startup). This is Amp's key behavior difference from most agents.
- `.agents/checks/<subdir>/` — scoped checks that apply only to files under that directory
- @-mention references in AGENTS.md files: `@doc/style.md`, `@specs/**/*.md`, glob patterns supported
- **Glob-gated includes**: mentioned files can declare `globs:` YAML front matter so they're only injected when the agent has read a matching file (e.g., TypeScript rules only when a `.ts` file was opened). This is a uniquely granular feature.

#### Level 5 — Tool (enforced)
- Enterprise Managed Settings at OS system paths act as hard overrides over all levels 1–4
- MCP Registry allowlist enforced at workspace level (can't be bypassed by user)
- No equivalent to Gemini's `GEMINI_SYSTEM_MD` or Claude Code's system prompt injection

### Skills (Unique to Amp)

Skills are a first-class concept not present in other agents. Each skill is a directory containing:
- `SKILL.md` with YAML front matter (`name`, `description`) — always visible to the model as a menu item
- The full body of `SKILL.md` is only loaded when the skill is invoked (lazy loading)
- Optional bundled scripts/templates in same directory
- Optional `mcp.json` to bundle MCP servers — servers start at launch but tools stay hidden until skill is activated

**Skill precedence** (first wins):
1. `~/.config/agents/skills/`
2. `~/.config/amp/skills/`
3. `.agents/skills/`
4. `.claude/skills/`
5. `~/.claude/skills/`
6. Plugins, toolbox directories, built-in skills

Install from GitHub/git: `amp skill add ampcode/amp-contrib/tmux`

### Toolboxes (Custom Tools as Scripts)

- Any executable in directory pointed to by `AMP_TOOLBOX` env var becomes a custom tool
- Default: `~/.config/amp/tools/` (if `AMP_TOOLBOX` not set)
- Multiple directories via colon-separated paths (earlier = higher precedence)
- Executables implement a describe/execute protocol via stdin/stdout
- Tools registered with `tb__` prefix (e.g., `tb__run_tests`)
- Can output JSON schema or simple text key-value format
- Scaffold new tools with: `amp tools make --bash run_tests`

Project-local toolbox pattern:
```bash
export AMP_TOOLBOX="$PWD/.agents/tools:$HOME/.config/amp/tools"
```

### Permissions System

Amp's permission system is the most sophisticated of any agent reviewed:
- Ordered list of rules evaluated sequentially; first match wins
- Actions: `allow`, `reject`, `ask`, `delegate` (to external program)
- Matching: glob patterns, regex (`/pattern/`), arrays (OR logic), nested object matching
- Context scoping: `"context": "thread"` or `"context": "subagent"` — can enforce different rules for main vs. subagent
- `delegate` action calls an external program; exit code 0 = allow, 1 = ask, ≥2 = reject
- Default if no rule matches: main thread → ask; subagent → reject
- Test rules without running: `amp permissions test Bash --cmd "git commit -m 'test'"`
- Edit interactively: `amp permissions edit` (opens `$EDITOR`)
- CLI: `amp permissions list`, `amp permissions add`, `amp permissions list --builtin`

### AGENTS.md — Amp-Specific Behaviors

- Files in cwd and all **parent directories up to `$HOME`** are always included at startup
- Subtree files are **lazily included** (only when agent reads a file in that subtree)
- Fallback chain: `AGENTS.md` → `AGENT.md` → `CLAUDE.md`
- @-mention other files from within AGENTS.md: relative paths, absolute paths, `@~/path`, glob patterns
- @-mentions in code blocks are ignored (false positive prevention)
- **Glob-gated files**: included files can declare `globs:` frontmatter to conditionally include themselves
- Amp can generate an initial AGENTS.md for you if none exists
- Inspect active files: command palette → `agents-md list`

**Migration helpers documented in manual:**
- From Claude Code: `mv CLAUDE.md AGENTS.md && ln -s AGENTS.md CLAUDE.md`
- From Cursor: `mv .cursorrules AGENTS.md && ln -s AGENTS.md .cursorrules`, then add `@.cursor/rules/*.mdc` in AGENTS.md

### Code Review Checks

A novel customization layer for quality enforcement:
- Markdown files in `.agents/checks/` with YAML front matter (`name`, `description`, `severity-default`, `tools`)
- Each check is run as an independent subagent during `amp review`
- Scope: project root applies everywhere; subdirectory checks only apply to files under that dir
- Global: `~/.config/amp/checks/` or `~/.config/agents/checks/`
- Closer project checks override same-named checks from parent/global

### Key Differentiators vs. Other Agents

| Feature | Amp | Others |
|---------|-----|--------|
| Lazy subtree AGENTS.md loading | ✅ On-demand when file in subtree is read | Most preload or do simple tree walk |
| Glob-gated conditional includes | ✅ `globs:` YAML frontmatter | ❌ |
| Skills (on-demand instruction packages) | ✅ First-class with lazy loading | ❌ |
| Toolboxes (script-based custom tools) | ✅ `AMP_TOOLBOX` env var | Gemini CLI only (similar concept) |
| Permission delegation to external program | ✅ `delegate` action | ❌ |
| Subagent-scoped permission rules | ✅ `context: subagent` | ❌ |
| Code review checks as subagents | ✅ `.agents/checks/` | ❌ |
| Enterprise managed settings (OS-level) | ✅ System paths | Gemini CLI `policies/*.toml` (similar) |
| MCP Registry allowlist | ✅ Enterprise | ❌ |
| Team-level AGENTS.md / dashboard rules | ❌ No dashboard/org rules for instructions | Cursor Team Rules, Copilot org instructions |
| System prompt override | ❌ | Gemini `GEMINI_SYSTEM_MD` |

### Indications & Gaps

- **No team-level instruction layer** for non-Enterprise customers. Amp has no equivalent of Cursor Team Rules or GitHub Copilot org instructions for the AGENTS.md/skills/checks hierarchy. Team sharing only works via committed project files (`.agents/skills/`, `AGENTS.md` in git).
- **Enterprise managed settings** are the closest analog to a "Level 5 guardrail" but they're OS-level, not dashboard-managed — requires sysadmin access, not a team lead clicking a UI.
- **Lazy loading is a double-edged sword**: subtree AGENTS.md is only picked up after the agent reads a file there. If a task never touches that subtree, the folder-level guidance is never seen. Contrast with Gemini CLI which may preload based on settings.
- **Skills are the most powerful composability primitive** in the ecosystem. The lazy-loaded, git-committable, MCP-bundling pattern is unique and highly practical.
- **The `delegate` permission action** enables custom governance logic (org-specific CLI tools deciding per-call), which no other agent supports natively.
- **`CLAUDE.md` and `AGENT.md` as fallbacks** mean Amp is backward-compatible with Claude Code and older repos out of the box.
