---
name: daily-standup
description: This skill should be used when the user asks for a "morning brief", "daily standup", "what happened yesterday", "what is on today", or wants a short start-of-day summary built from their notes, calendar, and task list.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Daily Standup

Build a start-of-day brief from what the system already knows. Read only. This skill changes nothing; it reports.

## Required Inputs

- Yesterday's log or notes (whatever the owner keeps: a daily note, a task tracker, a decision log)
- Today's calendar, if available
- The open task list

## Steps

1. Read yesterday's log. Pull out what actually got done and anything that stalled.
2. Read today's calendar and task list. Pull the top commitments with times.
3. Find blockers: anything waiting on a reply, a payment, an approval, or another person.
4. Write the brief in three short sections:
   - **Done yesterday**: 3 lines maximum
   - **Today**: the schedule and the top 3 tasks, nothing else
   - **Blocked**: each blocker with who or what it is waiting on
5. Keep the whole brief under 150 words. If it does not fit, cut detail, not sections.

## Approval Gate

None needed. This skill only reads and summarizes. If the owner asks the standup to also chase a blocker, that is a different action and follows that skill's own approval gate.

## Output

- One brief, delivered wherever the owner reads first thing (chat, note, or email to self)
- Nothing else. No state changes, no sent mail, no edits to the task list
