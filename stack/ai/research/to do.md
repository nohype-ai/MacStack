# AI Stack - To Do

| # | Topic | Why Now | Unlocks |
|---|-------|---------|---------|
| 1 | Agent Customization | Immediate ROI on existing tools | Everything |
| 2 | MCP Servers | Tools + context = capable agents | Background agents, evals, RAG |
| 3 | Evals | Quality gate before scaling | Trustworthy autonomous output |
| 4 | Background Coding Agents | Actual scale | Autonomous output |
| 5 | Observability | See what agents do at scale | Debugging, cost control, improvement |
| 6 | RAG / Knowledge Management | Feed agents your own knowledge | Smarter context, large codebases |
| 7 | Personal Agents | Broader automation, post-foundation | Lifestyle automation |
| 8 | Local Inference | Cost/privacy at scale | Independence from API providers |

The key insight: **1 and 2 are prerequisites, not just nice-to-haves.** Skipping to background agents without them is the most common reason people don't actually get the scale gains they expect. **3 (evals) is the unglamorous answer to "quality and control at scale"** — without it, step 4 is just shipping bugs faster.

1. agent customization
  * agent level (system prompts)
  * project level (AGENT.md etc.)
  * feature level (spec driven ...)
  * "rules"
2. mcp servers
  * and generally how to inspect and control the environment of agents (tools/context)
  * LeanCTX, efficient token use
3. evals
  * automated quality assessment of agent output
  * generating tests alongside code
  * regression suites, benchmark runs
  * the answer to "10k LoC/day with quality and control?"
4. background coding agents
  * long running, highly autonomous
  * team of agents
  * shipping 10000 LoC per day ... possible with quality and control?
    * many boast they do it. see also "gstack"
5. observability / tracing
  * understanding what agents are doing (token cost, latency, failures)
  * LangFuse, Helicone
  * prompt degradation over time
  * multi-agent failure debugging
6. rag / knowledge management
  * semantic retrieval of your own docs, codebases, notes, decisions
  * embeddings, vector stores, retrieval pipelines
  * distinct from MCP (tools) — this is about knowledge
  * see also: Context7
7. personal agents
  * openclaw
  * claude cowork
8. local inference
  * mlx
  * mlx-lm
  * ollama
  * LMStudio
  * LiteLLM
  * (vLLM)
