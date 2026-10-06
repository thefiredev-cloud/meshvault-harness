# Contributing

Issues and pull requests welcome.

* **Skills:** one skill per PR under `skills/<name>/SKILL.md`. Frontmatter `name` + `description`. Sections: Required Inputs, Steps, Approval Gate, Output. Anything that can send, pay, post or delete must stop at the gate.
* **Installer changes:** keep bash 3.2 compatibility (macOS), no new required tools, no secrets. Run `tests/run.sh` and, for installer changes, `tests/container-proof.sh`.
* **Catalog changes:** new model or runtime rows need a verified sha256 and a real install test.
* No telemetry, no tracking, no hard-coded hosts.
