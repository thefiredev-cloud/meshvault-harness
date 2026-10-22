# Graph Report - meshvault-harness  (2026-10-21)

## Corpus Check
- 54 files · ~21,254 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 10 file(s) not represented in the graph (top: (none) 6, .tsv 2, .toml 1)

## Summary
- 328 nodes · 392 edges · 40 communities (31 shown, 9 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Install
- common.sh
- Operations
- validate-template-syntax.py
- SanitizeCheckTests
- Sample output — Inbox Triage (fictional)
- MeshVault Harness
- Architecture
- Product copy (for thefiredev.com and meshvault.ai)
- sanitize-check.py
- Adoption Plan
- test-common.sh
- Security Sanitization
- Tiers
- Agents on Device
- Client Follow-Up
- Daily Standup
- Harness Doctor
- Inbox Triage
- Invoice Chaser
- Local Model Prompting
- Meeting Brief
- Quote Builder
- Receipt Organizer
- Weekly Pulse
- create-payment-links.sh
- Changelog
- Claude Code Operating Scope
- Codex Operating Scope
- MCP_DOCKER
- MCP_DOCKER
- Memory Policy
- run.sh
- install.sh
- workstation-templates/README.md
- claude-desktop/README.md
- codex-desktop/README.md
- 01-memory/README.md
- container-proof.sh

## God Nodes (most connected - your core abstractions)
1. `setup.sh script` - 17 edges
2. `SanitizeCheckTests` - 12 edges
3. `MeshVault Harness` - 12 edges
4. `Architecture` - 9 edges
5. `Operations` - 9 edges
6. `Install` - 8 edges
7. `Product copy (for thefiredev.com and meshvault.ai)` - 8 edges
8. `Adoption Plan` - 8 edges
9. `MCP Custom Configurations` - 8 edges
10. `sysdeps_linux()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `setup.sh script` --calls--> `step()`  [EXTRACTED]
  lib/setup.sh → lib/common.sh
- `setup.sh script` --calls--> `detect_os()`  [EXTRACTED]
  lib/setup.sh → lib/common.sh
- `setup.sh script` --calls--> `detect_arch()`  [EXTRACTED]
  lib/setup.sh → lib/common.sh
- `setup.sh script` --calls--> `ram_gb()`  [EXTRACTED]
  lib/setup.sh → lib/common.sh
- `setup.sh script` --calls--> `free_gb()`  [EXTRACTED]
  lib/setup.sh → lib/common.sh

## Import Cycles
- None detected.

## Communities (40 total, 9 thin omitted)

### Community 0 - "Install"
Cohesion: 0.06
Nodes (25): Contributing, Architecture, Choices and why, Going further, Principles (from the Home AI Operator guide), What moved where, Done-for-you install, Not included (+17 more)

### Community 1 - "common.sh"
Cohesion: 0.16
Nodes (20): detect_arch(), detect_os(), die(), download(), free_gb(), have(), ok(), ram_gb() (+12 more)

### Community 3 - "Operations"
Cohesion: 0.10
Nodes (19): Client Registrations, Curated Codex Server Lane, MCP Custom Configurations, Mutation Opt-In, Placeholder Variables, Read-Oriented Baseline, Refresh Checklist, Representative Docker MCP Profile (+11 more)

### Community 4 - "validate-template-syntax.py"
Cohesion: 0.21
Nodes (5): files_with_suffix(), main(), validate_json(), validate_toml(), validate_yaml()

### Community 6 - "Sample output — Inbox Triage (fictional)"
Cohesion: 0.15
Nodes (9): Sample output — Daily Standup (fictional), Act (3), Archive bucket, Reply drafts (2) — approve to send, Sample output — Inbox Triage (fictional), Draft — Northline Studio (approve to send), Sample output — Invoice Chaser (fictional), Summary (+1 more)

### Community 7 - "MeshVault Harness"
Cohesion: 0.17
Nodes (12): Be honest about speed, First five minutes, How it stays private and safe, Install, License, MeshVault Harness, Options, Tiers (+4 more)

### Community 8 - "Architecture"
Cohesion: 0.20
Nodes (9): Architecture, Control Plane, Design Decisions, Design Intent, MCP Access Model, Memory Model, Reference Deployment, Runtime Ownership (+1 more)

### Community 9 - "Product copy (for thefiredev.com and meshvault.ai)"
Cohesion: 0.22
Nodes (8): Done-for-you install: what is included, FAQ, Headline, Install block (copy exactly), Product copy (for thefiredev.com and meshvault.ai), Subhead, Three facts, Tiers

### Community 10 - "sanitize-check.py"
Cohesion: 0.36
Nodes (4): is_placeholder(), is_text_file(), iter_files(), main()

### Community 11 - "Adoption Plan"
Cohesion: 0.22
Nodes (8): Adoption Plan, Phase 1: Assess, Phase 2: Standardize Tooling, Phase 3: Define Runtime Ownership, Phase 4: Centralize Memory, Phase 5: Harden And Verify, Phase 6: Operate, Workstreams

### Community 12 - "test-common.sh"
Cohesion: 0.43
Nodes (5): eq(), falsy(), MESHVAULT_HOME, test-common.sh script, truthy()

### Community 13 - "Security Sanitization"
Cohesion: 0.29
Nodes (6): Excluded Local Surfaces, Manual Review Still Required, Placeholder Rules, Sanitization Strategy, Scanner, Security Sanitization

### Community 14 - "Tiers"
Cohesion: 0.33
Nodes (6): Done-for-you install ($499 once, one machine), Free core ($0, MIT), How to get it after you pay, Pro skills pack ($99 once, 12 months of updates), Tiers, What is never paywalled

### Community 15 - "Agents on Device"
Cohesion: 0.33
Nodes (5): Agents on Device, Approval Gate, Output, Required Inputs, Steps

### Community 16 - "Client Follow-Up"
Cohesion: 0.33
Nodes (5): Approval Gate, Client Follow-Up, Output, Required Inputs, Steps

### Community 17 - "Daily Standup"
Cohesion: 0.33
Nodes (5): Approval Gate, Daily Standup, Output, Required Inputs, Steps

### Community 18 - "Harness Doctor"
Cohesion: 0.33
Nodes (5): Approval Gate, Harness Doctor, Output, Required Inputs, Steps

### Community 19 - "Inbox Triage"
Cohesion: 0.33
Nodes (5): Approval Gate, Inbox Triage, Output, Required Inputs, Steps

### Community 20 - "Invoice Chaser"
Cohesion: 0.33
Nodes (5): Approval Gate, Invoice Chaser, Output, Required Inputs, Steps

### Community 21 - "Local Model Prompting"
Cohesion: 0.33
Nodes (5): Approval Gate, Local Model Prompting, Output, Required Inputs, Steps

### Community 22 - "Meeting Brief"
Cohesion: 0.33
Nodes (5): Approval Gate, Meeting Brief, Output, Required Inputs, Steps

### Community 23 - "Quote Builder"
Cohesion: 0.33
Nodes (5): Approval Gate, Output, Quote Builder, Required Inputs, Steps

### Community 24 - "Receipt Organizer"
Cohesion: 0.33
Nodes (5): Approval Gate, Output, Receipt Organizer, Required Inputs, Steps

### Community 25 - "Weekly Pulse"
Cohesion: 0.33
Nodes (5): Approval Gate, Output, Required Inputs, Steps, Weekly Pulse

### Community 26 - "create-payment-links.sh"
Cohesion: 0.53
Nodes (4): jget(), make_link(), create-payment-links.sh script, stripe()

### Community 27 - "Changelog"
Cohesion: 0.40
Nodes (4): 1.0.0 (2026-10-06), 1.0.1 (2026-10-06), Changelog, Unreleased

### Community 28 - "Claude Code Operating Scope"
Cohesion: 0.40
Nodes (4): Boundaries, Claude Code Operating Scope, Responsibilities, Shared Tooling

### Community 29 - "Codex Operating Scope"
Cohesion: 0.40
Nodes (4): Codex Operating Scope, Defers, Memory Policy, Owns

### Community 30 - "MCP_DOCKER"
Cohesion: 0.50
Nodes (3): PYTHONSAFEPATH, docker, MCP_DOCKER

### Community 31 - "MCP_DOCKER"
Cohesion: 0.50
Nodes (3): PYTHONSAFEPATH, docker, MCP_DOCKER

### Community 32 - "Memory Policy"
Cohesion: 0.50
Nodes (3): Client Responsibilities, Memory Policy, Rules

## Knowledge Gaps
- **6 isolated node(s):** `PATH`, `docker`, `PYTHONSAFEPATH`, `docker`, `PYTHONSAFEPATH` (+1 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 194 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MeshVault Harness` connect `MeshVault Harness` to `Install`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **What connects `PATH`, `docker`, `PYTHONSAFEPATH` to the rest of the system?**
  _6 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Install` be split into smaller, more focused modules?**
  _Cohesion score 0.062388591800356503 - nodes in this community are weakly interconnected._
- **Why does `SanitizeCheckTests` connect `SanitizeCheckTests` to `validate-template-syntax.py`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Should `Operations` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._