# Adoption Plan

This plan turns the public template into a private workstation deployment without copying private machine state into Git.

## Workstreams

| Workstream | Owner profile | Deliverables |
|---|---|---|
| Control plane | Platform or developer-experience owner | Docker MCP profile, client registrations, safe root paths, and gateway verification. |
| Runtime ownership | Engineering lead | Written scope for Codex, Claude Code, Claude Desktop, Hermes, and any finance or admin-specific runtime. |
| Memory policy | Operations owner | Obsidian vault path, durable-memory write rules, and local bridge-note policy. |
| Security boundary | Security or platform owner | Secret-store mapping, scanner checks, ignored runtime files, and manual review checklist. |
| Remote command surface | Automation owner | Hermes or equivalent runtime, channel access rules, confirmation gates, and session handling. |

## Phase 1: Assess

Map the current workstation before installing or moving anything.

Acceptance criteria:

- AI clients and local runtimes are listed.
- Current MCP servers and direct credentials are identified.
- Durable memory locations are identified.
- Runtime state, logs, transcripts, and local databases are classified as private.

## Phase 2: Standardize Tooling

Move shared integrations behind Docker MCP first. Keep direct client-specific MCP servers only when they are intentional private exceptions.

Acceptance criteria:

- Docker MCP is installed and responds from an unrestricted shell.
- Codex, Claude Code, and Claude Desktop are registered against the shared gateway baseline.
- Representative public templates use placeholders and safe example paths.
- The private profile can contain additional servers without exposing them in this repo.

## Phase 3: Define Runtime Ownership

Assign each AI surface a clear job so tools and memory do not drift.

Acceptance criteria:

- Codex owns review, repo hygiene, security posture, and public-template work.
- Claude Code owns active implementation and project-local workflows.
- Claude Desktop owns research and artifact-style exploration.
- Hermes owns remote sessions, channel routing, and resumable automation.

## Phase 4: Centralize Memory

Use Obsidian as the durable memory source of truth.

Acceptance criteria:

- Durable notes land under the private Obsidian vault.
- Generic memory MCPs, if enabled, are documented as non-durable bridge surfaces only.
- No raw memory notes are published in the template repository.

## Phase 5: Harden And Verify

Run automated and manual checks before publishing.

Acceptance criteria:

- `python3 scripts/sanitize-check.py` passes.
- `git diff --check` passes.
- Public files use placeholders only.
- `.env`, `auth.json`, SQLite state, transcripts, sessions, logs, and raw memory notes are untracked.
- Dedicated scanners such as gitleaks or TruffleHog are run before public release when available.

## Phase 6: Operate

Treat the repo as an architecture and onboarding surface, not as a live backup.

Recurring checks:

- Re-run Docker MCP client and profile verification before updating inventory claims.
- Re-run sanitizer before commits and pull requests.
- Keep exact live counts and private exceptions in inventory only when they are safe to publish.
- Keep App Review, finance, client, and personal operational data out of Git.
