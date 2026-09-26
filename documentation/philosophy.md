# MacStack — Philosophy & Strategic Direction

*Conversation summary by Claude Opus 4.6 on April 6, 2026*

## What MacStack Is

MacStack is a native, lightweight CLI tool that sets up and maintains the entire software stack on a Mac with one command. It is idempotent, non-destructive, and blends into any machine — whether a developer's personal laptop or a company's Mac Studio.

## Core Principles

### Native, Not Isolated

MacStack manages the real machine, not an abstraction of it. There are no containers, no virtual machines, no sandboxes. Software runs natively on the host, with direct access to Apple Silicon hardware, Metal GPU acceleration, and the full macOS experience.

This is not a limitation — it is the point. Local AI inference is fast on Apple Silicon precisely because models run natively with unified memory and Metal. The moment you put that into a Docker container, you lose the hardware advantage. MacStack manages the infrastructure without abstracting away the hardware.

### Lightweight, Not Locked Down

MacStack is not MDM. It does not fight the user, does not require IT approval, and does not lock things down. It is a tool for practitioners who want reproducible setups without giving up control. It only manages what is defined in the stack — everything else on the machine is left untouched.

This makes it equally appropriate for a solo developer customizing their personal laptop and for a team standardizing their AI tooling across a fleet of Mac Studios.

### Declarative, Not Procedural

A MacStack stack is a folder of configuration files that describe the desired state: which packages to install, which shell customizations to apply, which git repos to manage, which AI agent settings to enforce. Running `mack update` converges the machine toward that state. It does not matter whether the machine is freshly installed or has been running for years — the result is the same.

## What Makes MacStack Unique

### Among Mac Setup Tools

Tools like strap, chezmoi, and mackup each cover a slice of Mac provisioning — bootstrapping, dotfile management, or app settings backup. MacStack covers the full picture in one tool: Homebrew packages, shell configuration, git setup, IDE settings and extensions, AI agent configuration, and git repository management. The stack is a single, portable, versionable folder that defines an entire machine.

### The AI-Native Angle

MacStack is, to our knowledge, the only Mac provisioning tool that treats AI agent configuration as a first-class concern. It manages settings and permissions for tools like Cursor, Gemini CLI, and OpenCode today, with a natural path to managing the full AI developer stack:

- **Agent CLI tools** — installation and updates of Claude Code, Gemini CLI, OpenCode, Aider, and others as a managed category
- **Agent settings** — system prompts, rules, personas, and tool permissions versioned as code, not scattered across app settings
- **MCP server configuration** — the Model Context Protocol ecosystem is growing fast, and configuring MCP servers across multiple agent tools on a machine is currently a manual, fragmented process. MacStack can own this.
- **Local inference runtimes** — managing Ollama, LM Studio, or llama.cpp installations and potentially model downloads as declarative stack components
- **Team-wide AI configuration** — a shared base stack that defines an organization's AI tooling defaults, with individual overrides on top

### Positioning in the Market

MacStack occupies a genuine gap between three established categories:

| | MDM (Jamf, Mosyle) | Containers (Docker) | MacStack |
|---|---|---|---|
| **Weight** | Heavy, enterprise IT | Heavyweight, requires runtime | Lightweight CLI |
| **User control** | Restrictive, policy-driven | Isolated from the host | User stays in full control |
| **Native performance** | N/A | Loses hardware access | Full Apple Silicon / Metal |
| **AI inference** | Not designed for it | Suboptimal on Mac | Native, hardware-accelerated |
| **Audience** | IT administrators | DevOps engineers | Developers and AI practitioners |

## Growth Opportunities

### Homebrew Distribution

MacStack will be distributed as a Homebrew formula — initially via a custom tap (`brew tap nohype-ai/tap`), with the goal of graduating to Homebrew core once adoption justifies it. The AI configuration management angle is sufficiently novel to differentiate from existing tools in core.

### Stack Registry

A public registry where users can publish, browse, and fork stacks. A personal stack could inherit from a registry stack as its baseline, only defining overrides — similar to how user settings in an IDE override defaults. This creates network effects and a discovery mechanism.

### Nohype AI Context

MacStack is developed by Nohype AI, a company focused on AI infrastructure, business agents, and local inference on Apple hardware. MacStack is both a product and a tool the company uses internally to manage AI development environments for research and client consulting. This means it will naturally evolve alongside the real-world needs of professional AI work on Mac.
