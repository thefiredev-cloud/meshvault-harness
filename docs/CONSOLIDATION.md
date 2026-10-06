# What moved where

On 2026-10-05 six MeshVault repos and one guide were folded into this one. The old repos stay (nothing was deleted); their READMEs point here.

| Source | What it was | Now |
|---|---|---|
| `meshvault-skills-starter` (MIT, public) | 9 free skills | [`skills/`](../skills), plus [`examples/`](../examples). The old repo is a pointer. |
| `meshvault-agent-skills-starter-pack` (private, paid $49) | 5 operator skills, memory templates, runbooks, routing recipes | Source of the **Pro pack** (private repo `meshvault-harness-pro`). Still sold as a standalone pack at meshvault.ai/skills. |
| `agentic-workstation-stack-tanner` (MIT) | Sanitized templates for Codex, Claude Code, Hermes, Docker MCP, Obsidian memory, plus a secret scanner | [`reference/workstation-templates/`](../reference/workstation-templates). Advanced, optional. The fleet-specific monitor script was left behind. |
| `local-llm-desktop-stack` (private) | Docker Compose: Node chat UI, SearXNG, Ollama | Replaced by the native llama.cpp server in the installer (no Docker needed). Use `--endpoint` to keep using Ollama. The old repo remains for its web chat UI. |
| `agent-config-parity` (private) | Copy Claude/Codex/Hermes config between machines; DGX-only installer | The portable idea became `meshvault skills sync` (one skills source, every agent root). The DGX/fleet scripts stay in the old repo. |
| `meshvault-kit` (private, proprietary) | Python node, macOS and iOS apps, browser clipper for phone pairing | Separate product line (phone companion). This repo is the install story; the kit repo keeps its code. |
| `home-ai-operator-v5-final.pdf` | Architecture and operating model | Distilled into [ARCHITECTURE.md](ARCHITECTURE.md) and [SECURITY.md](SECURITY.md): loopback-only services, gated writes, evidence before claims. |
