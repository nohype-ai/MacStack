# The AI Coding Stack

Coding is the most impactful use case and most indicative of agentic performance, so this stack may later inform other use cases beyond coding.

## Essential Combinations: Coding Agent + Provider

### Selection Criteria

The basic category here is coding (not general purpose) and cloud inference (not local inference). Further criteria for combo selection were:
* Avoid the bloated, memory-inefficient, slow forks of VSCode (Cursor IDE, Antigravity, Kiro, Windsurf) and instead use lean client apps like Zed (via ACP) or OpenCode Desktop
* Avoid inference outside US/Europe
* Avoid OpenAI
* Avoid low performing agents (Zed's own internal Zed agent)
* Avoid free variants with impractically tight rate limits (OpenCode Zen free models)
* Use a given provider only with the best agent available for it (why use Anthropic account with any other agent than Claude Code)
* Cover range of cheap/fast- versus intelligent models as well as open weights- versus proprietary models

### ACP Agents in Zed and Terminal

| Agent | Provider | free/paid | Zed? | Terminal? | Viable? |
| --- | --- | --- | --- | --- | --- |
| Gemini CLI | Google AI | free (login) | ✅ (5?) | ✅ (5) | ✅ |
| OpenCode | DeepInfra | API key | ✅ (2) | ✅ (2) | ✅ |
| OpenCode | xAI | API key | ✅ | ✅ | ✅ |
| Gemini CLI | Google AI | API key / subscription | ✅ (5?) | ✅ (5) | ✅ |
| Claude Code | Anthropic | API key / subscription | ❓ (6) | ✅ | ✅ |
| Cursor CLI | Cursor | subscription | ✅ (4) | ✅ | ✅ (8) |
| OpenCode | OpenCode Zen | paid models (+6.15% fee) | ✅ | ✅ | 🛑 (9) |
| Cursor CLI | Cursor | free tier | 🛑 (3) | ⚠️ (7) | 🛑 (7) |
| OpenCode | OpenRouter | free models | 🛑 (1) | ✅ | 🛑 |
| OpenCode | OpenRouter | paid models (+5.5% fee) | 🛑 (1) | ✅ | 🛑 |

#### Comments

1. 🛑 OpenCode + OpenRouter: does currently not work in Zed at all, whether with free or paid models. Seems to be a known issue with OpenRouter, which does not even work in the Zed agent (without ACP).
2. ℹ️ OpenCode + DeepInfra: The model list is outdated because DeepInfra updates its available models rapidly, while OpenCode relies on models.dev. Solution: add a opencode.json file in ~/.config/opencode/ and define some desired but missing models in there. Prefix their names with "di-custom: " or so to make them discoverable. Backup/example: [opencode.json](opencode/opencode.json). (Related GitHub issue: [#6231](https://github.com/anomalyco/opencode/issues/6231))
3. 🛑 Cursor CLI + Cursor free tier: ACP is [explicitly not offered on the free tier](https://cursor.com/blog/jetbrains-acp).
4. ℹ️ Cursor CLI + Cursor paid subscription: Works flawlessly. Excellent ACP integration (tested with Sonnet 4.5 and 4.6).
5. ℹ️ Gemini CLI: Tuning model params (temperature etc.) can impact agentic performance. My setup is documented [here](gemini/README.md). I could not fully verify that the custom config is also loaded in Zed via ACP, but it is strongly indicated.
6. ❓ I have not yet tested Claude Code via ACP in Zed, only stand-alone Claude Code.
7. ⚠️ Cursor CLI + Cursor free tier (Terminal): Possible but rate limits are tight enough to possibly be annoying -> has to be used for short tasks only. But only would work in terminal anyway.
8. ℹ️ Cursor CLI + Cursor paid subscription: Bound to subscription, pure usage based is no option. Can't compete with the whole package that Anthropic subscription would offer (agent, cowork, chatbot, native mac app ...), but viable option as second subscription.
9. 🛑 OpenCode + OpenCode Zen: technically possible but can't compete with DeepInfra on price while offering no performance advantage.

**Every ACP Agent:**
* ⚠️ Basic thread management functions like "resuming threads from history" do not even work with "the reference ACP implementation" (Gemini CLI). This also means Zed offers no way to edit the agent's thread history (if it is even created) -> delete OpenCode threads by deleting `~/.local/share/opencode/opencode.db*`. Apply an equivalent solution with other agents.

### OpenCode Agent in OpenCode Desktop App

Mainly for the combinations that showed technical issues in Zed. But the OpenCode agent was generally not as reliable via ACP in Zed, so the OpenCode desktop app could be a fallback.

| Provider | free/paid | Works? | Viable? |
| --- | --- | --- | --- |
| OpenRouter | free models |  |  |
| DeepInfra | API key |  |  |
| xAI | API key |  |  |
| OpenRouter | paid models (+5.5% fee) |  |  |
| OpenCode Zen | paid models (+6.15% fee) |  |  |

## Models

The model comparison here relates to:
* Coding with the above selected app+agent+provider combinations.
* Usage based billing via API key, as this allows the most universal cost comparison.

Models are grouped by agent+provider combination and are sorted by cost per token.

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
