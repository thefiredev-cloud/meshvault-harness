# Codex Desktop Template

Codex Desktop should use the same operating posture as Codex CLI:

- Fast review and security lane.
- Docker MCP as the shared tool gateway.
- Obsidian as durable memory.
- No secrets in exported settings or public templates.

If the desktop client exposes a config file, mirror the MCP and shell policy from `templates/codex/config.toml` and inject credentials from the local environment.

