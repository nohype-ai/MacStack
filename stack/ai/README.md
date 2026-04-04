# The AI Stack

This README defines the general layers of an AI stack and selects specific tools at each layer. The coding-specific stack is defined in [coding stack.md](coding%20stack.md). Research and past decisions are documented in [research/](research/).

This stack does not yet involve local inference but still focusses on scaling up productivity. Research on local inference for privacy and cost-efficiency at scale [will follow in time](research/to%20do.md).

## Agent Clients

Native macOS apps that offer GUI frontends to agents – natively or via ACP. But no bloated VSCode forks.

- [Zed](https://dashboard.zed.dev) (via GitHub account)
  - login unlocks tab completions ("edit predictions")
  - Zed Pro is only for the mediocre internal Zed agent
- [OpenCode desktop app](https://opencode.ai/download) (no login)
  - `brew install --cask opencode-desktop`
- [Claude desktop app](https://code.claude.com/docs/en/desktop-quickstart) (via Claude/Anthropic account)
  - with free tier: only chat
  - with subscripton: Code and CoWork
  - no way to use API key as in Claude Code CLI

## Agents

### Coding Agents
Selection is explained in [coding stack.md](coding%20stack.md).
- [OpenCode](https://opencode.ai)
- [Cursor CLI](https://cursor.com/cli)
- [Gemini CLI](https://geminicli.com)
- [Claude Code](https://claude.com/product/claude-code)
- [Amp](https://ampcode.com)

### Personal Agents
Not deeply explored yet.
- [OpenClaw](https://openclaw.ai)
- [Claude CoWork](https://claude.com/product/cowork)

## Providers

Cloud services that offer access to model inference. Related research is in [byok costs.md](research/byok%20costs.md) and [routers.md](research/routers.md).

### Routers (Aggregators)
These poviders do not provide inference themselves but only act as gateways that aggregate- and route to other providers.
- [OpenRouter](https://openrouter.ai/workspaces/default) (via GitHub account)
  - usable rate limits on free models when funded with 10$
  - free models: https://openrouter.ai/models?fmt=cards&input_modalities=text&max_price=0&order=most-popular&output_modalities=text
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
- [Amp](https://ampcode.com/settings) (normal login)
  - routes to different LLMs as part of the agent's intelligence (best model for each task)
  - frontier professional agentic performance
  - no markup, but API prices plus heavy agentic work amount to high costs
  - free tier will be available again in the future

### Open Weights Providers
These providers only provide the inference, hosting a wide range of publically available models.
- [DeepInfra](https://deepinfra.com) (via GitHub account)
  - cheap and fast inference provider for open models
  - [Model Prices](https://deepinfra.com/models/text-generation)

### Proprietary Providers
These providers provide the inference and also train the models and are often the only way to access these models.
- [xAI](https://console.x.ai) (normal login)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)
  - [Model Prices](https://docs.x.ai/developers/models#model-pricing)
- [Google AI](https://aistudio.google.com/projects) (via Google Account)
  - [Model Prices](https://ai.google.dev/gemini-api/docs/pricing)
- [Anthropic](https://platform.claude.com) (via email)
  - [Model Prices](https://claude.com/pricing#api)

## Models

- Available models are determined by each agent+provider combination.
- Costs differ widely - more than performance.
- https://arena.ai/leaderboard/text/coding?viewBy=plot&rankBy=labs
- https://arena.ai/leaderboard/code?viewBy=plot&rankBy=labs
- See the models overview in the [coding stack.md](coding%20stack.md)
