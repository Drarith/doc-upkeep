---
name: doc-upkeep
description: Sets up agent-maintained project docs (AGENTS.md project map, CLAUDE.md import, doc-upkeep.md rules) in the current repo. Use only when the user explicitly asks to set up doc-upkeep, e.g. "/doc-upkeep". To check existing docs, use doc-upkeep-audit.
disable-model-invocation: true
license: MIT
metadata:
  author: Drarith
  repository: https://github.com/Drarith/doc-upkeep
---

# doc-upkeep

The user asking for this skill is their consent to add agent docs to this repo.

If the user asks for an audit, use the `doc-upkeep-audit` skill instead. If they pass any other
argument, reply `Usage: /doc-upkeep sets up this repo; /doc-upkeep-audit checks its docs` and change nothing.

The rules live in [rules.md](rules.md), next to this file.

## Setup
1. **Find the repo root.** Run `git rev-parse --show-toplevel`. If it fails, ask the user which folder is the project root; if nobody can answer, stop and report. Never set up in the home directory.

2. **Copy the rules.** Copy `rules.md` to `<root>/doc-upkeep.md`, overwriting any existing copy. If a shell copy is blocked, read `rules.md` and write its exact contents. Check: the two files are identical.

3. **Root `AGENTS.md`.**
   - If it doesn't exist, write a short project map: layout, non-obvious commands and their prerequisites, key gotchas. Max 40 lines, only facts you verified in the repo (README, build files, top-level folders).
   - Its first line (after any YAML frontmatter) must be exactly:
     `> Before finishing any task that changes code or needed digging to understand how something works, read doc-upkeep.md (repo root) and apply it.`
     If an older line mentioning `doc-upkeep.md` exists, replace it.
   - Check: that line appears exactly once.

4. **Root `CLAUDE.md`.**
   - Missing: create it containing only `@AGENTS.md`.
   - A symlink (older doc-upkeep setups): replace it with a regular file containing only `@AGENTS.md`.
   - A regular file without `@AGENTS.md`: add `@AGENTS.md` as its first line (after any YAML frontmatter) and keep everything else. Never rename, move, or delete it.
   - Check: `CLAUDE.md` is a regular file containing `@AGENTS.md` exactly once.

5. **Don't commit.** List the files you created or changed, one line each, and remind the user to commit them together.
