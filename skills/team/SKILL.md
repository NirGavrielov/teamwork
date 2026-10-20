---
name: team
description: List the teamwork members available to /teamwork (built-in and custom)
disable-model-invocation: true
---

List the members the `/teamwork` lead can delegate to. This is read-only: do not create, edit, or delete any file.

1. **Built-in members** (from the teamwork plugin; do not read the plugin's files, use this table):

| Member | Purpose |
| --- | --- |
| product-manager | Unclear goals, specs, acceptance criteria, scope tradeoffs |
| software-engineer | Design and implementation, bug fixes, tests, code review, estimates |
| ui-ux-engineer | User flows, front-end UI, accessibility, design system |
| qa-engineer | Test strategy, tests, bug hunting, release-readiness verdict |
| data-eval-engineer | AI or data steps only: gold sets, evals, model choice, cost |
| privacy-security-reviewer | Secrets, personal data, auth, untrusted input, dependencies |
| devops-engineer | Deploy, CI, hosting, backups, monitoring |

2. **Loaded agent types:** check the agent types the Agent tool offers in this session. `teamwork:<role>` types are the built-ins above; mark any built-in that is missing as not loaded. Any other type whose name matches a custom member file is a loaded custom member.
3. **Custom member files:** the `*.md` files in `.claude/agents/` (project) that contain a `## Decision authority` section. Read each one's `name` and `description` from its frontmatter. Checking `~/.claude/agents/` (personal) is best effort: if you can't read it, don't ask for access; list any loaded agent type that isn't a built-in or a project file as source `personal (loaded)`, and say in one line that a personal member created during this session appears after a new session. Ignore agent files without the `## Decision authority` section.

Print one table:

| Member | Purpose (one line) | Source | File | Loaded |
| --- | --- | --- | --- | --- |

Source is `built-in`, `project`, or `personal`. For built-ins, File is `(plugin)`. If a custom member has the same name as a built-in, list both and mark the built-in as "overridden by custom". A custom member that has a file but is not a loaded agent type needs a new session; until then the lead runs it through a general-purpose agent that reads its file. After the table, say in one line how many members there are and that `/teamwork:hire <description>` adds one.
