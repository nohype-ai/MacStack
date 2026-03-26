# AI Stack

## IDEs/Clients
- [Zed](https://dashboard.zed.dev) (via GitHub)
  - login unlocks tab completion
- OpenCode Desktop app (no login)
  - `brew install --cask opencode-desktop`

## Agents
- [OpenCode](https://opencode.ai) (no login)
  - ❌ Zed offers no way to edit the OpenCode agent's thread history -> delete threads by deleting `~/.local/share/opencode/opencode.db*` This may be the case for all external agents in Zed.
  - ❌ does currently not work with OpenRouter in Zed, works with OpenRouter in Terminal
- [OpenClaw](https://openclaw.ai)
  - ❌ i was so far unable to get this to work with a local model. tried ollama via LiteLLM and ollama directly but to no avail. it's all not as usable/valuable (yet) as the hype suggests.

## Routers
- [OpenRouter](https://openrouter.ai/workspaces/default) (via GitHub)
  - usable rate limits on free models when funded with 10$
  - ❌ 5.5% markup on paid models

## Providers
- [DeepInfra](https://deepinfra.com) (via GitHub)
  - cheap and fast inference provider for open models
  - ❌ current problem with OpenCode: list of available models does not match available models, some unavailable models are listed, some available models are not listed
- [OpenCode Zen](https://opencode.ai/zen) (via GitHub)
  - model variety without markup
  - can be used in any tool/agent, not just in OpenCode
  - not quite as cheap as DeepInfra
- [xAI](https://console.x.ai)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)
