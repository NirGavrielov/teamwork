#!/usr/bin/env bash
# Checks the plugin beyond `claude plugin validate`. Needs bash and python3 only.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
echo "== claude plugin validate --strict ."
claude plugin validate --strict . || fail=1

echo "== content checks"
python3 - <<'PY' || fail=1
import pathlib, re, sys

MARKER = "teamwork member"
LEFTOVERS = re.compile(r"job[ -]?search|job-lander|\bher\b|israel|hebrew|forums", re.I)
errors = []

def frontmatter(path):
    text = path.read_text()
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        errors.append(f"{path}: no frontmatter")
        return {}
    fm = dict(re.findall(r"^([\w-]+):\s*(.*)$", m.group(1), re.M))
    for k, v in fm.items():
        # strict YAML parsers (Gemini CLI) reject an unquoted value containing ": "
        if ": " in v and v[:1] not in "\"'": errors.append(f"{path}: quote the {k} value, it contains ': '")
    return {k: v.strip("\"'") for k, v in fm.items()}

skills = sorted(pathlib.Path("skills").glob("*/SKILL.md"))
agents = sorted(pathlib.Path("agents").glob("*.md"))
if not skills: errors.append("no skills/*/SKILL.md")
if not agents: errors.append("no agents/*.md")

for p in skills:
    fm = frontmatter(p)
    for key in ("name", "description"):
        if not fm.get(key): errors.append(f"{p}: missing {key}")
    if fm.get("name") != p.parent.name: errors.append(f"{p}: name {fm.get('name')!r} != {p.parent.name!r}")

for p in agents:
    fm = frontmatter(p)
    for key in ("name", "description"):
        if not fm.get(key): errors.append(f"{p}: missing {key}")
    if fm.get("name") != p.stem: errors.append(f"{p}: name {fm.get('name')!r} != {p.stem!r}")
    if MARKER not in fm.get("description", "").lower(): errors.append(f"{p}: description lacks {MARKER!r}")

template = pathlib.Path("templates/member-template.md").read_text()
if MARKER not in frontmatter(pathlib.Path("templates/member-template.md")).get("description", "").lower():
    errors.append(f"templates/member-template.md: description lacks {MARKER!r}")
m = re.search(r"^````markdown\n(.*?)^````$", pathlib.Path("skills/hire/SKILL.md").read_text(), re.S | re.M)
if not m or m.group(1) != template:
    errors.append("skills/hire/SKILL.md: embedded template differs from templates/member-template.md")

readme = pathlib.Path("README.md").read_text()
sec = re.search(r"^## The built-in team\n(.*?)(?=^## )", readme, re.S | re.M)
listed = set(re.findall(r"^\| `([\w-]+)` \|", sec.group(1), re.M)) if sec else set()
if listed != {p.stem for p in agents}:
    errors.append(f"README built-in table {sorted(listed)} != agents/ {sorted(p.stem for p in agents)}")

shipped = [pathlib.Path("README.md"), *pathlib.Path(".claude-plugin").glob("*.json"),
           *[p for d in ("skills", "agents", "templates") for p in pathlib.Path(d).rglob("*") if p.is_file()]]
for p in shipped:
    for n, line in enumerate(p.read_text().splitlines(), 1):
        if LEFTOVERS.search(line): errors.append(f"{p}:{n}: leftover: {line.strip()[:80]}")

for e in errors: print("FAIL", e)
print(f"{len(skills)} skills, {len(agents)} agents, {len(shipped)} shipped files checked")
sys.exit(1 if errors else 0)
PY

[ $fail -eq 0 ] && echo "== all checks passed" || echo "== checks FAILED"
exit $fail
