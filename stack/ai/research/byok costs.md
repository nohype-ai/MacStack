# BYOK Costs                

## Why BYOK (over Subscriptions)?

To avoid lock-in while using **OpenCode** (or other code editors, agents or LLM clients), you can just take an API key generated from any provider, like OpenRouter, xAI, or Google AI.

* Use in products (not just for personal use)
* Use/test all apps (not just app of subscription provider)
* No rate limits
* Flexible cost management, no costs when no usage occurs
* Using personal agents (like OpenClaw)
* Valuable learnings for client work and building products:
  - Manage token costs (what usage is valuable?)
  - One step closer to on-device/on-premise setups

## Methodology

* This report is composed of output from Gemini 3.1 Pro and Grok 4.20. Both gave the same recommendations and the same ranking.
* Prompt: "I do neither like openAI nor anthropic. I would consider open source models, Google and xAI. Given these 3 options, please give me an overview showing some sort of intelligence per dollar estimate for the different pay per token options for the different models. I am not familiar how pay per token (BYOK) works for open source models (who hosts them). give me a comprehensive overview. take your time to research this. you may Also include OpenCode's own BYOK offerings. I want only BYOK so I don't get locked into any specific software tool."
* All solutions here allow to generate an API key from the provider and plug it directly into your preferred custom software or IDEs (OpenCode, VS Code, Cursor, generic scripts, etc.).
* Pricing from provider sites + comparison tables  
* Coding/agentic performance from SWE-Bench Verified, LiveCodeBench, Artificial Analysis Quality Index  
* Blended cost ≈ (3:1 output:input ratio, common for coding/agent use)  
* Only models/providers: open-source hosted + Google + xAI + OpenCode BYOK options. No OpenAI/Anthropic.

## Intelligence-per-dollar overview (March 2026 data)

| Category / Model | Host (BYOK) | Input / Output per 1M tokens | Blended cost ≈ | Context | SWE-Bench / Coding strength | Intelligence / $ estimate | Best for |
|------------------|-------------|------------------------------|----------------|---------|-----------------------------|---------------------------|----------|
| **xAI Grok 4.1 Fast** | xAI direct | $0.20 / $0.50 | **$0.35** | 2M | Very strong agentic/tool use | ★★★★★ (best overall value) | Daily driver, long context, reasoning |
| **xAI Grok 4.20** | xAI direct | $2.00 / $6.00 | **$4.00** | 2M | Top-tier reasoning | ★★★ | Heavy agentic tasks (expensive) |
| **Google Gemini 3.1 Flash / Flash-Lite** | Google AI Studio or Vertex | $0.10–0.30 / $0.40 (caching cheaper) | **$0.25–0.45** | 1M+ | 75%+ SWE-Bench (high-reasoning mode) | ★★★★☆ | High-volume, multimodal, cheap speed |
| **Google Gemini 3.1 Pro** | Google | ~$2 / $4–12 | **$3–8** | 1M+ | Excellent (top 3 coding) | ★★★ | Complex projects (not best value) |
| **DeepSeek V3.2** (top open) | DeepInfra / Together / Fireworks | $0.28 / $0.42 | **$0.35** | 128K–1M | 89%+ LiveCodeBench | ★★★★★ (highest $/performance) | Pure coding, best bang-for-buck open |
| **Qwen3 Coder / Kimi K2.5** (top open) | Groq / Together / DeepInfra | $0.29–1.00 / $0.85–3.00 | **$0.60–1.50** | 128K–256K | Near frontier on agentic/coding | ★★★★★ | Coding specialists, Groq = fastest |
| **GLM-5 / MiniMax M2.5** (top open) | Together / OpenCode Zen (BYOK compatible) | $0.30–1.00 / $1.20–3.20 | **$0.70–1.80** | 200K+ | 75%+ SWE-Bench | ★★★★☆ | Agentic workflows |
| **Llama 4 Maverick / Scout** (Meta open) | Groq / Together | $0.11–0.27 / $0.34–0.85 | **$0.30–0.60** | 128K–10M (some) | Strong open baseline | ★★★★ | When you want fully open weights + speed |

## Open Source Models (DeepSeek, Llama, Qwen)

### How BYOK works with Open-Source Models

You don’t run them locally (unless you choose true local via Ollama/etc.). Instead, third-party hosts (specialized **inference providers**) run the open-weight models on their GPUs and expose a fast OpenAI-compatible API. Popular hosts (all supported in OpenCode):  
- **Groq** → fastest inference (LPU hardware)  
- **DeepInfra** → usually cheapest  
- **Together.ai** → wide selection + good caching  
- **Fireworks.ai** → very fast + strong structured output
- **OpenRouter:** A proxy that aggregates models from dozens of providers and automatically routes your request to the cheapest/fastest host. This is highly recommended for BYOK.

> Note: Pure inference providers (Groq, Together, DeepInfra) only host open-weights models, whereas aggregators like OpenRouter give access to both, open-weights AND proprietary closed-source models. So why use a pure inference provider at all? Answer: For individual developers and startups, aggregators are the better choice if they value model variety with single-billing convenience. BUT: aggregators like OpenRouter take a platform fee (markup). Also, enterprises deploying at scale will sign direct contracts with Groq, Together, or Google for further reasons: speed, uptime, privacy, compliance, advanced features and dedicated rate limits.

### Best Inference Providers for Open-Source Models

These are the non-chinese ones, assuming we don't want to send business- or user data to china:

| Provider          | HQ + Inference Location | Blended price example (70B-class open model, input/output per 1M tokens) | OpenAI-compatible? | Key advantage for you                  | Drawback                          |
|-------------------|-------------------------|--------------------------------------------------------------------------|--------------------|----------------------------------------|-----------------------------------|
| **DeepInfra**     | Palo Alto, CA (US)     | **~$0.29–0.46**                                                         | Yes               | Cheapest overall among Western providers | Slightly slower than Groq        |
| **Together.ai**   | San Francisco, CA (US) | ~$0.60–0.88                                                             | Yes               | Huge model catalog + fine-tuning       | Higher prices than DeepInfra            |
| **Fireworks AI**  | US                     | ~$0.60–0.90                                                             | Yes               | Very fast inference + strong tool use  | Not the absolute cheapest        |
| **Groq**          | US                     | ~$0.59–0.79 (Llama etc.)                                                | Yes               | Insanely fast (LPU hardware)           | More expensive + smaller catalog |

**DeepInfra versus OpenCode Zen:**

Raw per-token prices vary between providers, so we must compare **actual prices on overlapping open-weight models** + Zen’s fixed $1.23 per $20 top-up (6.15 % effective fee):

| Model                              | OpenCode Zen (input/output per 1M) | DeepInfra (input/output per 1M) | Winner & savings |
|------------------------------------|------------------------------------|---------------------------------|------------------|
| **MiniMax M2.5**                  | $0.30 / $1.20                     | $0.27 / $0.95                  | **DeepInfra** (~10–20 % cheaper) |
| **Qwen3-Coder 480B** (Turbo)      | $0.45 / $1.50                     | $0.22 / $1.00                  | **DeepInfra** (~50 % cheaper) |
| **Qwen3-Coder 480B** (standard)   | $0.45 / $1.50                     | $0.40 / $1.60                  | **DeepInfra** (slightly cheaper) |
| **Kimi K2.5**                     | $0.60 / $3.00                     | $0.45 / $2.25                  | **DeepInfra** (~25 % cheaper) |
| **GLM-5 / GLM-4.7**               | $1.00 / $3.20                     | $0.80–$0.90 / $2.56–$2.90     | **DeepInfra** (~15–20 % cheaper) |

Even without Zen’s 6.15 % processing fee, **DeepInfra is cheaper** on every overlapping open-weight model (often 10–50 % cheaper). DeepInfra also offers many additional very cheap open models (Llama-3.3-70B-Turbo at $0.10/$0.32, etc.) that Zen simply does not have.

### Best choice right now: **DeepInfra**
- It is the clear winner on price among Western providers.
- Zero markup beyond their own efficient bare-metal infrastructure.
- Pure pay-as-you-go (add credits any amount, no monthly fee).
- Full OpenAI-compatible API → you just `/connect` in OpenCode or OpenClaw
- Excellent uptime and support for many models

### Intelligence per Dollar (The Leaders)

Note that the costs of open weights models depends heavily on model architecture and not just on the inference provider. That is why it makes sense to compare models:

*   **DeepSeek V3 / V3.2**
    *   **Cost:** ~$0.14 - $0.28 per 1M Input | ~$0.28 - $0.40 per 1M Output
    *   **Intelligence:** Top-tier capability. DeepSeek frequently punches in the highest Chatbot Arena ELO brackets, matching elite proprietary models in reasoning and coding.
    *   **Value:** **Off the charts.** DeepSeek currently offers the absolute highest intelligence-per-dollar ratio available on the market.
*   **Llama 3.3 70B Instruct / Llama 4 Series**
    *   **Cost:** ~$0.10 per 1M Input | ~$0.32 per 1M Output
    *   **Intelligence:** Exceptional reasoning and instruction-following, consistently leading the open-weights pack.
    *   **Value:** Extremely high. Cheap enough for large-scale agentic reasoning loops while remaining incredibly competent.
*   **Qwen 2.5 72B / Qwen 3.5 Plus**
    *   **Cost:** ~$0.26 per 1M Input | ~$1.56 per 1M Output 
    *   **Intelligence:** Superb coding abilities and multi-lingual/context handling.
    *   **Value:** Moderate to High. Output tokens are slightly more expensive, but Alibaba's Qwen models are uniquely strong in coding.

## xAI (Grok Models)

xAI has drastically altered their developer API pricing, making their models highly competitive for BYOK developer use cases.

### Intelligence per Dollar
*   **Grok 4.1 Fast / Grok Code Fast 1**
    *   **Cost:** $0.20 per 1M Input | $0.50 - $1.50 per 1M Output
    *   **Intelligence:** Elite performance. Grok 4.1 frequently battles in the >1300 ELO brackets.
    *   **Value:** **Exceptional.** xAI is aggressively undercutting the proprietary market. Grok 4.1 Fast is one of the absolute best values for complex multi-step reasoning and coding tasks compared to legacy models.
*   **Grok 4 / Grok 3**
    *   **Cost:** $3.00 per 1M Input | $15.00 per 1M Output
    *   **Intelligence:** Flagship, cutting-edge models optimized for extreme reliability and complex system thinking.
    *   **Value:** Low to moderate. You get absolute peak performance, but the cost jumps roughly 15x compared to the "Fast" versions.

## Google (Gemini Models)

Google's models are accessible via Google AI Studio (which has generous free tiers) and Vertex AI (for enterprise). They remain the industry standard for sheer long-context tasks.

### Intelligence per Dollar
*   **Gemini 2.5 Flash / Gemini 3 Flash**
    *   **Cost:** ~$0.30 - $0.50 per 1M Input | ~$2.50 - $3.00 per 1M Output
    *   **Intelligence:** Very high, exceptionally fast, and top-tier multimodal vision processing.
    *   **Value:** High. An excellent balance of speed and cost, becoming invaluable when you require their massive 1M-2M context windows.
*   **Gemini 2.5 Pro / Gemini 3.1 Pro**
    *   **Cost:** ~$1.25 - $2.00 per 1M Input | ~$10.00 - $12.00 per 1M Output *(Note: Input/Output cost doubles for requests exceeding a 200,000 token context window)*
    *   **Intelligence:** Elite class. Gemini Pro routinely pushes the boundaries on hardest-tier prompts and code reasoning. 
    *   **Value:** Moderate. Among the smartest models in the world, but you pay a premium for its capabilities.

## Final Verdict: The "Intelligence per Dollar" Winners

If you want to maximize the sheer reasoning power you receive for every dollar spent dynamically via API in 2026:

1.  **DeepSeek V3 / V3.2 (via OpenRouter/Groq):** Unchallenged champion. Offers flagship-tier intelligence at budget open-source pricing (~$0.14-$0.28 per 1M input). **Best intelligence per dollar** → DeepSeek V3.2 or Qwen3/Kimi on DeepInfra/Together/Groq. Often beats or matches much more expensive models on real coding/agent tasks while costing 5–10× less. **DeepSeek V3 / V3.2** easily takes the crown for raw intelligence per dollar, running roughly on par with GPT-4 class models at a fraction of the cost.
2.  **Grok 4.1 Fast (via xAI API):** The proprietary disruptor. Offers elite-tier intelligence for just $0.20 per 1M input tokens with a 2-million context window. **Runner-up** → xAI Grok 4.1 Fast (insanely cheap + 2M context + excellent agentic performance). **xAI's Grok 4.1 Fast** model is extremely competitive, aggressively undercutting traditional proprietary costs to win over developers.
3.  **Llama 3.3 70B (via OpenRouter/Together):** The highly reliable open-source workhorse for ~$0.10 per 1M input.
4.  **Gemini 3 Flash (via Google AI Studio):** Unbeatable if your specific need is massive 1M+ context lengths or visual context. **Google's Gemini models** are slightly more expensive but shine particularly if you require ultra-long context windows (up to 2M tokens). **Convenient cheap volume** → Gemini 3.1 Flash-Lite (Google key).
5.  **OpenCode Zen**: Some of the same open models (e.g. MiniMax M2.5) at similar or slightly higher transparent rates with zero setup.
