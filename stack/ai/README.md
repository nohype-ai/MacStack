# AI Stack

This README (and folder) document my current state of finding a working AI stack.

Research is documented in [research/README.md](research/README.md)

## Agent Clients

- [Zed](https://dashboard.zed.dev) (via GitHub account)
  - login unlocks tab completions ("edit predictions")
  - Zed Pro is only for the mediocre internal Zed agent
- [OpenCode desktop app](https://opencode.ai/download) (no login)
  - `brew install --cask opencode-desktop`
- [Claude desktop app](https://code.claude.com/docs/en/desktop-quickstart)
  - with free tier: only chat
  - with subscripton: Code and CoWork
  - no way to use API key as in Claude Code CLI

## Agents

### Coding
- [OpenCode](https://opencode.ai) (no login)
- [Cursor CLI](https://cursor.com/cli) (no login)
- [Gemini CLI](https://geminicli.com) (no login)
- [Claude Code](https://claude.com/product/claude-code)

### Personal
- [OpenClaw](https://openclaw.ai) (🛑 not successfully set up yet)

## Providers

### Routers (Aggregators)
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

### Open Weights
- [DeepInfra](https://deepinfra.com) (via GitHub account)
  - cheap and fast inference provider for open models
  - [Model Prices](https://deepinfra.com/models/text-generation)

### Proprietary
- [xAI](https://console.x.ai) (normal login)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)
  - [Model Prices](https://docs.x.ai/developers/models#model-pricing)
- [Google AI](https://aistudio.google.com/projects) (via Google Account)
  - [Model Prices](https://ai.google.dev/gemini-api/docs/pricing)
- [Anthropic](https://platform.claude.com) (via email)
  - [Model Prices](https://claude.com/pricing#api)

## Models

Models are grouped by provider and sorted by cost per token.

### DeepInfra: Open Weights Models

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

### xAI

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | ACP in Zed |
|---|---|---|---|---|---|
| Grok 4.1 Fast (reasoning) | 0.20 | 0.50 | 70.8% | 1233 | ❓ fast, to the point, pragmatic, asks user instead of endless retries, has trouble editing files |
| Grok 4.20 (reasoning) | 2.00 | 6.00 | 76% | 1378 | ✅ Extremely fast and to the point, sometimes reluctant to edit files directly |

### Google AI

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | ACP in Zed |
|---|---|---|---|---|---|
| Gemini 3.1 Flash Lite Preview | 0.25 | 1.50 | 58% | 1242 | |
| Gemini 3 Flash Preview (low thinking) | 0.50 | 3.00 |  | 1392 | ✅ works wonderfully |
| Gemini 3.1 Pro Preview | 2.00 | 12.00 | 80.6% | 1455 |  |

### Anthropic

| Model | Tokens In | Tokens Out | SWE Bench verified | Arena.ai Coding | ACP in Zed |
|---|---|---|---|---|---|
| Claude Sonnet 4.6 | 3.00 | 15.00 | 77.4% | 1523 |  |
| Claude Opus 4.6 | 5.00 | 25.00 | 78.2% | 1549 |  |
