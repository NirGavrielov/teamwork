# teamwork extension: Gemini CLI notes

The teamwork skills (`teamwork`, `hire`, `team`) are written for Claude Code. Activate them only from the `/teamwork`, `/teamwork:hire` and `/teamwork:team` commands, never on your own. While following one, read its Claude Code terms this way:

- **Subagents.** "The Agent tool" and `subagent_type: X` mean calling the subagent named X. The built-in members are `product-manager`, `software-engineer`, `ui-ux-engineer`, `qa-engineer`, `data-eval-engineer`, `privacy-security-reviewer` and `devops-engineer`; where a skill writes `teamwork:<role>`, use `<role>`. `general-purpose` means `generalist`. For parallel tasks, call several subagents in one response. Subagents cannot start other subagents here either.
- **Members.** Loaded members are the subagents whose description contains "teamwork member". Member files that are not loaded: `*.md` in `.gemini/agents/`, `~/.gemini/agents/` and `.claude/agents/`; run them through `generalist` with the "read this file as your role" brief.
- **Hiring.** Save new members to `.gemini/agents/<name>.md` (project) or `~/.gemini/agents/<name>.md` (personal). Leave out `model` unless the user names a Gemini model; `tools` is a YAML list of Gemini tool names. New member files load in a new session or after `/agents reload`.
- **Tools.** Read = `read_file`, Write = `write_file`, Edit = `replace`, Bash = `run_shell_command`, Grep = `grep_search`, Glob = `glob`, task lists = `write_todos`, asking the user = `ask_user`.
- **Reviews.** `/code-review` and `/security-review` do not exist here: run the review through a fresh subagent that did not write the change (`privacy-security-reviewer` for security).
