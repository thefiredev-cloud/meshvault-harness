---
name: harness-doctor
description: This skill should be used when the user says the local AI "is not working", "is slow", "will not start", "won't answer", asks to "check the harness", "run doctor", "switch the local model", or asks which local model fits their machine.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Harness Doctor

Diagnose and repair the MeshVault Harness on this machine: the local model server, Hermes, OMP and the skills. Read first, change second.

## Required Inputs

- The `meshvault` command on PATH (installed at `~/.local/bin/meshvault`)
- Permission to run read-only checks. Restarting the local model server is allowed; anything else is not.

## Steps

1. Run `meshvault status`. If the server is down, run `meshvault start`, then `meshvault logs` if it does not come up.
2. Run `meshvault doctor`. Read every failed line before touching anything.
3. If answers are slow, run `meshvault model list`. Compare the current model with this machine's RAM. Propose a smaller model only if the current one does not fit.
4. If Hermes does not use the local model, run `hermes config get model` and confirm `base_url` is `http://127.0.0.1:<port>/v1` and the model name is `meshvault-local`.
5. If a skill is missing, run `meshvault skills list`, then `meshvault skills sync`.
6. Report in three lines: what was wrong, what was changed, what to do next.

## Approval Gate

Ask before: switching the default model (`meshvault model use`, downloads GBs), enabling autostart, editing any config file by hand, or running `meshvault uninstall`. Never delete the models folder, session history or memory without a clear yes.

## Output

- One short diagnosis, the exact commands run, and the result of a final `meshvault doctor`
- Nothing sent, paid, posted or deleted
