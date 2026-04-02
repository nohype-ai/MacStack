# AI Stack

This README (and folder) document my current state of finding a working AI stack.

Research is documented in [research/](research/)

## Layers of the Stack

### Agent Clients

Native macOS apps that offer GUI frontends to agents – natively or via ACP. And no bloated VSCode forks here.

- [Zed](https://dashboard.zed.dev) (via GitHub account)
  - login unlocks tab completions ("edit predictions")
  - Zed Pro is only for the mediocre internal Zed agent
- [OpenCode desktop app](https://opencode.ai/download) (no login)
  - `brew install --cask opencode-desktop`
- [Claude desktop app](https://code.claude.com/docs/en/desktop-quickstart) (via Claude/Anthropic account)
  - with free tier: only chat
  - with subscripton: Code and CoWork
  - no way to use API key as in Claude Code CLI

### Agents

CLI agents that can be used via TUI.

#### Coding Agents (with ACP support)
- [OpenCode](https://opencode.ai)
- [Cursor CLI](https://cursor.com/cli)
- [Gemini CLI](https://geminicli.com)
- [Claude Code](https://claude.com/product/claude-code)

#### Personal Agents
- [OpenClaw](https://openclaw.ai)

### Providers

Cloud services that offer access to model inference.

#### Routers (Aggregators)
- [OpenRouter](https://openrouter.ai/workspaces/default) (via GitHub account)
  - usable rate limits on free models when funded with 10$
  - 5.5% markup on paid models
- [OpenCode Zen](https://opencode.ai/zen) (via GitHub account)
  - aggregates and routes to curated, benchmarked models hosted at other providers
  - borderline fraudulent marketing of "zero markups". their "small payment processing fee of 1.23 USD per 20 USD balance top-up" amounts to a 6.15% fee, because you only can spend in 20 USD increments.
  - can be used in any tool/agent, not just in OpenCode
  - by far not as cheap as DeepInfra
  - but performs well in OpenCode, even via ACP (in Zed)
- [Cursor](https://cursor.com/dashboard) (normal login)
  - acts as aggregator for its own IDE/agent subscriptions, as it bundles access to multiple other providers but mostly does not host models itself
  - free "Hobby" tier with generous rate limits but without ACP support
  - login via GitHub would be possible (as second account or to simplify)

#### Open Weights
- [DeepInfra](https://deepinfra.com) (via GitHub account)
  - cheap and fast inference provider for open models
  - [Model Prices](https://deepinfra.com/models/text-generation)

#### Proprietary
- [xAI](https://console.x.ai) (normal login)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)
  - [Model Prices](https://docs.x.ai/developers/models#model-pricing)
- [Google AI](https://aistudio.google.com/projects) (via Google Account)
  - [Model Prices](https://ai.google.dev/gemini-api/docs/pricing)
- [Anthropic](https://platform.claude.com) (via email)
  - [Model Prices](https://claude.com/pricing#api)

### Models

- available models determined by Agent + Provider combination.
- prices differ widely - more than performance
- https://arena.ai/leaderboard/text/coding?viewBy=plot&rankBy=labs
- https://arena.ai/leaderboard/code?viewBy=plot&rankBy=labs

## Essential Combinations: ACP Agent + Provider

### Selection Criteria

The basic category here is coding (not general purpose), cloud inference (not local inference), and availability of ACP. Further criteria for combo selection were:
* Avoid inference outside US/Europe
* Avoid OpenAI
* Avoid low performing agents
* Avoid free variants with impractically tight rate limits (OpenCode Zen free models)
* Use a given provider/router only with the best agent available for it (why use Anthropic account with any other agent than Claude Code)
* Cover range of cheap/fast- versus intelligent models as well as open weights- versus proprietary models

### Selection

**Viable:**
| Agent | Provider | free/paid | In Zed via ACP | In Terminal |
| --- | --- | --- | --- | --- |
| Gemini CLI | Google AI | free (login) | ✅ (5?) | ✅ (5) |
| OpenCode | DeepInfra | API key | ✅ (2) | ✅ (2) |
| OpenCode | xAI | API key | ✅ | ✅ |
| Gemini CLI | Google AI | API key / subscription | ✅ (5?) | ✅ (5) |
| Claude Code | Anthropic | API key / subscription | ❓ (6) | ✅ |

**Ruled Out:**
| Agent | Provider | free/paid | In Zed via ACP | In Terminal |
| --- | --- | --- | --- | --- |
| Cursor CLI | Cursor | subscription | ✅ (4) | ✅ |
| OpenCode | OpenCode Zen | paid models (+6.15% fee) | ✅ | ✅ |
| Cursor CLI | Cursor | free tier | 🛑 (3) | ⚠️ (7) |
| OpenCode | OpenRouter | free models | 🛑 (1) | ✅ |
| OpenCode | OpenRouter | paid models (+5.5% fee) | 🛑 (1) | ✅ |

### Issues

1. 🛑 OpenCode + OpenRouter: does currently not work in Zed at all, whether with free or paid models. Seems to be a known issue with OpenRouter, which does not even work in the Zed agent (without ACP).
2. ℹ️ OpenCode + DeepInfra: The model list is outdated because DeepInfra updates its available models rapidly, while OpenCode relies on models.dev. Solution: add a opencode.json file in ~/.config/opencode/ and define some desired but missing models in there. Prefix their names with "di-custom: " or so to make them discoverable. Backup/example: [opencode.json](../opencode/opencode.json). (Related GitHub issue: [#6231](https://github.com/anomalyco/opencode/issues/6231))
3. 🛑 Cursor CLI + Cursor free tier: ACP is [explicitly not offered on the free tier](https://cursor.com/blog/jetbrains-acp).
4. ℹ️ Cursor CLI + Cursor paid subscription: Works flawlessly. Excellent ACP integration (tested with Sonnet 4.5 and 4.6). But of course it's bound to a subscription, pures usage based is no option. And can't compete with the whole package that Anthropic subscription would offer (agent, cowork, chatbot, native mac app ...).
5. ℹ️ Gemini CLI: Tuning model params (temperature etc.) can impact agentic performance. My setup is documented [here](../gemini/README.md). I could not fully verify that the custom config is also loaded in Zed via ACP, but it is strongly indicated.
6. ❓ I have not yet tested Claude Code via ACP in Zed, only stand-alone Claude Code.
7. Cursor CLI + Cursor free tier (Terminal): Possible but rate limits are tight enough to possibly be annoying -> has to be used for small tasks only

**Every ACP Agent:**
* ⚠️ Basic thread management functions like "resuming threads from history" do not even work with "the reference ACP implementation" (Gemini CLI). This also means Zed offers no way to edit the agent's thread history (if it is even created) -> delete OpenCode threads by deleting `~/.local/share/opencode/opencode.db*`. Apply an equivalent solution with other agents.

## Models

This sections focusses on:
* Coding with ACP agents (most impactful baseline use case)
* Usage based billing via API key (most universal cost comparison)

Models are grouped by [agent+provider combination](research/coding%20agents.md) and are sorted by cost per token.

### OpenCode + DeepInfra (Open Weights Models)

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | ACP in Zed |
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

### OpenCode + xAI (Grok models)

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | ACP in Zed |
|---|---|---|---|---|---|
| Grok 4.1 Fast (reasoning) | 0.20 | 0.50 | 70.8% | 1233 | ❓ fast, to the point, pragmatic, asks user instead of endless retries, has trouble editing files |
| Grok 4.20 (reasoning) | 2.00 | 6.00 | 76% | 1378 | ✅ Extremely fast and to the point, sometimes reluctant to edit files directly |

### Gemini CLI + Google AI (Gemini models)

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | ACP in Zed |
|---|---|---|---|---|---|
| Gemini 3.1 Flash Lite Preview | 0.25 | 1.50 | 58% | 1242 | |
| Gemini 3 Flash Preview (low thinking) | 0.50 | 3.00 |  | 1392 | ✅ works wonderfully |
| Gemini 3.1 Pro Preview | 2.00 | 12.00 | 80.6% | 1455 |  |

### Claude Code + Anthropic (Claude models)

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | ACP in Zed |
|---|---|---|---|---|---|
| Claude Sonnet 4.6 | 3.00 | 15.00 | 77.4% | 1523 |  |
| Claude Opus 4.6 | 5.00 | 25.00 | 78.2% | 1549 |  |
