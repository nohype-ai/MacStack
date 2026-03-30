# Gemini CLI Configuration

## How?

The [settings.json](settings.json) in this folder is a backup or example of `~/.gemini/settings.json`. It sets a custom alias as the default Gemini CLI model. Gemini will launch with this as its model, but note that the interactive model selector will not show these custom configs.

## Why Tinker with Settings?

The default interactive experience uses the built-in **`chat-base`** preset:

```json
"temperature": 1.0,
"topP": 0.95,
"topK": 64,
"thinkingConfig": {
  "thinkingLevel": "HIGH"
}
```

Gemini CLI has several agent-optimized internal aliases (e.g. `prompt-completion`, `edit-corrector`, `fast-ack-helper`) that use much lower temperature (0.2–0.3 or even 0) — but those are only used automatically by specific sub-agents, not by the main chat session. Google left the main path deliberately alive and creative.

It is fairly common among power users to set tighter values for reliability, precision and speed of real coding/agentic work. Google gives this ability to customize but also says that lower temps can sometimes hurt reasoning on the 3-series models.

## What are better Settings?

The temp 0.6 / topP 0.95 / topK 40 combo is the current community consensus (and NVIDIA's official recommendation) for any model doing structured agent work. It can result in more successful tool calls, less retries, and faster edits:

| Parameter       | Custom | Gemini native | Why customize |
|-----------------|--------------|-----------------------|--------------------|
| **temperature** | **0.6**      | 1.0                   | 1.0 = very creative/random. 0.6 makes outputs far more consistent and deterministic — critical for valid JSON tool calls and clean file edits. |
| **topK**        | **40**       | 64 | 40 is the proven sweet spot for coding/agentic work. Higher values let in too much noise. |
| **thinkingLevel** | LOW, MEDIUM | MEDIUM, HIGH | HIGH + temp=1.0 can trigger long internal monologues, delegation hangs and long loops |
