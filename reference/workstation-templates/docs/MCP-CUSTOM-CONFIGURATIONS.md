# MCP Custom Configurations

This document is the public-safe map of the workstation's MCP configuration surfaces. It documents names, routing, placeholder variables, and tool-lane policy. It does not publish credential values, private local paths, provider account state, or runtime logs.

## Source Of Truth

| Surface | Private source | Public template |
|---|---|---|
| Docker MCP profile names | `docker mcp profile server ls --filter profile=default` | [MCP Library](../inventory/mcp-library.md) |
| Docker MCP client registrations | `docker mcp client ls --global` | This document |
| Docker MCP representative profile | Private Docker MCP profile | [profile.default.yaml](../templates/docker-mcp/profile.default.yaml) |
| Docker MCP server configuration | Private Docker MCP config | [config.yaml](../templates/docker-mcp/config.yaml) |
| Read-oriented tool lane | Private allowlist policy | [tools.yaml](../templates/docker-mcp/tools.yaml) |
| Mutation opt-in lane | Private allowlist policy | [tools.opt-in.yaml](../templates/docker-mcp/tools.opt-in.yaml) |
| Codex MCP lane | `$HOME/.codex/config.toml` | [templates/codex/config.toml](../templates/codex/config.toml) |
| Hermes MCP lane | `$HOME/.hermes/config.yaml` | [templates/hermes/config.yaml](../templates/hermes/config.yaml) |

## Client Registrations

| Client | Public posture |
|---|---|
| Codex | Connected to `MCP_DOCKER`; uses a curated server lane. |
| Claude Code | Connected to `MCP_DOCKER`; project-local hooks and agents remain separate. |
| Claude Desktop | Connected to `MCP_DOCKER`; private direct exceptions are excluded from the public baseline. |
| Hermes | Uses its own long-lived `MCP_DOCKER` runtime block. |
| Cursor, Gemini, VS Code | May be installed but are not part of the public connected baseline. |

## Curated Codex Server Lane

```text
obsidian
github-official
brave
context7
appstore-intel
hig-doctor
recon
wolfram-mcp
```

## Representative Docker MCP Profile

The public profile is intentionally representative. It should show how the private profile is structured without claiming to be the complete private profile.

Published profile names:

```text
github
filesystem
desktop-commander
memory
obsidian
netlify
supabase
resend
playwright
sentry
```

Policy:

- Shared tools route through Docker MCP first.
- `memory` is disabled in the public profile and may only be used as a non-durable bridge.
- Durable cross-session memory belongs in Obsidian.
- Filesystem examples use `${WORKSTATION_SAFE_ROOT}`, not the whole home directory.
- Private deployments may add more servers after access review.

## Tool Lane Policy

The public baseline separates read-oriented tools from mutation-capable tools.

### Read-Oriented Baseline

Defined in [tools.yaml](../templates/docker-mcp/tools.yaml).

```text
github: get_file_contents, search_repositories
filesystem: read_file, list_directory, search_files
obsidian: list_files_in_vault, get_file_contents, simple_search
netlify: list_projects, read_environment
supabase: list_projects, generate_typescript_types
playwright: navigate, screenshot
sentry: get_sentry_issue
```

### Mutation Opt-In

Defined in [tools.opt-in.yaml](../templates/docker-mcp/tools.opt-in.yaml).

```text
github: create_branch, create_pull_request, issue_write, push_files
filesystem: write_file
obsidian: append_content
netlify: deploy, update_environment
supabase: execute_sql, apply_migration
playwright: click, fill, evaluate
resend: send_email
```

Mutation tools require a private access review, rollback expectation, and confirmation policy before use.

## Placeholder Variables

These names are safe to publish because they describe configuration shape only.

```text
ANTHROPIC_API_KEY
FIRECRAWL_API_KEY
GITHUB_PERSONAL_ACCESS_TOKEN
MCP_GATEWAY_COMMAND
NETLIFY_AUTH_TOKEN
OBSIDIAN_VAULT_PATH
OPENAI_API_KEY
PINECONE_ASSISTANT_HOST
RESEND_API_KEY
SENTRY_AUTH_TOKEN
SIGNAL_CLI_PATH
SUPABASE_ACCESS_TOKEN
TELEGRAM_ALLOWED_CHAT_IDS
TELEGRAM_BOT_TOKEN
WORKSTATION_SAFE_ROOT
```

## Refresh Checklist

Before updating this document:

1. Re-run `docker mcp profile server ls --filter profile=default`.
2. Re-run `docker mcp client ls --global`.
3. Update [MCP Library](../inventory/mcp-library.md) with names only.
4. Keep credentials, private paths, state files, logs, and raw memory out of Git.
5. Run the full verification suite from [Operations](OPERATIONS.md).
