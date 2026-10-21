---
name: doc-upkeep
description: Sets up or audits agent-maintained project docs (AGENTS.md project map, CLAUDE.md import, doc-upkeep.md rules) in the current repo. Use only when the user explicitly asks to set up doc-upkeep or to audit the docs, e.g. "/doc-upkeep" or "/doc-upkeep audit".
disable-model-invocation: true
argument-hint: "[audit]"
license: MIT
metadata:
  author: Drarith
  repository: https://github.com/Drarith/doc-upkeep
---

# doc-upkeep

The user asking for this skill is their consent to add agent docs to this repo.

Pick the mode from the request:
- Set up, or no argument: do **Setup**.
- Audit: do **Audit**.
- Any other argument: reply `Usage: /doc-upkeep (set up) or /doc-upkeep audit` and change nothing.

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

## Audit
1. Find the repo root as in Setup step 1. If `<root>/doc-upkeep.md` is missing, stop and suggest running setup first.
2. Compare the `Version:` line of `<root>/doc-upkeep.md` with [rules.md](rules.md). If they differ, say the copy is outdated and suggest rerunning setup. Don't change `doc-upkeep.md`.
3. Follow the **Audit** section of `<root>/doc-upkeep.md`. Don't commit.
