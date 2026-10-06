---
name: inbox-triage
description: This skill should be used when the user asks to "triage my inbox", "what needs a reply", "clean up my email", or wants unread mail sorted into act, reply, and archive with a short summary.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Inbox Triage

Sort unread email into three buckets and hand back a summary the owner can act on in two minutes. Never reply, never delete, never unsubscribe without approval.

## Required Inputs

- Access to the inbox (read scope is enough for triage)
- The owner's list of VIP senders, if one exists (clients, family, key vendors)
- Any standing rules the owner has stated (for example "receipts go to the receipts folder")

## Steps

1. Read unread messages from newest to oldest. Do not mark anything read unless the owner has said that is fine.
2. Put each message in exactly one bucket:
   - **Act**: money, deadlines, clients, anything with a date attached, anything from a VIP sender
   - **Reply**: real people waiting on an answer where a short reply closes it
   - **Archive**: newsletters, notifications, receipts, promotions
3. For each Act item, write one line: who, what they need, by when.
4. For each Reply item, draft a suggested reply in the owner's voice. Keep drafts short.
5. Present the summary: Act list first, then Reply drafts, then the Archive count.
6. Only after approval: send approved replies and archive the Archive bucket.

## Approval Gate

Replies are outbound client-facing text. Nothing sends until the owner approves each draft. Archiving is reversible, but still wait for the single "archive those" confirmation before touching anything.

## Output

- A triage summary the owner can read in under two minutes
- Approved replies sent, archive bucket cleared
- A count of what moved where, appended to the daily log
