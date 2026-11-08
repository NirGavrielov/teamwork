# teamwork

A Claude Code plugin that turns one assistant into a small team. Run `/teamwork <goal>` and Claude acts as **team lead**: it plans, delegates to expert subagents, verifies their work, gets a QA verdict, and reports to you.

## Install

```
/plugin marketplace add NirGavrielov/teamwork
/plugin install teamwork@teamwork
/reload-plugins
```

The repo is private: you need read access, and git must clone it without a prompt (an SSH key, or `gh auth setup-git` and the HTTPS URL). Update with `/plugin marketplace update teamwork` and `/plugin update teamwork@teamwork`.

Also works as a Gemini CLI extension: `gemini extensions install https://github.com/NirGavrielov/teamwork` (same commands). Other harnesses with skills and subagents can load `skills/` and `agents/` directly (experimental).

## Examples

```
/teamwork add a --version flag to the CLI
/teamwork team of 3: add CSV export
/teamwork add rate limiting, with QA and security reviewer
/teamwork solo: rename the config module
/teamwork:hire a technical writer who owns user docs and the changelog
/teamwork:team
```

Without a size or roles, the lead picks the smallest team that fits (with QA when code changes). Roles you name win over a size; an unknown role gets an offer to `hire` it.

## The built-in team

| Member | Use for |
| --- | --- |
| `product-manager` | Specs, acceptance criteria, scope |
| `software-engineer` | Design, implementation, fixes, tests |
| `ui-ux-engineer` | User flows, front-end UI, accessibility |
| `qa-engineer` | Tests, bug reports, the Ready / Not ready verdict |
| `data-eval-engineer` | AI or data steps: evals, model choice, cost |
| `privacy-security-reviewer` | Secrets, personal data, auth, untrusted input |
| `devops-engineer` | Deploy, CI, hosting, monitoring |

Add your own with `/teamwork:hire`: it saves `teamwork-<role>` to `~/.claude/agents/`, so the member is in all your sessions on that device (or to the project's `.claude/agents/` to share it through git). Or copy [`templates/member-template.md`](templates/member-template.md) there by hand. An agent is a member when its `description` contains "Teamwork member".

## Where the work lands

Each job gets `.teamwork/jobs/<date>-<slug>/` with `plan.md`, `spec.md`, per-member `logs/`, and QA's `bugs/`. Code changes land in your project as usual. The team never commits or pushes unless you ask.

## Contributing

Run `scripts/check.sh` before sending a change, and the eval suite for behavior changes (see [`evals/README.md`](evals/README.md)). Test from a sandbox project outside the plugin folder, with `claude --plugin-dir <a copy of the repo>`.
