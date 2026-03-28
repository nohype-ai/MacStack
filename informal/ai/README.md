# AI Stack

This README (and folder) documents my current state of finding a working AI stack, now focused on BYOK.

Background on specific aspects is documented in this folder:
* [BYOK](./byok%20overview.md)
* [Coding Agents](./coding%20agents%20overview.md)
* [Free Tiers of VSCode based IDEs](./VSCode%20based%20IDE%20free%20tiers.md)

## Layers

### IDEs/Clients
- [Zed](https://dashboard.zed.dev) (via GitHub account)
  - login unlocks tab completions ("edit predictions")
  - Zed Pro is only for the mediocre internal Zed agent
- [OpenCode desktop app](https://opencode.ai/download) (no login)
  - `brew install --cask opencode-desktop`
- [Claude desktop app](https://code.claude.com/docs/en/desktop-quickstart)
  - with free tier: only chat
  - with subscripton: Code and CoWork
  - no way to use API key as in Claude Code CLI

### Agents
- [OpenCode](https://opencode.ai) (no login)
- [Cursor CLI](https://cursor.com/cli) (no login)
- [Gemini CLI](https://geminicli.com) (no login)
- [Claude Code](https://claude.com/product/claude-code)
- [OpenClaw](https://openclaw.ai) (🛑 not successfully set up yet)

### Routers
- [OpenRouter](https://openrouter.ai/workspaces/default) (via GitHub account)
  - usable rate limits on free models when funded with 10$
  - 5.5% markup on paid models

### Providers
- [Cursor](https://cursor.com/dashboard) (normal login)
  - free "Hobby" tier with generous rate limits
  - login via GitHub would be possible (as second account or to simplify)
- [DeepInfra](https://deepinfra.com) (via GitHub account)
  - cheap and fast inference provider for open models
- [xAI](https://console.x.ai) (normal login)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)
  - [Model Prices](https://docs.x.ai/developers/models#model-pricing)
- [Google AI](https://aistudio.google.com/projects) (via Google Account)
  - [Model Prices](https://ai.google.dev/gemini-api/docs/pricing)
- [OpenCode Zen](https://opencode.ai/zen) (via GitHub account)
  - borderline fraudulent marketing of "zero markups". their "small payment processing fee of 1.23 USD per 20 USD balance top-up" amounts to a 6.15% fee, because you only can spend in 20 USD increments.
  - can be used in any tool/agent, not just in OpenCode
  - by far not as cheap as DeepInfra
  - but performs well in OpenCode, even via ACP (in Zed)
- [Anthropic](https://platform.claude.com) (via email)
  - [Model Prices](https://claude.com/pricing#api)

## ACP Coding Agent + Provider/Router

### Installing an ACP Agent

* 🚨 To set up an agent via ACP in Zed, install it within Zed from the ACP registry (Shift + Cmd + P -> "zed: acp registry"). Do **not** add a regular (Homebrew-) installation of the same agent as a custom agent to settings.json, since that will likely not work, as ACP support (from Zed and from agents) is generally still immature anyway. The installs offered via the registry are optimized and tested for ACP and Zed.
* However, at least the registry install of an agent is exclusively managed and used by Zed and will never conflict with a regular system-wide install of the same agent.
* In theory, ACP registry installs all support authentication via ACP, but that does not work with all registry-installed agents. The reliable route is to also have a regular system-wide (Homebrew-) install of the same agent and use that one for initial authentication (connecting the agent to a/its provider).

### Essential Combinations

The basic category here is coding (not general purpose), cloud inference (not local inference), and availability of ACP. Further criteria for combo selection were:
* Avoid inference outside US/Europe
* Avoid OpenAI
* Avoid paid subscriptions (avoid recurring costs that are unrelated to usage)
* Avoid low performing agents
* Avoid free variants with impractically tight rate limits (OpenCode Zen free models)
* Use a given provider/router only with the best agent available for it (why use Anthropic account with any other agent than Claude Code)
* Cover range of cheap/fast- versus intelligent models as well as open weights- versus proprietary models

| Agent | Provider/Router | free/paid | In Zed via ACP | In Terminal |
| --- | --- | --- | --- | --- |
| OpenCode | DeepInfra | paid | ✅ (2) | ✅ (2) |
| OpenCode | xAI | paid | ✅ | ✅ |
| Gemini CLI | Google AI | free + paid | ✅ | ✅ |
| Claude Code | Anthropic | paid | ✅ | ✅ |
| OpenCode | OpenCode Zen | paid models (+6.15% fee) | ✅ | ✅ |
| Cursor CLI | Cursor | paid subscription | ⚠️ (4) | ✅ |
| Cursor CLI | Cursor | free tier | 🛑 (3) | ✅ |
| OpenCode | OpenRouter | free models | 🛑 (1) | ✅ |
| OpenCode | OpenRouter | paid models (+5.5% fee) | 🛑 (1) | ✅ |

### Issues

1. 🛑 OpenCode + OpenRouter: does currently not work in Zed at all, whether with free or paid models. Seems to be a known issue with OpenRouter, which does not even work in the Zed agent (without ACP).
2. ℹ️ OpenCode + DeepInfra: The model list is outdated because DeepInfra updates its available models rapidly, while OpenCode relies on models.dev. Solution: add a opencode.json file in ~/.config/opencode/ and define some desired but missing models in there. Prefix their names with "di-custom: " or so to make them discoverable. Backup/example: [opencode.json](../../config/opencode/opencode.json). (Related [GitHub Issue](https://github.com/anomalyco/opencode/issues/6231))
3. 🛑 Cursor CLI + Cursor free tier: ACP is [explicitly not offered on the free tier](https://cursor.com/blog/jetbrains-acp).
4. ⚠️ Cursor CLI + Cursor paid subscription: Presumably this works. But of course it's bound to a subscription.

**Every ACP Agent:**
* ⚠️ Basic thread management functions like "resuming threads from history" do not even work with "the reference ACP implementation" (Gemini CLI). This also means Zed offers no way to edit the agent's thread history (if it is even created) -> delete OpenCode threads by deleting `~/.local/share/opencode/opencode.db*`. Apply an equivalent solution with other agents.

## General Purpose agents

* OpenClaw: I was so far unable to get this to work with a local model. tried ollama via LiteLLM and ollama directly but to no avail. it's all not as usable/valuable (yet) as the hype suggests.
