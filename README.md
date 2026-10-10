# MeshVault Harness

[![CI](https://github.com/thefiredev-cloud/meshvault-harness/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/thefiredev-cloud/meshvault-harness/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/thefiredev-cloud/meshvault-harness)](https://github.com/thefiredev-cloud/meshvault-harness/releases/latest)
[![MIT license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

MeshVault Harness installs Hermes Agent, OMP and a local Qwen3 model on your computer with one command. It is for people who want an AI agent that runs on hardware they own, with no account and no API key. It also installs 11 Markdown skills that tell the agent to ask before it sends, pays, posts or deletes.

Status: version 1.0.1. On every push, CI installs the pinned llama.cpp build and the 1.7B model on Ubuntu 24.04 x64 and checks that the model answers. CI skips Hermes and OMP. macOS, Fedora, Arch and WSL2 have no CI coverage.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh | bash
```

This pipes a script from GitHub into bash. [`install.sh`](install.sh) is short: it clones this repo and hands off to [`lib/setup.sh`](lib/setup.sh), which does the work. Read both first, or clone the repo and run `./install.sh` from the checkout.

Linux (Ubuntu/Debian, Fedora, Arch) and macOS (Apple Silicon and Intel). Windows through WSL2. You need `curl`, `git` and `tar`. No account, no API key. On Linux the installer uses `sudo` only if `libatomic` or `libgomp` is missing.

**Free:** the MIT installer, `meshvault` CLI and 11 skills. **Paid:** the Pro skills pack is $99 once; a done-for-you install is $499 once. [Compare the tiers and buy](https://thefiredev.com/harness).

![Terminal demo: meshvault doctor checks the install, then meshvault ask gets a local-model answer](docs/assets/demo.gif)

Recorded from a real run on Linux in a fresh home folder. The demo shows the installed CLI; idle time is shortened. [Setup options](docs/INSTALL.md) · [Privacy and approval limits](docs/SECURITY.md)

## What it downloads

Pinned and sha256-checked:

* This repo, cloned from `github.com/thefiredev-cloud/meshvault-harness` into `~/.meshvault/harness` at the newest `v*` tag (or `main` if there is none).
* llama.cpp server build `b11430` from the `ggml-org/llama.cpp` GitHub releases ([`catalog/runtime.tsv`](catalog/runtime.tsv)).
* One Qwen3 GGUF file from the `unsloth` repos on Hugging Face ([`catalog/models.tsv`](catalog/models.tsv)).

Not pinned and not checksummed. The installer pipes these third-party scripts straight to the shell:

* Hermes Agent: `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive --skip-browser --skip-computer-use`. That script clones `NousResearch/hermes-agent` and fetches its own dependencies.
* OMP: `curl -fsSL https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.sh | sh -s -- --binary`. That script downloads the latest OMP release binary from GitHub.

Skip either one with `--no-hermes` or `--no-omp`. If `hermes` or `omp` is already on your PATH, the installer reuses it and downloads nothing.

On Linux, a missing `libatomic` or `libgomp` comes from your package manager (`apt-get`, `dnf` or `pacman`).

## What you get

| Piece | What it is | Where it comes from |
|---|---|---|
| **Local model** | Qwen3 (Apache-2.0), chosen by your RAM (table below). Served by llama.cpp on `127.0.0.1` only, port 8484 by default. | pinned llama.cpp build, sha256-verified downloads |
| **Hermes Agent** | Chat agent with memory, skills, scheduling, and messaging gateways (Telegram, Discord, Slack and more). Set to use the local model. | Nous Research install script |
| **OMP** | Coding agent for your terminal. Gets a `meshvault-local` provider. | oh-my-pi install script |
| **11 free skills** | Invoice chasing, client follow-ups, inbox triage, daily standup, meeting briefs, quotes, receipts, weekly pulse, local-model prompting, on-device setup and a harness doctor. Plain Markdown. Each skill that can send, pay, post or delete tells the agent to stop and ask first. | [`skills/`](skills) (MIT) |
| **`meshvault` command** | Start/stop the model, switch models, doctor, update, sync skills, install Pro. | [`bin/meshvault`](bin/meshvault) |

The installer picks the largest model that fits your usable RAM. Override it with `--model ID`.

| Model ID | Usable RAM needed | Download size |
|---|---|---|
| `qwen3-1.7b` | 8 GB | 1.1 GB |
| `qwen3-4b-2507` | 12 GB | 2.5 GB |
| `qwen3-8b` | 20 GB | 5.0 GB |
| `qwen3-30b-a3b-2507` | 40 GB | 18.6 GB |

The RAM figures include the KV cache for the 64K context Hermes needs. Free disk must cover the model plus about 3 GB.

## First five minutes

```bash
meshvault doctor                       # checks model, Hermes, OMP, skills
meshvault ask "What can you do on this machine?"
hermes                                 # chat. Try: "give me a daily standup from the notes in ~/notes"
```

## Be honest about speed

Local models are private and free to run. They are not frontier models.

* **Apple Silicon, or an x64 Linux GPU through `--gpu vulkan`:** responses start in seconds. The default Linux build is CPU only.
* **CPU only:** the first Hermes message can take several minutes, because Hermes sends a long system prompt and a CPU has to read it once. Later messages reuse the cache and are much faster. On CPU, `meshvault ask` and OMP feel better than Hermes.
* **8 GB RAM** runs only the 1.7B model. **16 GB** is the sensible minimum. Hard tasks want the 8B or 30B.
* You can point the harness at a stronger model whenever you like: a bigger local one, a LAN box, or a cloud API with your own key (`hermes model`).

## Options

```bash
# pick a model, autostart the model at login
curl -fsSL https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh | bash -s -- --model qwen3-8b --autostart

# you already run Ollama (or any OpenAI-compatible server)
curl -fsSL https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh | bash -s -- --endpoint http://127.0.0.1:11434/v1 --endpoint-model qwen3:8b
```

`--gpu vulkan`, `--llama-server PATH`, `--ctx`, `--port`, `--no-hermes`, `--no-omp`, `--dry-run` and more: `install.sh --help`. `--dry-run` prints every download and install step; it creates an empty `~/.meshvault` folder and changes nothing else. Details in [docs/INSTALL.md](docs/INSTALL.md). Trouble: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

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

* **Pro skills pack, $99:** [buy the Pro pack with Stripe](https://buy.stripe.com/9B6aEX5mtgrCd4yaYz9ws0l). The download link and your license key arrive by email within minutes of payment, then `meshvault pro install FILE`. Questions first: [contact@meshvault.ai](mailto:contact@meshvault.ai?subject=Harness%20Pro). See [docs/TIERS.md](docs/TIERS.md).
* **Done-for-you install, $499:** [pay for the install with Stripe](https://buy.stripe.com/28E3cv5mt8Za1lQ7Mn9ws0m), or ask a question first on [thefiredev.com/harness](https://thefiredev.com/harness). A confirmation email arrives at once, you reply with times, and we schedule it. Scope and what is not included: [docs/DONE-FOR-YOU.md](docs/DONE-FOR-YOU.md).
* Paid tiers add skills and an assisted install. Nothing in the free install is locked.

## How it stays private and safe

* The bundled model server binds to `127.0.0.1`. It is never exposed to your network.
* The harness installs no telemetry and stores no secrets. Hermes and OMP are third-party tools with their own behavior; read their docs before enabling cloud providers or messaging gateways.
* Skills are plain Markdown you can read. Each one that can send, pay, post or delete carries an Approval Gate section that tells the agent to draft, show you, and wait for your yes.
* Local models can still be wrong. Review anything that matters. Full notes: [docs/SECURITY.md](docs/SECURITY.md).

## What it does not do

* It does not sandbox the agents. Hermes and OMP can run shell commands and edit files as your user.
* An Approval Gate is an instruction to the model, not an enforced permission. Keep the agent's own approval settings on.
* It ships no pinned CUDA or ROCm build. Use `--gpu vulkan` or bring your own llama.cpp with `--llama-server PATH`.
* It does not run natively on Windows. Use WSL2.
* The Pro pack is not in this repo. `meshvault pro install` checks that the archive holds `PRO-LICENSE.md` and a `skills/` folder; it does not check a license key.

## What is in this repo

```
install.sh            one-command installer (fetches the repo, runs lib/setup.sh)
lib/                  setup + shared shell helpers
bin/meshvault         day-to-day CLI
catalog/              pinned llama.cpp builds and model files with sha256
skills/               free skills (MIT)
templates/            OMP provider template
examples/             fictional sample outputs for three skills
reference/            sanitized multi-agent workstation templates (advanced)
docs/                 install, tiers, security, architecture, consolidation notes
tests/                shell tests and the clean-container proof
tools/                maintainer script that creates the Stripe payment links
```

Run the static checks with `bash tests/run.sh` (syntax, shellcheck if installed, catalog format, skill format). `tests/container-proof.sh` runs the full install in a fresh `ubuntu:24.04` Docker container and needs Docker.

This repo replaces six earlier MeshVault repos. [What moved where](docs/CONSOLIDATION.md). To contribute, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT for everything in this repo. The Pro pack has its own license. Hermes, OMP and llama.cpp are MIT; Qwen3 weights are Apache-2.0. MeshVault is a product of FireDev LLC. Support: [contact@meshvault.ai](mailto:contact@meshvault.ai).
