---
name: doc-upkeep
description: Set up, refresh, or audit agent-maintained project docs (AGENTS.md + CLAUDE.md symlink + doc-upkeep.md rules) in the current repo. Run only when the user invokes /doc-upkeep.
disable-model-invocation: true
argument-hint: "[audit]"
---

# doc-upkeep

The user running this skill is their consent to add agent docs to this repo.
Arguments: $ARGUMENTS
If the arguments say `audit`, do steps 1–2 of **Setup**, then **Audit**. Otherwise do **Setup**.

## Setup
1. **Find the repo root.** Run `git rev-parse --show-toplevel`. If it fails, ask the user which folder is the project root. Never set up in the home directory.

2. **Copy the rules.** `cp ~/.claude/skills/doc-upkeep/rules.md <root>/doc-upkeep.md`, overwriting any existing copy (it is managed here; rerunning refreshes it). If `cp` is blocked, Read `rules.md` and Write its exact contents instead. Either way, confirm with `diff` that the copy matches.

3. **Set up the root `AGENTS.md` and `CLAUDE.md`:**
   - `CLAUDE.md` already a symlink to `AGENTS.md`: nothing to do.
   - Only `AGENTS.md` exists: `ln -s AGENTS.md CLAUDE.md`.
   - Only a regular `CLAUDE.md` exists: ask the user, then `git mv CLAUDE.md AGENTS.md` (plain `mv` outside git) and `ln -s AGENTS.md CLAUDE.md`.
   - Both exist as separate files: stop and ask the user. Never merge them yourself.
   - Neither exists: create `AGENTS.md` with a short project map (layout, commands, key gotchas), max 40 lines, using only facts you verified in the repo (README, package/build files, top-level folders). Then `ln -s AGENTS.md CLAUDE.md`.

4. **Set the must-read line.** The first line of `AGENTS.md` must be exactly:
   `> Before finishing any task that changes code or needed digging to understand how something works, read doc-upkeep.md and apply it.`
   If an older line mentioning `doc-upkeep.md` is there, replace it; otherwise insert this one.

5. **Don't commit.** Report what you created or changed, one line each, and remind the user to commit `AGENTS.md`, `CLAUDE.md` and `doc-upkeep.md` together.

## Audit
Follow the **Audit** section of `<root>/doc-upkeep.md`. Don't commit; report as it says.
