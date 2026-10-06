---
name: client-followup
description: This skill should be used when the user asks to "follow up with clients", "nudge quiet leads", "who went silent", "re-engage stalled deals", or wants polite check-ins drafted without sending before approval.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Client Follow-Up

Find contacts who went quiet, draft a short human follow-up for each, and stop. Nothing sends until the owner approves.

## Required Inputs

- Contact or CRM list with last touch date, status, and email
- Owner tone notes if available (default: brief, useful, zero guilt)
- Any "do not contact" list or closed-lost rules

## Steps

1. Read the contact list. Select open or stalled contacts with no owner-side touch in the last 7+ days (use the owner's threshold if stated).
2. Skip anyone on do-not-contact, already booked, or marked closed-lost.
3. Sort by deal value if present; otherwise by days since last touch.
4. For each contact, draft one short message (email or the channel the owner names):
   - Lead: one useful question or resource, one soft next step.
   - Active client: status check, clear ask, easy out.
   - Never invent a discount, deadline, or commitment the owner did not approve.
5. Stop. Present each draft with name, days silent, channel, and full body.
6. Only after explicit approval, send the approved drafts. Log what went out.

## Approval Gate

Outbound client-facing messages are real-world actions. This skill never sends on its own. If a draft feels salesy or wrong for the relationship, hold it and ask.

## Output

- Approved messages sent (after approval only)
- Summary: how many drafted, how many held, how many sent
- Log entry per sent message
