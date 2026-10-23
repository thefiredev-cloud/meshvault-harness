---
name: review-requester
description: This skill should be used when the user asks to "ask for a review", "get reviews from happy clients", "who should I ask for a review", "request a testimonial", or wants review asks drafted at the right moment and held for approval.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Review Requester

Find finished jobs whose owner is plausibly happy, draft a short review ask for each, and stop. Nothing sends until the owner approves.

## Required Inputs

- Job or project list with completion date, client name, and channel
- Delivery status and any payment status (paid, partial, disputed)
- Any "do not contact" list, unresolved complaint list, or review-request history
- Review destination the owner wants (Google, site, marketplace, email reply)

## Steps

1. Read the job list. Select jobs marked complete within the owner's review window (default: 7 to 30 days after completion).
2. Skip any job with a disputed invoice, an open complaint, a do-not-contact flag, or an already-sent review ask in the window.
3. Confirm the job is actually finished. A job marked complete but with an open punch list is not ready.
4. Order by completion recency, then by job value if present.
5. For each client, draft one short message:
   - Lead: name the specific work delivered, in one clause.
   - Ask: one plain request for a review, with the exact link or destination.
   - Easy out: no guilt, no follow-up threat.
   - Never invent a discount, gift, deadline, or incentive the owner did not approve.
6. Stop. Present each draft with client name, job, completion date, channel, and full body.
7. Only after explicit approval, send the approved drafts. Log what went out, to whom, and when.

## Approval Gate

Review requests are outbound client-facing messages and they carry reputational risk. This skill never sends on its own. Hold any draft where the client's satisfaction is unproven, where the invoice is unsettled, or where the ask would feel transactional. Never offer an incentive for a review unless the owner states it, and never ask for a review in exchange for anything.

## Output

- Drafted asks listed with client, job, window day, and body
- Held asks with the reason each was held
- Approved messages sent (after approval only)
- Summary: drafted, held, sent
- Log entry per sent message, plus the next eligible date if a reminder is allowed
