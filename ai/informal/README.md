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
  - [Model Prices](https://deepinfra.com/models/text-generation)
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

**Viable:**
| Agent | Provider/Router | free/paid | In Zed via ACP | In Terminal |
| --- | --- | --- | --- | --- |
| Gemini CLI | Google AI | free tier (login) | ✅ (5?) | ✅ (5) |
| OpenCode | DeepInfra | paid | ✅ (2) | ✅ (2) |
| OpenCode | xAI | paid | ✅ | ✅ |
| Gemini CLI | Google AI | paid (API key) | ✅ (5?) | ✅ (5) |
| Claude Code | Anthropic | paid | ✅ | ✅ |

**Ruled Out:**
| Agent | Provider/Router | free/paid | In Zed via ACP | In Terminal |
| --- | --- | --- | --- | --- |
| OpenCode | OpenCode Zen | paid models (+6.15% fee) | ✅ | ✅ |
| Cursor CLI | Cursor | paid subscription | ⚠️ (4) | ✅ |
| Cursor CLI | Cursor | free tier | 🛑 (3) | ✅ |
| OpenCode | OpenRouter | free models | 🛑 (1) | ✅ |
| OpenCode | OpenRouter | paid models (+5.5% fee) | 🛑 (1) | ✅ |

### Issues

1. 🛑 OpenCode + OpenRouter: does currently not work in Zed at all, whether with free or paid models. Seems to be a known issue with OpenRouter, which does not even work in the Zed agent (without ACP).
2. ℹ️ OpenCode + DeepInfra: The model list is outdated because DeepInfra updates its available models rapidly, while OpenCode relies on models.dev. Solution: add a opencode.json file in ~/.config/opencode/ and define some desired but missing models in there. Prefix their names with "di-custom: " or so to make them discoverable. Backup/example: [opencode.json](../config/opencode/opencode.json). (Related [GitHub Issue](https://github.com/anomalyco/opencode/issues/6231))
3. 🛑 Cursor CLI + Cursor free tier: ACP is [explicitly not offered on the free tier](https://cursor.com/blog/jetbrains-acp).
4. ⚠️ Cursor CLI + Cursor paid subscription: Presumably this works. But of course it's bound to a subscription.
5. ℹ️ Gemini CLI: Tuning model params (temperature etc.) has big impact on agentic performance. See [gemini/README.md](../gemini/README.md). I could not fully verify that the custom config is also loaded in Zed via ACP, but it seems highly likely.

**Every ACP Agent:**
* ⚠️ Basic thread management functions like "resuming threads from history" do not even work with "the reference ACP implementation" (Gemini CLI). This also means Zed offers no way to edit the agent's thread history (if it is even created) -> delete OpenCode threads by deleting `~/.local/share/opencode/opencode.db*`. Apply an equivalent solution with other agents.

### Models Overview

Models are grouped by provider and sorted by cost per token.

#### DeepInfra: Open Weights Models

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | Experience |
|---|---|---|---|---|---|
| Nemotron-3-Nano-30B-A3B | 0.05 | 0.20 | 38.8% | — | 🛑 bad tool calling, did not finish simple edit |
| Step-3.5-Flash | 0.10 | 0.30 | 74.4% | — | ✅ did broad research plus simple edit quite fast |
| NVIDIA-Nemotron-3-Super-120B-A12B | 0.10 | 0.50 | 60.5% | — | ❓ took long for simple edit, overthinking |
| DeepSeek-V3.2 | 0.26 | 0.38 | 73.1% | 1325 | 🛑 read unrelated files, hallucinated URLs, took too long (DNF) |
| MiniMax-M2.5 | 0.27 | 0.95 | 80.2% | 1403 | ✅ web requests and simple edits blazingly fast, efficient reasoniong |
| Qwen 3.5 122B | 0.29 | 2.90 | 70.4% | 1364 |  |
| Kimi K2.5 | 0.45 | 2.25 | 76.8% | 1447 |  |
| GLM-5 | 0.80 | 2.56 | 77.8% | 1445 |  |
| Mimo v2 Pro | 1.00 | 3.00 | 78.0% | 1437 | |

#### xAI

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | Experience |
|---|---|---|---|---|---|
| Grok 4.1 Fast (reasoning) | 0.20 | 0.50 | 70.8% | 1233 | ✅ fast, to the point, pragmatic, asks user instead of endless retries |
| Grok 4.20 (reasoning) | 2.00 | 6.00 | 76% | 1378 | ❓ Extremely fast and to the point, bordering on denial of work |

#### Google AI

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | Experience |
|---|---|---|---|---|---|
| Gemini 3.1 Flash Lite Preview | 0.25 | 1.50 | 58% | 1242 | |
| Gemini 3 Flash Preview (low thinking) | 0.50 | 3.00 |  | 1392 | ✅ works wonderfully |
| Gemini 3.1 Pro Preview | 2.00 | 12.00 | 80.6% | 1455 |  |

#### Anthropic

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | Experience |
|---|---|---|---|---|---|
| Claude Sonnet 4.6 | 3.00 | 15.00 | 77.4% | 1523 |  |
| Claude Opus 4.6 | 5.00 | 25.00 | 78.2% | 1549 |  |

## General Purpose agents

* OpenClaw: I was so far unable to get this to work with a local model. tried ollama via LiteLLM and ollama directly but to no avail. it's all not as usable/valuable (yet) as the hype suggests.
