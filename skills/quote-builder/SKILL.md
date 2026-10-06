---
name: quote-builder
description: This skill should be used when the user asks to build, price, or draft a quote from a customer request and an approved price list, or asks for a quote in the owner's approved voice without sending it.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Quote Builder

Turn a customer request and an owner-approved price list into a clear quote draft. Do not guess prices or send the quote.

## Required Inputs

- The customer's request, including requested items, quantities, scope, and any deadline or delivery details.
- The current, owner-approved price list, with item names or IDs, units, prices, currency, and effective date or version.
- Any approved rules for tax, shipping, discounts, payment terms, delivery, and quote validity. If a rule is missing, do not assume it.
- The owner's approved tone notes, if the quote should use a particular voice. If none are provided, use a neutral, concise, professional tone.

## Steps

1. Read the request and price list. Record the source and its version or effective date.
2. Match each requested item to an exact entry in the approved price list. If an item, quantity, unit, currency, or important term is unclear, stop and ask instead of guessing.
3. Use only current, owner-approved prices. Do not invent or infer prices, substitute items, discounts, taxes, delivery charges, deadlines, or promises. If a requested item is missing or the list may be stale, mark the quote blocked and ask for an approved source.
4. Calculate each line as quantity multiplied by unit price. Apply tax, shipping, discounts, and other charges only when the approved price list or supplied policy gives the exact rule. Keep currencies separate; never convert without an approved rate and timestamp. Use the currency's stated precision and show the calculation.
5. Draft the quote with the customer, requested scope, line items, currency, subtotal, each approved adjustment, total, and only source-backed terms. Use a quote ID only if an approved system supplied one. List exclusions, assumptions, and open questions plainly.
6. Check the arithmetic a second time. Compare every price and term with its source. Mark the result `DRAFT — AWAITING APPROVAL`.
7. Present the full draft and its source notes to the owner. Stop.

## Approval Gate

This skill creates drafts only. It must never email, publish, submit, create an invoice or order, or charge a payment. Before any separate send or submission, show the exact channel, recipient, subject, complete quote, amounts, currency, and terms. Get explicit approval for that exact payload. Approval of one quote does not approve another. Hold any quote with missing, stale, conflicting, or unsupported details.

## Output

- Status: `DRAFT — AWAITING APPROVAL` or `BLOCKED — OWNER INPUT NEEDED`
- Customer and requested scope
- Itemized quote: description, quantity, unit, source unit price, and line total
- Subtotal, approved adjustments, and total with currency
- Source list and its version or effective date
- Source-backed terms, exclusions, assumptions, and open questions
- Complete proposed message, when requested, clearly labeled as unsent
