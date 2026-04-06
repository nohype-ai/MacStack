# AI Stack Research: To Do

Next research topics are prioritized to scale up productivity quickly, even at the cost of didactics:

1. ✅ [agent customization](coding%20agent%20customization.md)
2. background coding agents
   * long running, highly autonomous
   * team of agents
   * shipping 10000 LoC per day ... possible with quality and control?
     * many boast they do it. see also "gstack"
3. rag / knowledge management
   * semantic retrieval of your own docs, codebases, notes, decisions
   * spec-driven development?
   * embeddings, vector stores, retrieval pipelines
   * distinct from MCP (tools) — this is about knowledge
   * see also: Context7
5. evals
   * automated quality assessment of agent output
   * generating tests alongside code (even for shell scripts?)
   * regression suites, benchmark runs
   * the unglamorous answer to "10k LoC/day with quality and control?". without it, background coding agents just ship bugs faster
4. mcp servers
   * and generally how to inspect and control the environment of agents (tools/context)
   * LeanCTX, efficient token use
6. observability / tracing
   * understanding what agents are doing (token cost, latency, failures)
   * LangFuse, Helicone
   * prompt degradation over time
   * multi-agent failure debugging
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
