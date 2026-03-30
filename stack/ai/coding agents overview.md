# Coding Agents Overview

ACP allows using the agents in any IDE, most notably in Zed. It enables rotating through several different agents in the same IDE. Also Zed is much faster, memory efficient and open than VSCode based IDEs, so it's the way to go anyways.

## ACP Coding Agents Comparison (March 2026)

| Agent              | Score (0–100) | BYOK | Cost Min                                      | Cost Max                                      | Efficiency (0–100) | Free Tier                                      |
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
* It's free tier has gracious enough rate limits -> use as one of several external agent options in Zed

## OpenCode

OpenCode is the best open-source- and the best BYOK coding agent.

**Why OpenCode? (over Cursor, Antigravity, etc.)**
- Open-source and highly established (130k GitHub stars)
- Built from the ground up to work with any model/vendor
- Native support for local models
- Pure CLI agent (with ACP) as well as desktop app
- Desktop app is much leaner than VSCode-IDEs (memory footprint)
- Pay-as-you-go pricing (OpenCode Zen) charges no markup (and yet gives model variety)
- No lock-in into subscriptions, models, APIs or even agents (zen can be used in any agent/app via API key)

**Offerings:**
* **OpenCode Core (Standard BYOK):** The core OpenCode software naturally lets you inject an API key from any provioder (e.g., an OpenRouter key, an xAI API key, or a Google AI Studio key). **Your cost is $0 to OpenCode.** You rely 100% on the inference pricing defined by your external model provider. OpenCode supports **75+ model providers** directly via the AI SDK + Models.dev.
* **OpenCode Zen:** This is their pay-as-you-go proxy service. Zen allows you to access a curated list of open models hosted by OpenCode themselves (billed per tokens). Alternatively, you can inject third-party keys directly into Zen; when you do this, billing is handed off directly to your third-party provider, not OpenCode.
* **OpenCode Go:** A $10/month flat-rate subscription that gives access to set models without worrying about usage tokens.
