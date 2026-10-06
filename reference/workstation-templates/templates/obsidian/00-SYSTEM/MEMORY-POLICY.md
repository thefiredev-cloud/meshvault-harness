---
tags:
  - system/policy
  - memory
---

# Memory Policy

All durable memory writes go to the shared Obsidian vault.

```text
$HOME/.openclaw/workspace/01-memory/
```

## Rules

- Do not write durable memories to isolated local client stores.
- Do not write secrets, API keys, passwords, tokens, recovery codes, cookies, or reviewer credentials to memory.
- Reference secrets by environment variable name or secret-manager item name.
- Keep memory notes short, factual, and reusable by multiple agents.

## Client Responsibilities

| Client | Memory behavior |
|---|---|
| Codex | Save durable cross-session facts to Obsidian. |
| Claude Code | Save project decisions and handoffs to Obsidian. |
| Hermes | Save gateway and runtime lessons to Obsidian. |
| Claude Desktop | Use Obsidian for durable research handoff when needed. |

