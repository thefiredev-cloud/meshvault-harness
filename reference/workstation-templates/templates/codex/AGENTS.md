# Codex Operating Scope

Codex owns work that benefits from fast review, strong diff analysis, public documentation, security posture, and GitHub publishing.

## Owns

- Pull request review and diff analysis.
- Security, SBOM, and public-repo hygiene.
- App metadata and public documentation audits.
- Sanitized template maintenance.
- GitHub repository operations.

## Defers

- Large active product implementation goes to Claude Code.
- Artifact-style research and visual drafting goes to Claude Desktop.
- Voice, Telegram, and multi-channel runtime work goes to Hermes.
- Finance and trading workflows go to the finance-specific runtime.

## Memory Policy

Durable memory belongs in the shared Obsidian vault, not in local client-specific memory stores.

```text
$HOME/.openclaw/workspace/01-memory/
```

Never store secrets in memory. Store only references such as environment variable names or secret-manager item names.

