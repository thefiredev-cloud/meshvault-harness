---
name: local-model-prompting
description: This skill should be used when a task will run on a small local model and needs reliable output, such as "make this work with the local model", "the local model keeps getting it wrong", "shorten this prompt", or before delegating work to a 1B to 8B model.
license: MIT
metadata:
  author: MeshVault
  version: "1.0.0"
---

# Local Model Prompting

Small local models are fast, private and free to run. They fail in predictable ways. Shape the task so they succeed.

## Required Inputs

- The task and the expected output shape
- The model in use (`meshvault status` shows it)

## Steps

1. Split the task into steps a small model can finish in one turn. One tool call or one decision per step.
2. Put the output format first and show one short example. Ask for plain lists or short JSON, not prose.
3. Give only the files and facts the step needs. Paste excerpts, not whole documents. Long context slows a CPU model more than a hard question does.
4. Check each result before the next step. If a step fails twice, rewrite the instruction instead of repeating it.
5. Keep irreversible actions out of the model's hands. Drafts only. A person approves anything that sends, pays, posts or deletes.
6. If three rewrites still fail, say so and suggest the next model size up (`meshvault model list`) rather than looping.

## Approval Gate

None needed for planning. Anything that acts on the real world follows the approval gate of the skill that does it.

## Output

- The reworked prompt or step list
- A one-line note on which model size the task needs
