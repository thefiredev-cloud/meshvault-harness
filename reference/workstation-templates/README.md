# Workstation templates (advanced reference)

Sanitized templates for a heavier multi-agent workstation: Codex, Claude Code, Claude Desktop, Hermes, a Docker MCP gateway, and an Obsidian vault as shared memory. Moved here from `agentic-workstation-stack-tanner` (MIT). Not part of the one-command install. Copy what you need by hand.

```bash
python3 scripts/sanitize-check.py            # fails if a live-looking credential is committed
python3 scripts/validate-template-syntax.py
python3 -m unittest discover -s tests
```

Start with `docs/ARCHITECTURE.md` and `docs/OPERATIONS.md`. The "reference deployment" wording in those docs describes the author's own Mac workstation; adapt paths and tool choices to yours.
