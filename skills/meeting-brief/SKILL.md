---
name: meeting-brief
description: This skill should be used when the user asks to "prep me for the meeting", "meeting brief", "what do I need for this call", or wants a short prep pack from notes, calendar, and prior threads.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Meeting Brief

Build a five-minute prep pack for an upcoming meeting. Read only unless the owner asks to schedule or message someone (those are different skills).

## Required Inputs

- Meeting title, time, and attendees (calendar or owner statement)
- Prior notes, emails, or CRM context for those people if available
- Owner goal for the meeting in one sentence (ask if missing)

## Steps

1. Confirm who is in the room and why the meeting exists.
2. Pull the last relevant touch for each external attendee (one line each).
3. List open commitments from either side (promises, invoices, decisions).
4. Write the brief in four short blocks:
   - **Goal**: one sentence
   - **People**: name + role + last touch
   - **Open items**: bullets, max five
   - **Suggested agenda**: three bullets the owner can run
5. Keep the whole brief under 180 words. Prefer cuts over fluff.
6. Do not send calendar invites, emails, or chat messages from this skill.

## Approval Gate

None for the brief itself (read + draft only). If the owner wants the agenda emailed or the meeting rescheduled, switch to a skill with a send/schedule gate and stop here.

## Output

- One meeting brief the owner can skim in under a minute
- Optional: three questions to ask in the room
- No outbound actions
