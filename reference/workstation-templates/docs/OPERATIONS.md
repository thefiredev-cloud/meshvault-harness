# Operations

## Bootstrap Order

1. Install Docker Desktop and confirm the Docker CLI works from an unrestricted local shell.
2. Enable Docker MCP and create the default MCP profile.
3. Configure Codex with `templates/codex/config.toml`.
4. Configure Claude Code with `templates/claude/settings.json` and `templates/claude/mcp.json`.
5. Configure Claude Desktop with `templates/claude-desktop/claude_desktop_config.json`.
6. Configure Hermes with `templates/hermes/config.yaml` plus a private `.env`.
7. Point Obsidian at the vault structure in `templates/obsidian/`.
8. Run the sanitizer before committing public changes.

## Live Verification Commands

Use these commands to refresh the public-safe machine facts before updating the README or inventory.

```bash
defaults read /Applications/Docker.app/Contents/Info CFBundleShortVersionString
docker --version
docker version --format '{{.Server.Version}}'
docker mcp version
docker mcp client ls --global
docker mcp profile server ls --filter profile=default
docker mcp profile server ls --filter profile=default | tail -n +2 | wc -l
```

Expected public baseline:

- Docker Desktop is installed and the engine responds from the local shell.
- `MCP_DOCKER` is globally connected for Codex, Claude Code, and Claude Desktop.
- The default Docker MCP profile contains the shared server catalog.
- The public `templates/docker-mcp/tools.yaml` starts read-oriented; mutation tools belong in `tools.opt-in.yaml` or a private profile after access review.
- Private direct MCP exceptions, if any, remain outside this template unless they are safe and intentional to publish.

Avoid using `docker mcp tools count` as the first health check on a broad profile. It can be slow or start probing many servers. Prefer the profile list above, then run targeted per-server checks when a specific server is suspect.

## Codex Verification

Codex should use a narrow, job-oriented MCP lane rather than every available server.

```bash
rg -n 'model|model_reasoning_effort|service_tier|MCP_DOCKER|--servers=' "$HOME/.codex/config.toml"
```

Expected posture:

- Model: `gpt-5.5`.
- Reasoning: `xhigh`.
- Service tier: `fast`.
- Shared MCP gateway: `MCP_DOCKER`.
- Selected server lane for repo review, search/context, ASO, HIG, and security work.

## Hermes Verification

Keep Hermes configuration split:

- `config.yaml` for routing, runtime behavior, toolsets, and MCP gateway configuration.
- `.env` for private tokens and provider credentials.

Useful checks:

```bash
test -f "$HOME/.hermes/config.yaml"
test -f "$HOME/.hermes/.env"
rg -n 'provider: openai-codex|openai_runtime|MCP_DOCKER|gateway|--long-lived' "$HOME/.hermes/config.yaml"
```

Expected posture:

- Hermes uses the OpenAI-Codex runtime for the live Telegram/local gateway lane.
- Hermes has an `MCP_DOCKER` server block using `docker mcp gateway run --long-lived`.
- Hermes state files, session stores, logs, and `.env` stay out of this repository.

## Obsidian Memory Verification

The durable memory path should be:

```text
$HOME/.openclaw/workspace/01-memory/
```

New durable notes should go into that vault, not into local client-specific memory folders. Public docs may describe the path and policy; they must not include raw memory notes.

## Sanitization

Run the local scanner before every public commit:

```bash
python3 scripts/sanitize-check.py
python3 -m unittest discover -s tests
python3 scripts/validate-template-syntax.py
git diff --check
npx --yes markdownlint-cli2 "**/*.md"
```

Expected result:

```text
sanitize-check: passed
```

The scanner catches common token prefixes, private key headers, Telegram bot token format, AWS key IDs, JWT-like secrets, database URLs with embedded credentials, npm auth tokens, signed URL signatures, cookie headers, long hex secrets, and non-placeholder secret-like assignments.

## Public Release Checklist

- `python3 scripts/sanitize-check.py` passes.
- `git diff --check` passes.
- No `.env`, `auth.json`, SQLite database, transcript, session, cache, or log file is tracked.
- README states that the repo is a sanitized reference architecture, not a live backup.
- `inventory/sanitized-inventory.md` reflects only public-safe facts from the current machine.
- Docker MCP routing is documented as the shared baseline.
- Hermes is described as a runtime with its own long-lived `MCP_DOCKER` config, not as a generic desktop client.
- Obsidian is documented as durable memory without publishing any actual notes.

## Troubleshooting

| Symptom | Likely cause | Check |
|---|---|---|
| Docker Desktop is open but an agent says Docker is unavailable. | The agent shell may not have access to Docker's Unix socket. | Re-run `docker --version` and `docker mcp client ls --global` from an unrestricted local shell. |
| Docker MCP profile looks healthy but a tool fails. | The server may need a provider credential or targeted startup check. | Inspect `docker mcp profile server ls --filter profile=default`, then test only the specific server. |
| Public docs drift from the real workstation. | Inventory was edited from memory instead of verified state. | Re-run the live verification commands in this file. |
| Durable memory appears in local client folders. | Legacy client memory paths are still being used. | Move durable facts into the Obsidian vault and keep local bridge notes minimal. |
