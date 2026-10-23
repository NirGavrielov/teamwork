---
name: team
description: List the teamwork members available to /teamwork (built-in and custom)
disable-model-invocation: true
---

List the members the `/teamwork` lead can delegate to. This is read-only: do not create, edit, or delete any file, and do not read the plugin's own files.

A member is any agent whose `description` contains the phrase "teamwork member" (any case). List nothing else: not general-purpose, Explore, Plan, or other plugins' agents without that phrase.

1. **Loaded members:** the agent types the Agent tool offers in this session whose description has the phrase. The `teamwork:*` types are the built-ins; any other is a custom member. If no `teamwork:*` type is listed, say the plugin's agents are not loaded.
2. **Member files:** `*.md` files in `.claude/agents/` (project) whose frontmatter `description` has the phrase. Checking `~/.claude/agents/` (personal) is best effort: if you can't read it, don't ask for access; list a loaded custom type without a project file as source `personal`, and say in one line that a personal member created during this session appears after a new session.

Print one table:

| Member | Purpose (one line, from its description) | Source | File | Loaded |
| --- | --- | --- | --- | --- |

Source is `built-in`, `project`, or `personal`. For built-ins, Member is the name without `teamwork:` and File is `(plugin)`. If a custom member has the same name as a built-in, list both and mark the built-in "overridden by custom". A member file that isn't loaded needs a new session; until then the lead runs it through a general-purpose agent that reads its file. After the table, say in one line how many members there are and that `/teamwork:hire <description>` adds one.
