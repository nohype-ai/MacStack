# Agent Customization

## Levels

Custom instructions, rules and configurations can be injected into an agentic coding system at five levels, building a hierarchy of customizations, where the lower and more specific levels (higher numbers) take precedence:

1) Team Level:
   - default instructions or rules for all members of a team
   - rare, agent and provider account must be tightly linked
   - examples:
     - GitHub Copilot org custom instructions
     - Cursor Team Rules
       - Note: Cursor Team Rules can be used as soft team defaults (Level 1) or as unbreakable guardrails (Level 5)
2) User Level:
   - global on user machine, configs live in dotfiles/dotfoldfers in ~/ for persistence across projects
   - agent specific format/location
   - not version-controlled
3) Project Level:
   - Universal standard: AGENTS.md (or AGENT.md) in repo root — widely supported. Acts as "README for agents" with overview, commands, style, structure, boundaries.
   - Tool-specific stuff often in hidden folders (.cursor/, .continue/, .claude/) for clean project root
4) Folder Level:
   - Ideal for domain-specific rules (e.g., /api/ vs. /ui/)
5) Tool Level:
   - source of truth is inside the agent/tool itself (system prompt or enforced dashboard rules)
   - last-resort policy enforcement (final safeguard)
   - rare; only possible when the agent and its provider are tightly linked
   - Examples:
     - Cursor Team Rules
       - Note: Cursor Team Rules can be used as soft team defaults (Level 1) or as unbreakable guardrails (Level 5)
     - Gemini CLI GEMINI_SYSTEM_MD (full system prompt override)

## Customization Locations

| Level              | Cursor CLI                                      | Gemini CLI                                      | Claude Code                                      | OpenCode                                              |
|--------------------|-------------------------------------------------|-------------------------------------------------|--------------------------------------------------|-------------------------------------------------------|
| **Team** | Team Rules (dashboard, if logged in)            | ❌                                           | ❌                                            | ❌                                                 |
| **User** | `~/.cursor/cli-config.json` (no global prompt for CLI) | `~/.gemini/GEMINI.md`, `~/.gemini/settings.json`, `~/.gemini/policies/*.toml` | `~/.claude/CLAUDE.md`, `~/.claude/settings.json` | `~/.config/opencode/AGENTS.md`, `~/.config/opencode/opencode.json` |
| Project (root) | AGENTS.md, CLAUDE.md, .cursor/rules/, .cursorrules | GEMINI.md, .gemini/GEMINI.md, AGENTS.md | CLAUDE.md, AGENTS.md, .claude/rules/, .claude/settings.json | AGENTS.md, .opencode/opencode.json |
| Folder (any)   | AGENTS.md, CLAUDE.md                                   | GEMINI.md, .gemini/GEMINI.md, AGENTS.md | CLAUDE.md, AGENTS.md, .claude/rules/ | AGENTS.md                               |
| **Tool** | Team Rules (dashboard-enforced)          | `GEMINI_SYSTEM_MD` env var (agent system prompt override) | ❌                                            | ❌                                                 |

## Open Topics

* spec-driven development?
* so what can/should we back up?
* how do we handle symlinking to central prompts in a reproducible way when
  1. symlinks cannot hold relative paths
  2. the prompts are often integral part of a project in the sense they (even user-level prompts) must be versioned with the project and be reproducible
* how different agents actually consider and combine the customizations on Level 4 makes a difference (tree walk up, bfs, replacing versus combining prompts etc.). how do we handle that? is there a good enough approach that works for all equally as expected?
* how do custom prompts impact speed and cost versus quality? when is it too much customization?
* does any of this not work or work differently when the project is NOT a git repository?
