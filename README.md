# MeshVault Harness

**A private AI agent on your own computer. One command to install.**

Hermes (agent), OMP (coding agent), a local language model, and a set of approval-gated skills, wired together and running on hardware you own. Nothing you type leaves the machine unless you point the agent at a cloud model yourself.

```bash
curl -fsSL https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh | bash
```

Linux (Ubuntu/Debian, Fedora, Arch) and macOS (Apple Silicon and Intel). Windows through WSL2. No account, no API key, no sudo unless a system library is missing. [Read the installer first](install.sh); it is short.

## What you get

| Piece | What it is | Where it comes from |
|---|---|---|
| **Local model** | Qwen3 (Apache-2.0), chosen by your RAM: 1.7B, 4B, 8B or 30B-A3B. Served by llama.cpp on `127.0.0.1` only. | pinned llama.cpp build, sha256-verified downloads |
| **Hermes Agent** | Chat agent with memory, skills, scheduling, and messaging gateways (Telegram, Discord, Slack and more). | official Nous Research installer |
| **OMP** | Coding agent for your terminal and editor. | official installer |
| **11 free skills** | Invoice chasing, inbox triage, daily standup, meeting briefs, quotes, receipts, and a harness doctor. Plain Markdown. Every skill that can send, pay, post or delete stops and asks first. | [`skills/`](skills) (MIT) |
| **`meshvault` command** | Start/stop the model, switch models, doctor, update, sync skills, install Pro. | [`bin/meshvault`](bin/meshvault) |

## First five minutes

```bash
meshvault doctor                       # checks model, Hermes, OMP, skills
meshvault ask "What can you do on this machine?"
hermes                                 # chat. Try: "give me a daily standup from the notes in ~/notes"
```

## Be honest about speed

Local models are private and free to run. They are not frontier models.

* **Apple Silicon or a GPU:** responses start in seconds.
* **CPU only:** the first Hermes message can take several minutes, because Hermes sends a long system prompt and a CPU has to read it once. Later messages reuse the cache and are much faster. On CPU, `meshvault ask` and OMP feel better than Hermes.
* **8 GB RAM** runs the 1.7B model. **16 GB** is the sensible minimum for the default 4B. Hard tasks want the 8B or 30B.
* You can point the harness at a stronger model whenever you like: a bigger local one, a LAN box, or a cloud API with your own key (`hermes model`).

## Options

```bash
# pick a model, autostart the model at login
curl -fsSL .../install.sh | bash -s -- --model qwen3-8b --autostart

# you already run Ollama (or any OpenAI-compatible server)
curl -fsSL .../install.sh | bash -s -- --endpoint http://127.0.0.1:11434/v1 --endpoint-model qwen3:8b
```

`--gpu vulkan`, `--llama-server PATH`, `--ctx`, `--port`, `--no-hermes`, `--no-omp`, `--dry-run` and more: `install.sh --help`. Details in [docs/INSTALL.md](docs/INSTALL.md). Trouble: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Tiers

| | **Free core** | **Pro skills pack** | **Done-for-you install** |
|---|---|---|---|
| Price | $0, MIT | $99 once | $499 once |
| Installer, `meshvault` CLI, model catalog | yes | yes | yes |
| 11 free skills | yes | yes | yes |
| Pro skills: 5 operator skills, 5 memory templates, 4 runbooks, 3 routing recipes, 4 worked examples, plus 4 harness skills | | yes | yes |
| Pro updates | | 12 months of updated packs by email | 12 months |
| We install it on your machine over a screen-share, tune the model, set up your first workflow | | | yes, one machine |
| 30 days of email support | community (GitHub issues) | email | yes |

* **Pro skills pack:** email [contact@meshvault.ai](mailto:contact@meshvault.ai?subject=Harness%20Pro) to order. You get an invoice and a download within two business days, then `meshvault pro install FILE`. See [docs/TIERS.md](docs/TIERS.md).
* **Done-for-you install:** book at [thefiredev.com/harness](https://thefiredev.com/harness). Scope and what is not included: [docs/DONE-FOR-YOU.md](docs/DONE-FOR-YOU.md).
* The free core is the product. Paid tiers save you time and add skills; they do not lock features out of the free install.

## How it stays private and safe

* The model server binds to `127.0.0.1`. It is never exposed to your network.
* The harness installs no telemetry and stores no secrets. Hermes and OMP are third-party tools with their own behavior; read their docs before enabling cloud providers or messaging gateways.
* Skills are plain Markdown you can read. Sending, paying, posting and deleting always require your yes.
* Local models can still be wrong. Review anything that matters. Full notes: [docs/SECURITY.md](docs/SECURITY.md).

## What is in this repo

```
install.sh            one-command installer (fetches the repo, runs lib/setup.sh)
lib/                  setup + shared shell helpers
bin/meshvault         day-to-day CLI
catalog/              pinned llama.cpp builds and model files with sha256
skills/               free skills (MIT)
templates/            Hermes / OMP config templates
reference/            sanitized multi-agent workstation templates (advanced)
docs/                 install, tiers, security, architecture, consolidation notes
tests/                shell tests and the clean-container proof
```

This repo replaces and consolidates: `meshvault-skills-starter`, `meshvault-agent-skills-starter-pack` (Pro source), `agentic-workstation-stack-tanner`, `local-llm-desktop-stack`, `agent-config-parity`, and the install story of `meshvault-kit`. [What moved where](docs/CONSOLIDATION.md).

## License

MIT for everything in this repo. The Pro pack has its own license. Hermes, OMP and llama.cpp are MIT; Qwen3 weights are Apache-2.0. MeshVault is a product of FireDev LLC. Support: [contact@meshvault.ai](mailto:contact@meshvault.ai).
