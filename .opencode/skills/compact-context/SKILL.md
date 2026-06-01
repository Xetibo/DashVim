---
name: compact-context
description: >
  Compact the current conversation context to reduce token usage. Use when context is getting
  large, when you hit token limits, or when the user asks to compact/compress/summarize context.
  Invoked via /compact-context or when user says "compact context", "compress context", "shrink context".
---

## What I do

When invoked, perform context compaction:

1. Summarize all previous conversation turns into a concise technical summary
2. Preserve: all file paths mentioned, all code changes made, all decisions taken, current task state
3. Drop: repeated explanations, exploratory dead-ends, verbose tool outputs already acted on
4. Keep active: any ongoing task context, uncommitted changes list, current goals

## Output format

Produce a structured summary:

```
## Context Summary

### Changes Made
- [file:line] description of change

### Decisions
- decision and rationale (one line each)

### Current State
- what is done
- what remains

### Key Files
- list of relevant files being worked on
```

## When to use

- User says "compact context", "compress context", "shrink context", "save tokens"
- Context window getting full (agent notices token pressure)
- After completing a large multi-step task, before starting next one
- User invokes `/compact-context`

## Rules

- Never lose track of uncommitted file changes
- Preserve exact file paths and line numbers for recent changes
- Keep code snippets only if they are actively being discussed
- Summaries should be technically precise, not vague
- After compaction, confirm what was preserved and what was dropped
