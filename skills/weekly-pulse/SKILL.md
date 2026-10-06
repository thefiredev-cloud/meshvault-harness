---
name: weekly-pulse
description: This skill should be used when the user asks for a weekly pulse, Friday numbers, or a short summary of activity and metrics from the current week's approved source files.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Weekly Pulse

Create a five-line weekly summary from approved files that already exist. Read only; do not make up missing numbers or change any files.

## Required Inputs

- The reporting week, including its start and end dates, plus the owner's timezone.
- The specific existing files to read, or an approved folder and clear rule for choosing files.
- The metrics to report and their definitions, including units and how each metric is counted.
- The intended audience and destination. If the destination is outside the owner's private system, stop and ask before sharing.

## Steps

1. Confirm the week, timezone, source files, and metric definitions. Do not search unrelated folders or private accounts for extra data.
2. Read only the approved files. Record each source's path, date, and last-updated time. If a file is stale, incomplete, or outside the reporting period, mark that gap.
3. Extract only numbers that match the requested metric and date range. Keep counts, money, percentages, and durations separate. Do not combine unlike units or compare numbers with different definitions.
4. Treat missing, unreadable, conflicting, or unverified values as unknown, never as zero. Do not estimate or infer a trend from incomplete data. If a metric needs arithmetic, calculate it deterministically and check it again.
5. Draft exactly five concise lines. Use the owner's requested metrics; if none were prioritized, use: activity, delivery, pipeline, reliability, and next step. Include units and comparison periods where relevant. Cite a short source label on each line; retain full paths and timestamps in private notes.
6. Check every number against its source and confirm no line implies more certainty than the evidence supports. Keep private details out of a public or shared summary.
7. Present the draft to the owner. Stop before sending, publishing, or changing any source file.

## Approval Gate

This skill is read-only and creates a draft. It must never edit source files, send a message, publish a report, or share private metrics. Before any separate sharing action, show the exact destination, recipients, and complete five-line text, then get approval for that payload. If the audience or data scope is unclear, keep the draft private and ask.

## Output

- Status: `DRAFT — AWAITING APPROVAL` or `BLOCKED — OWNER INPUT NEEDED`
- Exactly five summary lines, with units, period, and short source labels
- Any missing, stale, conflicting, or unverified data, clearly marked
- Private source notes with paths and checked timestamps
