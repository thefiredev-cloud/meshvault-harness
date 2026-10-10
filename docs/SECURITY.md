# Security

## What the harness does

* The model server listens on `127.0.0.1` only. It has no API key because nothing outside the machine can reach it.
* The installer reads and writes no credentials, and the repo contains none (CI runs a secret scan on every push).
* Downloads are pinned and sha256-verified: llama.cpp builds and model files (`catalog/`). The Hermes and OMP install scripts are not pinned or checksummed: the installer fetches them over HTTPS from `hermes-agent.nousresearch.com` and `raw.githubusercontent.com/can1357/oh-my-pi/main` and pipes them to the shell. Skip them with `--no-hermes` and `--no-omp`.
* Skills are Markdown. Each one that can act on the real world carries an Approval Gate: it drafts, shows you, and waits for your yes before it sends, pays, posts or deletes.
* Everything installs under your home folder. System libraries are the only exception, and only with your `sudo`.

## What it does not do

* It does not sandbox the agents. Hermes and OMP can run shell commands and edit files as you. Their own approval modes are your guard rails; read them (`hermes` docs: Security). Run the harness on a machine or account you are comfortable letting an agent work in.
* It does not make a model correct. Local models are weaker than frontier models and can be confidently wrong. Review anything with consequences.
* It does not secure third-party services you connect (email, Telegram, cloud model keys). Keep those keys in `~/.hermes/.env`, never in a skill or a prompt.
* Prompt injection is real: text in a web page, email or file can try to instruct the agent. Keep approval gates on, and never remove the gate from a skill that can send, pay, post or delete.

## Network posture

Nothing listens on your LAN by default. If you later enable a Hermes messaging gateway, the agent talks outward to that service. To reach your machine from your phone, use an authenticated private overlay (for example a VPN or Tailscale) rather than opening a port to the internet.

## Reporting a problem

Email contact@meshvault.ai with "security" in the subject. Do not post exploit details in a public issue first.
