# teamwork

A Claude Code plugin that turns one assistant into a small team. Run `/teamwork <goal>` and Claude acts as **team lead**: it plans the work, delegates self-contained briefs to expert subagents, checks what comes back, gets a QA verdict, and reports to you.

## Install

From a git repository (for colleagues):

```
/plugin marketplace add <owner>/<repo>
/plugin install teamwork@teamwork
```

`<owner>/<repo>` is the GitHub repository that holds this plugin; a full git URL (`https://<git-host>/<owner>/<repo>.git`) works too. Restart Claude Code (or start a new session) after installing.

From a local checkout, without installing:

```
claude --plugin-dir /path/to/claude-teamwork
```

## Quick start

```
/teamwork add a --version flag to the CLI
```

The lead restates the goal, picks the smallest team that fits, writes a plan to `.teamwork/plans/`, delegates, verifies, and ends with a report: what was done, what was verified, what is open, and what it needs from you.

Run `/teamwork` with no goal and it asks you for one.

## Choosing the team

Say the size, the roles, or both, in plain words. Size counts members, not the lead.

| You type | The lead does |
| --- | --- |
| `/teamwork fix the login redirect bug` | Picks the smallest team that fits and says why |
| `/teamwork team of 3: add CSV export` | Uses exactly 3 members, chosen by fit |
| `/teamwork add rate limiting, with QA and security reviewer` | Uses exactly those roles |
| `/teamwork just PM and engineer: draft and build the settings page` | Uses those two |
| `/teamwork solo: rename the config module` | No delegation; the lead does it, still plans, verifies, and logs |
| `/teamwork team of 2 with PM, QA, and security` | Roles win; the size is raised to 3 |
| `/teamwork with a legal reviewer` | Says there is no such member and offers `/teamwork:hire` |

## The built-in team

| Member | Use for |
| --- | --- |
| `product-manager` | Unclear goals, specs, acceptance criteria, scope tradeoffs |
| `software-engineer` | Design and implementation, bug fixes, tests, code review |
| `ui-ux-engineer` | User flows, front-end UI, accessibility (uses the Impeccable skill if installed) |
| `qa-engineer` | Test strategy, tests, bug reports, the Ready / Not ready verdict |
| `data-eval-engineer` | AI or data steps only: gold sets, evals, model choice, cost |
| `privacy-security-reviewer` | Secrets, personal data, auth, untrusted input, dependencies |
| `devops-engineer` | Deploy, CI, hosting, backups, monitoring |

Run `/teamwork:team` to see every member, including your custom ones.

## Adding your own members

Members are ordinary Claude Code agent files. Save them in `.claude/agents/<name>.md` (project, shared through git) or `~/.claude/agents/<name>.md` (personal).

**Ask Claude to write one:**

```
/teamwork:hire a technical writer who owns user docs and the changelog
```

It checks for overlap with existing members, fills in the template, asks where to save it, and never overwrites an existing file without asking.

**Or write one by hand:** copy [`templates/member-template.md`](templates/member-template.md), fill in the placeholders, and keep its sections. The `## Decision authority` section is what tells the lead the file is a team member.

New agent files load when a session starts. Until then the lead can still use a new project member by running a general-purpose agent that reads the file as its role. The lead finds members mainly through the agent types loaded in the session; it may not be able to read `~/.claude/agents/` directly, so a personal member created during a session shows up after you start a new one.

## Where the work lands

Everything the team writes about the job goes under `.teamwork/` in your project:

```
.teamwork/
  plans/YYYY-MM-DD-<slug>.md          the lead's plan for each job
  specs/                              product manager specs
  logs/<member>/YYYY-MM-DD-<slug>.md  one work log per member per task
```

Code changes land in your project as usual. The team never commits or pushes unless you ask. Add `.teamwork/` to `.gitignore` if you don't want to keep the logs.

## How it works

The lead plans, picks a team, delegates self-contained briefs, reviews what comes back, gets a QA verdict, and reports to you. Members escalate questions to the lead, and the lead to you.

![Flow of /teamwork: you give a goal; the team lead plans in .teamwork/plans/, picks members from the roster, delegates briefs with a model per task, reviews handoffs, gets a QA verdict and reports back; members escalate up to the lead and you; each member logs to .teamwork/logs/<role>/](docs/images/flow.svg)

The lead runs in your main conversation because only the main thread can start subagents. Each member starts with no context, so the lead writes a complete brief and picks a model per task (haiku for mechanical work, sonnet for normal work, opus for architecture and security) to keep token use down.

## See it in action

### Using it

Real sessions in a throwaway project. This job ran one step after another (spec, then build, then QA), not in parallel.

![The lead plans, then delegates to the product manager, software engineer and QA engineer](docs/images/screenshot-e2e-delegation.png)
The lead writes a plan and delegates to three members.

![The lead's final report with the QA verdict Ready](docs/images/screenshot-e2e-report.png)
The final report: what was done, what was verified, what is open, and what needs you.

![/teamwork:hire saving a new technical-writer member](docs/images/screenshot-hire.png)
`/teamwork:hire` asks where to save the new member and writes it.

![/teamwork:team listing built-in and custom members](docs/images/screenshot-team.png)
`/teamwork:team` lists the built-in members and your custom one.

### Built with itself

These come from building this plugin with `/teamwork`'s own flow. QA's first verdict was "Not ready" because of a real bug (bare `/teamwork` was not invokable), which was then fixed.

![The team lead's brief to the product manager and its hand-back](docs/images/screenshot-team-lead-delegates.png)
The lead briefs the product manager, who hands back a summary and the decisions it needs.

![The product manager reading sources and writing the spec](docs/images/screenshot-product-manager.png)
The product manager reads the source material and writes the spec.

![QA verdict Not ready with the criterion table](docs/images/screenshot-qa-verdict.png)
QA's first verdict: "Not ready", with the criterion that failed.

## Commands

| Command | What it does |
| --- | --- |
| `/teamwork <goal>` | Start a job with you as the requester and Claude as team lead |
| `/teamwork:hire <description>` | Define a new member from a description (plain `/hire` also works if no other plugin or skill uses that name) |
| `/teamwork:team` | List built-in and custom members |

These run only when you type them; Claude does not start them on its own.

## Testing locally (contributors)

Claude Code treats writes inside a directory loaded with `--plugin-dir` as sensitive and refuses them. So never run test jobs from a folder inside the plugin directory: run them from a sandbox project outside it, with `--plugin-dir` pointing at the repo or at a copy:

```
cp -R /path/to/claude-teamwork /tmp/teamwork-copy
mkdir /tmp/tw-sandbox && cd /tmp/tw-sandbox && git init
claude --plugin-dir /tmp/teamwork-copy
```

Check the manifests and components with `claude plugin validate --strict /path/to/claude-teamwork`. The template embedded in `skills/hire/SKILL.md` must stay identical to `templates/member-template.md`.
