---
name: invoice-chaser
description: This skill should be used when the user asks to "chase invoices", "who still owes us", "send payment reminders", or wants overdue receivables nudged politely without anything sending before approval.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Invoice Chaser

Find overdue invoices, draft a friendly reminder for each one in the owner's voice, and stop at the approval gate. Nothing sends until the owner says yes.

## Required Inputs

- The invoice list (a spreadsheet, an accounting export, or a plain Markdown table with client, amount, due date, and status)
- Client contact emails
- The owner's preferred tone, if one is on file (default: warm, brief, zero pressure on the first nudge)

## Steps

1. Read the invoice list. Select every invoice past its due date that is not marked paid or disputed.
2. Sort by days overdue, largest amount first inside each bucket.
3. For each overdue invoice, draft one reminder email:
   - First nudge (1 to 14 days late): friendly, assume it slipped their mind, restate amount and due date, offer the payment link.
   - Second nudge (15 to 30 days late): direct, restate terms, ask for a payment date.
   - Third nudge (31+ days late): flag to the owner instead of drafting. Late accounts at this stage need a human decision, not another template.
4. Stop. Present every draft to the owner with client, amount, days late, and the full email body.
5. Only after explicit approval, send the approved drafts. Never send a reminder the owner has not seen.
6. Log what was sent, to whom, and when, in `decision-log.md` or the system of record.

## Approval Gate

Sending email to a client is a real-world action. This skill never sends on its own. If the owner approves some drafts and not others, send only the approved ones. If anything about an invoice looks disputed or already paid, hold it and ask.

## Output

- Sent reminders (after approval only)
- A short summary: how many chased, how many held, total amount outstanding
- A log entry per sent email
