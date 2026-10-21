# Doc Upkeep Rules

Version: 2026-10-21
Managed by the `doc-upkeep` skill. Do not edit this copy; edit the skill and rerun `/doc-upkeep`.
These rules describe how agents build and maintain this project's docs.

## Purpose
Project docs let a fresh session understand the project fast: where things are, how to run it,
what to watch out for, and why it is built this way. They supplement reading the code, never replace it.
Read code whenever you need to. When a doc and the code disagree, the code wins: fix the doc.

## Where docs live
- `AGENTS.md` at the repo root: the project map. Layout, commands, key decisions, gotchas.
- `<folder>/AGENTS.md`: details for one area, placed next to the code it describes.
- `DECISIONS.md` at the repo root: the decision history (see Decisions).
- Every `AGENTS.md` gets a sibling symlink: `ln -s AGENTS.md CLAUDE.md`.
- If a folder has a separate `CLAUDE.md` file, ask before renaming or merging it.
- Never put docs in ignored or generated folders (check with `git check-ignore <path>`).
- Project facts go in project docs, not personal memory, so every agent can see them.

## When to create or extend a doc
- Only for an area you worked in or had to investigate this session. Never document ahead of time.
- Only when something there was non-obvious and would cost the next agent time to rediscover.

## What goes in
- Map: where things live, entry points, what is generated or vendored.
- Commands: build, test, run, deploy, and their prerequisites.
- Why: the current reasons for decisions, constraints, and trade-offs the code cannot show.
- Gotchas: traps, ordering requirements, things that look wrong but are intentional.

## What stays out
- Anything obvious from the code, file names, or config.
- Line-by-line descriptions of functions.
- Current task state, plans, or progress notes.
- Anything you have not verified against the code or confirmed with the user.
- Secrets: never write keys, tokens, passwords, or private URLs. Name the env var instead.

## Decisions
- Reasons often exist only in the user's head. If the area you are working on has a non-obvious
  decision with no recorded reason, ask the user one short question and record the answer.
  At most one such question per task.
- When a decision changes, update the doc to the current state and append a dated entry to
  `DECISIONS.md`: `YYYY-MM-DD <area>: <old> -> <new>, because <reason>.`
- `DECISIONS.md` is append-only and exempt from the size limits. Never delete its entries.
- When you create `DECISIONS.md`, add a one-line pointer to it in the root `AGENTS.md`.

## Keeping docs small
- Limits: repo root `AGENTS.md` ≤ 100 lines, folder docs ≤ 150 lines. This file does not count.
- Over the limit: split by area into a folder doc next to that code, and leave a one-line
  pointer by plain path (e.g. `Payments: see src/payments/AGENTS.md`).
- Never use `@path` imports. They load every session and defeat the split.
- When splitting, also cut anything outdated or obvious. Splitting is not only moving.
- Each fact lives in exactly one doc. Point to it; never copy it.

## Keeping docs accurate
- If your change makes a doc wrong, fix the doc in the same change.
- If your change alters behavior elsewhere (a shared function, API, data shape, config,
  or default), even in code you did not edit, search the project's `.md` files for the
  affected names and check each doc that mentions them.
- Update a doc only when it is now wrong or misleading. Do not add to a doc that is
  merely incomplete.
- Delete stale content you come across, even if your change did not cause it.
  A stale reason goes into `DECISIONS.md` before it is deleted.

## Audit
When asked to audit the docs (e.g. `/doc-upkeep audit`):
1. Check that every path, command, and script named in each doc still exists.
2. Check each doc's claims against the current code. Start with code changed since the doc
   was last edited: `git log -1 --format=%cs -- <doc>`, then `git log --since=<that date> --name-only`.
3. Fix what is wrong, delete what is stale (reasons go to `DECISIONS.md` first),
   and enforce the size limits.
4. Report what you checked and what you changed.

## Reporting
At the end of your reply, list any docs you created, split, or changed, in one line each.
