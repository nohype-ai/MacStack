# Coding Agents

## ACP Coding Agents Comparison (March 2026)

ACP allows using the agents in any IDE, most notably in Zed. It enables rotating through several different agents in the same IDE. Also Zed is much faster, memory efficient and open than VSCode based IDEs, so it's the way to go anyways. So we limit this to agents with ACP integration in Zed plus Zed's own agent.

| Agent              | Agentic Performance | BYOK | Cost Min                                      | Cost Max                                      | Token Efficiency | Free Tier                                      |
|--------------------|---------------|------|-----------------------------------------------|-----------------------------------------------|--------------------|------------------------------------------------|
| **Claude Code**   | 98            | 🛑 | $1.00 (Claude Haiku 4.5)                     | $5.00 (Claude Opus 4.6)                      | 96                 | None (Pro $20/mo required for agent)          |
| **Codex** (CLI)   | 93            | 🛑 | $0.20 (GPT-5.4 Nano)                         | $2.50 (GPT-5.4)                              | 91                 | Limited (30–150 messages/5 hrs with Plus $20/mo) |
| **Cursor Agent**  | 89            | 🛑 (many models though)   | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 68                 | Limited agent requests (Hobby free tier)      |
| **Kimi CLI**      | 87            | 🛑 | $0.60 (Kimi K2.5)                            | $0.60 (Kimi K2.5)                            | 85                 | Limited daily queries (casual-use free tier)  |
| **Gemini CLI**    | 84            | 🛑 | $0.10 (Gemini 2.5 Flash-Lite)                | $2.00 (Gemini 3.1 Pro)                       | 89                 | 1,000 requests/day (free Google account)      |
| **OpenCode**      | 78            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 82                 | 1,000 req/day (Gemini free) **or** unlimited local |
| **GitHub Copilot**| 72            | 🛑 | Subscription ($10–39/mo + usage)             | Subscription ($10–39/mo + usage)             | 65                 | 2,000 completions + 50 premium req/mo         |
| **Kilo**          | 70            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 75                 | 1,000 req/day (Gemini free) **or** unlimited local |
| **Cline**         | 67            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 73                 | 1,000 req/day (Gemini free) **or** unlimited local |
| **Zed Agent**     | 60            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 62                 | 1,000 req/day (Gemini free) **or** unlimited local |

**Note on Cursor agent**:
* It offers virtually all models but provides them through its own plans with no true BYOK option.
* It offers no pure per token pricing but ties everything to subscriptions.
* Its free tier has maybe worthwile rate limits but does not support ACP.

## OpenCode

OpenCode is the best open-source- and the best BYOK coding agent.

**Why OpenCode?**
- Open-source and highly established (130k GitHub stars)
- Built from the ground up to work with any model/vendor
- Native support for local models
- Pure CLI agent (with ACP) as well as desktop app
- Desktop app is much leaner than VSCode-IDEs (memory footprint)
- Native pay-as-you-go pricing is offered (OpenCode Zen) and gives model variety (but charges 6.15% fee)
- No lock-in into subscriptions, models, APIs or even agents (zen can be used in any agent/app via API key)

**Offerings:**
* **OpenCode Core (Standard BYOK):** The core OpenCode software naturally lets you inject an API key from any provioder (e.g., an OpenRouter key, an xAI API key, or a Google AI Studio key). **Your cost is $0 to OpenCode.** You rely 100% on the inference pricing defined by your external model provider. OpenCode supports **75+ model providers** directly via the AI SDK + Models.dev.
* **OpenCode Zen:** This is their pay-as-you-go proxy service. Zen allows you to access a curated list of open models hosted by OpenCode partner providers.
* **OpenCode Go:** A $10/month flat-rate subscription that gives access to set models without worrying about usage tokens.

## Install ACP Agents in Zed

* 🚨 To set up an agent via ACP in Zed, install it within Zed from the ACP registry (Shift + Cmd + P -> "zed: acp registry"). Do **not** add a regular (Homebrew-) installation of the same agent as a custom agent to settings.json, since that will likely not work, as ACP support (from Zed and from agents) is generally still immature anyway. The installs offered via the registry are optimized and tested for ACP and Zed.
* However, at least the registry install of an agent is exclusively managed and used by Zed and will never conflict with a regular system-wide install of the same agent.
* In theory, ACP registry installs all support authentication via ACP, but that does not work with all registry-installed agents. The reliable route is to also have a regular system-wide (Homebrew-) install of the same agent and use that one for initial authentication (connecting the agent to a/its provider).
