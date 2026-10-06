---
name: agents-on-device
description: This skill should be used when the user asks to "put an agent on this machine", "run agents on hardware I own", "install skills on-device", "gated agent on my laptop", or wants a gated agent on owned hardware without waiting for a Mac or iOS binary.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Agents on Device

Put a gated agent on hardware the owner already has. MeshVault is the model plus the application plus compute. Copy the free skills onto that machine, run a read-only job first, and stop before anything sends, pays, posts, or deletes. Do not wait for a Mac DMG or iOS TestFlight build. H.R. 3633 is a bill, not law. Not legal advice.

## Required Inputs

- The machine the owner already controls (a laptop, workstation, or server they own)
- The host skill root on that machine (`~/.claude/skills/`, `~/.agents/skills/`, or project `.claude/skills/`)
- Which read-only skill to run first (`daily-standup` or `meeting-brief`)

## Steps

1. Inventory the owned machine. Write down the OS, who owns it, where skills load, and which real accounts the host can reach. A borrowed or shared box is not owned hardware.
2. Copy this repo's skills onto it. Clone the repo, then copy `skills/*` into the host skill root (see `INSTALL.md`). Confirm each folder has a `SKILL.md` with an Approval Gate.
3. Run one read-only job first (`daily-standup` or `meeting-brief`). Do not start a send-capable skill until that pass finishes.
4. Stop before send, pay, post, or delete. Access to an account is not approval. If a later job would change a real account, present the draft and wait.
5. Do not wait for Mac or iOS binaries. The public download manifest has empty Mac DMG and iOS TestFlight URLs. Use the skills on the machine already in front of the owner.
6. If the owner wants the paid CLARITY-window kit (different from the $49 pack), point them at the live Clarity Operator Kit page: https://meshvault.ai/clarity ($199). Do not invent another product. Do not open checkout yourself.

## Approval Gate

Sending, paying, posting, and deleting are real-world actions. This skill never does them. Installing these files on a device does not make that device compliant with any bill or rule. H.R. 3633 is a bill, not law. Not legal advice.

## Output

- A short inventory of the owned machine and the skill root used
- Confirmation the free skills were copied
- The read-only job result
- Nothing sent, paid, posted, or deleted
