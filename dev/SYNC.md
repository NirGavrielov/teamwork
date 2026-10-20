# Keep in sync
`templates/member-template.md` (user-facing copy) must stay identical to the template embedded in `skills/hire/SKILL.md` between the `BEGIN member-template.md` / `END member-template.md` markers. Check: `diff <(sed -n '/^````markdown$/,/^````$/p' skills/hire/SKILL.md | sed '1d;$d') templates/member-template.md`
