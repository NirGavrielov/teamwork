#!/usr/bin/env bash
# Fixtures: one custom member (marker phrase in description) and one non-member
# agent that only carries the old "## Decision authority" heading (F1 regression).
set -euo pipefail
mkdir -p .claude/agents
cat > .claude/agents/api-reviewer.md <<'MD'
---
name: api-reviewer
description: Teamwork member (API reviewer): reviews HTTP API designs for consistency and breaking changes. Use only when delegated by the /teamwork team lead.
---
You are the API reviewer on a team led by the team lead.

## Decision authority
Decide naming nits yourself; escalate breaking changes to the team lead.
MD
cat > .claude/agents/notes-helper.md <<'MD'
---
name: notes-helper
description: Summarizes meeting notes into action items.
---
You summarize meeting notes.

## Decision authority
Decide the summary format yourself.
MD
