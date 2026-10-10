# Install

## Requirements

| | Minimum | Recommended |
|---|---|---|
| OS | Ubuntu 22.04+/Debian 12+, Fedora, Arch, macOS 13+ | Apple Silicon Mac, or Linux with 16 GB RAM |
| RAM | 8 GB (1.7B model) | 16 GB (4B, the default), 32 GB+ for the 8B/30B |
| Disk | Model file + about 3 GB (about 4 GB for the 1.7B model, about 20 GB for the 30B) | 30 GB free |
| Tools | `curl`, `git`, `tar` | |
| Linux libs | `libatomic1`, `libgomp1` (the installer installs them with `sudo` if needed) | |

## One command

```bash
curl -fsSL https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh | bash
```

The script clones this repo to `~/.meshvault/harness` (newest `v*` release tag) and runs `lib/setup.sh`. Review before you run: [install.sh](../install.sh), [lib/setup.sh](../lib/setup.sh).

## What it does, in order

1. Checks OS, CPU, RAM, disk and required tools. Installs `libatomic1`/`libgomp1` through your package manager only if they are missing and you can grant `sudo`.
2. Downloads a pinned llama.cpp server build (sha256-checked) to `~/.meshvault/runtime/`.
3. Picks a model by your RAM and downloads it (resumable, sha256-checked) to `~/.meshvault/models/`.
4. Writes `~/.meshvault/config.env` and links `~/.local/bin/meshvault`.
5. Starts the model server on `127.0.0.1:8484`.
6. Installs Hermes Agent by piping `https://hermes-agent.nousresearch.com/install.sh` to bash (skips browser and computer-use add-ons) and points it at the local model. The script is not pinned or checksummed.
7. Installs OMP by piping `https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.sh` to sh (`--binary`) and adds a `meshvault-local` provider. The script is not pinned or checksummed.
8. Copies the free skills into `~/.hermes/skills/meshvault/` and `~/.omp/agent/skills/`.
9. Runs `meshvault doctor`.

Nothing is written outside `$HOME`, except system libraries from step 1.

## Options

| Option | Meaning |
|---|---|
| `--model ID` | `qwen3-1.7b`, `qwen3-4b-2507`, `qwen3-8b`, `qwen3-30b-a3b-2507` (see `catalog/models.tsv`) |
| `--gpu vulkan` | Linux Vulkan build of llama.cpp (NVIDIA/AMD/Intel). Needs `libvulkan1` and a driver. Default is CPU. macOS always uses Metal. |
| `--llama-server PATH` | Use your own llama.cpp build (for CUDA, ROCm, or a Homebrew install) |
| `--endpoint URL --endpoint-model NAME` | Use an OpenAI-compatible server you already run (Ollama, LM Studio, vLLM). Skips the model download. |
| `--autostart` | Start the model at login (systemd user unit or launchd) |
| `--ctx N`, `--port N` | Context window (default 65536; Hermes needs 64000+) and port |
| `--pro FILE` | Install your Pro skills pack in the same step |
| `--no-hermes`, `--no-omp`, `--no-start`, `--no-verify`, `--dry-run`, `--yes`, `--force` | As named |

Pass options through the pipe: `curl ... | bash -s -- --model qwen3-8b`.

## Day to day

```bash
meshvault status | start | stop | restart | logs
meshvault ask "question"        # straight to the local model
meshvault doctor
meshvault model list            # what fits this machine
meshvault model use qwen3-8b
meshvault skills sync | list
meshvault pro install ~/Downloads/meshvault-harness-pro-1.0.0.tar.gz
meshvault autostart on|off
meshvault update
meshvault uninstall
```

## Uninstall

`meshvault uninstall` removes the model server, downloaded models and managed skills. Hermes: `hermes uninstall`. OMP: delete `~/.local/bin/omp` and `~/.omp`. Skills you wrote yourself are never touched.

## Updating

`meshvault update` pulls this repo and re-syncs skills. Hermes and OMP update themselves (`hermes update`, `omp update`). Model and llama.cpp pins change only when this repo does, after testing.
