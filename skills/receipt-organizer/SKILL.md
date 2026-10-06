---
name: receipt-organizer
description: This skill should be used when the user asks to sort receipts, prepare a receipt filing plan, or add approved receipts to a running expense spreadsheet without moving files or editing the sheet before approval.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Receipt Organizer

Read receipts and propose where each belongs. Let the owner approve every file move and spreadsheet update before making it.

## Required Inputs

- The specific receipt files or approved input folder. Read only those files, not an entire inbox or drive.
- The destination folder rules: business or personal, year, and any categories the owner uses.
- The existing expense spreadsheet, its columns and currency, or an owner-approved template for a new one.
- Any owner-approved rules for shared expenses, tax, refunds, or duplicate receipts. Do not invent these rules.

## Steps

1. List the approved files and record the source path of each. Do not delete, rename, mark read, or move anything yet.
2. For each receipt, extract the merchant, transaction date, total, currency, and receipt or transaction ID when shown. Keep tax, tip, and other charges separate only if the receipt actually gives them. Record uncertain OCR or missing fields as unknown, not zero.
3. Compare the receipt with existing rows and other input files using the receipt ID if available, plus date, amount, currency, and merchant. Flag possible duplicates and refunds for review instead of counting them twice.
4. Propose one destination path and one spreadsheet row per supported, nonduplicate receipt. Show the exact original file, proposed destination, extracted fields, and the source evidence. Do not classify business or tax treatment without an approved rule.
5. Check that totals match each source. Keep currencies separate. If a receipt has multiple items or pages, prevent extra rows from changing the transaction total.
6. Show a preview of all proposed moves and row changes, including potential name collisions, duplicates, missing fields, and files that will be left untouched. Ask the owner to approve the exact set.
7. Only after approval, make the approved changes using the owner's storage and spreadsheet tools. Preserve the original or a recovery copy, verify each destination file and each new or updated row, and record any partial failure without replaying uncertain writes.

## Approval Gate

Parsing and previewing are read-only. Never move, rename, copy into a shared folder, delete, upload, or edit a spreadsheet before the owner approves the exact source paths, destinations, and proposed rows. Do not send receipt data to a new cloud service. A broad “organize my receipts” request authorizes a proposal, not a bulk write. Ask again if the destination, data, or amount changes after approval.

## Output

- A review table with source file, extracted date, merchant, amount and currency, proposed folder, proposed row, and confidence or open questions.
- An explicit list of duplicates, unreadable receipts, refunds, and missing rules held for the owner.
- After approval only: a read-back of the files and spreadsheet rows actually changed, plus recovery locations and any remaining work.
