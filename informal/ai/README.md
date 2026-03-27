# AI Stack

This README (and folder) documents my current state of finding a working AI stack, now focused on BYOK.

Background on specific aspects is documented in this folder:
* [BYOK](./byok%20overview.md)
* [Coding Agents](./coding%20agents%20overview.md)
* [Free Tiers of VSCode based IDEs](./VSCode%20based%20IDE%20free%20tiers.md)

## Layers

### IDEs/Clients
- [Zed](https://dashboard.zed.dev) (via GitHub)
  - login unlocks tab completion
- [OpenCode Desktop app](https://opencode.ai/download) (no login)
  - `brew install --cask opencode-desktop`

### Agents
- [OpenCode](https://opencode.ai) (no login)
- [Cursor CLI](https://cursor.com/cli) (no login)
- [OpenClaw](https://openclaw.ai) (🛑 not successfully set up yet)

### Routers
- [OpenRouter](https://openrouter.ai/workspaces/default) (via GitHub)
  - usable rate limits on free models when funded with 10$
  - 5.5% markup on paid models

### Providers
- [DeepInfra](https://deepinfra.com) (via GitHub)
  - cheap and fast inference provider for open models
- [OpenCode Zen](https://opencode.ai/zen) (via GitHub)
  - borderline fraudulent marketing of "zero markups". their "small payment processing fee of 1.23 USD per 20 USD balance top-up" amounts to a 6.15% fee, because you only can spend in 20 USD increments.
  - can be used in any tool/agent, not just in OpenCode
  - by far not as cheap as DeepInfra
  - but performs well in OpenCode, even via ACP (in Zed)
- [xAI](https://console.x.ai) (regular login)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)

## ACP Coding Agent + Provider/Router

### Essential Combinations

| Agent | Provider/Router | free/paid | Works in Zed? | Works in Terminal? |
| --- | --- | --- | --- | --- |
| OpenCode | OpenRouter | free models | 🛑 (1, 2) | ✅ |
| Cursor CLI | Cursor | free tier |  |  |
| Gemini CLI | Google AI | free + paid |  |  |
| OpenCode | DeepInfra | paid | ⚠️ (3) | ⚠️ (3) |
| OpenCode | xAI | paid |  |  |
| Claude Code | Anthropic | paid |  | ✅ |
| OpenCode | OpenRouter | paid models (+5.5% fee) | 🛑 (1, 2) | ✅ |
| OpenCode | OpenCode Zen | paid models (+6.15% fee) | ✅ | ✅ |

### Issues

1. 🛑 OpenCode + OpenRouter: does currently not work in Zed at all, whether with free or paid models.
2. ⚠️ OpenCode + OpenRouter: Zed offers no way to edit the agent's thread history -> delete threads by deleting `~/.local/share/opencode/opencode.db*` This may be an issue for all external agents in Zed and independent of provider (has to be tested).
3. ⚠️ OpenCode + DeepInfra: list of available models does not match available models, some unavailable models are listed, some available models are not listed (Nemotron 3 Super)

### Choice of Combinations
The basic category here is coding (not general purpose), cloud inference (not local inference), and availability of ACP. Further criteria for combo selection were:
* Avoid inference outside US/Europe
* Avoid OpenAI
* Avoid paid subscriptions (avoid recurring costs that are unrelated to usage)
* Avoid low performing agents
* Avoid free variants with impractically tight rate limits (OpenCode Zen free models)
* Use a given provider/router only with the best agent available for it (why use Anthropic account with any other agent than Claude Code)
* Cover range of cheap/fast- versus intelligent models as well as open weights- versus proprietary models

> Note: If Claude Code + Anthropic does not work in Zed, it might be worth adding/testing OpenCode + Anthropic. Same for Gemini CLI: If Gemini CLI + Google AI does not work in Zed, it might be worth adding/testing OpenCode + Google AI. Just for the Zed integration ...

## General Purpose agents

* OpenClaw: I was so far unable to get this to work with a local model. tried ollama via LiteLLM and ollama directly but to no avail. it's all not as usable/valuable (yet) as the hype suggests.
