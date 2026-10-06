# Architecture

```
            you ─ terminal / chat app / editor
                       │
        ┌──────────────┴──────────────┐
        │ Hermes Agent        OMP     │   agents: plan, call tools, keep memory
        └──────────────┬──────────────┘
                       │ OpenAI-compatible HTTP, 127.0.0.1:8484/v1
              llama.cpp llama-server        ← pinned build, one model, one slot
                       │
        ~/.meshvault/models/*.gguf          ← sha256-verified weights
```

Skills live beside the agents (`~/.hermes/skills/meshvault/`, `~/.omp/agent/skills/`). `meshvault skills sync` keeps both in step from one source.

## Principles (from the Home AI Operator guide)

1. **Local first, not zero egress.** The control plane and the default data path run on your machine. Cloud models are an explicit choice.
2. **Reach is not permission.** An agent that can see a service has no right to act on it. Skills carry approval gates; consequential writes need your yes.
3. **Proof, not claims.** `meshvault doctor` checks that the model answers, Hermes points at it and skills are installed, rather than trusting that the install script exited zero.
4. **Small blast radius.** Loopback bind, one user account, files under `$HOME`, no public ports.
5. **Earn traffic.** A local model gets real work only after it passes your own checks. Start with read-only skills (`daily-standup`, `meeting-brief`), then widen.

## Choices and why

| Choice | Reason |
|---|---|
| llama.cpp server, not a Docker stack | One binary, no daemon manager, works on Linux and macOS, Metal and Vulkan available. |
| Qwen3 family | Apache-2.0, solid tool calling at small sizes, GGUF builds from one source. |
| 64K context, q8 KV cache | Hermes needs 64K for agent work; q8 keeps RAM use near half of f16. |
| Official installers for Hermes and OMP | They own their update paths; we configure, not fork. |
| Config through `hermes config set` | Never hand-edit another tool's config file. OMP's `models.yml` is written only if absent. |
| Skills copied, not symlinked | Agents on different roots stay independent; `.meshvault-managed` marks what sync may replace. |

## Going further

[`reference/workstation-templates/`](../reference/workstation-templates) holds sanitized templates for a heavier multi-agent setup (Codex, Claude Code, Docker MCP gateway, Obsidian memory). It is a reference, not part of the one-command install.
