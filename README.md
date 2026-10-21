# doc-upkeep

A Claude Code skill that has agents build and maintain a repo's docs while they work,
so a fresh session (or you, years later) can understand the project fast.

## Install
```bash
git clone https://github.com/Drarith/doc-upkeep.git ~/.claude/skills/doc-upkeep
```

## Use
- `/doc-upkeep` in a repo: adds `doc-upkeep.md` (the rules), `AGENTS.md` (the project map)
  and `CLAUDE.md` (a symlink to it). Commit all three.
- `/doc-upkeep audit`: checks every doc against the current code and fixes drift from
  changes that skipped an agent. Run it when you come back to a project after a break.
- After editing `rules.md`, rerun `/doc-upkeep` in a repo to refresh its copy.
  `grep -H "^Version:" */doc-upkeep.md` shows which repos have old copies.

## How it works
- `rules.md` is the master copy. Each repo gets its own copy, so the docs keep working
  with any agent that reads `AGENTS.md` (Codex, Cursor, ...) and without this skill.
- The first line of `AGENTS.md` tells agents to read `doc-upkeep.md` before finishing a task.
- Docs live next to the code they describe, stay under size limits, and changed decisions
  are recorded in an append-only `DECISIONS.md`.
