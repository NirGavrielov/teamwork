# Teamwork evals

Regression cases for `claude plugin eval`. Each case is one directory with a `case.yaml` (prompt, limits, graders) and, where it needs fixture files, a `scaffold.sh` that writes them into the run's sandbox before the prompt is sent.

The skills use `disable-model-invocation`, so every case is a slash command (`/teamwork ...`, `/teamwork:team`, `/teamwork:hire ...`), except `14-no-autoinvoke`, which checks that nothing fires without one. Most cases are plan-only ("Stop after writing and showing the plan; do not delegate.") to stay cheap. Graders are deterministic (files created, text matched, tools used) wherever possible; a small `llm` grader is used only for judgments like "exactly 3 distinct members".

## Run

Copy the plugin somewhere outside your working tree first if you don't want `evals/results/` written into it, then:

```bash
claude plugin eval /path/to/claude-teamwork \
  --ablation none --scaffold --allow-tools Bash Write Edit \
  --model sonnet -j 4 --no-publish
```

- `--ablation none`: a no-plugin baseline is meaningless here (the slash commands don't exist without the plugin).
- `--scaffold`: required for cases 09, 12 and 13, which write fixture files. Only the scripts in this directory run.
- `--allow-tools Bash Write Edit`: the lead writes `.teamwork/jobs/...` and hire writes `.claude/agents/...`; without them those cases score 0.
- `--trust-plugin` skips the first-run trust prompt (CI).
- One case: `--case 09-team-lists-members`. A group: `--tag plan-only`.
- More confidence on a flaky case: `--runs 3`. Stricter judging: `--judge-model sonnet`.

Every case uses `runs: 1`. These are LLM runs, so one failure is a signal to read the trace (`evals/results/<timestamp>/`), not proof of a bug; rerun the case with `--runs 3` before filing.

## Cost and time

Measured 2026-10-23 (Claude Code 2.1.309, `--model sonnet`, `-j 4`, haiku judge): the first 14 cases in about 90 s wall time, about $1.15 in total ($0.04-0.11 per case; llm judging is under $0.01). Cases 15-20 add about $0.55 and 30 s. Without `-j 4`, expect 5-7 minutes. `--runs 3` triples the cost.

## Cases

| Case | Prompt (short) | Checks | Source |
| --- | --- | --- | --- |
| 01-bare-no-goal | `/teamwork` | asks one question; writes no file; no delegation | spec 8, bug bare-teamwork-unknown-command |
| 02-default-team | hello CLI, no size | plan at `.teamwork/jobs/<YYYY-MM-DD-slug>/plan.md`; no old `.teamwork/plans/` or `.teamwork/logs/`; 1-4 members incl. QA | spec 9, F3, F6 |
| 03-team-of-3 | `team of 3` | exactly 3 distinct members; tasks name the files they own; parallel tasks don't share files | spec 10, F5 |
| 04-roles-only-no-qa | `with the product manager and the software engineer` | exactly those roles; QA not added; lead verifies | spec 11, F3 |
| 05-team-of-12 | `team of 12` | says the roster is smaller; `/teamwork:hire` offered; no idle member; no non-teamwork agent types; no stop to ask | spec 12, F1, bug oversize-team-pads-idle-member |
| 06-unknown-role | `with a legal reviewer` | offers `/teamwork:hire` or nearest role; waits; no agent file; no delegation | spec 15 |
| 07-solo | `solo` (full run) | zero Agent calls; plan and `logs/team-lead.md` in the job dir; `hello.py` written; "No QA verdict" | spec 14, F3, F6 |
| 08-roles-raise-size | `team of 1 with PM and QA` | both roles; says the size was raised | spec 13 |
| 09-team-lists-members | `/teamwork:team` with fixtures | 7 built-ins + `api-reviewer` (project member) in the table; `notes-helper` (no marker phrase, but has a `## Decision authority` heading) and Claude Code's own types not listed; no file written; no access request | spec 17, F1, bug personal-agents-dir-not-discovered |
| 10-hire-refuses-team-lead | `/teamwork:hire ... name it team-lead` | refuses the reserved name; no agent file | F4 |
| 11-hire-new-member | `/teamwork:hire a technical writer` | a Write to `.claude/agents/technical-writer.md` whose content starts `name: technical-writer` / `description: Teamwork member (`; no read of the plugin's own files; honest report if the write is denied | spec 16, F1, bug plugin-root-read-prompt |
| 12-same-goal-distinct-ids | same goal as earlier jobs today (fixtures) | a new plan is created (an overwrite doesn't count as created) in a `-2`..`-9` suffixed job dir | F6 |
| 13-custom-member-delegation | `with the doc auditor only` (full run, fixture member with `tools` and `model`) | delegates to `doc-auditor`, either by agent type or via general-purpose with "Use only these tools: Read, Grep, Write"; plan, lead log and `TYPOS.md` created | spec 18, F6, F7 |
| 14-no-autoinvoke | plain request, no slash command | no Agent call to `teamwork:*`; no `.teamwork/`; task done | F2 (should-not-fire) |
| 15-risk-tier-low | docs typo (fixture README) | plan rated Low, no high-risk gates; says how to verify and revert | review rules: risk tiers |
| 16-risk-tier-high | password reset in `auth.py` | plan rated High; security reviewer or `/security-review`; user's OK before done | review rules: risk tiers |
| 17-high-risk-explicit-roles | secret in `config.py`, `with the software engineer only` | team kept as requested; rated High; lead names the security check it runs itself | review rules: tiers vs explicit roles |
| 18-evidence-in-handoff | `with the software engineer only` (full run) | brief asks for the command and its output; report shows commands and results, tier, revert, no-QA line | review rules: evidence |
| 19-review-findings-triage | automated reviewer findings (fixture, solo) | real bug fixed (file check); false finding dropped; style nit not applied (file check); pre-existing logged; fix verified | review rules: findings |
| 20-review-converges | contradictory tests (fixture) | at most 4 delegations; tests untouched; no false "passes"; escalates with options | review rules: converge |

Marker phrase used by the graders: "teamwork member" in an agent's `description` (case-insensitive).

## Notes for contributors

- `file_exists` and `target: files` only see files created during the run; fixture files written by `scaffold.sh` never count. That is how 12 detects an overwrite.
- 12 pre-creates the earlier job under several likely slugs. If the lead picks a slug that isn't in the list, no collision happens and `suffixed-job-id` fails: read the trace, and add the slug to `scaffold.sh` if that is the cause.
- The eval sandbox denies writes under `.claude/` (don't-ask mode), even with `--allow-tools Write`. That is why 11 grades the Write call in the trace instead of the file on disk, and why 09 and 13 write their fixture members from `scaffold.sh`.
- In the eval sandbox, fixture members under `.claude/agents/` were not loaded as agent types (2.1.309), so 09 lists them from the file scan and 13 runs the general-purpose fallback.
- 13 passes either path of F7: a member loaded at session start is called by its type; a member file that isn't loaded goes through general-purpose and the brief must state the tools limit. The trace shows which path ran.
- 19 is somewhat flaky (2 of 3 runs fully passed on 2026-10-23): the lead occasionally skips saying how it checked the fix. Treat a single `fix-verified` miss as noise; repeated misses mean the evidence rule needs tightening.
- 20 can't force real send-back rounds: any impossible task cheap enough for an eval is also visible by reading, so a lead that escalates before delegating passes. The 3-round cap itself is not exercised.
- Not covered (too costly or not reproducible in the sandbox): a full multi-member job with QA verdict, a personal `~/.claude/agents` member, hire's overwrite and shadowing prompts, `isolation: "worktree"`.
- Add a case for every fixed bug: a new directory with `case.yaml`, at least one deterministic grader, and a row in the table above.
