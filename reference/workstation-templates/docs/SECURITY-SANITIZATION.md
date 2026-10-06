# Security Sanitization

## Sanitization Strategy

This repository was created as a clean-room public template. It does not copy hidden runtime files directly. Instead, it preserves the architecture and configuration shape with safe placeholders.

## Excluded Local Surfaces

The following local surfaces are intentionally excluded:

- Codex auth files, logs, SQLite state, histories, sessions, shell snapshots, and memory caches.
- Claude Code settings that contain literal environment secrets.
- Claude Code session logs, debug logs, history, policy caches, and file-history state.
- Hermes `.env`, auth files, gateway state, sessions, logs, databases, caches, and generated reports.
- Docker MCP databases, long-lived logs, credential caches, and profile backups.
- Obsidian memory notes and private vault content.

## Placeholder Rules

Allowed placeholder patterns:

- Empty values.
- `${ENV_VAR_NAME}` references.
- `REPLACE_ME`.
- `SET_IN_ENV`.
- `<value-from-secret-manager>`.
- Example domains such as `operator@example.com`.

Disallowed patterns:

- Provider API keys.
- Personal access tokens.
- Bot tokens.
- Private keys.
- OAuth refresh tokens.
- Cookies.
- Signed URLs.
- Database URLs with embedded credentials.
- npm auth tokens.
- Sentry or similar DSNs with embedded project credentials.
- Long random secret-like strings.

## Scanner

Run:

```bash
python3 scripts/sanitize-check.py
```

The scanner checks for common token prefixes, private key headers, Telegram bot token format, AWS access key IDs, database URLs with embedded credentials, npm auth tokens, signed URL signatures, cookie headers, long hex secrets, JWT-like secrets, and non-placeholder secret assignments.

## Manual Review Still Required

Automated scanning cannot prove a public repository is safe. Before publishing, manually inspect files that mention:

- `token`
- `secret`
- `password`
- `api_key`
- `private_key`
- `auth`
- `webhook`
