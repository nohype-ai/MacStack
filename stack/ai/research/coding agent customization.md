# Agent Customization

## Levels

Custom instructions, rules and configurations can be injected into an agentic coding system at five levels, building a hierarchy of customizations, where the lower and more specific levels (higher numbers) take precedence.

❗ These levels are supposed to help in practice so they mirror actual practical precedence order. Who is able or permitted to edit each customization or where these customizations are stored are entirely different dimensions.

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
   - source of truth is conceptually with the agent/tool itself
   - this may be implemented via system prompt, dashboard rules, config files etc.
   - last-resort policy enforcement (final safeguard): customizations on this level overrule any customizations from levels 1 - 4
   - Examples:
     - Cursor Team Rules
       - Note: Cursor Team Rules can be used as soft team defaults (Level 1) or as unbreakable guardrails (Level 5)
     - Gemini CLI GEMINI_SYSTEM_MD (full system prompt override)
       - Any user can override this while Cursor Team Rules may be gated by specific roles in the team. But the important thing here is that this system prompt has the power to overrule even folder-level prompts.
     - `~/.gemini/policies/*.toml` actually overrule project-level policies. so `~/.gemini/policies/*.toml` represent the final safeguards of gemini CLI itself and not user preferences.

## Locations

| Level | Gemini CLI | OpenCode | Cursor CLI | Claude Code |
| --- | --- | --- | --- | --- |
| **Team** | ❌ | ❌ | Team Rules (if logged in) | ❌ |
| **User** | `~/.gemini/settings.json` (⚠️4)<br>`~/.gemini/GEMINI.md`<br>`AGENTS.md` (⚠️1) | `~/.config/opencode/opencode.json`<br>`~/.config/opencode/AGENTS.md`<br>`~/.claude/CLAUDE.md` (⚠️2) | `~/.cursor/cli-config.json` (⚠️3)<br>`~/.cursor/rules/*.md[c]` (🛑5) | `~/.claude/settings.json`<br>`~/.claude/CLAUDE.md` |
| **Project (root)** | `.gemini/settings.json` (⚠️4)<br>`.gemini/policies/*.toml`<br>`GEMINI.md`<br>`AGENTS.md` (⚠️1) | `opencode.json`<br>`.opencode/AGENTS.md`<br>`AGENTS.md`<br>`CLAUDE.md` (⚠️2) | `.cursor/cli.json` (only permissions)<br>`.cursor/rules/*.md[c]`<br>`AGENTS.md`<br>`CLAUDE.md` | `.claude/settings.json`<br>`.claude/rules/`<br>`.claude/CLAUDE.md`<br>`CLAUDE.md`<br>`AGENTS.md` |
| **Folder (any)** | `GEMINI.md`<br>`AGENTS.md` (⚠️1) | `AGENTS.md`<br>`CLAUDE.md` (⚠️2) | `AGENTS.md` | `.claude/CLAUDE.md`<br>`CLAUDE.md`<br>`AGENTS.md` |
| **Tool** | `~/.gemini/policies/*.toml`<br>`GEMINI_SYSTEM_MD` (agent system prompt override) | ❌ | Team Rules (enforced) | ❌ |

* ⚠️1)  `AGENTS.md` should work if configured (`context.fileName` in respective `settings.json`), but currently buggy: https://github.com/google-gemini/gemini-cli/issues/19872
* ⚠️2) Loading of Claude customizations can be deactivated and probably should
* ⚠️3) contains semi sensitive information and cannot be backed up into a repo as is.
* ⚠️4) permissions in `settings.json` are being phased out in favor of recommended fine-granular policy engine in `policies/*.toml`
* 🛑5) user-level rules are not supported for the CLI – only for the IDE
* [Amp's customization options](amp%20customization.md) are arguably richer than for other agents. But importantly, Amp supports `AGENTS.md` at user- (`~/.config/amp/AGENTS.md`), project- and folder level.

## Conclusions

* The `AGENTS.md` convention is the closest we can get to a cross-agent (agent-agnostic) way to guide agents.
* ❗ We can largely ignore user-level prompt customization:
  * `AGENTS.md` is not at all universally respected at the user level.
  * Hardly anything would truly add value across all projects and folders, in particular when coding agents are applied beyond coding.
  * It would add latency, cost and prompt dillution to every single prompt.
  * It can not easily be version-managed together with a version managed folder, so agent behaviour would be decoupled from commits
* True user-level infos (like user's name, language style preference, tooling, operating system) would need to be somehow injected via markdown (templates) at the project folder level. but this has relatively low impact and can be postponed.
* `AGENTS.md` files should only contain what truly only applies to agents (like infos about the user). Almost nothing is truly agent-specific, for example, instructions on how to work with a project also apply to humans. So almost everything should remain in regular `README.md` files.
  * This reduces redundancy and promotes well structured documentation.
  * Also avoid including pointers to `README.md`, they would add ceremony without value. Agents are increasingly able to do contextual discovery and read relevant documentation.
* ❗ This whole agent customization thing is converging back to classic principles of just providing good old documentation. But agents do indeed make those principles more crucial than ever:
  * make things explicit
  * put docs where they actually apply and are needed
  * structure texts well
  * avoid redundancy
  * give overview first
  * link to related docs
  * use precise (even if long) terms
  * clarify used terminology
  * keep it up to date
  * make it as concise and dense as possible
  * etc.
* ❗ Non-repo folders and non-codebase folders should also use `README.md` files as their entrypoint and overview. Agents know what a `README.md` is.
* ❗ user-level agent settings (in contrast to prompts) are not only ok but also necessary (like for iCloud Drive folders which are not repos and cannot have their own agent settings). so an agent's permissions (what it is allowed or denied to always do) must be defined at user-level and anyway should truly apply across projects.
* Agent permissions:
  * cases where it makes sense to actually deny agent actions
    1) are local exceptions
    2) can often be covered with formal rules but require intelligence
    3) can still manually be avoided with Plan/Ask mode
    4) Could still be reviewed and reverted in git repos
  * ❗ → best strategy: allow everything on a user-level and handle sensitive exceptions on a project/folder level via policies, rules, documentation and AGENTS.md files. this prioritizes productivity a bit over total safety, and that's ok.

| | Prompts | Permissions |
|---|---|---|
| **User level** | avoid | necessary |
| **Project/folder level** | primary home | possible but redundant if user-level covers it |
