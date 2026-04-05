# Agent Customization

## Levels

Custom instructions, rules and configurations can be injected into an agentic coding system at five levels, building a hierarchy of customizations, where the lower and more specific levels (higher numbers) take precedence.

❗ These levels are supposed to help in practice so they mirror actual practical precedence order. Who is able or permitted to edit each customization is an entirely different dimension.

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
   - Universal standard: AGENTS.md (or AGENT.md) in repo root as "README for agents"
   - Tool-specific stuff often in hidden folders (.cursor/, .continue/, .claude/) for clean project root
4) Folder Level:
   - Ideal for domain-specific rules (e.g., /api/ vs. /ui/)
5) Tool Level:
   - source of truth is inside the agent/tool itself (system prompt or enforced dashboard rules)
   - last-resort policy enforcement (final safeguard)
   - Examples:
     - Cursor Team Rules
       - Note: Cursor Team Rules can be used as soft team defaults (Level 1) or as unbreakable guardrails (Level 5)
     - Gemini CLI GEMINI_SYSTEM_MD (full system prompt override)
       - though any user can override this while Cursor Team Rules may be gated by specific roles in the team. But the important thing here is that this system prompt has the power to overrule even folder-level prompts.
     - `~/.gemini/policies/*.toml` can restrict shell commands no matter any customizations on levels 1 - 4

## Locations

| Level | Cursor CLI | Gemini CLI | Claude Code | OpenCode |
| --- | --- | --- | --- | --- |
| **Team** | Team Rules (dashboard, if logged in) | ❌ | ❌ | ❌ |
| **User** | `~/.cursor/cli-config.json`, no `AGENTS.md` support for CLI | `~/.gemini/GEMINI.md`, `~/.gemini/settings.json`, `AGENTS.md` (⚠️1)  | `~/.claude/CLAUDE.md`, `~/.claude/settings.json` | `~/.config/opencode/AGENTS.md`, `~/.config/opencode/opencode.json`, `~/.claude/CLAUDE.md` (can be deactivated) |
| **Project (root)** | `AGENTS.md`, `.cursor/rules/`, `.cursorrules` *(legacy)* | `GEMINI.md`, `.gemini/settings.json`, `AGENTS.md` (⚠️1) | `CLAUDE.md`, `AGENTS.md`, `.claude/rules/`, `.claude/settings.json` | `AGENTS.md`, `.opencode/AGENTS.md`, `.opencode/opencode.json`, `CLAUDE.md` |
| **Folder (any)** | `AGENTS.md` | `GEMINI.md`, `AGENTS.md` (⚠️1) | `CLAUDE.md`, `AGENTS.md` | `AGENTS.md`, `CLAUDE.md` |
| **Tool** | Team Rules (dashboard-enforced) | `~/.gemini/policies/*.toml`, `GEMINI_SYSTEM_MD` env var (agent system prompt override) | ❌ | ❌ |

* (⚠️1)  `AGENTS.md` should work if configured in respective settings (`context.fileName` in `~/.gemini/settings.json` or project level `.gemini/settings.json`), but currently buggy: https://github.com/google-gemini/gemini-cli/issues/19872
* [Amp's customization options](amp%20customization.md) are arguably richer than for other agents. But importantly, Amp supports `AGENTS.md` at user- (`~/.config/amp/AGENTS.md`), project- and folder level.

## First Conclusions

* The `AGENTS.md` convention is the closest we can get to a cross-agent (agent-agnostic) way to guide agents.
* We should probably largely ignore user-level prompt customization:
  * `AGENTS.md` is not at all universally respected at the user level.
  * Hardly anything would truly add value across all projects and folders, in particular when coding agents are applied beyond coding.
  * It would add latency, cost and prompt dillution to every single prompt.
  * It can not easily be version-managed together with a version managed folder, so agent behaviour would be decoupled from commits
* True user-level infos (like user's name, language style preference, tooling, operating system) would need to be somehow injected via markdown (templates) at the project folder level. but this has relatively low impact and can be postponed.

## Open Topics

* how do we handle symlinking to markdown files within a git repo, when symlinks cannot hold relative paths
* how do i generally allow non-destructive actions like reading, searching and fetching in every agent and backup/restore these settings? for example Cursor CLI asks for each fetch and search operation but offer no option like "always allow search". it only offers "always allow search on this specific website"
* so what can/should we back up?
* does any of this not work or work differently when the project is NOT a git repository?
* how do custom prompts impact speed and cost versus quality? when is it too much customization?
* how different agents actually consider and combine the customizations on Level 4 makes a difference (tree walk up, bfs, replacing versus combining prompts etc.). how do we handle that? is there a good enough approach that works for all equally as expected?
* spec-driven development?
